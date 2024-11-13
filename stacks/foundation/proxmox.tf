data "proxmox_virtual_environment_acme_accounts" "all" {}

output "proxmox_acme_accounts" {
  value = data.proxmox_virtual_environment_acme_accounts.all
}
