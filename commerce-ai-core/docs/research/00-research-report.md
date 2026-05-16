# Commerce AI Core - Research Report

## تاريخ الإنشاء
2024-01-XX

## المصادر التي تمت مراجعتها

### 1. Temporal.io
**المصادر الرسمية:**
- https://docs.temporal.io/
- https://docs.temporal.io/concepts/what-is-a-workflow
- https://docs.temporal.io/concepts/what-is-an-activity
- https://docs.temporal.io/dev-guide/python
- https://docs.temporal.io/application-development/durable-execution

**أهم المفاهيم المستفادة:**
- **Durable Execution**: Workflows تستمر حتى لو تعطلت الـ workers
- **Workflows**: كود deterministic يصف业务流程
- **Activities**: مهام غير deterministic (API calls, DB writes)
- **Retries**: Built-in retry policies مع exponential backoff
- **Signals**: آلية لإرسال بيانات للـ workflow أثناء التنفيذ
- **Queries**: الاستعلام عن حالة workflow دون التأثير عليه
- **Schedules**: تشغيل workflows بشكل دوري
- **Human Approval Patterns**: استخدام signals للانتظار
- **Failure Recovery**: Event sourcing مدمج
- **Determinism**: workflows يجب أن تكون deterministic

### 2. LangGraph / LangChain
**المصادر الرسمية:**
- https://langchain-ai.github.io/langgraph/
- https://python.langchain.com/docs/get_started/introduction
- https://langchain-ai.github.io/langgraph/tutorials/introduction/

**أهم المفاهيم المستفادة:**
- **Durable Execution**: checkpointing عبر persistence layer
- **Persistence/Checkpointing**: حفظ state بعد كل node
- **Human-in-the-loop**: interruption points للموافقة البشرية
- **Tools**: functions يستدعيها الـ agent
- **Structured Outputs**: JSON schema validation
- **Memory**: conversation history & vector stores
- **Graph State**: typed state يمر بين nodes

### 3. Shopify API
**المصادر الرسمية:**
- https://shopify.dev/docs/api/admin-graphql
- https://shopify.dev/docs/api/admin-rest
- https://shopify.dev/docs/apps/auth/oauth

**القرارات المعمارية:**
- **GraphQL-first**: REST في وضع legacy، GraphQL هو المستقبل
- **API Versioning**: quarterly releases، يجب تحديد version
- **OAuth**: required لكل app
- **Webhooks**: real-time events بدلاً من polling
- **Rate Limits**: leaky bucket algorithm
- **Customers, Orders, Products, Discounts**: جميعها متاحة في GraphQL

### 4. WhatsApp Business Platform / Meta
**المصادر الرسمية:**
- https://developers.facebook.com/docs/whatsapp/cloud-api
- https://developers.facebook.com/docs/whatsapp/cloud-api/webhooks
- https://developers.facebook.com/docs/whatsapp/business-management-api/message-templates

**أهم النقاط:**
- **Cloud API**: hosted by Meta، لا حاجة للبنية التحتية
- **Webhooks**: incoming messages و status updates
- **Message Templates**: pre-approved templatesRequired
  - Marketing templates: promotional content
  - Utility templates: order updates, alerts
- **Opt-in/Opt-out**: إلزامي قانونيًا
- **Message Status Events**: sent, delivered, read, failed
- **Rate Limits**: tiered حسب quality rating
- **Quality Rating**: يؤثر على rate limits

### 5. Zoho CRM API v8
**المصادر الرسمية:**
- https://www.zoho.com/crm/developer/docs/api/v8/
- https://www.zoho.com/crm/developer/docs/api/oauth-overview.html

**أهم النقاط:**
- **API v8**: أحدث نسخة
- **OAuth 2.0**: مطلوب للوصول
- **Modules**: Contacts, Leads, Deals, Tasks, Notes
- **Fields**: customizable per organization
- **Bulk APIs**: لعمليات批量
- **Notification APIs**: webhooks بديلة
- **Pagination**: page و per_page parameters
- **Rate Limits**: 
  - Free: 100 requests/minute
  - Paid: 500-2000 requests/minute

**غير مؤكد:**
- لم يتم التأكد من حدود rate limits الدقيقة لكل plan من مصدر رسمي حديث

### 6. PostgreSQL Multi-Tenancy
**المصادر:**
- https://www.postgresql.org/docs/current/indexes-intro.html
- https://www.postgresql.org/docs/current/datatype-json.html
- https://alembic.sqlalchemy.org/en/latest/

**القرارات المعمارية:**
- **tenant_id Strategy**: عمود في كل جدول
- **Indexes**: composite indexes على (tenant_id, id)
- **JSONB**: للمتغيرات الديناميكية
- **Migrations**: Alembic mandatory
- **RLS (Row Level Security)**: optional layer إضافي

### 7. OpenTelemetry
**المصادر الرسمية:**
- https://opentelemetry.io/docs/
- https://opentelemetry.io/docs/concepts/

**المفاهيم:**
- **Traces**: تتبع الطلبات عبر الخدمات
- **Metrics**: قياس الأداء والاستخدام
- **Logs**: structured logging
- **Collector**: تجميع البيانات
- **Context Propagation**: تمرير trace IDs

### 8. Qdrant
**المصادر الرسمية:**
- https://qdrant.tech/documentation/
- https://qdrant.tech/documentation/concepts/collections/

**المفاهيم:**
- **Collections**: مجموعات vectors
- **Payloads**: metadata مع vectors
- **Filtering**: search مع conditions
- **Vector Memory**: للتوصيات والبحث الدلالي
- **Tenant Isolation**: collections منفصلة أو payload filtering

---

## أهم القرارات المعمارية

### لماذا نستخدم Temporal وليس Cron فقط؟

1. **State Management**: Temporal يحفظ state تلقائيًا، Cron يحتاج تخزين خارجي
2. **Retry Logic**: Built-in مع exponential backoff، Cron يحتاج custom code
3. **Long-running Processes**: Workflow يمكن أن يستمر أيام/أسابيع
4. **Human Approval**: Signals تسمح بالانتظار للموافقة البشرية
5. **Event Sourcing**: كل execution مُسجل ويمكن replayه
6. **Failure Recovery**: Worker failure لا يفقد workflow state
7. **Visibility**: UI للاستعلام عن حالة workflows
8. **Scalability**: Auto-scaling للـ workers

**Cron مناسب فقط لـ:**
- مهام بسيطة بدون state
- مهام قصيرة الأمد
- لا تحتاج retry معقدة

### لماذا نستخدم LangGraph وليس prompt عشوائي؟

1. **Structured Execution**: Graph يحدد flow واضح
2. **Checkpointing**: حفظ state بعد كل خطوة
3. **Human-in-the-loop**: نقاط توقف للموافقة
4. **Tool Usage**: استدعاء APIs بشكل منظم
5. **Validation**: JSON schema outputs
6. **Testability**: كل node قابل للاختبار
7. **Maintainability**: كود منظم بدلاً من prompts متفرقة
8. **Memory Management**: Conversation history مُدارة

**Prompt العشوائي مشاكله:**
- لا يوجد state management
- صعب الاختبار
- لا يوجد audit trail
- صعب الصيانة

### لماذا Shopify GraphQL-first؟

1. **REST Legacy**: Shopify نفسها توجه لـ GraphQL
2. **Efficiency**: Fetch بيانات محددة فقط
3. **Versioning**: GraphQL أكثر استقرارًا
4. **Type Safety**: Schema واضح
5. **Future-proof**: REST قد يُهمل مستقبلاً

### كيف نتعامل مع WhatsApp templates و webhooks؟

**Templates:**
1. Template creation via Business Manager
2. Pre-approval required قبل الاستخدام
3. Categorization: Marketing vs Utility
4. Version control للـ templates
5. Dynamic variables عبر template rendering

**Webhooks:**
1. Signature verification (X-Hub-Signature)
2. Raw payload storage للأudit
3. Idempotency checks لمنع التكرار
4. Normalization إلى internal events
5. Async processing عبر event bus

### كيف نبني Zoho connector بدون hardcoding؟

1. **Field Mapping UI**: المستخدم يربط الحقول
2. **Dynamic Schema**: جلب fields من API
3. **Module Abstraction**: generic module interface
4. **Credential Encryption**: secure token storage
5. **Sync Cursors**: تتبع آخر update
6. **Error Handling**: retry logic مع backoff
7. **Rate Limit Awareness**: respect limits

---

## المخاطر الرئيسية

### مخاطر تقنية
1. **Temporal Complexity**: منحنى تعلم steep
2. **LangGraph Immaturity**: مشروع جديد نسبيًا
3. **Multi-tenancy Leaks**: خطر أمني عالي
4. **Vector DB Costs**: Qdrant memory-intensive
5. **API Rate Limits**: قد تحد من scalability

### مخاطر تجارية
1. **WhatsApp Policy Changes**: Meta قد تغير القواعد
2. **Shopify API Deprecation**: breaking changes محتملة
3. **Data Privacy Regulations**: GDPR, CCPA compliance
4. **Customer Data Breach**: كارثة للشركة

### مخاطر تشغيلية
1. **Workflow Stuck States**: workflows قد تتعطل
2. **Dead Letter Queue Growth**: فشل متكرر في activities
3. **AI Hallucinations**: قرارات خاطئة من AI
4. **Cost Overruns**: AI tokens و infrastructure

---

## الافتراضات

1. **Python 3.12+**: متاح في بيئة الإنتاج
2. **PostgreSQL 15+**: features حديثة مطلوبة
3. **Redis 7+**: لـ caching و queues
4. **Docker Compose**: للـ development
5. **Kubernetes**: للإنتاج (لاحقًا)
6. **Cloud Provider**: AWS/GCP/Azure
7. **LLM Provider**: OpenAI-compatible API
8. **WhatsApp BSP**: Meta Cloud API أو BSP معتمد

---

## الأشياء غير المؤكدة التي يجب مراجعتها

1. **Zoho CRM Rate Limits**: لم يتم التأكد من مصدر رسمي حديث
   - "لم يتم التأكد من هذه النقطة من مصدر رسمي، ويجب مراجعتها قبل الإنتاج."

2. **WhatsApp Template Approval Time**: يختلف حسب المنطقة والصناعة
   - "لم يتم التأكد من الوقت الدقيق، ويجب تجربته عمليًا."

3. **Shopify GraphQL Query Complexity**: كيفية حساب التكلفة بدقة
   - "لم يتم التأكد من خوارزمية cost calculation، ويجب اختبارها."

4. **Qdrant Multi-tenancy Best Practices**: هل collections منفصلة أم payloads؟
   - "لم يتم التأكد من best practices للإنتاج، ويجب عمل proof of concept."

5. **Temporal Python SDK Maturity**: مقارنة بـ TypeScript SDK
   - "لم يتم التأكد من maturity level، ويجب مراجعة GitHub issues."

6. **LangGraph Production Readiness**: حالات فشل معروفة
   - "لم يتم التأكد من production track record، ويجب مراجعة case studies."

---

## خلاصة القرارات

| القرار | السبب | البديل المرفوض |
|--------|-------|----------------|
| Temporal | Durable execution, retries, visibility | Cron, Celery |
| LangGraph | Structured AI flows, checkpointing | Raw prompts |
| Shopify GraphQL | Future-proof, efficient | REST API |
| PostgreSQL tenant_id | Simple, queryable | Separate databases |
| Qdrant | Fast vector search, filtering | Pinecone, Weaviate |
| Event-driven | Decoupling, audit trail | Direct calls |
| Module system | Extensibility | Monolithic features |

---

## مصادر إضافية للقراءة

1. https://temporal.io/blog/durable-distributed-execution
2. https://langchain-ai.github.io/langgraph/concepts/
3. https://shopify.dev/docs/api/usage/rate-limits
4. https://developers.facebook.com/docs/whatsapp/cloud-api/support/error-codes
5. https://www.zoho.com/crm/developer/docs/api/v8/bulk-operations.html
6. https://www.postgresql.org/docs/current/ddl-rowsecurity.html
7. https://opentelemetry.io/docs/instrumentation/python/
8. https://qdrant.tech/documentation/guides/multitenancy/

---

## تحديثات مستقبلية

يجب تحديث هذا التقرير عند:
- تغيير أي قرار معماري
- إضافة integration جديدة
- اكتشاف security vulnerability
- تغيير provider رئيسي
