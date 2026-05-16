"""
Commerce AI Core - API Service Main Entry Point

نقطة الدخول الرئيسية لتطبيق FastAPI.
يحتوي على:
- إعداد التطبيق (app factory)
- تسجيل الـ middleware
- تسجيل الـ routers
- health check endpoints
- exception handlers

ملاحظة: هذا skeleton للـ Phase 02، سيتم إضافة routes و services في المراحل القادمة.
"""

from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .config import settings


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """
    إدارة دورة حياة التطبيق (startup & shutdown)
    
    يتم تنفيذ الكود قبل بدء التشغيل وبعد إيقاف التطبيق هنا.
    
    TODO في المراحل القادمة:
    - إنشاء database connections pool
    - تهيئة Redis connection
    - الاتصال بـ Temporal client
    - تهيئة Qdrant client
    - تحميل modules الديناميكية
    """
    # Startup
    print(f"🚀 Starting {settings.app_name} in {settings.environment} mode")
    print(f"📊 Debug: {settings.debug}")
    print(f"🔗 Database: {settings.database.host}:{settings.database.port}")
    print(f"💾 Redis: {settings.redis.host}:{settings.redis.port}")
    print(f"⏱️  Temporal: {settings.temporal.target}")
    print(f"🧠 Qdrant: {settings.qdrant.url}")
    
    yield
    
    # Shutdown
    print("👋 Shutting down Commerce AI Core API...")
    # TODO: إغلاق connections بشكل نظيف


def create_application() -> FastAPI:
    """
    Factory function لإنشاء تطبيق FastAPI
    
    تستخدم factory pattern لسهولة الاختبار وإعادة الاستخدام.
    
    Returns:
        FastAPI: تطبيق FastAPI المهيأ بالكامل
    """
    application = FastAPI(
        title=settings.app_name,
        description="""
## Commerce AI Core API

منصة SaaS احترافية لأتمتة التجارة الإلكترونية بالذكاء الاصطناعي.

### الميزات الرئيسية:
- **Multi-Tenant**: دعم متعدد العملاء من أول يوم
- **Customer 360**: رؤية شاملة للعميل من جميع القنوات
- **AI-Powered**: قرارات ذكية مدعومة بـ LangGraph
- **Workflow Engine**: أتمتة العمليات بـ Temporal
- **Integrations**: تكامل مع Shopify, Zoho, WhatsApp, وغيرها

### الخدمات المستقبلية:
- Retention & Re-Selling Module
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
        """,
        version="0.1.0",
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
        lifespan=lifespan,
    )
    
    # ============================================
    # CORS Middleware
    # ============================================
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # ============================================
    # Register Routers (Phase 02 - Skeleton only)
    # ============================================
    # TODO في Phase 05: إضافة auth, tenants, users, roles routers
    # TODO في Phase 07: إضافة audit, usage, billing routers
    # TODO في Phase 08: إضافة events router
    # TODO في Phase 10: إضافة integrations router
    # TODO في Phase 11: إضافة customers router
    # TODO في Phase 12: إضافة products, orders routers
    # TODO في Phase 13: إضافة conversations, messages, templates routers
    # TODO في Phase 15: إضافة workflows, approvals routers
    # TODO في Phase 16: إضافة ai_runs, ai_decisions routers
    # TODO في Phase 17: إضافة modules router
    # TODO في Phase 21: إضافة retention_campaigns router
    
    # ============================================
    # Exception Handlers
    # ============================================
    @application.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        """
        معالجة الاستثناءات العامة
        
        TODO في المراحل القادمة:
        - تسجيل الاستثناءات في Audit Log
        - إرسال إشعارات لـ Sentry
        - إرجاع رسائل خطأ مناسبة حسب نوع الخطأ
        """
        # Logging will be added in Phase 07
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "error": "internal_server_error",
                "message": "حدث خطأ داخلي في الخادم",
                "detail": str(exc) if settings.debug else None,
            },
        )
    
    return application


# إنشاء تطبيق FastAPI الرئيسي
app = create_application()


# ============================================
# Health Check Endpoints
# ============================================

@app.get("/health", tags=["Health"])
async def health_check() -> dict:
    """
    فحص صحة الخدمة الأساسي
    
    Returns:
        dict: حالة الخدمة
    """
    return {
        "status": "healthy",
        "service": "commerce-ai-core-api",
        "version": "0.1.0",
        "environment": settings.environment,
    }


@app.get("/health/ready", tags=["Health"])
async def readiness_check() -> dict:
    """
    فحص جاهزية الخدمة
    
    يتحقق من أن جميع dependencies جاهزة.
    TODO في Phase 04: إضافة فحوصات قاعدة البيانات
    TODO في Phase 03: إضافة فحوصات Redis, Temporal, Qdrant
    
    Returns:
        dict: حالة الجاهزية
    """
    checks = {
        "api": True,
        "database": None,  # TODO: إضافة فحص database
        "redis": None,     # TODO: إضافة فحص redis
        "temporal": None,  # TODO: إضافة فحص temporal
        "qdrant": None,    # TODO: إضافة فحص qdrant
    }
    
    all_healthy = all(v is True for v in checks.values())
    
    return {
        "status": "ready" if all_healthy else "not_ready",
        "checks": checks,
    }


@app.get("/health/live", tags=["Health"])
async def liveness_check() -> dict:
    """
    فحص الحياة (liveness probe)
    
    يستخدم من Kubernetes لمعرفة إذا كان container يعمل.
    
    Returns:
        dict: حالة الحياة
    """
    return {"status": "alive"}


# ============================================
# Root Endpoint
# ============================================

@app.get("/", tags=["Root"])
async def root() -> dict:
    """
    نقطة الدخول الرئيسية
    
    Returns:
        dict: معلومات التطبيق
    """
    return {
        "name": settings.app_name,
        "version": "0.1.0",
        "description": "SaaS Platform for AI Commerce Automation",
        "docs": "/docs",
        "health": "/health",
    }
