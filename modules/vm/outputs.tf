output "vm_id" {
  description = "ID of the virtual machine"
  value       = yandex_compute_instance.vm.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = yandex_compute_instance.vm.name
}

output "internal_ip" {
  description = "Internal IP address of the VM"
  value       = yandex_compute_instance.vm.network_interface[0].ip_address
}

output "external_ip" {
  description = "External (NAT) IP address of the VM (empty if NAT is disabled)"
  value       = var.nat ? yandex_compute_instance.vm.network_interface[0].nat_ip_address : ""
}

output "boot_disk_id" {
  description = "ID of the boot disk"
  value       = yandex_compute_disk.boot.id
}

output "data_disk_id" {
  description = "ID of the secondary data disk (empty if not created)"
  value       = var.secondary_disk_size > 0 ? yandex_compute_disk.data[0].id : ""
}

output "fqdn" {
  description = "Fully qualified domain name of the VM"
  value       = yandex_compute_instance.vm.fqdn
}
