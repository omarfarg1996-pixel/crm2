# Commerce AI Core - Production Rules

## قواعد التشغيل في بيئة الإنتاج

هذا يوثق القواعد الإلزامية للتشغيل في بيئة الإنتاج. مخالفة هذه القواعد قد تؤدي إلى:
- تسرب بيانات بين tenants
- توقف الخدمة
- فقدان البيانات
- خروقات أمنية

---

## 1. Multi-Tenancy Rules

### قاعدة 1.1: tenant_id إلزامي
كل query يجب أن يحتوي على `WHERE tenant_id = ?`

```python
# صحيح ✅
customers = await db.execute(
    select(Customer).where(Customer.tenant_id == tenant_id)
)

# خطأ ❌
customers = await db.execute(select(Customer))  # Missing tenant_id!
```

### قاعدة 1.2: لا shared state
ممنوع تخزين بيانات tenant في متغيرات global:

```python
# خطأ ❌
_current_tenant_data = None  # Shared state!

async def get_tenant_data():
    global _current_tenant_data
    return _current_tenant_data

# صحيح ✅
async def get_tenant_data(tenant_id: str):
    return await tenant_repository.get_by_id(tenant_id)
```

### قاعدة 1.3: Cache keys prefixed
كل cache key يجب أن يبدأ بـ `tenant:{id}:`

```python
# صحيح ✅
cache_key = f"tenant:{tenant_id}:customer:{customer_id}"
await redis.set(cache_key, data)

# خطأ ❌
cache_key = f"customer:{customer_id}"  # No tenant prefix!
```

---

## 2. Database Rules

### قاعدة 2.1: كل writes عبر Alembic
ممنوع تعديل schema بدون migration:

```bash
# صحيح ✅
alembic revision --autogenerate -m "Add customer scores"
alembic upgrade head

# خطأ ❌
# تعديل مباشر في database
ALTER TABLE customers ADD COLUMN score INTEGER;
```

### قاعدة 2.2: Indexes على tenant_id
كل جدول tenant-specific يجب أن يحتوي index على tenant_id:

```python
# صحيح ✅
__table_args__ = (
    Index('ix_customers_tenant_id', 'tenant_id'),
    Index('ix_customers_tenant_email', 'tenant_id', 'email'),
)

# خطأ ❌
# لا indexes على tenant_id
```

### قاعدة 2.3: Transactions للعمليات المتعددة
أي عملية تعدّل أكثر من جدول يجب أن تكون في transaction:

```python
# صحيح ✅
async with db.transaction():
    await create_customer(data)
    await create_audit_log(...)
    await publish_event(...)

# خطأ ❌
await create_customer(data)  # قد يفشل التالي
await create_audit_log(...)  # ولا rollback
```

---

## 3. API Rules

### قاعدة 3.1: Authentication مطلوب
كل endpoint يحتاج authentication إلا ما تم استثناؤه صراحةً:

```python
# صحيح ✅
@router.get("/customers")
async def list_customers(user: User = Depends(get_current_user)):
    ...

# خطأ ❌
@router.get("/customers")  # No auth!
async def list_customers():
    ...
```

### قاعدة 3.2: Input validation
كل input يجب validateه باستخدام Pydantic:

```python
# صحيح ✅
class CreateCustomerRequest(BaseModel):
    email: EmailStr
    phone: str
    name: str

async def create_customer(req: CreateCustomerRequest):
    ...

# خطأ ❌
async def create_customer(email: str, phone: str, name: str):
    # لا validation
```

### قاعدة 3.3: Error handling
كل exception يجب التعامل معها وإرجاع error مناسب:

```python
# صحيح ✅
try:
    customer = await get_customer(customer_id)
except NotFoundError:
    raise HTTPException(status_code=404, detail="Customer not found")
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    raise HTTPException(status_code=500, detail="Internal server error")

# خطأ ❌
customer = await get_customer(customer_id)  # قد يسبب crash
```

---

## 4. Messaging Rules

### قاعدة 4.1: Policy check قبل الإرسال
ممنوع إرسال أي رسالة بدون policy check:

```python
# صحيح ✅
policy_result = await policy_engine.check(
    tenant_id=tenant_id,
    customer_id=customer_id,
    message_type="marketing"
)

if policy_result.allowed:
    await send_message(...)
else:
    logger.info(f"Message blocked: {policy_result.reason}")

# خطأ ❌
await send_message(...)  # No policy check!
```

### قاعدة 4.2: Idempotency للإرسال
كل رسالة يجب أن يكون لها idempotency key:

```python
# صحيح ✅
idempotency_key = f"msg:{tenant_id}:{campaign_id}:{customer_id}"
if await is_sent(idempotency_key):
    return previous_result

await send_message(...)
await mark_sent(idempotency_key)

# خطأ ❌
await send_message(...)  # قد يُرسل مرتين
```

### قاعدة 4.3: Template approval
Marketing templates يجب أن تكون pre-approved:

```python
# صحيح ✅
template = await get_template(template_id)
if template.category == "marketing" and not template.approved:
    raise ValueError("Marketing template not approved")

# خطأ ❌
# استخدام template بدون التحقق من approval
```

---

## 5. AI Rules

### قاعدة 5.1: AI decisions مسجلة
كل AI decision يجب أن يُحفظ في database:

```python
# صحيح ✅
decision = AIDecision(
    tenant_id=tenant_id,
    input=input_data,
    output=output_data,
    model=model_name,
    prompt_version=prompt_version
)
await db.add(decision)

# خطأ ❌
output = await ai_model.predict(input)  # No logging!
```

### قاعدة 5.2: Output validation
AI output يجب validateه قبل الاستخدام:

```python
# صحيح ✅
output = await ai_model.predict(input)
validated = ResponseSchema.model_validate(output)  # May raise ValidationError

# خطأ ❌
output = await ai_model.predict(input)
# استخدام output بدون validation
```

### قاعدة 5.3: Human approval للحالات الحرجة
بعض القرارات تحتاج human approval:

```python
# صحيح ✅
if decision.risk_score > 0.8:
    await request_approval(decision)
    return {"status": "pending_approval"}

# خطأ ❌
# AI يتخذ قرارات عالية المخاطر بدون مراجعة
```

---

## 6. Security Rules

### قاعدة 6.1: Secrets في environment variables
ممنوع hardcoding secrets:

```python
# صحيح ✅
DATABASE_URL = os.getenv("DATABASE_URL")
API_KEY = os.getenv("WHATSAPP_API_KEY")

# خطأ ❌
DATABASE_URL = "postgresql://user:password@localhost/db"  # Hardcoded!
```

### قاعدة 6.2: SQL parameters
ممنوع SQL concatenation:

```python
# صحيح ✅
await db.execute(
    select(Customer).where(Customer.email == email)
)

# خطأ ❌
query = f"SELECT * FROM customers WHERE email = '{email}'"  # SQL injection risk!
```

### قاعدة 6.3: Logging آمن
ممنوع logging sensitive data:

```python
# صحيح ✅
logger.info(f"User {user_id} logged in")

# خطأ ❌
logger.info(f"User login: email={email}, password={password}")  # Password in logs!
```

---

## 7. Observability Rules

### قاعدة 7.1: Structured logging
استخدام JSON logging في production:

```python
# صحيح ✅
logger.info("Customer created", extra={
    "tenant_id": tenant_id,
    "customer_id": customer_id,
    "action": "customer.created"
})

# خطأ ❌
print(f"Customer {customer_id} created")  # Not structured!
```

### قاعدة 7.2: Health endpoints
كل service يجب أن يحتوي health endpoint:

```python
# صحيح ✅
@app.get("/health")
async def health():
    return {"status": "healthy", "service": "api"}

# خطأ ❌
# لا health endpoint
```

### قاعدة 7.3: Metrics للأعمال المهمة
قياس الأعمال المهمة:

```python
# صحيح ✅
from prometheus_client import Counter

MESSAGE_SENT = Counter("messages_sent_total", "Total messages sent")

async def send_message(...):
    MESSAGE_SENT.inc()

# خطأ ❌
# لا metrics
```

---

## 8. Performance Rules

### قاعدة 8.1: Pagination للقوائم
كل list endpoint يجب أن يدعم pagination:

```python
# صحيح ✅
@router.get("/customers")
async def list_customers(page: int = 1, per_page: int = 20):
    offset = (page - 1) * per_page
    customers = await db.query(...).offset(offset).limit(per_page)

# خطأ ❌
@router.get("/customers")
async def list_customers():
    return await db.query(Customer).all()  # May return millions!
```

### قاعدة 8.2: Async للـ I/O operations
استخدام async للـ I/O:

```python
# صحيح ✅
async def fetch_customer(customer_id):
    return await db.query(...).one()

# خطأ ❌
def fetch_customer(customer_id):
    return db.query(...).one()  # Blocking!
```

### قاعدة 8.3: Connection pooling
استخدام connection pools:

```python
# صحيح ✅
engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,
    max_overflow=10
)

# خطأ ❌
# لا connection pooling
```

---

## 9. Deployment Rules

### قاعدة 9.1: Environment-specific configs
Configs مختلفة لكل environment:

```python
# صحيح ✅
if ENV == "production":
    LOG_LEVEL = "INFO"
    DEBUG = False
elif ENV == "development":
    LOG_LEVEL = "DEBUG"
    DEBUG = True

# خطأ ❌
# نفس config للجميع
```

### قاعدة 9.2: Graceful shutdown
التعامل مع shutdown بشكل صحيح:

```python
# صحيح ✅
@app.on_event("shutdown")
async def shutdown():
    await db.close()
    await redis.close()
    await temporal_client.close()

# خطأ ❌
# لا cleanup
```

### قاعدة 9.3: Rollback plan
يجب وجود خطة rollback:

```bash
# صحيح ✅
# قبل deployment
./scripts/backup-db.sh

# بعد deployment إذا فشل
./scripts/restore-db.sh backup-2024-01-XX.sql

# خطأ ❌
# deployment بدون backup
```

---

## 10. Incident Response Rules

### قاعدة 10.1: Alerting
Alerts للحوادث الحرجة:

```python
# صحيح ✅
if error_rate > 0.05:  # 5% error rate
    await send_alert("High error rate detected")

# خطأ ❌
# لا alerting
```

### قاعدة 10.2: Runbooks
توثيق procedures للتعامل مع الحوادث:

```markdown
# docs/runbooks/webhook-failures.md

## Symptoms
- Webhooks failing with 500 errors
- Dead letter queue growing

## Steps
1. Check webhook Gateway logs
2. Verify provider status
3. ...
```

### قاعدة 10.3: Post-mortems
تحليل الحوادث بعد الحل:

```markdown
# Post-mortem Template

## Incident Summary
- Date: ...
- Duration: ...
- Impact: ...

## Root Cause
...

## Action Items
- [ ] Fix ...
- [ ] Add monitoring ...
- [ ] Update runbook ...
```

---

## Enforcement

### Automated Checks

```bash
# scripts/check-production-rules.sh

#!/bin/bash

# Check for hardcoded secrets
if grep -r "password=" --include="*.py" apps/; then
    echo "❌ Found hardcoded passwords"
    exit 1
fi

# Check for missing tenant_id in queries
if grep -r "SELECT \* FROM" --include="*.py" apps/; then
    echo "❌ Found raw SQL without tenant_id"
    exit 1
fi

# Check for print statements
if grep -r "^print(" --include="*.py" apps/; then
    echo "❌ Found print statements"
    exit 1
fi

echo "✅ All production rules checks passed"
```

### Code Review Checklist

- [ ] tenant_id في كل query
- [ ] Authentication على كل endpoint
- [ ] Input validation
- [ ] Error handling
- [ ] Audit logging
- [ ] No hardcoded secrets
- [ ] No print statements
- [ ] Health endpoint موجود
- [ ] Tests مكتوبة

---

**آخر تحديث**: 2024-01-XX  
**المالك**: Architecture Team  
**الحالة**: Active  
**الإلزامية**: Required for production deployment
