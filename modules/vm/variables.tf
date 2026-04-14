variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "cores" {
  description = "Number of vCPU cores"
  type        = number
}

variable "memory" {
  description = "Amount of RAM in GB"
  type        = number
}

variable "core_fraction" {
  description = "Guaranteed vCPU share (percent): 20, 50 or 100"
  type        = number
  default     = 100
}

variable "disk_name" {
  description = "Name of the boot disk"
  type        = string
}

variable "disk_type" {
  description = "Disk type: network-hdd or network-ssd"
  type        = string
  default     = "network-ssd"
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
}

variable "image_family" {
  description = "OS image family (e.g. ubuntu-2204-lts)"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "secondary_disk_name" {
  description = "Name of the secondary (data) disk"
  type        = string
  default     = ""
}

variable "secondary_disk_type" {
  description = "Type of the secondary disk"
  type        = string
  default     = "network-hdd"
}

variable "secondary_disk_size" {
  description = "Size of the secondary disk in GB"
  type        = number
  default     = 0
}

variable "subnet_id" {
  description = "ID of the subnet to attach the VM to"
  type        = string
}

variable "nat" {
  description = "Enable NAT (public IP)"
  type        = bool
  default     = false
}

variable "ssh_user" {
  description = "OS user for SSH access"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key string (contents of .pub file)"
  type        = string
}

variable "labels" {
  description = "Labels to attach to all resources"
  type        = map(string)
  default     = {}
}
