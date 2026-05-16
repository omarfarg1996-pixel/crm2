# Commerce AI Core - Webhook Gateway Dockerfile
# For receiving external webhooks from providers

FROM python:3.12-slim-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements/webhook-gateway.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r webhook-gateway.txt

FROM python:3.12-slim-bookworm AS runtime

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --disabled-password --gecos '' appuser

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY apps/webhook_gateway/app ./apps/webhook_gateway/app
COPY packages ./packages

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8004

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8004/health || exit 1

CMD ["uvicorn", "apps.webhook_gateway.app.main:app", "--host", "0.0.0.0", "--port", "8004"]
