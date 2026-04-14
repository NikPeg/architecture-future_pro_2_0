terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.100.0"
    }
  }
  required_version = ">= 1.4.0"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.zone
}

module "vm" {
  source = "../../modules/vm"

  vm_name        = var.vm_name
  zone           = var.zone
  cores          = var.cores
  memory         = var.memory
  core_fraction  = var.core_fraction
  disk_name      = var.disk_name
  disk_type      = var.disk_type
  disk_size      = var.disk_size
  image_family   = var.image_family
  secondary_disk_name = var.secondary_disk_name
  secondary_disk_type = var.secondary_disk_type
  secondary_disk_size = var.secondary_disk_size
  subnet_id      = var.subnet_id
  nat            = var.nat
  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
  labels         = var.labels
}

# ── Provider-level variables ────────────────────────────────────────────────

variable "yc_token"     { type = string }
variable "yc_cloud_id"  { type = string }
variable "yc_folder_id" { type = string }

# ── Module variables (mirror modules/vm/variables.tf) ──────────────────────

variable "vm_name"       { type = string }
variable "zone"          { type = string  ; default = "ru-central1-a" }
variable "cores"         { type = number }
variable "memory"        { type = number }
variable "core_fraction" { type = number  ; default = 100 }
variable "disk_name"     { type = string }
variable "disk_type"     { type = string  ; default = "network-ssd" }
variable "disk_size"     { type = number }
variable "image_family"  { type = string  ; default = "ubuntu-2204-lts" }
variable "secondary_disk_name" { type = string ; default = "" }
variable "secondary_disk_type" { type = string ; default = "network-hdd" }
variable "secondary_disk_size" { type = number ; default = 0 }
variable "subnet_id"     { type = string }
variable "nat"           { type = bool   ; default = false }
variable "ssh_user"      { type = string ; default = "ubuntu" }
variable "ssh_public_key" { type = string }
variable "labels"        { type = map(string) ; default = {} }

# ── Outputs ─────────────────────────────────────────────────────────────────

output "vm_id"       { value = module.vm.vm_id }
output "vm_name"     { value = module.vm.vm_name }
output "internal_ip" { value = module.vm.internal_ip }
output "external_ip" { value = module.vm.external_ip }
output "boot_disk_id"{ value = module.vm.boot_disk_id }
output "data_disk_id"{ value = module.vm.data_disk_id }
output "fqdn"        { value = module.vm.fqdn }
