#!/bin/bash
# Commerce AI Core - Stop All Services Script
# سكريبت إيقاف جميع الخدمات

set -e

echo "🛑 Stopping Commerce AI Core services..."

# تحديد أمر Docker Compose المناسب
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# إيقاف الخدمات
$COMPOSE_CMD -f docker-compose.dev.yml down
$COMPOSE_CMD -f docker-compose.observability.yml down 2>/dev/null || true

echo "✅ All services stopped!"
echo ""
echo "💡 To restart, run: make dev"
