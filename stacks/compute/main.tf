data "terraform_remote_state" "foundation" {
  backend = "remote"

  config = {
    organization = var.tfe_organization_name
    workspaces   = { name = "foundation" }
  }
}

locals {
  talos = {
    version      = "v1.8.4"
    platform     = "nocloud"
    architecture = "amd64"

    # If there are less than 3 Proxmox nodes, we only deploy 1 Talos control plane node.
    control_plane_node_count = length(data.terraform_remote_state.foundation.outputs.proxmox_node_names) < 3 ? 1 : 3
    cluster_name             = element(split(".", data.terraform_remote_state.foundation.outputs.domain), 0)
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Presuming we want a Talos node on each Proxmox node, we start by downloading the Talos image from the Talos Image Factory onto each Proxmox node.
# ---------------------------------------------------------------------------------------------------------------------
data "talos_image_factory_extensions_versions" "default" {
  talos_version = local.talos.version

  filters = {
    names = [
      "intel-ucode",
      "qemu-guest-agent",
    ]
  }
}

resource "talos_image_factory_schematic" "default" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.default.extensions_info.*.name
      }
    }
  })
}

data "talos_image_factory_urls" "default" {
  schematic_id  = talos_image_factory_schematic.default.id
  talos_version = local.talos.version
  platform      = local.talos.platform
  architecture  = local.talos.architecture
}

resource "proxmox_virtual_environment_download_file" "talos_disk_image" {
  for_each = toset(data.terraform_remote_state.foundation.outputs.proxmox_node_names)

  content_type = "iso"
  datastore_id = "local"
  node_name    = each.value

  # The Talos Image Factory provides the disk_image compressed using xz, but gzip images are available as well. Proxmox does not support xz compression, so we need to replace the extension.
  url                     = replace(data.talos_image_factory_urls.default.urls.disk_image, ".xz", ".gz")
  file_name               = "talos-${data.talos_image_factory_urls.default.talos_version}-${data.talos_image_factory_urls.default.platform}-${data.talos_image_factory_urls.default.architecture}.raw.iso"
  decompression_algorithm = "gz"
  overwrite               = false # Do not overwrite the file if it already exists. The extracted size will be different from the compressed size and will cause constant re-downloads.
}

# ---------------------------------------------------------------------------------------------------------------------
# Control Plane Node/s
# ---------------------------------------------------------------------------------------------------------------------
module "talos_control_plane_node" {
  for_each = toset([for i in range(local.talos.control_plane_node_count) : data.terraform_remote_state.foundation.outputs.proxmox_node_names[i]])

  source = "./modules/proxmox-talos-node"

  talos_node_type       = "control-plane"
  talos_node_index      = index(data.terraform_remote_state.foundation.outputs.proxmox_node_names, each.value) + 1
  proxmox_node_name     = each.value
  proxmox_disk_image_id = proxmox_virtual_environment_download_file.talos_disk_image[each.value].id
  proxmox_cpu_cores     = 2
  proxmox_memory        = 4 * 1024
}

# ---------------------------------------------------------------------------------------------------------------------
# Worker Node/s
# ---------------------------------------------------------------------------------------------------------------------
module "talos_worker_node" {
  for_each = toset(data.terraform_remote_state.foundation.outputs.proxmox_node_names)

  source = "./modules/proxmox-talos-node"

  talos_node_type       = "worker"
  talos_node_index      = index(data.terraform_remote_state.foundation.outputs.proxmox_node_names, each.value) + 1
  proxmox_node_name     = each.value
  proxmox_disk_image_id = proxmox_virtual_environment_download_file.talos_disk_image[each.value].id
  proxmox_cpu_cores     = 4
  proxmox_memory        = 10 * 1024
}

# ---------------------------------------------------------------------------------------------------------------------
# Talos Cluster Bootstrap
# ---------------------------------------------------------------------------------------------------------------------
resource "talos_machine_secrets" "default" { talos_version = local.talos.version }

data "talos_machine_configuration" "control_plane" {
  cluster_name     = local.talos.cluster_name
  cluster_endpoint = "https://${module.talos_control_plane_node[data.terraform_remote_state.foundation.outputs.proxmox_node_names[0]].ip_address}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.default.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = local.talos.cluster_name
  cluster_endpoint = "https://${module.talos_control_plane_node[data.terraform_remote_state.foundation.outputs.proxmox_node_names[0]].ip_address}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.default.machine_secrets
}

data "talos_client_configuration" "default" {
  cluster_name         = local.talos.cluster_name
  client_configuration = talos_machine_secrets.default.client_configuration
  endpoints            = [for node in module.talos_control_plane_node : node.ip_address]
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each = module.talos_control_plane_node

  client_configuration        = talos_machine_secrets.default.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
  node                        = each.value.ip_address
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = module.talos_worker_node

  client_configuration        = talos_machine_secrets.default.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ip_address
}

resource "talos_machine_bootstrap" "default" {
  client_configuration = talos_machine_secrets.default.client_configuration
  node                 = module.talos_control_plane_node[data.terraform_remote_state.foundation.outputs.proxmox_node_names[0]].ip_address

  depends_on = [talos_machine_configuration_apply.control_plane]
}

resource "talos_cluster_kubeconfig" "default" {
  client_configuration = talos_machine_secrets.default.client_configuration
  node                 = module.talos_control_plane_node[data.terraform_remote_state.foundation.outputs.proxmox_node_names[0]].ip_address

  depends_on = [talos_machine_bootstrap.default]
}
