# Commerce AI Core - AI Governance

## حوكمة الذكاء الاصطناعي (AI Governance)

هذا يوثق المبادئ والضوابط لاستخدام الذكاء الاصطناعي في المنصة.

---

## المبادئ الأساسية

### 1. AI يقترح، لا يقرر
**المبدأ:** AI يقدم توصيات، لكن القرارات النهائية تكون:
- تلقائية للحالات منخفضة المخاطر
- بمراجعة بشرية للحالات عالية المخاطر

**التطبيق:**
```python
# AI يقترح
recommendation = await ai_engine.analyze_customer(customer)

# Policy Engine يراجع
policy_result = await policy_engine.check(recommendation)

# Human approval إذا لزم الأمر
if policy_result.requires_approval:
    await request_human_approval(recommendation)
else:
    await execute(recommendation)
```

---

### 2. الشفافية الكاملة
**المبدأ:** كل قرار من AI يجب أن يكون قابل للتتبع والفهم.

**التطبيق:**
- حفظ input و output للـ AI
- تسجيل model و prompt version
- تخزين scores و confidence levels
- Audit log لكل decision

```python
decision = AIDecision(
    tenant_id=tenant_id,
    input_data=input_json,
    output_data=output_json,
    model="gpt-4",
    prompt_version="v2.1",
    confidence_score=0.87,
    created_at=datetime.utcnow()
)
await db.add(decision)
```

---

### 3. التحيز والعدالة
**المبدأ:** منع التمييز ضد أي مجموعة من العملاء.

**التطبيق:**
- مراقبة recommendations حسب demographics
- اختبارات منتظمة للتحيز
- Diversity في training data
- Escalation للقرارات المشبوهة

---

### 4. الخصوصية
**المبدأ:** حماية بيانات العملاء عند استخدام AI.

**التطبيق:**
- لا إرسال PII لـ external APIs بدون consent
- Data minimization (إرسال الحد الأدنى)
- Encryption في transit و rest
- Retention policies للـ AI logs

---

## AI Decision Framework

### مستويات المخاطرة

#### Level 1: Low Risk (تلقائي)
**أمثلة:**
- تصنيف رسالة عميل
- اقتراح منتج
- تحليل مشاعر

**الضوابط:**
- تنفيذ تلقائي
- Logging فقط
- Monitoring للأداء

---

#### Level 2: Medium Risk (مراقبة)
**أمثلة:**
- عرض خصم < 20%
- رسالة تسويقية
- تغيير segment

**الضوابط:**
- Policy check مطلوب
- Sampling للمراجعة البشرية (10%)
- Alert للانحرافات

---

#### Level 3: High Risk (موافقة بشرية)
**أمثلة:**
- عرض خصم >= 20%
- رسالة لحساس customer
- قرار بإيقاف خدمة
- تغيير سعر

**الضوابط:**
- Human approval إلزامي
- Justification مطلوب
- Audit trail كامل
- Manager escalation للاعتراضات

---

## Prompt Management

### Prompt Registry

كل prompt يجب أن يُسجل في registry:

```yaml
# prompts/customer_analysis_v2.yaml
id: customer_analysis
version: 2.1
description: Analyze customer for retention campaign

system_prompt: |
  You are an e-commerce analytics assistant.
  Analyze the customer data and provide recommendations.
  Be conservative in your estimates.
  Do not make up product information.

user_template: |
  Customer ID: {{customer_id}}
  Total Orders: {{total_orders}}
  Last Order: {{last_order_days_ago}} days ago
  Total Spent: ${ total_spent }
  
  Analyze this customer for retention potential.

variables:
  - customer_id
  - total_orders
  - last_order_days_ago
  - total_spent

output_schema: |
  {
    "churn_risk": "low|medium|high",
    "recommended_action": "string",
    "product_suggestions": ["product_id"],
    "discount_recommendation": "0-100",
    "confidence": "0.0-1.0"
  }

risk_level: medium
approval_required: false
```

### Prompt Versioning

- Semantic versioning (MAJOR.MINOR.PATCH)
- Backward compatibility maintained
- Deprecation notices (30 days minimum)
- Rollback capability

---

## Output Validation

### Schema Validation

كل output من AI يجب validateه:

```python
from pydantic import BaseModel, validator

class CustomerAnalysisOutput(BaseModel):
    churn_risk: Literal["low", "medium", "high"]
    recommended_action: str
    product_suggestions: List[str]
    discount_recommendation: int
    confidence: float
    
    @validator('discount_recommendation')
    def validate_discount(cls, v):
        if v < 0 or v > 100:
            raise ValueError("Discount must be 0-100")
        return v
    
    @validator('confidence')
    def validate_confidence(cls, v):
        if v < 0.0 or v > 1.0:
            raise ValueError("Confidence must be 0.0-1.0")
        return v

# Validate
try:
    output = CustomerAnalysisOutput.model_validate(ai_response)
except ValidationError as e:
    logger.error(f"AI output validation failed: {e}")
    raise InvalidAIOutputError(str(e))
```

### Content Validation

```python
async def validate_ai_content(output: dict, context: dict) -> ValidationResult:
    errors = []
    
    # Check products exist
    for product_id in output.get('product_suggestions', []):
        if not await product_exists(product_id):
            errors.append(f"Product {product_id} does not exist")
    
    # Check discount within policy
    max_discount = await get_max_discount(context['tenant_id'])
    if output.get('discount_recommendation', 0) > max_discount:
        errors.append(f"Discount exceeds maximum allowed ({max_discount}%)")
    
    # Check no hallucinated information
    if 'fake_info' in output:
        errors.append("AI generated fake information")
    
    return ValidationResult(
        valid=len(errors) == 0,
        errors=errors
    )
```

---

## AI Testing & Evaluation

### Automated Evals

```python
# tests/ai_evals/test_message_quality.py

import pytest
from packages.ai.evals import MessageQualityEval

class TestMessageQuality:
    
    @pytest.mark.asyncio
    async def test_no_fake_discounts(self):
        """AI should not invent discounts that don't exist."""
        
        eval_result = await MessageQualityEval.run(
            test_cases=[
                {
                    "input": {"customer_id": "cust_123"},
                    "expected_constraints": {
                        "no_fake_discounts": True,
                        "products_must_exist": True
                    }
                }
            ]
        )
        
        assert eval_result.passed, f"Eval failed: {eval_result.errors}"
    
    @pytest.mark.asyncio
    async def test_product_must_exist(self):
        """AI should only recommend existing products."""
        
        # ... similar test
```

### Human Evaluation

```python
# Sample for human review
sample_rate = 0.10  # 10% of AI decisions

if random.random() < sample_rate:
    await human_review_queue.add({
        "decision_id": decision.id,
        "ai_output": decision.output_data,
        "reviewer_notes": ""
    })
```

### Metrics

```python
# AI Performance Metrics
AI_EVAL_PASS_RATE = Gauge('ai_eval_pass_rate', 'AI evaluation pass rate')
AI_HALLUCINATION_COUNT = Counter('ai_hallucinations_total', 'AI hallucinations detected')
AI_APPROVAL_REJECTION_RATE = Gauge('ai_approval_rejection_rate', 'Human rejection rate')
AI_LATENCY_P95 = Histogram('ai_latency_seconds', 'AI response time')
```

---

## Human-in-the-Loop

### Approval Workflow

```python
async def process_ai_decision(decision: AIDecision):
    # Determine if approval needed
    if decision.risk_level == "high":
        # Route to human approval
        approval_request = await create_approval_request(decision)
        await notify_approvers(approval_request)
        
        # Wait for approval
        approved = await wait_for_approval(approval_request)
        
        if not approved:
            await record_rejection(approval_request)
            return {"status": "rejected"}
    
    # Execute decision
    await execute_decision(decision)
    return {"status": "executed"}
```

### Approval UI

```typescript
// apps/web/src/app/approvals/page.tsx

export default function ApprovalsPage() {
  const { data: pendingApprovals } = useQuery({
    queryKey: ['pending-approvals'],
    queryFn: fetchPendingApprovals
  });
  
  return (
    <div>
      <h1>Pending AI Approvals</h1>
      {pendingApprovals.map(approval => (
        <ApprovalCard
          key={approval.id}
          approval={approval}
          onApprove={handleApprove}
          onReject={handleReject}
        />
      ))}
    </div>
  );
}
```

---

## Incident Response

### AI Incidents

#### Type 1: Hallucination Detected
**Response:**
1. Log incident
2. Review affected decisions
3. Update prompt/validation
4. Retrain if needed

#### Type 2: Bias Detected
**Response:**
1. Immediate investigation
2. Pause affected AI feature
3. Root cause analysis
4. Remediation plan

#### Type 3: Data Leak via AI
**Response:**
1. Contain leak
2. Assess impact
3. Notify affected parties
4. Security review

---

## Compliance

### Regulations

- **GDPR**: Right to explanation for automated decisions
- **CCPA**: Opt-out of AI profiling
- **Industry-specific**: Healthcare, finance regulations

### Documentation

```markdown
## AI System Documentation

### Purpose
Description of what the AI system does

### Data Sources
List of data sources used

### Model Information
- Model name and version
- Training data description
- Known limitations

### Impact Assessment
- Potential impacts on users
- Mitigation measures

### Contact
Responsible team contact information
```

---

## Continuous Improvement

### Feedback Loop

```python
# Collect feedback on AI decisions
async def collect_feedback(decision_id: str, feedback: dict):
    await db.add(AIFeedback(
        decision_id=decision_id,
        feedback_type=feedback['type'],  # positive/negative
        feedback_text=feedback.get('text'),
        created_by=feedback['user_id']
    ))
    
    # Use feedback for improvement
    if feedback['type'] == 'negative':
        await flag_for_review(decision_id)
```

### Regular Reviews

- **Weekly**: Review AI metrics
- **Monthly**: Evaluate prompt performance
- **Quarterly**: Full AI system audit
- **Annually**: External AI ethics review

---

**آخر تحديث**: 2024-01-XX  
**المالك**: AI Governance Committee  
**الحالة**: Active  
**المراجعة القادمة**: 2024-02-XX
