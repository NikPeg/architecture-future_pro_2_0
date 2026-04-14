# ── Yandex Cloud credentials ─────────────────────────────────────────────────
# Fill in before running terraform apply.
yc_token     = "YOUR_YC_OAUTH_TOKEN"
yc_cloud_id  = "YOUR_CLOUD_ID"
yc_folder_id = "YOUR_FOLDER_ID"

# ── VM configuration (dev — minimal resources) ────────────────────────────────
vm_name       = "future-dev-vm"
zone          = "ru-central1-a"
cores         = 2
memory        = 2
core_fraction = 20   # burstable — saves cost in non-prod

disk_name  = "future-dev-boot"
disk_type  = "network-hdd"
disk_size  = 20
image_family = "ubuntu-2204-lts"

# No secondary data disk in dev
secondary_disk_size = 0

subnet_id      = "YOUR_SUBNET_ID"
nat            = true   # expose public IP for developer access
ssh_user       = "ubuntu"
ssh_public_key = "ssh-rsa AAAA...your-dev-key... dev@future20"

labels = {
  env     = "dev"
  project = "future20"
}
