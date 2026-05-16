# Commerce AI Core - Folder Structure

## الهيكل النهائي للمشروع

```
commerce-ai-core/
├── README.md                    # نظرة عامة على المشروع
├── Makefile                     # Commands شائعة
├── .env.example                 # Environment variables template
├── .gitignore                   # Git ignore rules
├── .dockerignore                # Docker ignore rules
├── docker-compose.dev.yml       # Development environment
├── docker-compose.observability.yml  # Observability stack
├── pyproject.toml               # Python project config
├── package.json                 # Root package.json
├── pnpm-workspace.yaml          # PNPM workspaces config
├── turbo.json                   # Turborepo config
│
├── requirements/                # Python dependencies
│   ├── api.txt                  # API dependencies
│   ├── worker.txt               # Background worker dependencies
│   ├── workflow-worker.txt      # Temporal worker dependencies
│   ├── ai-engine.txt            # AI engine dependencies
│   ├── webhook-gateway.txt      # Webhook gateway dependencies
│   └── dev.txt                  # Development dependencies
│
├── apps/                        # تطبيقات قابلة للتشغيل
│   ├── web/                     # Next.js frontend
│   │   ├── package.json
│   │   ├── next.config.js
│   │   ├── tsconfig.json
│   │   ├── tailwind.config.ts
│   │   ├── postcss.config.js
│   │   ├── components.json
│   │   ├── Dockerfile
│   │   └── src/
│   │       ├── app/             # Next.js app router pages
│   │       ├── components/      # React components
│   │       ├── lib/             # Utilities
│   │       └── types/           # TypeScript types
│   │
│   ├── api/                     # FastAPI backend
│   │   ├── Dockerfile
│   │   ├── alembic.ini          # Alembic migrations config
│   │   ├── alembic/             # Database migrations
│   │   └── app/
│   │       ├── __init__.py
│   │       ├── main.py          # FastAPI app entry
│   │       ├── config.py        # Configuration
│   │       ├── middleware/      # FastAPI middleware
│   │       ├── routes/          # API endpoints
│   │       ├── services/        # Business logic
│   │       ├── repositories/    # Data access
│   │       └── schemas/         # Pydantic models
│   │
│   ├── worker/                  # Background jobs worker
│   │   ├── Dockerfile
│   │   └── app/
│   │       ├── __init__.py
│   │       └── main.py
│   │
│   ├── workflow_worker/         # Temporal workflows worker
│   │   ├── Dockerfile
│   │   └── app/
│   │       ├── __init__.py
│   │       ├── main.py          # Temporal worker entry
│   │       ├── client.py        # Temporal client
│   │       ├── registry.py      # Workflow registry
│   │       ├── workflows/       # Workflow definitions
│   │       └── activities/      # Activity implementations
│   │
│   ├── ai_engine/               # AI/ML engine
│   │   ├── Dockerfile
│   │   └── app/
│   │       ├── __init__.py
│   │       ├── main.py          # FastAPI for AI
│   │       ├── config.py
│   │       ├── router.py
│   │       ├── runtime.py       # LangGraph runtime
│   │       ├── routes/          # AI endpoints
│   │       ├── schemas/         # AI schemas
│   │       ├── graphs/          # LangGraph definitions
│   │       ├── nodes/           # Graph nodes
│   │       ├── tools/           # AI tools
│   │       ├── prompts/         # Prompt templates
│   │       ├── evals/           # Evaluation tests
│   │       └── policies/        # AI policies
│   │
│   └── webhook_gateway/         # Webhook ingestion service
│       ├── Dockerfile
│       └── app/
│           ├── __init__.py
│           ├── main.py          # Webhook server
│           ├── config.py
│           ├── router.py
│           ├── providers/       # Provider-specific handlers
│           ├── services/        # Ingestion logic
│           └── schemas/         # Webhook schemas
│
├── packages/                    # مكتبات مشتركة
│   ├── core/                    # Core business logic
│   │   ├── __init__.py
│   │   ├── tenancy/             # Multi-tenancy support
│   │   ├── identity/            # Authentication
│   │   ├── permissions/         # Authorization (RBAC)
│   │   ├── audit/               # Audit logging
│   │   ├── usage/               # Usage metering
│   │   └── billing/             # Billing support
│   │
│   ├── database/                # Database layer
│   │   ├── __init__.py
│   │   ├── base.py              # Base model
│   │   ├── session.py           # DB session management
│   │   ├── engine.py            # DB engine setup
│   │   ├── mixins.py            # Model mixins
│   │   ├── types.py             # Custom DB types
│   │   ├── tenant_guard.py      # Tenant isolation guard
│   │   ├── transaction.py       # Transaction management
│   │   ├── models/              # SQLAlchemy models
│   │   └── repositories/        # Base repositories
│   │
│   ├── events/                  # Event system
│   │   ├── __init__.py
│   │   ├── base.py              # Base event class
│   │   ├── event_types.py       # Event type definitions
│   │   ├── publisher.py         # Event publisher
│   │   ├── subscriber.py        # Event subscriber
│   │   ├── bus.py               # Event bus
│   │   ├── store.py             # Event store
│   │   ├── replay.py            # Event replay
│   │   ├── dead_letter.py       # Dead letter queue
│   │   ├── idempotency.py       # Idempotency handling
│   │   ├── schemas/             # Event schemas
│   │   └── consumers/           # Event consumers
│   │
│   ├── data/                    # Data services
│   │   ├── __init__.py
│   │   ├── customer360/         # Customer data unification
│   │   └── commerce/            # Commerce data (products, orders)
│   │
│   ├── connectors/              # External integrations
│   │   ├── __init__.py
│   │   ├── base/                # Base connector interface
│   │   ├── zoho/                # Zoho CRM connector
│   │   ├── shopify/             # Shopify connector
│   │   ├── woocommerce/         # WooCommerce connector
│   │   └── whatsapp/            # WhatsApp provider abstraction
│   │
│   ├── messaging/               # Messaging layer
│   │   ├── __init__.py
│   │   ├── providers/           # Message providers
│   │   ├── templates/           # Template management
│   │   ├── conversations/       # Conversation management
│   │   └── policies/            # Messaging policies
│   │
│   ├── workflows/               # Workflow definitions
│   │   ├── __init__.py
│   │   ├── client.py            # Workflow client
│   │   ├── registry.py          # Workflow registry
│   │   ├── workflow_ids.py      # Workflow ID constants
│   │   ├── task_queues.py       # Task queue names
│   │   ├── status.py            # Workflow status types
│   │   ├── definitions/         # Workflow definitions
│   │   ├── activities/          # Shared activities
│   │   ├── human_approval/      # Approval workflows
│   │   └── schedules/           # Scheduled workflows
│   │
│   ├── ai/                      # AI shared libraries
│   │   ├── __init__.py
│   │   ├── graphs/              # Shared graph components
│   │   ├── agents/              # Agent definitions
│   │   ├── tools/               # Shared tools
│   │   ├── prompts/             # Shared prompts
│   │   ├── policies/            # AI policies
│   │   ├── evals/               # Evaluation utilities
│   │   └── memory/              # Vector memory
│   │
│   ├── modules/                 # Module system
│   │   ├── __init__.py
│   │   ├── base/                # Base module classes
│   │   ├── retention/           # Retention module
│   │   ├── support_ai/          # Support AI module (future)
│   │   ├── follow_up/           # Follow-up module (future)
│   │   └── ...                  # Other modules
│   │
│   ├── observability/           # Observability layer
│   │   ├── __init__.py
│   │   ├── logging.py           # Logging setup
│   │   ├── metrics.py           # Metrics collection
│   │   ├── tracing.py           # Distributed tracing
│   │   ├── context.py           # Context propagation
│   │   ├── error_tracking.py    # Error tracking
│   │   ├── health.py            # Health checks
│   │   └── dashboards.py        # Dashboard definitions
│   │
│   └── shared/                  # Shared utilities
│       ├── __init__.py
│       ├── utils.py             # General utilities
│       ├── errors.py            # Custom exceptions
│       ├── constants.py         # Constants
│       └── types.py             # Shared types
│
├── infra/                       # Infrastructure as Code
│   ├── docker/                  # Dockerfiles
│   │   ├── api.Dockerfile
│   │   ├── web.Dockerfile
│   │   ├── worker.Dockerfile
│   │   ├── workflow-worker.Dockerfile
│   │   ├── ai-engine.Dockerfile
│   │   └── webhook-gateway.Dockerfile
│   │
│   ├── postgres/                # PostgreSQL config
│   │   ├── extensions.sql
│   │   └── init.sql
│   │
│   ├── redis/                   # Redis config
│   │   └── redis.conf
│   │
│   ├── temporal/                # Temporal config
│   │   ├── dynamicconfig/
│   │   │   └── development.yaml
│   │   └── README.md
│   │
│   ├── qdrant/                  # Qdrant config
│   │   ├── config.yaml
│   │   └── README.md
│   │
│   ├── minio/                   # MinIO (S3-compatible) config
│   │   ├── create-buckets.sh
│   │   └── README.md
│   │
│   ├── observability/           # Observability stack
│   │   ├── prometheus/
│   │   │   └── prometheus.yml
│   │   ├── grafana/
│   │   │   ├── dashboards/
│   │   │   └── provisioning/
│   │   ├── loki/
│   │   │   └── loki-config.yml
│   │   └── otel/
│   │       └── otel-collector-config.yml
│   │
│   ├── kubernetes/              # Kubernetes manifests (future)
│   └── terraform/               # Terraform configs (future)
│
├── scripts/                     # Utility scripts
│   ├── dev.sh                   # Start development environment
│   ├── stop.sh                  # Stop all services
│   ├── health.sh                # Health check script
│   ├── reset.sh                 # Reset development environment
│   ├── migrate.sh               # Run database migrations
│   ├── reset-db.sh              # Reset database
│   ├── create-migration.sh      # Create new migration
│   ├── clean.sh                 # Clean build artifacts
│   ├── lint.sh                  # Run linters
│   ├── format.sh                # Format code
│   ├── typecheck.sh             # Type checking
│   ├── test.sh                  # Run all tests
│   ├── test-unit.sh             # Run unit tests
│   ├── test-integration.sh      # Run integration tests
│   ├── test-e2e.sh              # Run e2e tests
│   ├── test-ai-evals.sh         # Run AI evaluations
│   ├── build.sh                 # Build all services
│   ├── smoke-test.sh            # Smoke tests
│   ├── backup-db.sh             # Backup database
│   ├── restore-db.sh            # Restore database
│   ├── check-phase01.sh         # Phase 01 validation
│   └── check-phase02.sh         # Phase 02 validation
│
├── docs/                        # Documentation
│   ├── architecture/            # Architecture documentation
│   │   ├── 00-product-vision.md
│   │   ├── 01-architecture-principles.md
│   │   ├── 02-folder-structure.md
│   │   ├── 03-module-contract.md
│   │   ├── 04-production-rules.md
│   │   ├── 05-naming-conventions.md
│   │   ├── 06-definition-of-done.md
│   │   ├── 07-release-gates.md
│   │   ├── 08-risk-register.md
│   │   ├── 09-ai-governance.md
│   │   └── 10-messaging-governance.md
│   │
│   ├── research/                # Research reports
│   │   └── 00-research-report.md
│   │
│   ├── progress/                # Progress reports per phase
│   │   ├── phase-01-report.md
│   │   ├── phase-02-report.md
│   │   └── ...
│   │
│   ├── security/                # Security documentation
│   │   ├── security-model.md
│   │   ├── tenant-isolation.md
│   │   ├── secrets-management.md
│   │   ├── webhook-security.md
│   │   ├── data-retention.md
│   │   ├── audit-logging.md
│   │   └── incident-response.md
│   │
│   ├── onboarding/              # Onboarding guides
│   │   ├── first-tenant.md
│   │   ├── import-customers.md
│   │   ├── create-first-retention-campaign.md
│   │   └── pilot-checklist.md
│   │
│   └── runbooks/                # Operational runbooks
│       ├── webhook-failures.md
│       ├── provider-down.md
│       ├── zoho-token-expired.md
│       ├── shopify-sync-failed.md
│       ├── whatsapp-message-failed.md
│       ├── workflow-stuck.md
│       ├── temporal-worker-failed.md
│       ├── ai-cost-spike.md
│       ├── message-delivery-drop.md
│       ├── duplicate-customers.md
│       ├── wrong-recommendation-sent.md
│       └── tenant-data-leak-investigation.md
│
├── tests/                       # Test suites
│   ├── __init__.py
│   ├── conftest.py              # Pytest configuration
│   ├── fixtures/                # Test fixtures
│   │   ├── tenants.json
│   │   ├── customers.json
│   │   ├── products.json
│   │   ├── orders.json
│   │   ├── campaigns.json
│   │   └── whatsapp_webhooks.json
│   │
│   ├── unit/                    # Unit tests
│   │   ├── core/
│   │   ├── events/
│   │   ├── connectors/
│   │   ├── messaging/
│   │   ├── ai/
│   │   └── modules/
│   │
│   ├── integration/             # Integration tests
│   │   ├── test_auth_flow.py
│   │   ├── test_tenant_isolation.py
│   │   ├── test_webhook_ingestion.py
│   │   ├── test_workflow_start.py
│   │   └── ...
│   │
│   ├── e2e/                     # End-to-end tests
│   │   ├── test_first_tenant_flow.py
│   │   ├── test_customer360_flow.py
│   │   ├── test_retention_pilot_flow.py
│   │   └── test_campaign_approval_send_reply_flow.py
│   │
│   └── ai_evals/                # AI evaluation tests
│       ├── test_message_quality.py
│       ├── test_reply_classification.py
│       ├── test_no_fake_discount.py
│       ├── test_product_must_exist.py
│       └── test_risky_customer_requires_approval.py
│
└── .github/                     # GitHub configurations
    ├── workflows/               # CI/CD workflows
    │   ├── ci.yml
    │   ├── cd.yml
    │   └── release.yml
    └── ISSUE_TEMPLATE/          # Issue templates
        ├── bug_report.md
        └── feature_request.md
```

---

## قواعد الهيكل

### 1. فصل التطبيقات عن المكتبات

**apps/**: تحتوي على تطبيقات قابلة للتشغيل بشكل مستقل
- كل app له Dockerfile خاص
- كل app يمكن تشغيله بشكل منفصل
- أمثلة: web, api, worker, ai_engine, webhook_gateway

**packages/**: مكتبات مشتركة غير قابلة للتشغيل مباشرة
- تُستخدَم من قبل apps
- لا تحتوي على entry points
- أمثلة: core, database, events, connectors

### 2. تسمية المجلدات

**صحيح:**
- `apps/ai_engine` (underscore)
- `apps/workflow_worker` (underscore)
- `apps/webhook_gateway` (underscore)

**خطأ:**
- `apps/ai-engine` (hyphen) ❌
- `apps/temporal-worker` (غير موحد) ❌
- `apps/api/src` (duplicate path) ❌

### 3. عدم وجود duplicate runtime paths

ممنوع تمامًا:
- `apps/api/app` + `apps/api/src` معًا
- `apps/ai-engine` + `apps/ai_engine` معًا
- أي مجلدين يؤديان لنفس الغرض

### 4. هيكل كل تطبيق Python

```
apps/{app_name}/
├── Dockerfile
└── app/
    ├── __init__.py
    ├── main.py          # Entry point
    ├── config.py        # Configuration
    ├── routes/          # Endpoints (إذا كان API)
    ├── services/        # Business logic
    ├── repositories/    # Data access
    └── schemas/         # Pydantic models
```

### 5. هيكل كل package

```
packages/{package_name}/
├── __init__.py
├── module1.py
├── module2.py
└── subpackage/
    ├── __init__.py
    └── ...
```

### 6. ملفات مطلوبة في كل مجلد

- `__init__.py` للمجلدات Python
- `README.md` للمجلدات الكبيرة
- لا توجد مجلدات فارغة

### 7. ملفات الاختبار

تتبع نفس هيكل الكود:
```
tests/unit/core/tenancy/test_tenant_context.py
tests/integration/test_auth_flow.py
tests/e2e/test_first_tenant_flow.py
```

---

## ملاحظات هامة

1. **لا ملفات فارغة**: إذا كان الملف placeholder، يجب أن يحتوي على شرح
2. **لا __pycache__**: يُضاف لـ .gitignore
3. **لا secrets في الكود**: كلها عبر environment variables
4. **التعليقات بالعربية**: للشرح الوافي داخل الكود
5. **الأسماء بالإنجليزية**: للكلاسات والدوال والمتغيرات

---

**آخر تحديث**: 2024-01-XX  
**المالك**: Architecture Team  
**الحالة**: Active
