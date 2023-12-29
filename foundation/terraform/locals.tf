data "cloudflare_api_token_permission_groups" "all" {}
data "cloudflare_zone" "default" { name = var.cloudflare_zone_name }

locals {
  base_resource_name = split(".", data.cloudflare_zone.default.name)[0]
}
