# Non-sensitive variables for CI/CD.
# Sensitive values (yc_token, yc_cloud_id, yc_folder_id, subnet_id, ssh_public_key)
# are injected by the pipeline as TF_VAR_* environment variables from GitHub Secrets.

vm_name       = "future-stage-vm"
zone          = "ru-central1-a"
cores         = 4
memory        = 8
core_fraction = 50

disk_name    = "future-stage-boot"
disk_type    = "network-ssd"
disk_size    = 40
image_family = "ubuntu-2204-lts"

secondary_disk_name = "future-stage-data"
secondary_disk_type = "network-ssd"
secondary_disk_size = 100

nat      = false
ssh_user = "ubuntu"

labels = {
  env     = "stage"
  project = "future20"
}
