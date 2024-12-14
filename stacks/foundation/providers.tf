provider "proxmox" {
  endpoint  = "https://${var.proxmox_hostname}:8006/"
  api_token = var.proxmox_api_token
}
