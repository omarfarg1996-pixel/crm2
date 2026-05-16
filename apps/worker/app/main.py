"""
Commerce AI Core - Background Worker Service
خدمة المعالجة الخلفية للمهام غير المتزامنة
"""

from fastapi import FastAPI
from contextlib import asynccontextmanager
import logging
from typing import Dict, Any

logging.basicConfig(
    level="INFO",
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """إدارة دورة حياة خدمة الـ Worker"""
    logger.info("🔧 Starting Commerce AI Core Worker...")
    yield
    logger.info("🛑 Stopping Commerce AI Core Worker...")


app = FastAPI(
    title="Commerce AI Core Worker",
    description="Background worker for async task processing",
    version="1.0.0",
    lifespan=lifespan,
)


@app.get("/health")
async def health_check() -> Dict[str, Any]:
    """فحص صحة خدمة الـ Worker"""
    return {
        "status": "healthy",
        "service": "commerce-ai-core-worker",
        "version": "1.0.0",
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8001)
