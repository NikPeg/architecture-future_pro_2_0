# Task1Advanced — Reusable Terraform VM Module

Переиспользуемый Terraform-модуль для создания виртуальной машины (+ опциональный диск данных) в Yandex Cloud. Модуль не содержит захардкоженных значений: все параметры передаются через переменные и `.tfvars`-файлы окружений.

## Структура

```
Task1Advanced/
├── modules/
│   └── vm/
│       ├── main.tf        # ресурсы ВМ, загрузочный диск, диск данных
│       ├── variables.tf   # входные переменные модуля
│       └── outputs.tf     # выходные значения модуля
└── envs/
    ├── dev/
    │   ├── main.tf            # провайдер + вызов модуля + переменные окружения
    │   └── terraform.tfvars   # конкретные значения для dev
    ├── stage/
    │   ├── main.tf
    │   └── terraform.tfvars
    └── prod/
        ├── main.tf
        └── terraform.tfvars
```

## Параметры модуля (`modules/vm/variables.tf`)

| Переменная           | Тип          | Обязательна | Описание                                          |
|----------------------|--------------|-------------|---------------------------------------------------|
| `vm_name`            | string       | да          | Имя виртуальной машины                            |
| `zone`               | string       | нет         | Зона доступности (default: `ru-central1-a`)       |
| `cores`              | number       | да          | Количество vCPU                                   |
| `memory`             | number       | да          | Объём RAM в ГБ                                    |
| `core_fraction`      | number       | нет         | Гарантированная доля vCPU в % (default: 100)      |
| `disk_name`          | string       | да          | Имя загрузочного диска                            |
| `disk_type`          | string       | нет         | Тип диска: `network-ssd` / `network-hdd`          |
| `disk_size`          | number       | да          | Размер загрузочного диска в ГБ                    |
| `image_family`       | string       | нет         | Семейство образов ОС (default: `ubuntu-2204-lts`) |
| `secondary_disk_name`| string       | нет         | Имя диска данных                                  |
| `secondary_disk_type`| string       | нет         | Тип диска данных (default: `network-hdd`)         |
| `secondary_disk_size`| number       | нет         | Размер диска данных в ГБ; 0 = не создавать        |
| `subnet_id`          | string       | да          | ID подсети                                        |
| `nat`                | bool         | нет         | Включить NAT / публичный IP (default: false)      |
| `ssh_user`           | string       | нет         | Пользователь ОС для SSH (default: `ubuntu`)       |
| `ssh_public_key`     | string       | да          | Публичный SSH-ключ (содержимое `.pub`-файла)      |
| `labels`             | map(string)  | нет         | Метки ресурсов (default: `{}`)                    |

## Выходные значения (`modules/vm/outputs.tf`)

| Output          | Описание                                              |
|-----------------|-------------------------------------------------------|
| `vm_id`         | ID виртуальной машины                                 |
| `vm_name`       | Имя виртуальной машины                                |
| `internal_ip`   | Внутренний IP-адрес                                   |
| `external_ip`   | Внешний IP (пусто, если NAT выключен)                 |
| `boot_disk_id`  | ID загрузочного диска                                 |
| `data_disk_id`  | ID диска данных (пусто, если не создавался)           |
| `fqdn`          | FQDN виртуальной машины                               |

## Конфигурация окружений

| Параметр            | dev          | stage         | prod          |
|---------------------|--------------|---------------|---------------|
| cores               | 2            | 4             | 8             |
| memory              | 2 ГБ         | 8 ГБ          | 16 ГБ         |
| core_fraction       | 20 %         | 50 %          | 100 %         |
| disk_type           | network-hdd  | network-ssd   | network-ssd   |
| disk_size           | 20 ГБ        | 40 ГБ         | 60 ГБ         |
| secondary_disk_size | —            | 100 ГБ        | 500 ГБ        |
| nat                 | true         | false         | false         |
| zone                | ru-central1-a| ru-central1-a | ru-central1-b |

## Как запустить

### Подготовка

1. Установить [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.4.0.
2. Получить OAuth-токен Yandex Cloud, Cloud ID и Folder ID.
3. В нужном окружении открыть `terraform.tfvars` и заполнить:
   - `yc_token`, `yc_cloud_id`, `yc_folder_id`
   - `subnet_id`
   - `ssh_public_key`

### Dev

```bash
cd envs/dev
terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Stage

```bash
cd envs/stage
terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Prod

```bash
cd envs/prod
terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Удаление ресурсов

```bash
terraform destroy -var-file=terraform.tfvars
```

## Хранение state

По умолчанию `terraform.tfstate` создаётся локально. Для командной работы рекомендуется вынести remote state в Yandex Object Storage (S3-совместимый):

```hcl
terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "your-tfstate-bucket"
    key      = "future20/prod/terraform.tfstate"
    region   = "ru-central1"
    ...
  }
}
```

## Безопасность

- Не коммитьте реальные значения `yc_token` и `ssh_public_key` в репозиторий.  
- Используйте переменные окружения (`TF_VAR_yc_token`) или секреты CI/CD вместо хранения токенов в `.tfvars`.
- Добавьте `*.tfvars` в `.gitignore`, если файлы содержат секреты.
