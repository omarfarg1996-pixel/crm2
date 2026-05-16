"""
Commerce AI Core - Webhook Gateway Service

External webhook receiver and normalizer.
يستقبل webhooks من:
- Shopify (orders, customers, products)
- WhatsApp (messages, status updates)
- Zoho CRM (contacts, deals, tasks)
- WooCommerce (orders, products)

Phase 02: Skeleton فقط
"""

from fastapi import FastAPI

app = FastAPI(
    title="Commerce AI Core - Webhook Gateway",
    description="External webhook receiver",
    version="0.1.0",
)


@app.get("/health", tags=["Health"])
async def health_check() -> dict:
    """فحص صحة الخدمة"""
    return {
        "status": "healthy",
        "service": "commerce-ai-core-webhook-gateway",
        "version": "0.1.0",
    }


@app.get("/", tags=["Root"])
async def root() -> dict:
    """نقطة الدخول الرئيسية"""
    return {
        "name": "Commerce AI Core Webhook Gateway",
        "version": "0.1.0",
        "description": "External webhook receiver",
    }
