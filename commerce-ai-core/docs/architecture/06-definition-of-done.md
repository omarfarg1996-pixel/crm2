# Commerce AI Core - Definition of Done

## تعريف "منتهي" (Definition of Done)

هذا يوثق المعايير المطلوبة لاعتبار أي task أو feature "منتهية" تمامًا.

---

## مستويات Definition of Done

### مستوى 1: Code Complete

الكود مكتوب ويعمل محليًا.

**المعايير:**
- [ ] الكود مكتوب بالكامل
- [ ] لا توجد أخطاء syntax
- [ ] يعمل محليًا (local development)
- [ ] يتبع naming conventions
- [ ] يحتوي على type hints
- [ ] يحتوي على docstrings

---

### مستوى 2: Tested

الكود مختبر ومحمي من regressions.

**المعايير:**
- [ ] Unit tests مكتوبة
- [ ] Integration tests (إذا لزم الأمر)
- [ ] جميع tests تمر بنجاح
- [ ] Code coverage > 80%
- [ ] No flaky tests

---

### مستوى 3: Reviewed

الكود تم مراجعته من الفريق.

**المعايير:**
- [ ] Pull request مفتوح
- [ ] Reviewer واحد على الأقل وافق
- [ ] Comments تم معالجتها
- [ ] CI checks خضراء
- [ ] No merge conflicts

---

### مستوى 4: Documented

الfeature موثقة بشكل كافٍ.

**المعايير:**
- [ ] API documentation محدثة
- [ ] README محدث (إذا لزم الأمر)
- [ ] تغييرات Moquqa في changelog
- [ ] Runbooks محدثة (إذا لزم الأمر)
- [ ] تعليقات بالعربية داخل الكود

---

### مستوى 5: Deployable

الfeature جاهزة للإنتاج.

**المعايير:**
- [ ] Migration scripts (إذا لزم الأمر)
- [ ] Environment variables موثقة
- [ ] Metrics/Alerts مضافة
- [ ] Feature flag (إذا لزم الأمر)
- [ ] Rollback plan موجود

---

## Checklist حسب نوع العمل

### Feature جديدة

```markdown
## Code
- [ ] Implementation complete
- [ ] Follows architecture principles
- [ ] Multi-tenancy implemented
- [ ] Error handling
- [ ] Logging

## Tests
- [ ] Unit tests
- [ ] Integration tests
- [ ] E2E tests (إذا لزم الأمر)
- [ ] All tests passing

## Documentation
- [ ] API docs
- [ ] README updated
- [ ] Arabic comments in code

## Security
- [ ] Authentication/Authorization
- [ ] Input validation
- [ ] No sensitive data in logs
- [ ] Secrets in env vars

## Observability
- [ ] Metrics added
- [ ] Traces instrumented
- [ ] Alerts configured (إذا لزم الأمر)

## Deployment
- [ ] Migration script
- [ ] Env vars documented
- [ ] Feature flag (optional)
```

### Bug Fix

```markdown
## Fix
- [ ] Root cause identified
- [ ] Fix implemented
- [ ] No side effects

## Tests
- [ ] Regression test added
- [ ] Existing tests still pass

## Verification
- [ ] Verified in staging
- [ ] Original issue resolved
```

### Hotfix

```markdown
## Urgency
- [ ] Production impact confirmed
- [ ] Minimal fix applied

## Safety
- [ ] Tested locally
- [ ] Reviewed by senior
- [ ] Rollback plan ready

## Follow-up
- [ ] Proper fix planned
- [ ] Post-mortem scheduled
```

---

## Quality Gates

### Gate 1: Pre-commit

قبل commit الكود:

```bash
# Run formatters
pnpm format
black .

# Run linters
pnpm lint
flake8 .

# Run type checker
pnpm typecheck
mypy .

# Run unit tests
pnpm test-unit
```

### Gate 2: CI Pipeline

عند فتح Pull Request:

```yaml
# GitHub Actions workflow
- name: Lint
  run: ./scripts/lint.sh

- name: Type Check
  run: ./scripts/typecheck.sh

- name: Test
  run: ./scripts/test-unit.sh

- name: Build
  run: ./scripts/build.sh
```

### Gate 3: Pre-merge

قبل Merge الـ PR:

- [ ] All CI checks green
- [ ] Code review approved
- [ ] No unresolved comments
- [ ] Branch up to date with main

### Gate 4: Pre-deploy

قبل Deployment للإنتاج:

- [ ] Staging deployment successful
- [ ] E2E tests passing
- [ ] Performance acceptable
- [ ] No error spikes
- [ ] Stakeholder approval

---

## Acceptance Criteria Template

```markdown
## User Story
كـ {نوع المستخدم}
أريد {الهدف}
بحيث {القيمة}

## Acceptance Criteria

### Functional
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

### Non-Functional
- [ ] Performance: < 200ms response time
- [ ] Availability: 99.9% uptime
- [ ] Security: Auth required
- [ ] Accessibility: WCAG AA

### Technical
- [ ] Multi-tenancy implemented
- [ ] Events published
- [ ] Audit logs created
- [ ] Metrics exposed
```

---

## Examples

### مثال 1: إضافة API Endpoint

**Task:** إضافة endpoint لإنشاء حملة Retention

**Definition of Done:**

```markdown
## Code
- [x] POST /api/v1/retention/campaigns implemented
- [x] Request/Response schemas defined
- [x] Service layer created
- [x] Repository methods added
- [x] Database migration created

## Tests
- [x] Unit test for service layer
- [x] Integration test for API endpoint
- [x] Test for tenant isolation
- [x] All tests passing (15/15)

## Documentation
- [x] API documentation in OpenAPI
- [x] Arabic comments in code
- [x] Example request/response added

## Security
- [x] JWT authentication required
- [x] Tenant isolation verified
- [x] Input validation with Pydantic
- [x] Rate limiting applied

## Observability
- [x] Structured logging
- [x] Metrics: campaign_created counter
- [x] Trace spans for DB queries

## Deployment
- [x] Migration: alembic upgrade head
- [x] Env var: RETENTION_MODULE_ENABLED
```

### مثال 2: إصلاح Bug

**Task:** إصلاح تسرب بيانات بين tenants

**Definition of Done:**

```markdown
## Fix
- [x] Missing tenant_id in query identified
- [x] Query fixed with tenant filter
- [x] Similar issues audited

## Tests
- [x] Regression test: tenant isolation
- [x] Integration test: cross-tenant access blocked
- [x] All existing tests passing

## Verification
- [x] Tested in staging with multiple tenants
- [x] Security team verified
```

---

## Enforcement

### Automated Checks

```bash
#!/bin/bash
# scripts/check-definition-of-done.sh

echo "Checking Definition of Done..."

# Check for empty files
if find apps packages -name "*.py" -empty | grep -q .; then
    echo "❌ Found empty Python files"
    exit 1
fi

# Check for __pycache__
if find . -type d -name "__pycache__" | grep -q .; then
    echo "❌ Found __pycache__ directories"
    exit 1
fi

# Check for print statements
if grep -r "^print(" --include="*.py" apps/ | grep -v test | grep -q .; then
    echo "❌ Found print statements in production code"
    exit 1
fi

# Check for TODOs without dates
if grep -r "# TODO:" --include="*.py" apps/ | grep -v "# TODO(@[a-z]* \d{4}-\d{2}-\d{2})" | grep -q .; then
    echo "⚠️  Found TODOs without dates"
fi

echo "✅ Definition of Done checks passed"
```

### Code Review Template

```markdown
## Review Checklist

### Architecture
- [ ] Follows multi-tenancy principles
- [ ] Event-driven where appropriate
- [ ] No circular dependencies

### Code Quality
- [ ] Clean and readable
- [ ] DRY (Don't Repeat Yourself)
- [ ] SOLID principles

### Testing
- [ ] Adequate test coverage
- [ ] Tests are meaningful
- [ ] No flaky tests

### Security
- [ ] Authentication/Authorization
- [ ] Input validation
- [ ] No security vulnerabilities

### Performance
- [ ] No N+1 queries
- [ ] Efficient algorithms
- [ ] Caching where appropriate

### Documentation
- [ ] Code comments (Arabic)
- [ ] API documentation
- [ ] README updated
```

---

**آخر تحديث**: 2024-01-XX  
**المالك**: Engineering Team  
**الحالة**: Active  
**الإلزامية**: Required for all work items
