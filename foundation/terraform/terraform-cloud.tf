# ---------------------------------------------------------------------------------------------------------------------
# Organization
# ---------------------------------------------------------------------------------------------------------------------
resource "tfe_organization" "default" {
  name  = local.base_resource_name
  email = var.email_address
}

resource "tfe_agent_pool" "default" {
  name         = local.base_resource_name
  organization = tfe_organization.default.name
}

resource "tfe_organization_default_settings" "default" {
  organization           = tfe_organization.default.name
  default_agent_pool_id  = tfe_agent_pool.default.id
  default_execution_mode = "agent"
}

resource "tfe_agent_token" "default" {
  agent_pool_id = tfe_agent_pool.default.id
  description   = "${local.base_resource_name}-server"
}

# ---------------------------------------------------------------------------------------------------------------------
# Workspace : Foundation
# ---------------------------------------------------------------------------------------------------------------------
resource "tfe_workspace" "foundation" {
  name         = "foundation"
  organization = tfe_organization.default.name
  description = "Foundational resources for the ${local.base_resource_name} organization - this is largely meta-terraform"
  terraform_version = "latest"
  allow_destroy_plan = false
}

# ---------------------------------------------------------------------------------------------------------------------
# Workspace : Home
# ---------------------------------------------------------------------------------------------------------------------
resource "tfe_workspace" "home" {
  name         = "home"
  organization = tfe_organization.default.name
  description = "A collection of resources to form the shared baseline of all home infrastructure"
  terraform_version = "latest"
  allow_destroy_plan = false
}

resource "cloudflare_api_token" "terraform_workspace_home" {
  name = "terraform-${local.base_resource_name}-${tfe_workspace.home.name}"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.account["Argo Tunnel Write"],
      data.cloudflare_api_token_permission_groups.all.account["Access: Apps and Policies Write"],
    ]

    resources = {
      "com.cloudflare.api.account.${data.cloudflare_zone.default.account_id}" = "*"
    }
  }

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"],
    ]

    resources = {
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.default.id}" = "*"
    }
  }

  condition {
    request_ip {
      in = [var.home_public_ip_address]
    }
  }
}

resource "tfe_variable" "terraform_workspace_home_cloudflare_zone_name" {
  workspace_id = tfe_workspace.home.id
  category     = "terraform"
  key          = "cloudflare_zone_name"
  value        = data.cloudflare_zone.default.name
}

resource "tfe_variable" "terraform_workspace_home_cloudflare_api_token" {
  workspace_id = tfe_workspace.home.id
  category     = "env"
  key          = "CLOUDFLARE_API_TOKEN"
  value        = cloudflare_api_token.terraform_workspace_home.value
  sensitive = true
}
