# Task 1 — Модульная инфраструктура для нескольких сред

## Что сделано

Создан переиспользуемый Terraform-модуль `modules/vm` для Yandex Cloud и три окружения (`envs/dev`, `envs/stage`, `envs/prod`), каждое со своим `.tfvars`.

Код вынесен в корень репозитория, чтобы Task 2 (бэкенд + CI/CD) мог расширять ту же кодовую базу без дублирования.

## Структура (в корне репозитория)

```
modules/
└── vm/
    ├── main.tf        — ресурсы ВМ, загрузочный диск, опциональный диск данных
    ├── variables.tf   — все входные параметры модуля
    └── outputs.tf     — выходные значения (id ВМ, IP, диски, FQDN)
envs/
├── dev/
│   ├── main.tf            — провайдер + вызов модуля
│   └── terraform.tfvars   — параметры dev-окружения
├── stage/
│   ├── main.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    └── terraform.tfvars
```

## Параметры модуля

| Переменная            | Тип         | Обяз. | Описание                                              |
|-----------------------|-------------|-------|-------------------------------------------------------|
| `vm_name`             | string      | да    | Имя ВМ                                                |
| `zone`                | string      | нет   | Зона доступности (default: `ru-central1-a`)           |
| `cores`               | number      | да    | Количество vCPU                                       |
| `memory`              | number      | да    | RAM в ГБ                                              |
| `core_fraction`       | number      | нет   | Гарантированная доля vCPU в % (default: 100)          |
| `disk_name`           | string      | да    | Имя загрузочного диска                                |
| `disk_type`           | string      | нет   | `network-ssd` / `network-hdd` (default: `network-ssd`)|
| `disk_size`           | number      | да    | Размер загрузочного диска в ГБ                        |
| `image_family`        | string      | нет   | Семейство образов ОС (default: `ubuntu-2204-lts`)     |
| `secondary_disk_name` | string      | нет   | Имя диска данных                                      |
| `secondary_disk_type` | string      | нет   | Тип диска данных (default: `network-hdd`)             |
| `secondary_disk_size` | number      | нет   | Размер диска данных в ГБ; 0 = не создавать            |
| `subnet_id`           | string      | да    | ID подсети                                            |
| `nat`                 | bool        | нет   | Включить NAT / публичный IP (default: false)          |
| `ssh_user`            | string      | нет   | Пользователь ОС для SSH (default: `ubuntu`)           |
| `ssh_public_key`      | string      | да    | Публичный SSH-ключ (содержимое `.pub`-файла)          |
| `labels`              | map(string) | нет   | Метки ресурсов                                        |

## Выходные значения

| Output         | Описание                                          |
|----------------|---------------------------------------------------|
| `vm_id`        | ID виртуальной машины                             |
| `vm_name`      | Имя виртуальной машины                            |
| `internal_ip`  | Внутренний IP-адрес                               |
| `external_ip`  | Внешний IP (пусто, если NAT выключен)             |
| `boot_disk_id` | ID загрузочного диска                             |
| `data_disk_id` | ID диска данных (пусто, если не создавался)       |
| `fqdn`         | FQDN виртуальной машины                           |

## Конфигурации окружений

| Параметр             | dev          | stage        | prod           |
|----------------------|--------------|--------------|----------------|
| cores                | 2            | 4            | 8              |
| memory               | 2 ГБ         | 8 ГБ         | 16 ГБ          |
| core_fraction        | 20 %         | 50 %         | 100 %          |
| disk_type            | network-hdd  | network-ssd  | network-ssd    |
| disk_size            | 20 ГБ        | 40 ГБ        | 60 ГБ          |
| secondary_disk_size  | —            | 100 ГБ       | 500 ГБ         |
| nat (публичный IP)   | true         | false        | false          |
| zone                 | ru-central1-a| ru-central1-a| ru-central1-b  |

Разные зоны для prod сделаны намеренно: изоляция от dev/stage на уровне дата-центра.  
`core_fraction = 20` в dev — burstable-режим, снижает стоимость нагрузочно-нейтральной среды.
