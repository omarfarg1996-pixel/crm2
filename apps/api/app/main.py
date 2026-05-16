"""
Commerce AI Core - API Service
البوابة الرئيسية لواجهة برمجة التطبيقات
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
import logging
from typing import Dict, Any

from .config import settings

# إعداد التسجيل (Logging)
logging.basicConfig(
    level=settings.LOG_LEVEL,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    إدارة دورة حياة التطبيق
    يتم استدعاؤه عند بدء التشغيل وعند الإيقاف
    """
    # Startup: تهيئة الاتصالات بقواعد البيانات والخدمات
    logger.info("🚀 Starting Commerce AI Core API...")
    logger.info(f"Environment: {settings.ENVIRONMENT}")
    logger.info(f"Database URL: {settings.DATABASE_URL[:20]}...")
    
    # TODO: إضافة تهيئة قاعدة البيانات هنا في Phase 04
    # await init_database()
    
    yield
    
    # Shutdown: إغلاق الاتصالات بشكل نظيف
    logger.info("🛑 Shutting down Commerce AI Core API...")
    # TODO: إضافة إغلاق قاعدة البيانات هنا
    # await close_database()


# إنشاء تطبيق FastAPI
app = FastAPI(
    title="Commerce AI Core API",
    description="""
    ## Commerce AI Core API
    
    منصة SaaS احترافية لأتمتة التجارة الإلكترونية بالذكاء الاصطناعي
    
    ### الميزات الرئيسية:
    - **Multi-Tenant**: عزل كامل بين العملاء
    - **Event-Driven**: بنية قائمة على الأحداث
    - **AI-Powered**: قرارات ذكية مدعومة بـ LangGraph
    - **Durable Workflows**: سير عمل موثوق مع Temporal
    
    ### الخدمات المدعومة:
    - Shopify & WooCommerce
    - WhatsApp Business
    - Zoho CRM
    - Facebook Ads
    """,
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json"
)

# إعداد CORS للسماح للواجهة الأمامية بالاتصال
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["Health"])
async def health_check() -> Dict[str, Any]:
    """
    نقطة فحص الصحة
    تُستخدم من قبل Docker وKubernetes للتحقق من جاهزية الخدمة
    
    Returns:
        حالة الخدمة ومعلومات التشخيص
    """
    return {
        "status": "healthy",
        "service": "commerce-ai-core-api",
        "version": "1.0.0",
        "environment": settings.ENVIRONMENT,
        "timestamp": "2026-05-XX",  # سيتم تحديثه ديناميكيًا
    }


@app.get("/ready", tags=["Health"])
async def readiness_check() -> Dict[str, Any]:
    """
    نقطة فحص الجاهزية
    تتحقق من أن جميع الاعتماديات جاهزة
    
    Returns:
        حالة الجاهزية للخدمة
    """
    # TODO: إضافة فحوصات للاتصالات الخارجية
    # - قاعدة البيانات
    # - Redis
    # - Temporal
    # - Qdrant
    
    return {
        "status": "ready",
        "checks": {
            "database": "pending",  # سيتم تنفيذه في Phase 04
            "redis": "pending",
            "temporal": "pending",
            "qdrant": "pending",
        }
    }


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request, 
    exc: RequestValidationError
) -> JSONResponse:
    """
    معالجة أخطاء التحقق من صحة البيانات
    تسجل الأخطاء وتعيد استجابة واضحة للعميل
    """
    logger.warning(
        f"Validation error on {request.url}: {exc.errors()}"
    )
    
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "error": "validation_error",
            "message": "بيانات غير صالحة",
            "details": exc.errors(),
        },
    )


@app.exception_handler(Exception)
async def general_exception_handler(
    request: Request, 
    exc: Exception
) -> JSONResponse:
    """
    معالجة الاستثناءات العامة
    تسجل الخطأ وتعيد استجابة آمنة دون كشف تفاصيل داخلية
    """
    logger.error(
        f"Unhandled exception on {request.url}: {str(exc)}",
        exc_info=True
    )
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": "internal_error",
            "message": "حدث خطأ داخلي في الخادم",
            "path": str(request.url),
        },
    )


# Routes will be added in Phase 05
# from .routes import auth, tenants, users, roles
# app.include_router(auth.router, prefix="/auth", tags=["Authentication"])
# app.include_router(tenants.router, prefix="/tenants", tags=["Tenants"])
# app.include_router(users.router, prefix="/users", tags=["Users"])
# app.include_router(roles.router, prefix="/roles", tags=["Roles"])


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.ENVIRONMENT == "development",
        log_level=settings.LOG_LEVEL.lower(),
    )
