# TODO: Add descriptions to the outputs

output "domain" {
  value = var.cloudflare_zone_name
}

output "home_public_ip_address" {
  value = var.home_public_ip_address
}
