# ── Yandex Cloud credentials ─────────────────────────────────────────────────
yc_token     = "YOUR_YC_OAUTH_TOKEN"
yc_cloud_id  = "YOUR_CLOUD_ID"
yc_folder_id = "YOUR_FOLDER_ID"

# ── VM configuration (stage — close to prod, SSD, data disk) ─────────────────
vm_name       = "future-stage-vm"
zone          = "ru-central1-a"
cores         = 4
memory        = 8
core_fraction = 50

disk_name  = "future-stage-boot"
disk_type  = "network-ssd"
disk_size  = 40
image_family = "ubuntu-2204-lts"

secondary_disk_name = "future-stage-data"
secondary_disk_type = "network-ssd"
secondary_disk_size = 100

subnet_id      = "YOUR_SUBNET_ID"
nat            = false   # access via internal network / VPN
ssh_user       = "ubuntu"
ssh_public_key = "ssh-rsa AAAA...your-stage-key... stage@future20"

labels = {
  env     = "stage"
  project = "future20"
}
