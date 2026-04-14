data "yandex_compute_image" "os" {
  family = var.image_family
}

resource "yandex_compute_disk" "boot" {
  name   = var.disk_name
  type   = var.disk_type
  zone   = var.zone
  size   = var.disk_size
  image_id = data.yandex_compute_image.os.image_id
  labels = var.labels
}

resource "yandex_compute_disk" "data" {
  count  = var.secondary_disk_size > 0 ? 1 : 0

  name   = var.secondary_disk_name
  type   = var.secondary_disk_type
  zone   = var.zone
  size   = var.secondary_disk_size
  labels = var.labels
}

resource "yandex_compute_instance" "vm" {
  name        = var.vm_name
  zone        = var.zone
  labels      = var.labels

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot.id
  }

  dynamic "secondary_disk" {
    for_each = var.secondary_disk_size > 0 ? [1] : []
    content {
      disk_id = yandex_compute_disk.data[0].id
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}
