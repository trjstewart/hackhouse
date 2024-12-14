variable "talos_node_type" {
  type        = string
  description = "The type of Talos node to deploy."

  validation {
    condition     = contains(["control-plane", "worker"], var.talos_node_type)
    error_message = "The value of talos_node_type must be either 'control-plane' or 'worker'."
  }
}

variable "talos_node_index" {
  type        = number
  description = "The index of the Talos node to deploy."

  validation {
    condition     = var.talos_node_index > 0
    error_message = "The value of talos_node_index must be greater than 0."
  }
}

variable "proxmox_node_name" {
  type        = string
  description = "The name of the Proxmox node to deploy the Talos VM onto."
}

variable "proxmox_disk_image_id" {
  type        = string
  description = "The ID of the Proxmox disk image to use for the Talos VM."
}

variable "proxmox_cpu_cores" {
  type        = number
  description = "The number of CPU cores to allocate to the Talos VM."
  default     = 2
}

variable "proxmox_memory" {
  type        = number
  description = "The amount of memory (in MB) to allocate to the Talos VM."
  default     = 2048
}
