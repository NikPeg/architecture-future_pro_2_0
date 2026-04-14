# QUICKSTART

Terraform-код находится в корне репозитория (`modules/`, `envs/`).

## Предварительные требования

- Terraform ≥ 1.4.0
- Yandex Cloud аккаунт: OAuth-токен, Cloud ID, Folder ID, Subnet ID

## Запуск

```bash
# Выбрать нужное окружение, например dev:
cd envs/dev

# Заполнить значения в terraform.tfvars:
#   yc_token, yc_cloud_id, yc_folder_id, subnet_id, ssh_public_key

terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Аналогично для `envs/stage` и `envs/prod`.

## Удаление ресурсов

```bash
terraform destroy -var-file=terraform.tfvars
```
