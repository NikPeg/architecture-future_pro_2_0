# Non-sensitive variables for CI/CD.
# Sensitive values (yc_token, yc_cloud_id, yc_folder_id, subnet_id, ssh_public_key)
# are injected by the pipeline as TF_VAR_* environment variables from GitHub Secrets.

vm_name       = "future-prod-vm"
zone          = "ru-central1-b"
cores         = 8
memory        = 16
core_fraction = 100

disk_name    = "future-prod-boot"
disk_type    = "network-ssd"
disk_size    = 60
image_family = "ubuntu-2204-lts"

secondary_disk_name = "future-prod-data"
secondary_disk_type = "network-ssd"
secondary_disk_size = 500

nat      = false
ssh_user = "ubuntu"

labels = {
  env     = "prod"
  project = "future20"
}
