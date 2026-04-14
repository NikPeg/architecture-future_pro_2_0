# Быстрый старт

## Предварительные требования

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.4
- [yc CLI](https://cloud.yandex.ru/docs/cli/quickstart) — авторизован в вашем облаке
- Доступ к репозиторию на GitHub с правами на изменение Secrets

---

## Шаг 1. Создать бакет для хранения состояния

```bash
yc storage bucket create --name future20-tfstate
yc storage bucket update --name future20-tfstate --versioning versioning-enabled
```

---

## Шаг 2. Создать сервисный аккаунт для CI

```bash
# Создать аккаунт
yc iam service-account create --name tf-ci

# Узнать его ID
SA_ID=$(yc iam service-account get tf-ci --format json | jq -r .id)

# Выдать права на бакет
yc storage bucket update future20-tfstate \
  --grants grant-type=grant-type-account,grantee-id=$SA_ID,permission=permission-full-control

# Сгенерировать статический ключ
yc iam access-key create --service-account-name tf-ci
```

Вывод команды содержит `key_id` и `secret`. Запишите — они нужны на следующем шаге.

---

## Шаг 3. Добавить секреты в GitHub

Перейти в **Settings → Secrets and variables → Actions → New repository secret** и добавить:

| Секрет | Откуда взять |
|--------|-------------|
| `YC_TOKEN` | `yc iam create-token` |
| `YC_CLOUD_ID` | `yc config get cloud-id` |
| `YC_STORAGE_ACCESS_KEY` | `key_id` из шага 2 |
| `YC_STORAGE_SECRET_KEY` | `secret` из шага 2 |
| `SSH_PUBLIC_KEY` | содержимое `~/.ssh/id_rsa.pub` (или нужного ключа) |
| `DEV_YC_FOLDER_ID` | `yc config get folder-id` (папка dev) |
| `DEV_SUBNET_ID` | `yc vpc subnet list` → ID подсети в зоне `ru-central1-a` |
| `STAGE_YC_FOLDER_ID` | ID папки stage |
| `STAGE_SUBNET_ID` | ID подсети stage |
| `PROD_YC_FOLDER_ID` | ID папки prod |
| `PROD_SUBNET_ID` | ID подсети prod |

---

## Шаг 4. Настроить окружение prod в GitHub

1. **Settings → Environments → New environment** → назвать `prod`
2. Включить **Required reviewers**, добавить себя или команду
3. Повторить для `dev` и `stage` (без reviewers — они применяются автоматически)

---

## Шаг 5. Запустить первый деплой

### Через пуш в ветку

`plan` запускается при пуше в **любую** ветку (если изменились файлы в `envs/`, `modules/` или сам воркфлоу).
`apply` выполняется только при пуше в `main` (→ stage) или `develop` (→ dev).

```bash
# Просто запустить plan — подойдёт любая ветка:
git push origin my

# Запустить plan + apply в dev:
git checkout develop
git merge my
git push origin develop
```

### Вручную (любое окружение)

1. Открыть вкладку **Actions** в репозитории
2. Выбрать воркфлоу **Terraform CI/CD**
3. Нажать **Run workflow**, выбрать окружение (`dev` / `stage` / `prod`)
4. Для `prod` — дождаться уведомления и нажать **Review deployments → Approve**

---

## Шаг 6. Проверить, что состояние ушло в облако

```bash
yc storage object list --bucket future20-tfstate
```

Ожидаемый вывод после первого применения:

```
+----------------------------+
| KEY                        |
+----------------------------+
| dev/terraform.tfstate      |
+----------------------------+
```

---

## Локальный запуск (опционально)

```bash
cd envs/dev
cp terraform.tfvars.example terraform.tfvars
# заполнить: yc_token, yc_cloud_id, yc_folder_id, subnet_id, ssh_public_key

export AWS_ACCESS_KEY_ID=<key_id из шага 2>
export AWS_SECRET_ACCESS_KEY=<secret из шага 2>

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Локальный и CI-запуск разделяют один state-файл в бакете. Не запускайте их параллельно.
