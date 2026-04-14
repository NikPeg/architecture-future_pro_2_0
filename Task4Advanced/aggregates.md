# Каталог агрегатов — «Будущее 2.0»

---

## Healthcare

### Patient
| Поле | Значение |
|------|----------|
| **Ключ** | `patient_id` (UUID) |
| **Граница** | Patient Management sub-context |
| **Состояния** | `REGISTERED → ACTIVE → ARCHIVED` |
| **Инварианты** | Пациент обязан иметь уникальный `person_id` из Identity & Access; дата рождения не может быть в будущем; медкарта создаётся автоматически при регистрации |
| **Команды** | RegisterPatient, UpdateContacts, ArchivePatient |
| **События** | PatientRegistered, PatientContactsUpdated, PatientArchived |

### Appointment
| Поле | Значение |
|------|----------|
| **Ключ** | `appointment_id` (UUID) |
| **Граница** | Clinic Operations sub-context |
| **Состояния** | `REQUESTED → CONFIRMED → CANCELLED / COMPLETED` |
| **Инварианты** | Время приёма не может пересекаться для одного врача; нельзя записать к врачу, у которого нет актуальной лицензии; отмена возможна не позднее чем за 2 часа |
| **Команды** | BookAppointment, ConfirmAppointment, CancelAppointment, CompleteAppointment |
| **События** | AppointmentBooked, AppointmentConfirmed, AppointmentCancelled, AppointmentCompleted |

### Admission
| Поле | Значение |
|------|----------|
| **Ключ** | `admission_id` (UUID) |
| **Граница** | Clinic Operations sub-context |
| **Состояния** | `ADMITTED → IN_TREATMENT → DISCHARGED` |
| **Инварианты** | Госпитализация обязана ссылаться на существующего пациента; нельзя выписать пациента без финального диагноза в MedicalRecord |
| **Команды** | AdmitPatient, DischargePatient |
| **События** | PatientAdmitted, PatientDischarged |

### MedicalRecord
| Поле | Значение |
|------|----------|
| **Ключ** | `record_id` (UUID), `patient_id` |
| **Граница** | Medical Records sub-context |
| **Состояния** | `DRAFT → COMPLETED → AMENDED` |
| **Инварианты** | Запись принадлежит ровно одному пациенту; диагноз обязан быть кодифицирован по МКБ-10; изменение завершённой записи создаёт Amendment, не перезаписывает оригинал |
| **Команды** | CreateRecord, RecordDiagnosis, AmendRecord |
| **События** | DiagnosisCompleted, RecordAmended |

### DiagnosticRequest
| Поле | Значение |
|------|----------|
| **Ключ** | `request_id` (UUID) |
| **Граница** | Medical Records sub-context (инициатор) |
| **Состояния** | `CREATED → SENT → COMPLETED / FAILED` |
| **Инварианты** | Запрос ссылается на конкретный `record_id`; после отправки в AI нельзя изменить входные данные |
| **Команды** | RequestAIAnalysis |
| **События** | AIAnalysisRequested |

### Prescription
| Поле | Значение |
|------|----------|
| **Ключ** | `prescription_id` (UUID) |
| **Граница** | Medical Records sub-context |
| **Состояния** | `ISSUED → PARTIALLY_FULFILLED → FULFILLED / EXPIRED` |
| **Инварианты** | Срок действия рецепта — не более 30 дней; контролируемые препараты требуют электронной подписи врача |
| **Команды** | IssuePrescription, ExpirePrescription |
| **События** | PrescriptionIssued, PrescriptionExpired |

---

## AI Diagnostics

### AnalysisJob
| Поле | Значение |
|------|----------|
| **Ключ** | `job_id` (UUID), `request_id` (ref к Healthcare) |
| **Граница** | Analysis Execution sub-context |
| **Состояния** | `QUEUED → RUNNING → COMPLETED / FAILED` |
| **Инварианты** | Каждый job привязан к конкретной версии модели из Model Registry; результат неизменяем после записи; повторный запуск создаёт новый job, не перезаписывает старый |
| **Команды** | StartAnalysis, RetryAnalysis |
| **События** | AIAnalysisCompleted, AIAnalysisFailed |

---

## Fintech / Banking

### Account
| Поле | Значение |
|------|----------|
| **Ключ** | `account_id` (UUID) |
| **Граница** | Accounts sub-context |
| **Состояния** | `PENDING → ACTIVE → BLOCKED → CLOSED` |
| **Инварианты** | Баланс не может быть отрицательным без овердрафт-лимита; закрытие счёта возможно только при нулевом балансе |
| **Команды** | OpenAccount, BlockAccount, CloseAccount |
| **События** | AccountOpened, AccountBlocked, AccountClosed |

### LoanApplication
| Поле | Значение |
|------|----------|
| **Ключ** | `application_id` (UUID) |
| **Граница** | Lending sub-context |
| **Состояния** | `SUBMITTED → UNDER_REVIEW → APPROVED / REJECTED` |
| **Инварианты** | Сумма заявки в допустимом диапазоне для типа кредита; клиент не может иметь более N активных заявок одновременно |
| **Команды** | SubmitLoanApplication, ApproveLoan, RejectLoan |
| **События** | LoanApplicationSubmitted, LoanApplicationApproved, LoanApplicationRejected |

### LoanAgreement
| Поле | Значение |
|------|----------|
| **Ключ** | `agreement_id` (UUID) |
| **Граница** | Lending sub-context |
| **Состояния** | `CREATED → ACTIVE → CLOSED / DEFAULTED` |
| **Инварианты** | Договор создаётся только из одобренной заявки; сумма платежей по графику должна равняться сумме долга + проценты; досрочное погашение пересчитывает график |
| **Команды** | SignLoanAgreement, MakeRepayment, CloseAgreement |
| **События** | LoanAgreementSigned, LoanRepaymentMade, LoanAgreementClosed |

### Payment
| Поле | Значение |
|------|----------|
| **Ключ** | `payment_id` (UUID) |
| **Граница** | Payments sub-context |
| **Состояния** | `INITIATED → PROCESSING → COMPLETED / FAILED` |
| **Инварианты** | Сумма > 0; идемпотентность: повторный запрос с тем же `idempotency_key` не создаёт новый платёж |
| **Команды** | InitiatePayment, RetryPayment |
| **События** | PaymentCompleted, PaymentFailed |

---

## Pharmacy

### PharmacyOrder
| Поле | Значение |
|------|----------|
| **Ключ** | `order_id` (UUID), `prescription_id` (ref) |
| **Граница** | Prescriptions sub-context |
| **Состояния** | `CREATED → DISPENSING → FULFILLED / REJECTED` |
| **Инварианты** | Заказ создаётся только по действующему рецепту; контролируемые препараты отпускаются только после проверки подписи врача |
| **Команды** | FulfillPrescription, RejectOrder |
| **События** | PrescriptionFulfilled, OrderRejected |

### DrugSupplyOrder
| Поле | Значение |
|------|----------|
| **Ключ** | `supply_id` (UUID) |
| **Граница** | Supply Chain sub-context |
| **Состояния** | `CREATED → SHIPPED → DELIVERED / CANCELLED` |
| **Инварианты** | Нельзя заказать препарат, не зарегистрированный в Drug Catalog |
| **Команды** | CreateDrugOrder, ConfirmDelivery |
| **События** | DrugOrderCreated, DrugOrderDelivered |

---

## MedTech

### MedicalDevice
| Поле | Значение |
|------|----------|
| **Ключ** | `device_id` (UUID) |
| **Граница** | Device Management sub-context |
| **Состояния** | `REGISTERED → OPERATIONAL → MAINTENANCE → DECOMMISSIONED` |
| **Инварианты** | Каждое устройство привязано к конкретной клинике; показания принимаются только от устройств в состоянии OPERATIONAL |
| **Команды** | RegisterDevice, RecordReading, TriggerAlert, DecommissionDevice |
| **События** | DeviceRegistered, DeviceReadingRecorded, DeviceAlertTriggered, DeviceDecommissioned |

### MaintenanceTask
| Поле | Значение |
|------|----------|
| **Ключ** | `task_id` (UUID), `device_id` (ref) |
| **Граница** | Maintenance sub-context |
| **Состояния** | `SCHEDULED → IN_PROGRESS → COMPLETED / CANCELLED` |
| **Инварианты** | Устройство переводится в MAINTENANCE при создании задачи; завершение задачи обязано включать report от инженера |
| **Команды** | ScheduleMaintenance, CompleteMaintenance |
| **События** | MaintenanceScheduled, MaintenanceCompleted |
