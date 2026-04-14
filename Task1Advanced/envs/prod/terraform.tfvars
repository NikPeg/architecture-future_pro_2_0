# ── Yandex Cloud credentials ─────────────────────────────────────────────────
yc_token     = "YOUR_YC_OAUTH_TOKEN"
yc_cloud_id  = "YOUR_CLOUD_ID"
yc_folder_id = "YOUR_FOLDER_ID"

# ── VM configuration (prod — full resources, SSD, large data disk) ────────────
vm_name       = "future-prod-vm"
zone          = "ru-central1-b"   # different AZ from dev/stage for isolation
cores         = 8
memory        = 16
core_fraction = 100   # guaranteed 100 % vCPU

disk_name  = "future-prod-boot"
disk_type  = "network-ssd"
disk_size  = 60
image_family = "ubuntu-2204-lts"

secondary_disk_name = "future-prod-data"
secondary_disk_type = "network-ssd"
secondary_disk_size = 500

subnet_id      = "YOUR_PROD_SUBNET_ID"
nat            = false   # no public IP; access only through internal network
ssh_user       = "ubuntu"
ssh_public_key = "ssh-rsa AAAA...your-prod-key... prod@future20"

labels = {
  env     = "prod"
  project = "future20"
}
