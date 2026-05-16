# Commerce AI Core - AI Engine Dockerfile
# For LangGraph-based AI processing

FROM python:3.12-slim-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements/ai-engine.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r ai-engine.txt

FROM python:3.12-slim-bookworm AS runtime

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --disabled-password --gecos '' appuser

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY apps/ai_engine/app ./apps/ai_engine/app
COPY packages ./packages

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8003

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8003/health || exit 1

CMD ["uvicorn", "apps.ai_engine.app.main:app", "--host", "0.0.0.0", "--port", "8003"]
