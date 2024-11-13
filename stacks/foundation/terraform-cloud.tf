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
# Workspaces
# ---------------------------------------------------------------------------------------------------------------------
resource "tfe_workspace" "foundation" {
  name              = "foundation"
  description       = "Foundational resources for the ${local.base_resource_name} organization - this is largely meta-terraform"
  organization      = tfe_organization.default.name
  project_id        = tfe_project.homelab.id
  terraform_version = "latest"

  depends_on = [tfe_organization_default_settings.default]
}

resource "tfe_workspace" "compute" {
  name              = "compute"
  description       = "Shared compute resources for the ${local.base_resource_name} organization. This includes Proxmox Nodes, Shared Storage, and a Kubernetes Cluster."
  organization      = tfe_organization.default.name
  project_id        = tfe_project.homelab.id
  terraform_version = "latest"

  depends_on = [tfe_organization_default_settings.default]
}
