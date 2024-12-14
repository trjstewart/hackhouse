data "cloudflare_zone" "default" { name = var.cloudflare_zone_name }
data "proxmox_virtual_environment_user" "terraform_provider" { user_id = "terraform-provider@pve" } # This user is expected to have been created manually in order to generate the initial token for this workspace.
data "proxmox_virtual_environment_role" "administrator" { role_id = "Administrator" }

locals {
  base_resource_name = element(split(".", data.cloudflare_zone.default.name), 0)
}

# ---------------------------------------------------------------------------------------------------------------------
# Organization
# ---------------------------------------------------------------------------------------------------------------------
resource "tfe_organization" "default" {
  name  = local.base_resource_name
  email = var.email_address

  collaborator_auth_policy = "two_factor_mandatory"
}

resource "tfe_organization_default_settings" "default" {
  organization           = tfe_organization.default.name
  default_execution_mode = "agent"
  default_agent_pool_id  = tfe_agent_pool.default.id
}

resource "tfe_agent_pool" "default" {
  name         = local.base_resource_name
  organization = tfe_organization.default.name
}

resource "tfe_agent_token" "default" {
  agent_pool_id = tfe_agent_pool.default.id
  description   = "${local.base_resource_name}-server"
}

# ---------------------------------------------------------------------------------------------------------------------
# Projects
# ---------------------------------------------------------------------------------------------------------------------
resource "tfe_project" "homelab" {
  organization = tfe_organization.default.name
  name         = "homelab"
  description  = "personal homelab"
}

# ---------------------------------------------------------------------------------------------------------------------
# Workspace - Foundation
# ---------------------------------------------------------------------------------------------------------------------
resource "tfe_workspace" "foundation" {
  name              = "foundation"
  description       = "Foundational resources for the ${local.base_resource_name} organization - this is largely meta-terraform"
  organization      = tfe_organization.default.name
  project_id        = tfe_project.homelab.id
  terraform_version = "latest"

  remote_state_consumer_ids = [
    tfe_workspace.compute.id,
  ]

  depends_on = [tfe_organization_default_settings.default]
}

# ---------------------------------------------------------------------------------------------------------------------
# Workspace - Compute
# ---------------------------------------------------------------------------------------------------------------------
resource "tfe_workspace" "compute" {
  name              = "compute"
  description       = "Shared compute resources for the ${local.base_resource_name} organization. This includes Proxmox Nodes, Shared Storage, and a Kubernetes Cluster."
  organization      = tfe_organization.default.name
  project_id        = tfe_project.homelab.id
  terraform_version = "latest"

  depends_on = [tfe_organization_default_settings.default]
}

resource "tfe_variable" "compute_tfe_organization_name" {
  workspace_id = tfe_workspace.compute.id
  category     = "terraform"
  key          = "tfe_organization_name"
  value        = tfe_organization.default.name
}

resource "proxmox_virtual_environment_user_token" "compute" {
  user_id    = data.proxmox_virtual_environment_user.terraform_provider.user_id
  token_name = "compute"
  comment    = "Managed by Terraform"
}

resource "proxmox_virtual_environment_acl" "operations_automation_monitoring" {
  token_id  = proxmox_virtual_environment_user_token.compute.id
  path      = "/"
  role_id   = data.proxmox_virtual_environment_role.administrator.role_id
  propagate = true
}

resource "tfe_variable" "compute_proxmox_api_token" {
  workspace_id = tfe_workspace.compute.id
  category     = "terraform"
  key          = "proxmox_api_token"
  value        = proxmox_virtual_environment_user_token.compute.value
  sensitive    = true
}

resource "tfe_variable" "compute_proxmox_username" {
  workspace_id = tfe_workspace.compute.id
  category     = "terraform"
  key          = "proxmox_username"
  value        = var.proxmox_username
  sensitive    = true
}

resource "tfe_variable" "compute_proxmox_password" {
  workspace_id = tfe_workspace.compute.id
  category     = "terraform"
  key          = "proxmox_password"
  value        = var.proxmox_password
  sensitive    = true
}
