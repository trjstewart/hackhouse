output "talosconfig" {
  value     = data.talos_client_configuration.default.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = resource.talos_cluster_kubeconfig.default.kubeconfig_raw
  sensitive = true
}
