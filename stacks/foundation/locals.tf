data "cloudflare_zone" "default" { name = var.cloudflare_zone_name }

locals {
  base_resource_name = element(split(".", data.cloudflare_zone.default.name), 0)
}
