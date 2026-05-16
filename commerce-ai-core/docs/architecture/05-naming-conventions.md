# Commerce AI Core - Naming Conventions

## تسمية الملفات والمجلدات والكود

هذا يوثق conventions التسمية للمشروع بأكمله. الالتزام بهذه القواعد يسهل:
- القراءة والفهم
- البحث عن الملفات
- الصيانة
- التعاون بين الفريق

---

## 1. مجلدات المشروع (Directories)

### القاعدة العامة
- **snake_case** للمجلدات Python
- **kebab-case** للمجلدات غير Python
- أحرف صغيرة فقط (lowercase)

### أمثلة صحيحة ✅

```
commerce-ai-core/           # kebab-case (root project)
├── apps/
│   ├── webhook_gateway/    # snake_case (Python app)
│   └── workflow_worker/    # snake_case (Python app)
├── packages/
│   ├── customer360/        # snake_case (package name)
│   └── ai_engine/          # snake_case
├── docs/
│   └── architecture/       # lowercase
└── infra/
    └── docker/             # lowercase
```

### أمثلة خاطئة ❌

```
apps/webhook-gateway/       # ❌ kebab-case لـ Python app
apps/AI_Engine/             # ❌ uppercase
packages/Customer360/       # ❌ PascalCase
```

---

## 2. ملفات Python

### القاعدة
- **snake_case** لجميع ملفات Python
- أحرف صغيرة فقط

### أمثلة صحيحة ✅

```
customer_repository.py
audit_logger.py
event_publisher.py
tenant_guard.py
```

### أمثلة خاطئة ❌

```
CustomerRepository.py       # ❌ PascalCase
auditLogger.py              # ❌ camelCase
EVENT_PUBLISHER.py          # ❌ UPPER_CASE
```

---

## 3. كلاسات Python

### القاعدة
- **PascalCase** (CapWords) للكلاسات
- أسماء معبرة وقصيرة

### أمثلة صحيحة ✅

```python
class CustomerRepository:
    ...

class AuditLogger:
    ...

class EventPublisher:
    ...

class TenantGuard:
    ...
```

### أمثلة خاطئة ❌

```python
class customer_repository:    # ❌ snake_case
class Customerrepository:     # ❌ Missing capital
class IEventPublisher:        # ❌ Hungarian notation
```

---

## 4. دوال Python (Functions)

### القاعدة
- **snake_case** للدوال
- أفعال في البداية للأفعال

### أمثلة صحيحة ✅

```python
async def get_customer(customer_id):
    ...

async def create_campaign(data):
    ...

def validate_email(email):
    ...

async def send_whatsapp_message(...):
    ...
```

### أمثلة خاطئة ❌

```python
async def getCustomer(id):        # ❌ camelCase
async def CreateCampaign(data):   # ❌ PascalCase
def validator_email(email):       # ❌ ليس فعل
```

---

## 5. متغيرات Python (Variables)

### القاعدة
- **snake_case** للمتغيرات
- أسماء معبرة وليست مختصرة جدًا

### أمثلة صحيحة ✅

```python
customer_id = "cust_123"
tenant_context = get_tenant()
max_retries = 3
is_active = True
```

### أمثلة خاطئة ❌

```python
customerId = "cust_123"       # ❌ camelCase
cid = "cust_123"              # ❌ غامض جدًا
MAX_RETRIES = 3               # ❌ CONSTANT (ليس constant)
isActive = True               # ❌ camelCase
```

---

## 6. ثوابت Python (Constants)

### القاعدة
- **UPPER_SNAKE_CASE** للثوابت
- قيم لا تتغير خلال execution

### أمثلة صحيحة ✅

```python
MAX_RETRIES = 3
DEFAULT_PAGE_SIZE = 20
WHATSAPP_API_VERSION = "v18.0"
DATABASE_URL = os.getenv("DATABASE_URL")
```

### أمثلة خاطئة ❌

```python
max_retries = 3               # ❌ snake_case
MaxRetries = 3                # ❌ PascalCase
MAXRETRIES = 3                # ❌ No underscore
```

---

## 7. ملفات TypeScript/JavaScript

### القاعدة
- **kebab-case** لملفات components
- **camelCase** لملفات utilities
- **PascalCase** لملفات types/interfaces

### أمثلة صحيحة ✅

```
components/
├── customer-table.tsx        # kebab-case (component)
├── message-bubble.tsx        # kebab-case (component)
└── campaign-wizard.tsx       # kebab-case (component)

lib/
├── api-client.ts             # camelCase (utility)
├── format-date.ts            # camelCase (utility)
└── utils.ts                  # camelCase (utility)

types/
├── Customer.ts               # PascalCase (type)
├── Campaign.ts               # PascalCase (type)
└── index.ts                  # barrel export
```

---

## 8. API Endpoints

### القاعدة
- **kebab-case** للـ URL paths
- **plural nouns** للـ resources
- **lowercase** فقط

### أمثلة صحيحة ✅

```
GET    /api/v1/customers
POST   /api/v1/campaigns
GET    /api/v1/customer-messages
PUT    /api/v1/retention-campaigns/{id}
DELETE /api/v1/integrations/zoho
```

### أمثلة خاطئة ❌

```
GET  /api/v1/Customer          # ❌ uppercase
GET  /api/v1/customer          # ❌ singular (should be plural)
POST /api/v1/createCampaign    # ❌ verb in path
GET  /api/v1/customerMessages  # ❌ camelCase in path
```

---

## 9. Database Tables

### القاعدة
- **snake_case** لأسماء الجداول
- **plural nouns** للجداول
- أحرف صغيرة

### أمثلة صحيحة ✅

```sql
CREATE TABLE customers (...);
CREATE TABLE tenant_modules (...);
CREATE TABLE ai_decisions (...);
CREATE TABLE message_templates (...);
```

### أمثلة خاطئة ❌

```sql
CREATE TABLE Customer (...);      # ❌ PascalCase
CREATE TABLE customer (...);      # ❌ singular
CREATE TABLE tenantModules (...); # ❌ camelCase
```

---

## 10. Database Columns

### القاعدة
- **snake_case** للأعمدة
- أسماء معبرة

### أمثلة صحيحة ✅

```sql
tenant_id
customer_id
created_at
updated_at
is_active
total_orders
```

### أمثلة خاطئة ❌

```sql
tenantId          # ❌ camelCase
CustomerId        # ❌ PascalCase
createdat         # ❌ no underscore
isactive          # ❌ no underscore
cnt               # ❌ مختصر جدًا
```

---

## 11. Events

### القاعدة
- **snake_case** مع فعل ومفعول
- زمن الماضي للأحداث التي وقعت

### أمثلة صحيحة ✅

```
customer.created
order.completed
message.sent
campaign.started
payment.failed
```

### أمثلة خاطئة ❌

```
customerCreated       # ❌ camelCase
CUSTOMER_CREATED      # ❌ uppercase
create_customer       # ❌ present tense
customer_create       # ❌ wrong order
```

---

## 12. Environment Variables

### القاعدة
- **UPPER_SNAKE_CASE**
- بادئات للخدمات

### أمثلة صحيحة ✅

```bash
DATABASE_URL
REDIS_HOST
WHATSAPP_API_KEY
SHOPIFY_APP_ID
ZOHOCRM_CLIENT_ID
TEMPORAL_HOST
OPENAI_API_KEY
```

### أمثلة خاطئة ❌

```bash
databaseUrl           # ❌ camelCase
whatsappApiKey        # ❌ camelCase
DATABASE-URL          # ❌ kebab-case
```

---

## 13. Git Branches

### القاعدة
- **kebab-case** للفروع
- بادئات لنوع الفرع

### أمثلة صحيحة ✅

```
feature/retention-module
bugfix/webhook-signature
hotfix/tenant-isolation
release/v1.0.0
main
develop
```

### أمثلة خاطئة ❌

```
feature/retentionModule     # ❌ camelCase
bugfix/WebhookSignature     # ❌ PascalCase
main-branch                 # ❌ no prefix
```

---

## 14. Commits Messages

### القاعدة
- صيغة imperative
- بادئة لنوع التغيير

### أمثلة صحيحة ✅

```
feat: add retention campaign API
fix: resolve tenant isolation bug
docs: update architecture diagrams
test: add integration tests for webhooks
refactor: extract messaging policy engine
chore: update dependencies
```

### أمثلة خاطئة ❌

```
Added retention API         # ❌ past tense
FIXED bug                   # ❌ all caps
update stuff                # ❌ vague
```

---

## 15. Docker Images

### القاعدة
- **kebab-case** لأسماء images
- lowercase فقط

### أمثلة صحيحة ✅

```
commerce-ai-core-api:latest
commerce-ai-core-web:1.0.0
commerce-ai-core-worker:latest
```

### أمثلة خاطئة ❌

```
commerceAiCoreApi           # ❌ camelCase
Commerce-AI-Core-API        # ❌ uppercase
```

---

## 16. Prompts & Templates

### القاعدة
- **snake_case** لأسماء prompts
- وصف واضح للنسخة

### أمثلة صحيحة ✅

```
prompts/
├── customer_analysis_v1.txt
├── retention_decision_v2.txt
└── message_personalization_v1.txt
```

### أمثلة خاطئة ❌

```
prompts/
├── CustomerAnalysis.txt    # ❌ PascalCase
├── customer-analysis.txt   # ❌ kebab-case
└── prompt1.txt             # ❌ غير واضح
```

---

## 17. Test Files

### القاعدة
- بادئة `test_` لملفات الاختبار
- نفس اسم الملف الأصلي

### أمثلة صحيحة ✅

```
customer_repository.py       → test_customer_repository.py
auth_service.py              → test_auth_service.py
test_integration_auth.py     → integration tests
test_e2e_campaign.py         → e2e tests
```

### أمثلة خاطئة ❌

```
customerRepository_test.py   # ❌ wrong position
TestCustomerRepository.py    # ❌ PascalCase
customer_tests.py            # ❌ not specific
```

---

## 18. Configuration Files

### القاعدة
- أسماء معيارية معروفة
- YAML/TOML حسب الحاجة

### أمثلة صحيحة ✅

```
pyproject.toml               # Python project config
alembic.ini                  # Alembic config
docker-compose.dev.yml       # Docker Compose
tsconfig.json                # TypeScript config
tailwind.config.ts           # Tailwind config
```

### أمثلة خاطئة ❌

```
python-config.toml           # ❌ non-standard
docker-compose.yaml          # ❌ should be .yml
config.json                  # ❌ too generic
```

---

## ملخص سريع

| العنصر | Convention | مثال |
|--------|-----------|------|
| مجلدات Python | snake_case | `apps/webhook_gateway` |
| مجلدات أخرى | kebab-case | `infra/docker` |
| ملفات Python | snake_case | `customer_repository.py` |
| كلاسات | PascalCase | `CustomerRepository` |
| دوال | snake_case | `get_customer` |
| متغيرات | snake_case | `customer_id` |
| ثوابت | UPPER_SNAKE_CASE | `MAX_RETRIES` |
| Components TSX | kebab-case | `customer-table.tsx` |
| API endpoints | kebab-case | `/api/v1/customers` |
| Database tables | snake_case (plural) | `customers` |
| Events | snake_case (past) | `customer.created` |
| Env vars | UPPER_SNAKE_CASE | `DATABASE_URL` |
| Git branches | kebab-case | `feature/retention-module` |

---

**آخر تحديث**: 2024-01-XX  
**المالك**: Architecture Team  
**الحالة**: Active  
**الإلزامية**: Required
