# Стратегический роадмап Data Mesh — «Будущее 2.0»

---

## Ключевые роли

| Роль | Ответственность | Где сидит |
|------|-----------------|-----------|
| **Data Product Owner (DPO)** | Определяет ценность данных домена, SLA на качество, доступность и документацию. Принимает решение о публикации нового Data Product. | В доменной команде |
| **Data Engineer** | Строит и поддерживает пайплайны: Event Bus → Bronze → Silver → Gold. Пишет качество-контракты, управляет схемами событий. | В доменной команде |
| **Platform Engineer** | Поддерживает общую Data Platform (Kafka, Spark, Object Storage, DataHub, Airflow). Обеспечивает self-service инструменты для доменных команд. | Платформенная команда |
| **BI-аналитик** | Строит аналитические витрины, дашборды и отчёты в DataLens. Консультирует бизнес по интерпретации данных. | В доменной команде или централизованно |
| **Data Governance Lead** | Формирует стандарты, политики, Business Glossary. Контролирует соблюдение compliance (152-ФЗ, ЦБ). | Платформенная команда / CDO |
| **Архитектор данных** | Проектирует контракты событий, Bounded Context Map, ADR. Контролирует эволюцию Schema Registry. | Платформенная команда |

---

## Этапы внедрения

### Этап 1: Пилот (Месяцы 0–6)

**Цель:** Доказать ценность Event-Driven + Data Mesh на двух доменах. Сформировать общую платформу и стандарты.

```mermaid
gantt
    title Этап 1 — Пилот (М0–М6)
    dateFormat  YYYY-MM
    axisFormat  М%m

    section Платформа
    Развернуть Yandex Cloud — инфра, IAM, сеть        :2025-01, 1M
    Managed Kafka + Schema Registry                    :2025-02, 1M
    Object Storage + Delta Lake (Bronze/Silver)        :2025-02, 2M
    DataHub MVP — регистрация первых датасетов         :2025-03, 2M
    Airflow — оркестрация первых пайплайнов            :2025-03, 2M

    section Домен Fintech (пилотный)
    Назначить DPO и Data Engineer                      :2025-01, 1M
    Разработать события — Payment*, Loan*, Account*     :2025-02, 2M
    Первые топики Kafka + контракты Avro               :2025-02, 2M
    Витрина финансовых KPI в Gold Layer                :2025-04, 2M

    section Домен Healthcare (пилотный)
    Назначить DPO и Data Engineer                      :2025-01, 1M
    Разработать события — Patient*, Admission*          :2025-02, 2M
    CDC из Legacy DWH — первая выгрузка                :2025-03, 2M
    Базовые метрики клиник в Gold Layer                :2025-05, 1M

    section Self-service BI
    Подключить DataLens к Gold Layer                   :2025-05, 1M
    Обучение BI-аналитиков (DataLens, Data Catalog)    :2025-05, 2M

    section Legacy (ACL)
    DWH перевести в read-only режим                    :2025-02, 1M
    CDC-коннектор (Yandex Data Transfer)               :2025-02, 2M
```

**Deliverables к концу М6:**
- Работающий Event Bus с 2 пилотными доменами
- Lakehouse Bronze/Silver/Gold с первыми витринами
- DataHub с каталогом первых Data Products
- DWH переведён в read-only
- 2 Data Product Owner назначены и прошли обучение
- Первые дашборды в DataLens для бизнес-пользователей

**Бизнес-цели этапа:**
- Продемонстрировать near-real-time отчётность по финансовым KPI (vs overnight batch)
- Снизить нагрузку на DBA за счёт вывода первых запросов из DWH

---

### Этап 2: Масштабирование (Месяцы 6–18)

**Цель:** Распространить Data Mesh на все критические домены. Подключить новые домены (Фарма, МедТех). Вывести ESB из критического пути.

```mermaid
gantt
    title Этап 2 — Масштабирование (М6–М18)
    dateFormat  YYYY-MM
    axisFormat  М%m

    section Платформа
    Gold Layer — витрины для всех доменов               :2025-07, 4M
    Data Quality gates (Great Expectations)            :2025-07, 3M
    RBAC в DataHub — политики по доменам               :2025-08, 2M
    Business Glossary — кросс-доменные термины         :2025-09, 3M
    Monitoring — Kafka lag, pipeline SLA                :2025-07, 2M

    section Домен AI Diagnostics
    DPO + Data Engineer назначены                      :2025-07, 1M
    Топики medical.ai.*, интеграция с ML-платформой    :2025-08, 3M
    Model Registry (DataSphere / MLflow)               :2025-09, 3M

    section Домен Pharmacy (новый)
    Бизнес-анализ, DPO назначен                        :2025-07, 2M
    Разработка сервисов + события Prescription*, Drug* :2025-09, 3M
    Интеграция с фармацевтическими партнёрами          :2025-10, 3M

    section Домен MedTech (новый)
    Бизнес-анализ, DPO назначен                        :2025-08, 2M
    IoT-коннекторы + события Device*, Maintenance*     :2025-10, 4M
    Телеметрия в Silver/Gold Layer                     :2026-01, 2M

    section Self-service BI
    Self-service портал для всех доменов               :2025-10, 3M
    Онбординг бизнес-пользователей (5 доменов)         :2026-01, 3M

    section Legacy вывод
    Camel ESB — вывод из критического пути             :2025-09, 3M
    PowerBuilder — замена доменными UI                 :2025-07, 4M
    Power BI — миграция дашбордов в DataLens           :2025-10, 4M
```

**Deliverables к концу М18:**
- Все 5 доменов работают через Event Bus
- ESB Camel — только Compatibility Adapter для остаточных интеграций
- PowerBuilder выведен из эксплуатации
- Power BI заменён DataLens
- DataHub с полным каталогом и Business Glossary
- Новые домены Фарма и МедТех запущены в production

**Бизнес-цели этапа:**
- Подключение новых партнёров (фарма, медоборудование) без изменений в DWH
- Self-service BI доступен для всех бизнес-пользователей
- Сокращение времени построения отчётов с часов до минут

---

### Этап 3: Поддержка доменов и финальный вывод Legacy (Месяцы 18–36)

**Цель:** Вывести DWH и ESB из эксплуатации. Перейти к доменной near-real-time аналитике. Масштабировать на новые регионы.

```mermaid
gantt
    title Этап 3 — Финальный (М18–М36)
    dateFormat  2026-01
    axisFormat  М%m

    section Платформа
    Streaming витрины (near-real-time Gold Layer)      :2026-01, 4M
    Apache Iceberg — оценка, финальное решение         :2026-01, 3M
    Multi-region — репликация на 2-й регион YC          :2026-04, 4M
    Data Mesh Governance зрелость (автоматизация)      :2026-03, 6M

    section Legacy вывод
    CDC-миграция всех исторических данных завершена    :2026-01, 3M
    SQL Server DWH — полный вывод из эксплуатации      :2026-04, 2M
    Camel Adapter — полный вывод                       :2026-03, 2M
    On-prem серверы — возврат или продажа              :2026-06, 2M

    section Новые продукты
    Монетизация ИИ-функций как внешний сервис          :2026-04, 6M
    Новые финтех-продукты на событийной платформе      :2026-01, 12M
    Выход на 2-й регион (данные, compliance)           :2026-07, 6M

    section Data Mesh зрелость
    Data Product SLA-метрики в DataHub                 :2026-01, 3M
    Автоматическая проверка контрактов в CI/CD         :2026-02, 3M
    Data Mesh maturity review с командами              :2026-07, 1M
    Пересмотр Tech Radar (полугодовой)                 :2026-07, 1M
```

**Deliverables к концу М36:**
- DWH SQL Server 2008 — полностью выведен
- ESB Camel — полностью выведен
- On-premise инфраструктура — ликвидирована
- Near-real-time витрины по всем доменам
- 2–3 региона поддерживаются единой платформой
- Новые продукты (AI-as-a-service, новые финтех) запущены на событийной платформе

**Бизнес-цели этапа:**
- Монетизация ИИ как самостоятельного продукта
- Запуск в новых регионах без пропорционального роста IT-затрат
- Компания полностью Data Mesh по всем доменам

---

## Сводный таймлайн

```mermaid
%%{init: {'theme': 'default', 'themeVariables': {'cScale0': '#e8f5e9', 'cScale1': '#e3f2fd', 'cScale2': '#fff3e0'}}}%%
timeline
    title Трансформация Будущее 2.0 — 3 года
    section М0–М6 Пилот
        Платформа данных : Kafka, Object Storage, Airflow
        Пилотные домены : Fintech и Healthcare на Event Bus
        Legacy : DWH переведён в read-only
        Self-service BI : Первые витрины в DataLens
    section М6–М18 Масштабирование
        Все домены : На Event Bus
        Новые домены : Фарма и МедТех запущены
        Legacy вывод : ESB из критического пути, PowerBuilder, Power BI заменены
        Self-service BI : Портал для всех пользователей
    section М18–М36 Финальный
        Legacy вывод : DWH и ESB полностью выведены
        Аналитика : Near-real-time витрины по всем доменам
        Масштаб : Выход на новые регионы
        Продукты : Монетизация ИИ, новые финтех
```

---

## Привязка к бизнес-целям

| Бизнес-цель | Этап реализации | Ключевые роли | Архитектурные решения |
|-------------|-----------------|---------------|-----------------------|
| Портал самообслуживания для аналитиков | М6–М12 | BI-аналитик, DPO | Self-service BI (DataLens) + Gold Layer + DataHub |
| Интеграция новых партнёров (Фарма, МедТех) без DWH | М6–М18 | Data Engineer, DPO | Event Bus, новые bounded contexts |
| Near-real-time вместо batch overnight | М18–М24 | Platform Engineer | Streaming Gold Layer (Kafka → Spark Streaming) |
| Масштабирование на 2–3 региона | М24–М36 | Platform Engineer, Архитектор | Yandex Cloud multi-region, Data Catalog с регионами |
| Монетизация ИИ как продукта | М24–М36 | DPO AI-домена, Data Engineer | AI Diagnostics как внешний API, Model Registry |
| Запуск новых финтех-продуктов | М18–М36 | DPO Fintech, Data Engineer | Event-driven микросервисы на платформе |
