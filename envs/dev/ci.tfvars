# Non-sensitive variables for CI/CD.
# Sensitive values (yc_token, yc_cloud_id, yc_folder_id, subnet_id, ssh_public_key)
# are injected by the pipeline as TF_VAR_* environment variables from GitHub Secrets.

vm_name       = "future-dev-vm"
zone          = "ru-central1-a"
cores         = 2
memory        = 2
core_fraction = 20

disk_name    = "future-dev-boot"
disk_type    = "network-hdd"
disk_size    = 20
image_family = "ubuntu-2204-lts"

secondary_disk_size = 0

nat      = true
ssh_user = "ubuntu"

labels = {
  env     = "dev"
  project = "future20"
}
