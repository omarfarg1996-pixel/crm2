# 🚀 Commerce AI Core

**SaaS Platform for AI Commerce Automation**

منصة SaaS احترافية قابلة للتوسع لبناء خدمات AI Commerce Automation لمتاجر التجارة الإلكترونية.

---

## 📋 نظرة عامة

Commerce AI Core هو منصة SaaS مصممة خصيصًا لمتاجر:
- **Cash on Delivery (COD)**
- **WhatsApp-first commerce**
- **Zoho CRM users**
- **Shopify / WooCommerce stores**
- **Facebook Ads advertisers**
- **فرق المبيعات وخدمة العملاء**

### أول خدمة: Retention & Re-Selling Module
سيتم بناؤها لاحقاً على هذه النواة الصلبة.

### خدمات مستقبلية:
- Customer Support AI
- Follow-up Automation
- Order Confirmation AI
- Live Call AI
- Ads Intelligence
- Shipping Recovery
- Loyalty Program
- Review Collection
- Inventory Campaigns
- Sales Copilot
- Customer Risk Scoring

---

## 🏗️ البنية المعمارية

```
┌─────────────────────────────────────────────────────────────┐
│                      Frontend (Next.js)                      │
│                         Port 3000                            │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌─────────────────┐   ┌───────────────┐
│     API       │   │  Webhook Gateway│   │   AI Engine   │
│   FastAPI     │   │    FastAPI      │   │  LangGraph    │
│   Port 8000   │   │    Port 8002    │   │   Port 8001   │
└───────────────┘   └─────────────────┘   └───────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌─────────────────┐   ┌───────────────┐
│    Worker     │   │Workflow Worker  │   │   PostgreSQL  │
│    Celery     │   │   Temporal      │   │               │
└───────────────┘   └─────────────────┘   └───────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌─────────────────┐   ┌───────────────┐
│     Redis     │   │     Qdrant      │   │     MinIO     │
│               │   │   Vector DB     │   │   Object Store│
└───────────────┘   └─────────────────┘   └───────────────┘
```

---

## 🛠️ Tech Stack

### Backend
- **Python 3.12+** - لغة البرمجة الرئيسية
- **FastAPI** - Web framework
- **SQLAlchemy 2.x** - ORM
- **Alembic** - Database migrations
- **Pydantic v2** - Validation & serialization
- **PostgreSQL** - قاعدة البيانات الرئيسية
- **Redis** - Caching & task queues
- **Temporal** - Durable workflow execution

### Frontend
- **Next.js** - React framework
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling
- **shadcn/ui** - UI components
- **TanStack Query** - Data fetching
- **Recharts** - Charts & visualization

### AI
- **LangGraph** - AI workflows
- **LangChain Tools** - LLM tools
- **Qdrant** - Vector memory
- **Structured JSON outputs** - Reliable AI responses

### Infrastructure
- **Docker Compose** - Local development
- **MinIO** - S3-compatible storage
- **OpenTelemetry** - Observability
- **Prometheus + Grafana** - Monitoring
- **Loki** - Log aggregation

### Integrations
- **Shopify GraphQL** - E-commerce platform
- **WooCommerce REST** - Legacy support
- **Zoho CRM API v8** - CRM integration
- **WhatsApp Business API** - Messaging

---

## 📁 هيكل المشروع

```
commerce-ai-core/
├── apps/                    # التطبيقات الرئيسية
│   ├── web/                 # Next.js frontend
│   ├── api/                 # FastAPI backend
│   ├── worker/              # Celery background jobs
│   ├── workflow_worker/     # Temporal workflows
│   ├── ai_engine/           # LangGraph runtime
│   └── webhook_gateway/     # External webhooks
├── packages/                # الحزم المشتركة
│   ├── core/                # Core utilities
│   ├── database/            # Database models & migrations
│   ├── events/              # Event definitions
│   ├── data/                # Data processing
│   ├── connectors/          # External integrations
│   ├── messaging/           # Message handling
│   ├── workflows/           # Workflow definitions
│   ├── ai/                  # AI utilities
│   ├── modules/             # Feature modules
│   ├── observability/       # Logging, metrics, tracing
│   └── shared/              # Shared types & utils
├── infra/                   # Infrastructure configs
│   ├── docker/              # Dockerfiles
│   ├── postgres/            # PostgreSQL configs
│   ├── redis/               # Redis configs
│   ├── temporal/            # Temporal configs
│   ├── qdrant/              # Qdrant configs
│   ├── minio/               # MinIO configs
│   ├── observability/       # Prometheus, Grafana, Loki
│   ├── kubernetes/          # K8s manifests
│   └── terraform/           # Terraform configs
├── requirements/            # Python dependencies
├── scripts/                 # Utility scripts
├── tests/                   # Test suites
├── docs/                    # Documentation
└── docker-compose*.yml      # Docker compose files
```

---

## 🚀 البدء السريع

### المتطلبات المسبقة
- Docker & Docker Compose
- Python 3.12+
- Node.js 20+
- pnpm 9+

### التطوير المحلي

```bash
# استنساخ المستودع
git clone <repository-url>
cd commerce-ai-core

# نسخ ملف البيئة
cp .env.example .env

# تشغيل جميع الخدمات
make dev

# الانتظار 30 ثانية ثم فحص الصحة
make health

# عرض الـ API docs
open http://localhost:8000/docs

# عرض الـ Frontend
open http://localhost:3000

# عرض Temporal UI
open http://localhost:8233

# عرض Grafana
open http://localhost:3001
```

### إيقاف الخدمات

```bash
make stop
```

### تنظيف كامل

```bash
make clean
```

---

## 📊 حالة المرحلة الحالية

### ✅ Phase 01 - Project Constitution
- Research report مكتمل
- Architecture principles محددة
- Folder structure معرّف
- Module contract موضّح

### ✅ Phase 02 - Clean Monorepo Skeleton
- Root configs مكتملة
- Apps skeletons موجودة
- Packages boundaries معرّفة
- Docker configuration جاهزة

### 🔜 المراحل القادمة
- Phase 03: Database Foundation
- Phase 04: Events & Audit System
- Phase 05: Authentication & Tenants
- ... (راجع docs/progress/)

---

## 📖 التوثيق

- [Architecture Principles](docs/architecture/)
- [Research Report](docs/research/00-research-report.md)
- [Progress Reports](docs/progress/)
- [Runbooks](docs/runbooks/)

---

## 🧪 الاختبار

```bash
# تشغيل جميع الاختبارات
make test

# Unit tests فقط
make test-unit

# Integration tests فقط
make test-integration

# E2E tests فقط
make test-e2e

# مع coverage report
make test-coverage
```

---

## 🔒 الأمان

- Multi-tenant isolation من أول يوم
- JWT authentication
- Role-based access control (RBAC)
- Audit logging شامل
- Webhook signature verification
- Secrets management

راجع [Security Documentation](docs/security/) للتفاصيل.

---

## 📝 الترخيص

Proprietary - جميع الحقوق محفوظة.

---

## 👥 الفريق

Commerce AI Core Team

---

## 📞 الدعم

للأسئلة والدعم، يرجى فتح issue في المستودع.
