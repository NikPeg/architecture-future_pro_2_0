# Каталог доменных событий — «Будущее 2.0»

Все события публикуются в Apache Kafka. Топики именуются по схеме `{domain}.{aggregate}.{event}` в snake_case.
Формат сериализации: **Avro** с версионированием через Schema Registry.

Обязательные поля в каждом событии:
- `event_id` — UUID, уникальный идентификатор события
- `event_type` — строка, полное имя события
- `occurred_at` — ISO 8601 timestamp
- `schema_version` — версия контракта

---

## Healthcare

### PatientRegistered
| Поле | Значение |
|------|----------|
| **Топик** | `healthcare.patient.registered` |
| **Агрегат** | Patient |
| **Семантика** | Пациент успешно зарегистрирован в системе. Создана медицинская карта. |
| **Подписчики** | Analytics Platform |

```json
{
  "event_id": "uuid",
  "event_type": "healthcare.PatientRegistered",
  "occurred_at": "2025-01-15T10:30:00Z",
  "schema_version": "1.0",
  "patient_id": "uuid",
  "person_id": "uuid",
  "clinic_id": "uuid",
  "registration_date": "2025-01-15"
}
```

---

### PatientAdmitted
| Поле | Значение |
|------|----------|
| **Топик** | `healthcare.admission.admitted` |
| **Агрегат** | Admission |
| **Семантика** | Пациент госпитализирован. Открыт эпизод лечения. |
| **Подписчики** | Fintech (проверка фин. покрытия), Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "healthcare.PatientAdmitted",
  "occurred_at": "2025-01-15T14:00:00Z",
  "schema_version": "1.0",
  "admission_id": "uuid",
  "patient_id": "uuid",
  "clinic_id": "uuid",
  "department": "cardiology",
  "admission_type": "EMERGENCY | PLANNED"
}
```

---

### DiagnosisCompleted
| Поле | Значение |
|------|----------|
| **Топик** | `healthcare.medical_record.diagnosis_completed` |
| **Агрегат** | MedicalRecord |
| **Семантика** | Врач зафиксировал диагноз в медицинской карте. |
| **Подписчики** | Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "healthcare.DiagnosisCompleted",
  "occurred_at": "2025-01-15T16:00:00Z",
  "schema_version": "1.0",
  "record_id": "uuid",
  "admission_id": "uuid",
  "icd10_code": "I21.0",
  "doctor_id": "uuid"
}
```

> Медицинская карта пациента **не включается** в событие — только идентификаторы. Персональные данные остаются в домене Healthcare.

---

### AIAnalysisRequested
| Поле | Значение |
|------|----------|
| **Топик** | `healthcare.diagnostic_request.ai_requested` |
| **Агрегат** | DiagnosticRequest |
| **Семантика** | Healthcare-домен запрашивает ML-анализ медицинских данных у AI Diagnostics. |
| **Подписчики** | AI Diagnostics |

```json
{
  "event_id": "uuid",
  "event_type": "healthcare.AIAnalysisRequested",
  "occurred_at": "2025-01-15T16:05:00Z",
  "schema_version": "1.0",
  "request_id": "uuid",
  "record_id": "uuid",
  "analysis_type": "ECG_INTERPRETATION | CT_SCAN | MRI",
  "data_reference": "s3://medical-secure-bucket/studies/uuid",
  "priority": "URGENT | ROUTINE"
}
```

---

### PrescriptionIssued
| Поле | Значение |
|------|----------|
| **Топик** | `healthcare.prescription.issued` |
| **Агрегат** | Prescription |
| **Семантика** | Врач выписал рецепт пациенту. |
| **Подписчики** | Pharmacy, Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "healthcare.PrescriptionIssued",
  "occurred_at": "2025-01-15T17:00:00Z",
  "schema_version": "1.0",
  "prescription_id": "uuid",
  "patient_id": "uuid",
  "record_id": "uuid",
  "drugs": [
    { "drug_code": "A01AB03", "dosage": "500mg", "quantity": 20, "controlled": false }
  ],
  "valid_until": "2025-02-15"
}
```

---

### PatientDischarged
| Поле | Значение |
|------|----------|
| **Топик** | `healthcare.admission.discharged` |
| **Агрегат** | Admission |
| **Семантика** | Пациент выписан, эпизод лечения закрыт. |
| **Подписчики** | Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "healthcare.PatientDischarged",
  "occurred_at": "2025-01-20T11:00:00Z",
  "schema_version": "1.0",
  "admission_id": "uuid",
  "patient_id": "uuid",
  "discharge_date": "2025-01-20",
  "outcome": "RECOVERED | REFERRED | DECEASED"
}
```

---

## AI Diagnostics

### AIAnalysisCompleted
| Поле | Значение |
|------|----------|
| **Топик** | `ai.analysis_job.completed` |
| **Агрегат** | AnalysisJob |
| **Семантика** | ML-модель завершила анализ, результат готов. |
| **Подписчики** | Healthcare, Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "ai.AIAnalysisCompleted",
  "occurred_at": "2025-01-15T16:12:00Z",
  "schema_version": "1.0",
  "job_id": "uuid",
  "request_id": "uuid",
  "model_name": "cardio-ecg-v3",
  "model_version": "3.2.1",
  "result_reference": "s3://ai-results-bucket/jobs/uuid",
  "confidence_score": 0.94,
  "findings_summary": "Признаки ишемии в отведении II"
}
```

---

### AIAnalysisFailed
| Поле | Значение |
|------|----------|
| **Топик** | `ai.analysis_job.failed` |
| **Агрегат** | AnalysisJob |
| **Семантика** | Анализ не выполнен: данные недоступны, модель недоступна или превышен таймаут. |
| **Подписчики** | Healthcare (алерт врачу), Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "ai.AIAnalysisFailed",
  "occurred_at": "2025-01-15T16:20:00Z",
  "schema_version": "1.0",
  "job_id": "uuid",
  "request_id": "uuid",
  "failure_reason": "DATA_UNAVAILABLE | MODEL_ERROR | TIMEOUT",
  "retry_count": 2
}
```

---

## Fintech / Banking

### AccountOpened
| Поле | Значение |
|------|----------|
| **Топик** | `fintech.account.opened` |
| **Агрегат** | Account |
| **Семантика** | Новый банковский счёт открыт для клиента. |
| **Подписчики** | Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "fintech.AccountOpened",
  "occurred_at": "2025-01-10T09:00:00Z",
  "schema_version": "1.0",
  "account_id": "uuid",
  "person_id": "uuid",
  "account_type": "CURRENT | SAVINGS | ESCROW",
  "currency": "RUB"
}
```

---

### LoanApplicationApproved
| Поле | Значение |
|------|----------|
| **Топик** | `fintech.loan_application.approved` |
| **Агрегат** | LoanApplication |
| **Семантика** | Кредитная заявка одобрена скоринговой системой. |
| **Подписчики** | Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "fintech.LoanApplicationApproved",
  "occurred_at": "2025-01-12T11:30:00Z",
  "schema_version": "1.0",
  "application_id": "uuid",
  "person_id": "uuid",
  "approved_amount": 500000,
  "currency": "RUB",
  "interest_rate": 12.5,
  "term_months": 24
}
```

---

### LoanAgreementSigned
| Поле | Значение |
|------|----------|
| **Топик** | `fintech.loan_agreement.signed` |
| **Агрегат** | LoanAgreement |
| **Семантика** | Кредитный договор подписан клиентом. Обязательства приняты. |
| **Подписчики** | Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "fintech.LoanAgreementSigned",
  "occurred_at": "2025-01-13T10:00:00Z",
  "schema_version": "1.0",
  "agreement_id": "uuid",
  "application_id": "uuid",
  "person_id": "uuid",
  "principal_amount": 500000,
  "currency": "RUB",
  "start_date": "2025-01-13",
  "end_date": "2027-01-13"
}
```

---

### PaymentCompleted
| Поле | Значение |
|------|----------|
| **Топик** | `fintech.payment.completed` |
| **Агрегат** | Payment |
| **Семантика** | Платёж успешно проведён и зачислен. |
| **Подписчики** | Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "fintech.PaymentCompleted",
  "occurred_at": "2025-01-14T15:00:00Z",
  "schema_version": "1.0",
  "payment_id": "uuid",
  "idempotency_key": "uuid",
  "payer_account_id": "uuid",
  "payee_account_id": "uuid",
  "amount": 15000,
  "currency": "RUB",
  "payment_type": "LOAN_REPAYMENT | SERVICE | TRANSFER"
}
```

---

## Pharmacy

### PrescriptionFulfilled
| Поле | Значение |
|------|----------|
| **Топик** | `pharmacy.order.prescription_fulfilled` |
| **Агрегат** | PharmacyOrder |
| **Семантика** | Рецепт отпущен пациенту в аптеке. |
| **Подписчики** | Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "pharmacy.PrescriptionFulfilled",
  "occurred_at": "2025-01-16T12:00:00Z",
  "schema_version": "1.0",
  "order_id": "uuid",
  "prescription_id": "uuid",
  "pharmacy_id": "uuid",
  "fulfilled_drugs": [
    { "drug_code": "A01AB03", "quantity_dispensed": 20 }
  ]
}
```

---

### DrugOrderDelivered
| Поле | Значение |
|------|----------|
| **Топик** | `pharmacy.supply_order.delivered` |
| **Агрегат** | DrugSupplyOrder |
| **Семантика** | Поставка препаратов от фармацевтического партнёра получена. |
| **Подписчики** | Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "pharmacy.DrugOrderDelivered",
  "occurred_at": "2025-01-17T08:00:00Z",
  "schema_version": "1.0",
  "supply_id": "uuid",
  "supplier_id": "uuid",
  "pharmacy_id": "uuid",
  "delivered_items": [
    { "drug_code": "A01AB03", "quantity": 500, "batch_number": "B2025-001", "expiry_date": "2027-06-01" }
  ]
}
```

---

## MedTech

### DeviceAlertTriggered
| Поле | Значение |
|------|----------|
| **Топик** | `medtech.device.alert_triggered` |
| **Агрегат** | MedicalDevice |
| **Семантика** | Оборудование зафиксировало аномалию или критическое состояние. |
| **Подписчики** | Healthcare (уведомление персонала), Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "medtech.DeviceAlertTriggered",
  "occurred_at": "2025-01-15T03:22:00Z",
  "schema_version": "1.0",
  "device_id": "uuid",
  "clinic_id": "uuid",
  "alert_type": "CRITICAL | WARNING",
  "alert_code": "HEART_RATE_CRITICAL",
  "patient_id": "uuid",
  "reading_value": 180,
  "unit": "bpm"
}
```

---

### DeviceReadingRecorded
| Поле | Значение |
|------|----------|
| **Топик** | `medtech.device.reading_recorded` |
| **Агрегат** | MedicalDevice |
| **Семантика** | Плановая запись показаний датчика. |
| **Подписчики** | Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "medtech.DeviceReadingRecorded",
  "occurred_at": "2025-01-15T03:20:00Z",
  "schema_version": "1.0",
  "device_id": "uuid",
  "device_type": "ECG | MRI | VENTILATOR | INFUSION_PUMP",
  "clinic_id": "uuid",
  "metric": "heart_rate",
  "value": 75,
  "unit": "bpm"
}
```

---

### MaintenanceCompleted
| Поле | Значение |
|------|----------|
| **Топик** | `medtech.maintenance.completed` |
| **Агрегат** | MaintenanceTask |
| **Семантика** | Техническое обслуживание оборудования завершено, устройство возвращено в эксплуатацию. |
| **Подписчики** | Analytics |

```json
{
  "event_id": "uuid",
  "event_type": "medtech.MaintenanceCompleted",
  "occurred_at": "2025-01-18T16:00:00Z",
  "schema_version": "1.0",
  "task_id": "uuid",
  "device_id": "uuid",
  "engineer_id": "uuid",
  "maintenance_type": "PREVENTIVE | CORRECTIVE",
  "next_maintenance_date": "2025-07-18"
}
```
