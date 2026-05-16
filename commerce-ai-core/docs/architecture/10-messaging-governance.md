# Commerce AI Core - Messaging Governance

## حوكمة المراسلة (Messaging Governance)

هذا يوثق الضوابط والسياسات لإرسال الرسائل للعملاء.

---

## المبادئ الأساسية

### 1. Consent First
**المبدأ:** لا رسالة بدون consent صريح من العميل.

**التطبيق:**
- Opt-in مطلوب لكل نوع من الرسائل
- Opt-out سهل ومتاح دائمًا
- Consent recorded مع timestamp و source
- Consent expiry للرسائل التسويقية

```python
class ConsentService:
    async def check_consent(
        self,
        customer_id: str,
        message_type: str,
        tenant_id: str
    ) -> ConsentResult:
        consent = await self.get_consent(customer_id, message_type)
        
        if not consent:
            return ConsentResult(
                allowed=False,
                reason="No consent found"
            )
        
        if consent.expired:
            return ConsentResult(
                allowed=False,
                reason="Consent expired"
            )
        
        return ConsentResult(allowed=True)
```

---

### 2. Right Message, Right Time
**المبدأ:** الرسائل يجب أن تكون ذات توقيت مناسب.

**التطبيق:**
- Quiet hours enforcement (لا رسائل ليلاً)
- Frequency caps (حد أقصى للرسائل)
- Timezone awareness
- Customer preferences respected

```python
class QuietHoursRule:
    async def check(self, context: MessageContext) -> PolicyResult:
        customer = await get_customer(context.customer_id)
        local_time = get_local_time(customer.timezone)
        
        quiet_start = 21  # 9 PM
        quiet_end = 9     # 9 AM
        
        if local_time.hour >= quiet_start or local_time.hour < quiet_end:
            return PolicyResult(
                allowed=False,
                reason="Quiet hours violation",
                retry_after=next_business_hour()
            )
        
        return PolicyResult(allowed=True)
```

---

### 3. Value Exchange
**المبدأ:** كل رسالة يجب أن تقدم قيمة للعميل.

**التطبيق:**
- No spam EVER
- Relevant content only
- Personalization based on history
- Clear value proposition

---

## Message Types

### Transactional Messages (لا تحتاج opt-in)
**أمثلة:**
- تأكيد الطلب
- تحديث الشحن
- إشعار الدفع
- رد على استفسار

**الضوابط:**
- مرتبطة بـ action من العميل
- محتوى محدود بالغرض
- لا تسويق في الرسالة

---

### Marketing Messages (تحتاج opt-in)
**أمثلة:**
- عروض ترويجية
- منتجات جديدة
- حملات Retention
- خصومات خاصة

**الضوابط:**
- Opt-in صريح مطلوب
- Unsubscribe link إلزامي
- Frequency caps صارمة
- Template approval من WhatsApp

---

### Utility Messages (تحتاج opt-in)
**أمثلة:**
- تذكير بعربة التسوق
- تنبيه مخزون
- نصائح استخدام المنتج

**الضوابط:**
- Opt-in مطلوب
- Value واضح
- Non-intrusive

---

## Messaging Policies

### Policy Engine Architecture

```python
class MessagingPolicyEngine:
    """
    محرك السياسات للرسائل.
    
    يفحص كل رسالة قبل الإرسال عبر قواعد متعددة.
    """
    
    def __init__(self):
        self.rules = [
            ConsentRule(),
            SuppressionRule(),
            FrequencyCapRule(),
            QuietHoursRule(),
            TemplateRule(),
            QuotaRule(),
            RiskRule(),
            OfferMarginRule()
        ]
    
    async def check(self, context: MessageContext) -> PolicyResult:
        results = []
        
        for rule in self.rules:
            result = await rule.check(context)
            results.append(result)
            
            if not result.allowed and rule.is_blocking:
                return result  # Fail fast
        
        return self.aggregate_results(results)
```

### Rule: Consent

```python
class ConsentRule(BasePolicyRule):
    """التحقق من consent العميل."""
    
    async def check(self, context: MessageContext) -> PolicyResult:
        consent_service = ConsentService()
        result = await consent_service.check_consent(
            customer_id=context.customer_id,
            message_type=context.message_type,
            tenant_id=context.tenant_id
        )
        
        if not result.allowed:
            return PolicyResult(
                allowed=False,
                reason=f"Consent check failed: {result.reason}",
                code="CONSENT_MISSING"
            )
        
        return PolicyResult(allowed=True)
```

### Rule: Suppression

```python
class SuppressionRule(BasePolicyRule):
    """التحقق من suppression lists."""
    
    async def check(self, context: MessageContext) -> PolicyResult:
        suppressed = await suppression_service.is_suppressed(
            customer_id=context.customer_id,
            tenant_id=context.tenant_id
        )
        
        if suppressed:
            return PolicyResult(
                allowed=False,
                reason=f"Customer is suppressed: {suppressed.reason}",
                code="SUPPRESSED"
            )
        
        return PolicyResult(allowed=True)
```

### Rule: Frequency Cap

```python
class FrequencyCapRule(BasePolicyRule):
    """منع الإكثار من الرسائل."""
    
    async def check(self, context: MessageContext) -> PolicyResult:
        count = await message_count.get_count(
            customer_id=context.customer_id,
            tenant_id=context.tenant_id,
            window="24h"
        )
        
        max_per_day = await tenant_settings.get_max_messages_per_day(
            context.tenant_id
        )
        
        if count >= max_per_day:
            return PolicyResult(
                allowed=False,
                reason=f"Frequency cap exceeded: {count}/{max_per_day}",
                code="FREQUENCY_CAP_EXCEEDED",
                retry_after="24h"
            )
        
        return PolicyResult(allowed=True)
```

---

## Template Management

### Template Categories

#### Marketing Templates
- محتوى ترويجي
- تحتاج approval من WhatsApp
- أمثلة: عروض، خصومات، منتجات جديدة

#### Utility Templates
- معلومات غير ترويجية
- Approval أسرع
- أمثلة: تأكيدات، تنبيهات، تذكيرات

### Template Lifecycle

```python
class TemplateService:
    async def create_template(self, data: TemplateCreateRequest) -> Template:
        # Validate template
        validator = TemplateValidator()
        validation = await validator.validate(data)
        
        if not validation.valid:
            raise TemplateValidationError(validation.errors)
        
        # Submit to WhatsApp for approval
        provider = WhatsAppProvider()
        submission = await provider.submit_template(data)
        
        # Save pending template
        template = Template(
            name=data.name,
            category=data.category,
            status="pending_approval",
            external_id=submission.template_id,
            submitted_at=datetime.utcnow()
        )
        await db.add(template)
        
        return template
    
    async def render_template(
        self,
        template_id: str,
        variables: dict
    ) -> str:
        template = await self.get_template(template_id)
        
        renderer = TemplateRenderer()
        rendered = await renderer.render(template.content, variables)
        
        return rendered
```

---

## Opt-Out Handling

### Automatic Detection

```python
class OptOutDetector:
    """كشف opt-out من رسائل العملاء."""
    
    OPT_OUT_PATTERNS = [
        r"\b(stop|opt[- ]?out|unsubscribe)\b",
        r"\b(quit|end|cancel)\b",
        r"\b(لا\s+أرغب|كف|توقف)\b",
    ]
    
    async def detect(self, message: str) -> OptOutResult:
        for pattern in self.OPT_OUT_PATTERNS:
            if re.search(pattern, message, re.IGNORECASE):
                return OptOutResult(
                    is_opt_out=True,
                    confidence=0.95,
                    pattern=pattern
                )
        
        return OptOutResult(is_opt_out=False)
```

### Opt-Out Processing

```python
async def process_opt_out(customer_id: str, tenant_id: str):
    # Add to suppression list
    await suppression_service.add(
        customer_id=customer_id,
        tenant_id=tenant_id,
        reason="customer_opted_out",
        global_=True  # All message types
    )
    
    # Revoke consent
    await consent_service.revoke_all(customer_id, tenant_id)
    
    # Send confirmation
    await send_confirmation_message(customer_id, "You have been unsubscribed")
    
    # Log for compliance
    await audit_logger.log(
        action="customer.opted_out",
        customer_id=customer_id,
        tenant_id=tenant_id
    )
```

---

## Provider Management

### Provider Abstraction

```python
class MessagingProviderRegistry:
    """تسجيل وإدارة providers."""
    
    def __init__(self):
        self.providers: Dict[str, MessagingProvider] = {}
    
    def register(self, provider: MessagingProvider):
        self.providers[provider.name] = provider
    
    def get_provider(self, name: str) -> MessagingProvider:
        if name not in self.providers:
            raise ProviderNotFoundError(f"Provider {name} not found")
        return self.providers[name]
    
    async def send_message(
        self,
        provider_name: str,
        to: str,
        content: str,
        **kwargs
    ):
        provider = self.get_provider(provider_name)
        return await provider.send(to, content, **kwargs)
```

### Supported Providers

```python
# WhatsApp providers
providers = [
    MetaCloudAPI(),      # Official Meta
    Twilio(),            # Twilio WhatsApp API
    Dialog360(),         # Dialog360
    Gupshup(),           # Gupshup
]

# Future providers
# - Email (SendGrid, SES)
# - SMS (Twilio, Vonage)
# - Voice (Twilio, Aircall)
```

---

## Analytics & Monitoring

### Metrics

```python
# Messaging Metrics
MESSAGES_SENT = Counter('messages_sent_total', 'Total messages sent', ['type', 'provider'])
MESSAGES_DELIVERED = Counter('messages_delivered_total', 'Total delivered')
MESSAGES_FAILED = Counter('messages_failed_total', 'Total failed')
OPT_OUT_RATE = Gauge('opt_out_rate', 'Opt-out rate')
CONSENT_RATE = Gauge('consent_rate', 'Customers with consent')
POLICY_BLOCK_RATE = Gauge('policy_block_rate', 'Messages blocked by policy')
```

### Dashboards

```typescript
// Messaging Dashboard
const messagingDashboard = {
  panels: [
    {
      title: "Messages Sent (24h)",
      query: "sum(rate(messages_sent_total[1h]))",
      type: "timeseries"
    },
    {
      title: "Delivery Rate",
      query: "sum(messages_delivered_total) / sum(messages_sent_total)",
      type: "gauge"
    },
    {
      title: "Blocked by Policy",
      query: "sum(messages_blocked_total) by (reason)",
      type: "piechart"
    },
    {
      title: "Opt-outs (7d)",
      query: "sum(rate(opt_outs_total[7d]))",
      type: "stat"
    }
  ]
};
```

---

## Compliance

### Regulations

- **GDPR**: Consent requirements for EU customers
- **TCPA**: US telemarketing rules
- **WhatsApp Business Policy**: Meta's platform rules
- **Local regulations**: Country-specific laws

### Audit Trail

```python
class MessageAudit:
    """تدقيق جميع الرسائل."""
    
    async def log_message(
        self,
        message_id: str,
        tenant_id: str,
        customer_id: str,
        content: str,
        policy_result: PolicyResult,
        provider_response: dict
    ):
        await db.add(MessageAuditLog(
            message_id=message_id,
            tenant_id=tenant_id,
            customer_id=customer_id,
            content_hash=hash_content(content),  # Don't store raw content
            policy_checks=policy_result.dict(),
            provider_response=provider_response,
            created_at=datetime.utcnow()
        ))
```

---

**آخر تحديث**: 2024-01-XX  
**المالك**: Messaging Team  
**الحالة**: Active  
**المراجعة القادمة**: 2024-02-XX
