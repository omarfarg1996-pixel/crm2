# Commerce AI Core - Architecture Principles

## المبادئ المعمارية الأساسية

هذا يوثق المبادئ الحاكمة لتصميم وبناء Commerce AI Core. يجب الالتزام بهذه المبادئ في جميع القرارات التقنية.

---

## 1. Multi-Tenancy First

### المبدأ
كل شيء مصمم ليدعم تعدد العملاء (tenants) من أول يوم.

### التطبيق
- كل جدول في قاعدة البيانات يحتوي على `tenant_id`
- لا يوجد shared state بين tenants
- عزل تام للبيانات على مستوى:
  - Database rows (tenant_id column)
  - Cache keys (prefixed by tenant_id)
  - File storage (tenant_id in path)
  - Vector collections (separate or filtered)
  - Queue topics (tenant-specific)

### محظورات
- ❌ متغيرات global تخزن بيانات tenant
- ❌ Queries بدون WHERE tenant_id = ?
- ❌ Cache keys بدون tenant prefix
- ❌ File paths بدون tenant namespace

---

## 2. Event-Driven Architecture

### المبدأ
كل عملية مهمة تُنتج Event. الخدمات تتواصل عبر events وليس direct calls.

### التطبيق
- Events تُخزن في `events` table
- Event bus ينشر events للمهتمين
- كل event له schema محدد
- Dead letter queue للفشل
- Replay capability للأحداث

### أمثلة على Events
```
customer.created
customer.updated
order.created
order.cancelled
message.sent
message.received
campaign.created
campaign.started
ai.decision.made
workflow.started
workflow.completed
```

### محظورات
- ❌ Direct service-to-service calls للعمليات غير المتزامنة
- ❌ Business logic داخل webhook handlers
- ❌ تعديل بيانات Tenant A استجابةً لـ Event من Tenant B

---

## 3. Durable Execution

### المبدأ
العمليات الطويلة والمهمة تستخدم Temporal workflows لضمان الاستمرارية.

### التطبيق
- أي عملية تستغرق > 5 ثواني → Workflow
- أي عملية تحتاج retry معقدة → Workflow
- أي عملية تحتاج human approval → Workflow
- Activities تكون idempotent
- Workflows تكون deterministic

### محظورات
- ❌ Cron jobs للعمليات الحرجة
- ❌ In-memory retries بدون persistence
- ❌ Non-deterministic code في workflows

---

## 4. AI Governance

### المبدأ
AI يقترح، Policy Engine يراجع، Human يوافق عند الحاجة، Workflow ينفذ.

### التطبيق
- كل AI decision يُحفظ في `ai_decisions` table
- AI لا يرسل رسائل مباشرة
- Policy Engine يفحص قبل الإرسال:
  - Consent status
  - Suppression lists
  - Frequency caps
  - Quiet hours
  - Template approval
  - Tenant quotas
  - Customer risk score
  - Offer margins
- Human approval مطلوب للحالات عالية المخاطر

### محظورات
- ❌ AI يرسل رسائل بدون policy check
- ❌ AI يعد بخصومات غير مصرح بها
- ❌ AI يتصل بـ APIs خارجية بدون audit
- ❌ Prompts بدون version control

---

## 5. Idempotency

### المبدأ
كل external write operation يجب أن يكون idempotent.

### التطبيق
- Idempotency keys لكل request
- Deduplication على مستوى database
- External APIs تُستدعى مع idempotency headers
- Operations تُصمم لتكون safe to retry

### أمثلة
```python
# صحيح
def send_whatsapp_message(idempotency_key: str, ...):
    if already_sent(idempotency_key):
        return previous_result
    # send message
    save_idempotency_key(idempotency_key, result)

# خطأ
def send_whatsapp_message(...):
    # قد يرسل نفس الرسالة مرتين
    whatsapp_client.send(...)
```

### محظورات
- ❌ عمليات write بدون idempotency check
- ❌ Retry بدون idempotency key
- ❌ اعتماد على timestamps للتفرد

---

## 6. Observability First

### المبدأ
التتبع والقياس والتسجيل مدمجة من البداية، وليست إضافة لاحقة.

### التطبيق
- OpenTelemetry للـ traces و metrics
- Structured logging (JSON format)
- Correlation IDs عبر الخدمات
- Health endpoints لكل خدمة
- Metrics للأداء والاستخدام
- Error tracking مع context

### محظورات
- ❌ print() statements في production code
- ❌ Errors بدون context
- ❌ Requests بدون trace ID
- ❌ Services بدون health endpoint

---

## 7. Connector Abstraction

### المبدأ
Integrations مع أنظمة خارجية (Shopify, Zoho, WhatsApp) تكون عبر connectors مجرّدة.

### التطبيق
- Base connector interface
- كل connector يلتزم بالـ contract
- Credentials مخزنة بشكل آمن
- Rate limiting مُدار
- Error handling موحد
- Field mapping قابل للتكوين

### محظورات
- ❌ منطق Shopify/Zoho داخل business logic
- ❌ Hardcoded credentials
- ❌ Direct API calls بدون abstraction
- ❌ Mixing connector logic مع module logic

---

## 8. Module System

### المبدأ
الخدمات الجديدة تُبنى كـ modules قابلة للإضافة/الإزالة.

### التطبيق
- كل module له manifest (module.yaml)
- Modules تسجل permissions المطلوبة
- Modules تسجل events التي تهتم بها
- Modules يمكن تمكينها/تعطيلها per tenant
- Modules لا تعدل النواة

### هيكل Module
```
packages/modules/retention/
├── module.yaml          # Manifest
├── README.md            # Documentation
├── services/            # Business logic
├── schemas/             # Data models
├── policies/            # Policy rules
├── events/              # Event handlers
├── workflows/           # Temporal workflows
└── tests/               # Tests
```

### محظورات
- ❌ تعديل core code لإضافة feature
- ❌ Dependencies بين modules
- ❌ Modules بدون manifest

---

## 9. Security by Design

### المبدأ
الأمان مُدمج في التصميم، ليس ميزة إضافية.

### التطبيق
- Authentication مطلوب لكل API call
- Authorization على مستوى resource
- Input validation صارم
- Output encoding لمنع XSS
- SQL parameters لمنع injection
- Secrets في environment variables
- Encryption للبيانات الحساسة
- Audit logs لكل operations مهمة

### محظورات
- ❌ Hardcoded secrets
- ❌ SQL concatenation
- ❌ Trust user input
- ❌ Logging sensitive data
- ❌ Skipping auth checks

---

## 10. Performance & Scalability

### المبدأ
الأداء القابل للتوسع يُصمم من البداية.

### التطبيق
- Database indexes مدروسة
- Caching استراتيجي
- Async processing للعمليات الثقيلة
- Pagination لكل list endpoints
- Rate limiting لحماية APIs
- Connection pooling
- Lazy loading للبيانات الكبيرة

### محظورات
- ❌ N+1 queries
- ❌ Loading all records in memory
- ❌ Synchronous external API calls في request path
- ❌ No pagination على large datasets

---

## 11. Type Safety & Validation

### المبدأ
النوعيات والتحقق مُعلنة وصارمة.

### التطبيق
- Python type hints في كل مكان
- Pydantic models للـ request/response
- Runtime validation للـ inputs
- Database constraints
- API schema validation

### محظورات
- ❌ Any types بدون سبب وجيه
- ❌ Missing type hints
- ❌ Trusting client input بدون validation
- ❌ Silent type coercion

---

## 12. Documentation & Comments

### المبدأ
الكود موثق بشكل واضح ومفيد.

### التطبيق
- Docstrings للدوال والكلاسات
- تعليقات تشرح "لماذا" وليس "ماذا"
- التعليقات بالعربية للشرح الوافي
- أسماء واضحة ومعبرة
- README لكل module/service
- Architecture decision records (ADRs)

### محظورات
- ❌ Comments تشرح الكود بوضوح
- ❌ TODOs بدون تاريخ أو مسؤول
- ❌ Documentation قديمة
- ❌ Files بدون docstring

---

## تطبيق المبادئ

### Code Review Checklist
- [ ] Multi-tenancy محمي (tenant_id في كل query)
- [ ] Events مُنتَجة للعمليات المهمة
- [ ] Idempotency مُطبَّقة
- [ ] AI decisions مسجلة
- [ ] Policy checks قبل messaging
- [ ] Traces/Metrics/Logs موجودة
- [ ] Types محددة
- [ ] Documentation كافية

### Architecture Decision Process
1. تحديد المشكلة
2. تقييم الخيارات المتاحة
3. اختيار الحل الأنسب للمبادئ
4. توثيق القرار في ADR
5. مراجعة مع الفريق
6. تنفيذ ومتابعة

---

**آخر تحديث**: 2024-01-XX  
**المالك**: Architecture Team  
**الحالة**: Active
