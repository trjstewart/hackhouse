# TODO: Add descriptions to the outputs

output "domain" {
  value = var.cloudflare_zone_name
}

output "home_public_ip_address" {
  value = var.home_public_ip_address
}

output "proxmox_hostname" {
  value = var.proxmox_hostname
}

output "proxmox_node_names" {
  value = var.proxmox_node_names
}
