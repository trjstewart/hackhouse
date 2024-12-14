output "ip_address" {
  # There should only be a single non-loopback / non-link-local IPv4 address
  # TODO: This is a bit of a hack, but it works for now. Had trouble wittling down the list of IPs to just the one I wanted.
  value = one([for ip in flatten(proxmox_virtual_environment_vm.default.ipv4_addresses) : ip if startswith(ip, "192.168.0.")])
}
