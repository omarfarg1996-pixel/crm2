"""
Commerce AI Core - Worker Service

Background job processor باستخدام Celery.
يعالج المهام غير المتزامنة مثل:
- إرسال emails
- معالجة webhooks
- sync البيانات
- تقارير مجدولة

Phase 02: Skeleton فقط
"""

from fastapi import FastAPI, status
from fastapi.responses import JSONResponse

app = FastAPI(
    title="Commerce AI Core - Worker",
    description="Background job processor",
    version="0.1.0",
)


@app.get("/health", tags=["Health"])
async def health_check() -> dict:
    """فحص صحة الخدمة"""
    return {
        "status": "healthy",
        "service": "commerce-ai-core-worker",
        "version": "0.1.0",
    }


@app.get("/", tags=["Root"])
async def root() -> dict:
    """نقطة الدخول الرئيسية"""
    return {
        "name": "Commerce AI Core Worker",
        "version": "0.1.0",
        "description": "Background job processor",
    }
