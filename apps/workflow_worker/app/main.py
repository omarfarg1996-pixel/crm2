"""
Commerce AI Core - Workflow Worker Service

Temporal workflow and activities executor.
يشغل workflows طويلة الأمد مثل:
- Retention campaigns
- Follow-up sequences
- Order confirmation flows
- Human approval workflows

Phase 02: Skeleton فقط
"""

from fastapi import FastAPI

app = FastAPI(
    title="Commerce AI Core - Workflow Worker",
    description="Temporal workflow executor",
    version="0.1.0",
)


@app.get("/health", tags=["Health"])
async def health_check() -> dict:
    """فحص صحة الخدمة"""
    return {
        "status": "healthy",
        "service": "commerce-ai-core-workflow-worker",
        "version": "0.1.0",
    }


@app.get("/", tags=["Root"])
async def root() -> dict:
    """نقطة الدخول الرئيسية"""
    return {
        "name": "Commerce AI Core Workflow Worker",
        "version": "0.1.0",
        "description": "Temporal workflow executor",
    }
