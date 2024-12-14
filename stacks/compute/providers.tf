provider "proxmox" {
  endpoint  = "https://${data.terraform_remote_state.foundation.outputs.proxmox_hostname}:8006/"
  api_token = var.proxmox_api_token

  ssh {
    agent = true
    username = var.proxmox_username
    password = var.proxmox_password
  }
}
