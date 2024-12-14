resource "proxmox_virtual_environment_vm" "default" {
  name        = "talos-${var.talos_node_type == "control-plane" ? "control-plane" : "worker"}-${format("%02d", var.talos_node_index)}"
  description = "Talos Linux ${title(var.talos_node_type)} Node. Managed by Terraform."
  tags        = ["talos", "kubernetes", "managed-by-terraform", var.talos_node_type]
  node_name   = var.proxmox_node_name
  vm_id       = (var.talos_node_type == "control-plane" ? 600 : 650) + var.talos_node_index - 1

  cpu {
    cores = var.proxmox_cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.proxmox_memory
    floating  = var.proxmox_memory
  }

  agent { # QEMU Guest Agent
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    file_id     = var.proxmox_disk_image_id
    file_format = "raw"
    interface   = "virtio0"
    size        = 20 # GB
  }

  operating_system { # https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines
    type = "l26"     # Linux 2.6 - 6.X Kernel
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
