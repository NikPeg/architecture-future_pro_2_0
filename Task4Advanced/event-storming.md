# Event Storming — «Будущее 2.0»

Диаграмма отражает целевую событийную архитектуру. Нотация:
- 🟠 **Событие** (Domain Event) — произошедший факт
- 🔵 **Команда** (Command) — намерение изменить состояние
- 🟡 **Агрегат** (Aggregate) — объект, обрабатывающий команду и порождающий событие
- 🟣 **Политика** (Policy) — реакция одного домена на событие другого
- 🔴 **Внешняя система** — Legacy DWH, партнёры

---

## 1. Домен: Healthcare

```mermaid
flowchart LR
    CMD1["🔵 RegisterPatient"]
    AGG1["🟡 Patient"]
    EVT1["🟠 PatientRegistered"]

    CMD2["🔵 BookAppointment"]
    AGG2["🟡 Appointment"]
    EVT2["🟠 AppointmentBooked"]

    CMD3["🔵 AdmitPatient"]
    AGG3["🟡 Admission"]
    EVT3["🟠 PatientAdmitted"]

    CMD4["🔵 RecordDiagnosis"]
    AGG4["🟡 MedicalRecord"]
    EVT4["🟠 DiagnosisCompleted"]

    CMD5["🔵 RequestAIAnalysis"]
    AGG5["🟡 DiagnosticRequest"]
    EVT5["🟠 AIAnalysisRequested"]

    CMD6["🔵 IssuePrescription"]
    AGG6["🟡 Prescription"]
    EVT6["🟠 PrescriptionIssued"]

    CMD7["🔵 DischargePatient"]
    AGG3
    EVT7["🟠 PatientDischarged"]

    CMD1 --> AGG1 --> EVT1
    CMD2 --> AGG2 --> EVT2
    CMD3 --> AGG3 --> EVT3
    CMD4 --> AGG4 --> EVT4
    EVT4 -- "Policy:\ndiagnosis needs AI" --> CMD5
    CMD5 --> AGG5 --> EVT5
    EVT4 -- "Policy:\ntreatment needs drugs" --> CMD6
    CMD6 --> AGG6 --> EVT6
    CMD7 --> AGG3 --> EVT7

    style EVT1 fill:#ff9800,color:#000
    style EVT2 fill:#ff9800,color:#000
    style EVT3 fill:#ff9800,color:#000
    style EVT4 fill:#ff9800,color:#000
    style EVT5 fill:#ff9800,color:#000
    style EVT6 fill:#ff9800,color:#000
    style EVT7 fill:#ff9800,color:#000
    style AGG1 fill:#ffeb3b,color:#000
    style AGG2 fill:#ffeb3b,color:#000
    style AGG3 fill:#ffeb3b,color:#000
    style AGG4 fill:#ffeb3b,color:#000
    style AGG5 fill:#ffeb3b,color:#000
    style AGG6 fill:#ffeb3b,color:#000
    style CMD1 fill:#42a5f5,color:#000
    style CMD2 fill:#42a5f5,color:#000
    style CMD3 fill:#42a5f5,color:#000
    style CMD4 fill:#42a5f5,color:#000
    style CMD5 fill:#42a5f5,color:#000
    style CMD6 fill:#42a5f5,color:#000
    style CMD7 fill:#42a5f5,color:#000
```

---

## 2. Домен: AI Diagnostics

```mermaid
flowchart LR
    EXT1["🟠 AIAnalysisRequested\n(из Healthcare)"]
    AGG1["🟡 AnalysisJob"]
    EVT1["🟠 AIAnalysisCompleted"]
    EVT2["🟠 AIAnalysisFailed"]

    CMD1["🔵 RetryAnalysis"]
    AGG2["🟡 AnalysisJob"]
    EVT3["🟠 AIAnalysisCompleted"]

    EXT1 --> AGG1
    AGG1 --> EVT1
    AGG1 --> EVT2
    EVT2 -- "Policy:\nretry or alert" --> CMD1
    CMD1 --> AGG2 --> EVT3

    style EXT1 fill:#ff9800,color:#000
    style EVT1 fill:#ff9800,color:#000
    style EVT2 fill:#ff9800,color:#000
    style EVT3 fill:#ff9800,color:#000
    style AGG1 fill:#ffeb3b,color:#000
    style AGG2 fill:#ffeb3b,color:#000
    style CMD1 fill:#42a5f5,color:#000
```

---

## 3. Домен: Fintech / Banking

```mermaid
flowchart LR
    CMD1["🔵 OpenAccount"]
    AGG1["🟡 Account"]
    EVT1["🟠 AccountOpened"]

    CMD2["🔵 SubmitLoanApplication"]
    AGG2["🟡 LoanApplication"]
    EVT2["🟠 LoanApplicationSubmitted"]

    CMD3["🔵 ApproveLoan"]
    AGG2
    EVT3["🟠 LoanApplicationApproved"]

    CMD4["🔵 SignLoanAgreement"]
    AGG3["🟡 LoanAgreement"]
    EVT4["🟠 LoanAgreementSigned"]

    CMD5["🔵 MakeRepayment"]
    AGG3
    EVT5["🟠 LoanRepaymentMade"]

    CMD6["🔵 InitiatePayment"]
    AGG4["🟡 Payment"]
    EVT6["🟠 PaymentCompleted"]
    EVT7["🟠 PaymentFailed"]

    EXT1["🟠 PatientAdmitted\n(из Healthcare)"]

    CMD1 --> AGG1 --> EVT1
    CMD2 --> AGG2 --> EVT2
    EVT2 --> CMD3
    CMD3 --> AGG2 --> EVT3
    EVT3 -- "Policy:\ncreate agreement" --> CMD4
    CMD4 --> AGG3 --> EVT4
    CMD5 --> AGG3 --> EVT5
    CMD6 --> AGG4 --> EVT6
    AGG4 --> EVT7
    EXT1 -. "Policy:\ncheck loan eligibility\nfor hospital services" .-> CMD2

    style EVT1 fill:#ff9800,color:#000
    style EVT2 fill:#ff9800,color:#000
    style EVT3 fill:#ff9800,color:#000
    style EVT4 fill:#ff9800,color:#000
    style EVT5 fill:#ff9800,color:#000
    style EVT6 fill:#ff9800,color:#000
    style EVT7 fill:#ff9800,color:#000
    style EXT1 fill:#ff9800,color:#000
    style AGG1 fill:#ffeb3b,color:#000
    style AGG2 fill:#ffeb3b,color:#000
    style AGG3 fill:#ffeb3b,color:#000
    style AGG4 fill:#ffeb3b,color:#000
    style CMD1 fill:#42a5f5,color:#000
    style CMD2 fill:#42a5f5,color:#000
    style CMD3 fill:#42a5f5,color:#000
    style CMD4 fill:#42a5f5,color:#000
    style CMD5 fill:#42a5f5,color:#000
    style CMD6 fill:#42a5f5,color:#000
```

---

## 4. Домен: Pharmacy

```mermaid
flowchart LR
    EXT1["🟠 PrescriptionIssued\n(из Healthcare)"]
    CMD1["🔵 FulfillPrescription"]
    AGG1["🟡 PharmacyOrder"]
    EVT1["🟠 PrescriptionFulfilled"]

    CMD2["🔵 CreateDrugOrder"]
    AGG2["🟡 DrugSupplyOrder"]
    EVT2["🟠 DrugOrderCreated"]
    EVT3["🟠 DrugOrderDelivered"]

    EXT1 -- "Policy:\ncheck availability\nand fulfil" --> CMD1
    CMD1 --> AGG1 --> EVT1
    EVT1 -- "Policy:\nrestock if low" --> CMD2
    CMD2 --> AGG2 --> EVT2
    AGG2 --> EVT3

    style EXT1 fill:#ff9800,color:#000
    style EVT1 fill:#ff9800,color:#000
    style EVT2 fill:#ff9800,color:#000
    style EVT3 fill:#ff9800,color:#000
    style AGG1 fill:#ffeb3b,color:#000
    style AGG2 fill:#ffeb3b,color:#000
    style CMD1 fill:#42a5f5,color:#000
    style CMD2 fill:#42a5f5,color:#000
```

---

## 5. Домен: MedTech

```mermaid
flowchart LR
    CMD1["🔵 RegisterDevice"]
    AGG1["🟡 MedicalDevice"]
    EVT1["🟠 DeviceRegistered"]

    CMD2["🔵 RecordReading"]
    AGG1
    EVT2["🟠 DeviceReadingRecorded"]

    CMD3["🔵 TriggerAlert"]
    AGG1
    EVT3["🟠 DeviceAlertTriggered"]

    CMD4["🔵 ScheduleMaintenance"]
    AGG2["🟡 MaintenanceTask"]
    EVT4["🟠 MaintenanceScheduled"]

    CMD5["🔵 CompleteMaintenance"]
    AGG2
    EVT5["🟠 MaintenanceCompleted"]

    CMD1 --> AGG1 --> EVT1
    CMD2 --> AGG1 --> EVT2
    EVT2 -- "Policy:\nanomaly detected" --> CMD3
    CMD3 --> AGG1 --> EVT3
    EVT3 -- "Policy:\nschedule repair" --> CMD4
    CMD4 --> AGG2 --> EVT4
    CMD5 --> AGG2 --> EVT5

    style EVT1 fill:#ff9800,color:#000
    style EVT2 fill:#ff9800,color:#000
    style EVT3 fill:#ff9800,color:#000
    style EVT4 fill:#ff9800,color:#000
    style EVT5 fill:#ff9800,color:#000
    style AGG1 fill:#ffeb3b,color:#000
    style AGG2 fill:#ffeb3b,color:#000
    style CMD1 fill:#42a5f5,color:#000
    style CMD2 fill:#42a5f5,color:#000
    style CMD3 fill:#42a5f5,color:#000
    style CMD4 fill:#42a5f5,color:#000
    style CMD5 fill:#42a5f5,color:#000
```

---

## 6. Сводная схема кросс-доменных взаимодействий

```mermaid
flowchart TD
    subgraph HC["🏥 Healthcare"]
        HC_EVT1["🟠 PatientRegistered"]
        HC_EVT2["🟠 PatientAdmitted"]
        HC_EVT3["🟠 DiagnosisCompleted"]
        HC_EVT4["🟠 AIAnalysisRequested"]
        HC_EVT5["🟠 PrescriptionIssued"]
        HC_EVT6["🟠 PatientDischarged"]
    end

    subgraph AI["🤖 AI Diagnostics"]
        AI_EVT1["🟠 AIAnalysisCompleted"]
        AI_EVT2["🟠 AIAnalysisFailed"]
    end

    subgraph FT["🏦 Fintech"]
        FT_EVT1["🟠 AccountOpened"]
        FT_EVT2["🟠 LoanAgreementSigned"]
        FT_EVT3["🟠 PaymentCompleted"]
        FT_EVT4["🟠 LoanRepaymentMade"]
    end

    subgraph PH["💊 Pharmacy"]
        PH_EVT1["🟠 PrescriptionFulfilled"]
        PH_EVT2["🟠 DrugOrderDelivered"]
    end

    subgraph MT["🔬 MedTech"]
        MT_EVT1["🟠 DeviceReadingRecorded"]
        MT_EVT2["🟠 DeviceAlertTriggered"]
        MT_EVT3["🟠 MaintenanceCompleted"]
    end

    subgraph AN["📊 Analytics Platform"]
        AN_NOTE["Подписчик всех событий\n(кроме медкарт)"]
    end

    HC_EVT4 -- "топик: medical.ai.requests" --> AI
    AI_EVT1 -- "топик: ai.analysis.results" --> HC
    HC_EVT5 -- "топик: healthcare.prescriptions" --> PH
    HC_EVT2 -- "топик: healthcare.admissions" --> FT
    MT_EVT2 -- "топик: medtech.alerts" --> HC

    HC_EVT1 --> AN
    HC_EVT2 --> AN
    HC_EVT6 --> AN
    FT_EVT1 --> AN
    FT_EVT2 --> AN
    FT_EVT3 --> AN
    FT_EVT4 --> AN
    PH_EVT1 --> AN
    PH_EVT2 --> AN
    MT_EVT1 --> AN
    MT_EVT3 --> AN

    style HC fill:#e8f5e9
    style AI fill:#f3e5f5
    style FT fill:#e3f2fd
    style PH fill:#fff8e1
    style MT fill:#fbe9e7
    style AN fill:#fce4ec
```

---

## Матрица подписок (кросс-доменные события)

| Событие | Источник | Подписчики | Семантика |
|---------|----------|------------|-----------|
| PatientRegistered | Healthcare | Analytics | Новый пациент в системе |
| PatientAdmitted | Healthcare | Fintech, Analytics | Госпитализация — триггер для проверки финансового покрытия |
| DiagnosisCompleted | Healthcare | Analytics | Факт постановки диагноза |
| AIAnalysisRequested | Healthcare | AI Diagnostics | Запрос на ML-анализ мед. данных |
| AIAnalysisCompleted | AI Diagnostics | Healthcare, Analytics | Результат ML-диагностики |
| PrescriptionIssued | Healthcare | Pharmacy, Analytics | Выписанный рецепт передаётся в аптеку |
| PatientDischarged | Healthcare | Analytics | Закрытие эпизода лечения |
| LoanAgreementSigned | Fintech | Analytics | Кредитный договор оформлен |
| PaymentCompleted | Fintech | Analytics | Платёж проведён успешно |
| PrescriptionFulfilled | Pharmacy | Analytics | Рецепт отпущен пациенту |
| DeviceAlertTriggered | MedTech | Healthcare, Analytics | Аварийный сигнал оборудования → уведомление клиники |
| DeviceReadingRecorded | MedTech | Analytics | Показания для аналитики |
