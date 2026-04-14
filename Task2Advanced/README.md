# Задание 2: CI/CD и удалённое хранение состояния

Автоматизированное развёртывание инфраструктуры через GitHub Actions. Terraform-состояние хранится в Yandex Object Storage (S3-совместимое хранилище) — не локально.

## Что изменилось

| Файл | Изменение |
|------|-----------|
| `envs/dev/main.tf` | Добавлен `backend "s3"` — состояние в `future20-tfstate/dev/terraform.tfstate` |
| `envs/stage/main.tf` | Добавлен `backend "s3"` — состояние в `future20-tfstate/stage/terraform.tfstate` |
| `envs/prod/main.tf` | Добавлен `backend "s3"` — состояние в `future20-tfstate/prod/terraform.tfstate` |
| `envs/*/ci.tfvars` | Несекретные переменные, зафиксированные в репозитории для CI (заменяют gitignored `terraform.tfvars`) |
| `.github/workflows/terraform.yml` | Пайплайн GitHub Actions: plan на PR, plan+apply при пуше в ветку |

---

## Удалённый backend

Каждое окружение пишет состояние в отдельный ключ внутри одного бакета:

```
future20-tfstate/
  dev/terraform.tfstate
  stage/terraform.tfstate
  prod/terraform.tfstate
```

Учётные данные backend (`access_key`, `secret_key`) **никогда не хранятся в коде**. Terraform подхватывает их из стандартных AWS-переменных окружения:

```
AWS_ACCESS_KEY_ID     ← секрет YC_STORAGE_ACCESS_KEY
AWS_SECRET_ACCESS_KEY ← секрет YC_STORAGE_SECRET_KEY
```

Создание бакета (разовая ручная операция):

```bash
yc storage bucket create --name future20-tfstate
yc storage bucket update --name future20-tfstate \
  --versioning versioning-enabled   # история версий состояния
```

Создание сервисного аккаунта для CI и генерация статического ключа:

```bash
yc iam service-account create --name tf-ci
yc resource-manager folder add-access-binding <FOLDER_ID> \
  --role storage.editor \
  --subject serviceAccount:<SA_ID>
yc iam access-key create --service-account-name tf-ci
# → записать access_key_id и secret в GitHub Secrets
```

---

## CI/CD пайплайн

Файл: `.github/workflows/terraform.yml`

### Триггеры

| Событие | Ветка | Действие |
|---------|-------|----------|
| `push` | `develop` | plan + apply → **dev** |
| `push` | `main` | plan + apply → **stage** |
| `pull_request` | `develop` / `main` | только plan (apply не выполняется) |
| `workflow_dispatch` | любая | plan + apply → выбранное окружение (dev / stage / prod) |

### Джобы

```
resolve-env  →  plan  →  apply
```

**resolve-env** — определяет целевое окружение по триггеру.

**plan** — запускает `terraform init`, `terraform validate`, `terraform plan -var-file=ci.tfvars -out=tfplan`. Собранный план сохраняется как артефакт воркфлоу (хранится 1 день).

**apply** — скачивает артефакт из `plan` и запускает `terraform apply -auto-approve tfplan`. Использует `environment:` для применения правил защиты GitHub Environments. Пропускается для pull request'ов.

Параллельные запуски на одном ref заблокированы (`concurrency: cancel-in-progress: false`) — два джоба не могут одновременно работать с одним state-файлом.

### Ручное подтверждение для prod

Правила защиты GitHub Environment выполняют роль gate'а:

1. Открыть **Settings → Environments → prod**
2. Включить **Required reviewers**, добавить ответственных
3. Любой `workflow_dispatch` на prod приостановится перед джобом `apply` и будет ждать подтверждения

Джоб `plan` всегда запускается без gate'а — ревьюер видит план до того, как принимает решение.

---

## Необходимые GitHub Secrets

Задаются в **Settings → Secrets and variables → Actions**:

### Секреты репозитория (общие для всех окружений)

| Секрет | Описание |
|--------|----------|
| `YC_TOKEN` | IAM / OAuth-токен Yandex Cloud для провайдера |
| `YC_CLOUD_ID` | ID облака Yandex Cloud |
| `YC_STORAGE_ACCESS_KEY` | Статический ключ доступа к бакету tfstate |
| `YC_STORAGE_SECRET_KEY` | Статический секретный ключ к бакету tfstate |
| `SSH_PUBLIC_KEY` | SSH-публичный ключ, который добавляется на ВМ |

### Секреты по окружениям

| Секрет | Описание |
|--------|----------|
| `DEV_YC_FOLDER_ID` | ID папки для dev |
| `DEV_SUBNET_ID` | ID подсети для ВМ dev |
| `STAGE_YC_FOLDER_ID` | ID папки для stage |
| `STAGE_SUBNET_ID` | ID подсети для ВМ stage |
| `PROD_YC_FOLDER_ID` | ID папки для prod |
| `PROD_SUBNET_ID` | ID подсети для ВМ prod |

---

## Разделение переменных: что в репозитории, что в секретах

`ci.tfvars` (зафиксирован в git) содержит только несекретные значения: количество ядер, память, размеры дисков, имена ВМ, метки. Никаких токенов и идентификаторов облачного аккаунта.

Чувствительные значения передаются CI как `TF_VAR_*`-переменные окружения:

- `TF_VAR_yc_token`
- `TF_VAR_yc_cloud_id`
- `TF_VAR_yc_folder_id`
- `TF_VAR_subnet_id`
- `TF_VAR_ssh_public_key`

Такое разделение позволяет держать репозиторий публичным — все данные, специфичные для аккаунта, живут только в GitHub Secrets.

---

## Локальный запуск

Скопируйте пример и заполните свои значения:

```bash
cd envs/dev
cp terraform.tfvars.example terraform.tfvars
# заполнить terraform.tfvars своими данными

export AWS_ACCESS_KEY_ID=<ваш-access-key>
export AWS_SECRET_ACCESS_KEY=<ваш-secret-key>

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Состояние пишется в тот же удалённый бакет, что и в CI. Не запускайте локально и через пайплайн одновременно.

---

## Чеклист безопасности

- State-файлы не хранятся локально и не коммитятся — всё в YOS
- Учётные данные backend — стандартные AWS env vars, ни в одном `.tf`-файле их нет
- `terraform.tfvars` и `terraform.tfstate*` в gitignore
- Apply в prod требует явного подтверждения человека через GitHub Environment
- Параллельные запуски пайплайна заблокированы — защита от race condition на state
- Сервисный аккаунт CI имеет только роль `storage.editor` на бакет и минимальные `compute.editor` / `vpc.user` на папку — без прав администратора
