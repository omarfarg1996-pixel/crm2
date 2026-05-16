# Commerce AI Core - Module Contract

## تعريف الـ Module

الـ **Module** هو وحدة وظيفية مستقلة تُضاف إلى المنصة لتقديم خدمة محددة.

### أمثلة على Modules
- Retention & Re-Selling Module
- Customer Support AI Module
- Follow-up Automation Module
- Order Confirmation AI Module
- Live Call AI Module
- Ads Intelligence Module

---

## هيكل Module القياسي

```
packages/modules/{module_name}/
├── module.yaml              # Manifest file (مطلوب)
├── README.md                # Documentation (مطلوب)
├── __init__.py              # Python package init
├── services/                # Business logic
│   ├── service1.py
│   └── service2.py
├── schemas/                 # Data models (Pydantic)
│   ├── requests.py
│   └── responses.py
├── policies/                # Policy rules
│   ├── module_policy.py
│   └── validation.py
├── events/                  # Event handlers
│   ├── handlers.py
│   └── event_types.py
├── workflows/               # Temporal workflows
│   ├── workflow1.py
│   └── workflow2.py
├── tests/                   # Module tests
│   ├── test_services.py
│   └── test_workflows.py
└── migrations/              # Database migrations (optional)
    └── 0001_module_init.py
```

---

## Module Manifest (module.yaml)

كل module يجب أن يحتوي على `module.yaml` بالتالي:

```yaml
# معرف module فريد
id: retention

# اسم module للقراءة
name: Retention & Re-Selling

# وصف module
description: |
  Automated retention campaigns for e-commerce stores.
  Analyzes customer behavior, recommends products, and sends
  personalized WhatsApp messages.

# إصدار module
version: 1.0.0

# الحالة: draft, beta, stable, deprecated
status: stable

# المؤلفون
authors:
  - name: Architecture Team
    email: architecture@commerceaicore.com

# Dependencies على modules أخرى (optional)
dependencies:
  - messaging
  - workflows

# Permissions المطلوبة
permissions:
  - customers:read
  - orders:read
  - products:read
  - messages:write
  - campaigns:write

# Events التي ينتجها module
produces_events:
  - campaign.created
  - campaign.started
  - campaign.completed
  - message.sent
  - revenue.attributed

# Events التي يستمع إليها module
consumes_events:
  - order.completed
  - customer.inactive
  - product.low_stock

# Workflows المسجلة
workflows:
  - retention_campaign_workflow
  - winback_workflow

# Settings قابلة للتكوين
settings:
  - name: default_approval_required
    type: boolean
    default: true
    description: Require human approval before sending messages
  
  - name: max_audience_size
    type: integer
    default: 10000
    description: Maximum number of customers in a campaign audience
  
  - name: ai_model
    type: string
    default: gpt-4
    description: AI model to use for recommendations

# Endpoints API التي يضيفها module (optional)
api_endpoints:
  - path: /api/v1/retention/campaigns
    methods: [GET, POST]
  
  - path: /api/v1/retention/campaigns/{id}
    methods: [GET, PUT, DELETE]

# UI routes التي يضيفها module (optional)
ui_routes:
  - path: /campaigns
    page: campaigns/page.tsx
  
  - path: /campaigns/new
    page: campaigns/new/page.tsx

# تاريخ الإصدار
release_date: 2024-01-XX

# ملاحظات الإصدار
release_notes: |
  Initial release of Retention Module.
  Includes audience building, scoring, recommendations,
  and WhatsApp campaign automation.
```

---

## دورة حياة Module

### 1. التطوير (Development)
```bash
# إنشاء module جديد
mkdir -p packages/modules/{module_name}
cd packages/modules/{module_name}

# إنشاء الهيكل الأساسي
mkdir -p services schemas policies events workflows tests

# إنشاء manifest
touch module.yaml
```

### 2. التسجيل (Registration)
Module يُسجل تلقائيًا عند:
- وجود `module.yaml`
- وجود `__init__.py`
- module موجود في `packages/modules/`

### 3. التمكين (Enablement)
Module يمكن تمكينه per tenant:
```python
# في database
tenant_modules = {
    "tenant_id": "abc123",
    "modules": [
        {
            "module_id": "retention",
            "enabled": True,
            "settings": {
                "default_approval_required": True
            }
        }
    ]
}
```

### 4. التعطيل (Disable)
عند تعطيل module:
- APIs تتوقف عن الاستجابة
- Workflows تتوقف عن البدء
- Events لا تُعالَج
- البيانات محفوظة لكن غير مُستخدَمة

### 5. الحذف (Removal)
قبل حذف module:
1. تعطيل module لجميع tenants
2. إيقاف جميع workflows النشطة
3. Backup البيانات
4. حذف من codebase
5. تحديث documentation

---

## Module Interfaces

### Service Interface

```python
from abc import ABC, abstractmethod
from typing import Any, Dict, List

class BaseModuleService(ABC):
    """
    الواجهة الأساسية لجميع Module services.
    
    كل service في module يجب أن يرث من هذه الفئة.
    """
    
    @abstractmethod
    async def initialize(self, tenant_id: str) -> None:
        """تهيئة service لـ tenant محدد."""
        pass
    
    @abstractmethod
    async def validate_settings(self, settings: Dict[str, Any]) -> bool:
        """التحقق من صحة settings."""
        pass
    
    @abstractmethod
    def get_permissions(self) -> List[str]:
        """إرجاع permissions المطلوبة."""
        pass
```

### Event Handler Interface

```python
from abc import ABC, abstractmethod
from packages.events.base import Event

class BaseEventHandler(ABC):
    """
    الواجهة الأساسية لـ event handlers.
    """
    
    @property
    @abstractmethod
    def subscribed_events(self) -> List[str]:
        """قائمة events التي يستمع إليها handler."""
        pass
    
    @abstractmethod
    async def handle(self, event: Event) -> None:
        """معالجة event."""
        pass
```

### Workflow Interface

```python
from abc import ABC, abstractmethod
from temporalio import workflow

class BaseModuleWorkflow(ABC):
    """
    الواجهة الأساسية لـ module workflows.
    """
    
    @property
    @abstractmethod
    def workflow_id(self) -> str:
        """معرف workflow الفريد."""
        pass
    
    @property
    @abstractmethod
    def task_queue(self) -> str:
        """اسم task queue."""
        pass
```

---

## Module Communication

### مع Core Platform

Modules تتواصل مع core platform عبر:

1. **Events**: نشر واستقبال events
2. **Services**: استدعاء core services
3. **APIs**: استخدام REST/GraphQL APIs
4. **Database**: قراءة/كتابة بيانات (مع tenant isolation)

### بين Modules

Modules **لا** تتواصل مباشرة مع بعضها:
- ❌ Direct imports بين modules
- ❌ Function calls بين modules
- ✅ عبر events فقط
- ✅ عبر core services المشتركة

---

## Module Testing

### Unit Tests

```python
# packages/modules/retention/tests/test_audience_builder.py

import pytest
from packages.modules.retention.services.audience_builder import AudienceBuilder

class TestAudienceBuilder:
    
    @pytest.mark.asyncio
    async def test_build_audience_with_filters(self):
        builder = AudienceBuilder(tenant_id="test_tenant")
        
        filters = {
            "last_order_days_ago": {"gte": 30},
            "total_orders": {"gte": 2}
        }
        
        audience = await builder.build(filters)
        
        assert len(audience) > 0
        assert all(customer.tenant_id == "test_tenant" for customer in audience)
```

### Integration Tests

```python
# tests/integration/test_retention_module.py

import pytest
from packages.modules.module_loader import ModuleLoader

class TestRetentionModuleIntegration:
    
    @pytest.mark.asyncio
    async def test_module_loads_successfully(self):
        loader = ModuleLoader()
        module = await loader.load("retention")
        
        assert module is not None
        assert module.id == "retention"
        assert module.status == "stable"
    
    @pytest.mark.asyncio
    async def test_module_can_create_campaign(self):
        # Create campaign through API
        response = await api_client.post(
            "/api/v1/retention/campaigns",
            json={
                "name": "Test Campaign",
                "filters": {...}
            }
        )
        
        assert response.status_code == 201
```

---

## Module Versioning

### Semantic Versioning

Modules تتبع Semantic Versioning:
- **MAJOR.MINOR.PATCH**
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes (backward compatible)

### Multiple Versions

يدعم النظام multiple versions من نفس module:
```
packages/modules/
├── retention_v1/
│   └── module.yaml  # version: 1.0.0
└── retention_v2/
    └── module.yaml  # version: 2.0.0
```

Tenants يمكنهم اختيار version:
```json
{
  "tenant_id": "abc123",
  "modules": [
    {
      "module_id": "retention",
      "version": "1.0.0",
      "enabled": true
    }
  ]
}
```

---

## Module Security

### Permissions

كل module يحدد permissions المطلوبة:
```yaml
permissions:
  - customers:read
  - orders:read
  - messages:write
```

API يتحقق من permissions قبل تنفيذ operations.

### Data Access

Modules تصل للبيانات فقط عبر:
- Repositories مع tenant isolation
- Services مع authorization checks
- لا direct SQL queries

### Audit Logging

كل operations من module تُسجل في audit logs:
```python
from packages.core.audit import audit_logger

@audit_logger.log(action="campaign.created", resource_type="campaign")
async def create_campaign(data):
    ...
```

---

## Module Discovery

### Runtime Discovery

النظام يكتشف modules تلقائيًا:

```python
# packages/modules/base/loader.py

import os
import yaml
from pathlib import Path

class ModuleLoader:
    def __init__(self, modules_path: str = "packages/modules"):
        self.modules_path = Path(modules_path)
    
    def discover_modules(self) -> List[Dict]:
        """اكتشاف جميع modules المتاحة."""
        modules = []
        
        for module_dir in self.modules_path.iterdir():
            if not module_dir.is_dir():
                continue
            
            manifest_path = module_dir / "module.yaml"
            if not manifest_path.exists():
                continue
            
            with open(manifest_path) as f:
                manifest = yaml.safe_load(f)
            
            modules.append({
                "path": str(module_dir),
                "manifest": manifest
            })
        
        return modules
```

---

## Module Best Practices

### Do's ✅

1. اتبع الهيكل القياسي
2. اكتب module.yaml كامل
3. عرّف permissions بوضوح
4. استخدم events للتواصل
5. اكتب tests شاملة
6. وثّق الـ module
7. تعامل مع الأخطاء بشكل صحيح
8. احترم tenant isolation

### Don'ts ❌

1. ❌ تعديل core code
2. ❌ dependencies بين modules
3. ❌ direct database access بدون repositories
4. ❌ hard-coded credentials
5. ❌ skipping permission checks
6. ❌ missing error handling
7. ❌ no documentation
8. ❌ no tests

---

## Module Examples

### Simple Module Structure

```
packages/modules/support_ai/
├── module.yaml
├── README.md
├── __init__.py
├── services/
│   ├── answer_generator.py
│   └── ticket_classifier.py
├── schemas/
│   ├── ticket.py
│   └── response.py
├── graphs/
│   └── support_graph.py
└── tests/
    ├── test_answer_generator.py
    └── test_ticket_classifier.py
```

### Complex Module Structure

```
packages/modules/retention/
├── module.yaml
├── README.md
├── __init__.py
├── services/
│   ├── audience_builder.py
│   ├── segment_engine.py
│   ├── scoring_engine.py
│   ├── recommendation_engine.py
│   ├── offer_engine.py
│   ├── message_engine.py
│   └── campaign_sender.py
├── schemas/
│   ├── campaign.py
│   ├── audience.py
│   ├── recommendation.py
│   └── result.py
├── policies/
│   ├── retention_policy.py
│   ├── discount_policy.py
│   └── risk_policy.py
├── events/
│   └── retention_events.py
├── workflows/
│   ├── retention_campaign_workflow.py
│   └── winback_workflow.py
├── migrations/
│   └── 0001_retention_init.py
└── tests/
    ├── test_audience_builder.py
    ├── test_segment_engine.py
    ├── test_scoring_engine.py
    ├── test_recommendation_engine.py
    └── test_revenue_attribution.py
```

---

**آخر تحديث**: 2024-01-XX  
**المالك**: Architecture Team  
**الحالة**: Active
