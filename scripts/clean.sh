#!/bin/bash
# Commerce AI Core - Clean Build Artifacts Script
# سكريبت تنظيف ملفات البناء

set -e

echo "🧹 Cleaning build artifacts..."

# تحديد أمر Docker Compose المناسب
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# إيقاف الخدمات
echo "🛑 Stopping services..."
$COMPOSE_CMD -f docker-compose.dev.yml down 2>/dev/null || true
$COMPOSE_CMD -f docker-compose.observability.yml down 2>/dev/null || true

# إزالة الحاويات
echo "🗑️ Removing containers..."
docker rm -f $(docker ps -aq --filter "name=commerce-ai-core*" 2>/dev/null) 2>/dev/null || true

# إزالة الصور
echo "🗑️ Removing images..."
docker rmi -f $(docker images -q "commerce-ai-core*" 2>/dev/null) 2>/dev/null || true

# إزالة volumes
echo "🗑️ Removing volumes..."
docker volume rm $(docker volume ls -q --filter "name=commerce-ai-core*" 2>/dev/null) 2>/dev/null || true

# تنظيف Python cache
echo "🗑️ Removing Python cache..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
find . -type f -name "*.pyo" -delete 2>/dev/null || true
find . -type f -name "*.pyd" -delete 2>/dev/null || true
find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
rm -rf .coverage htmlcov/ 2>/dev/null || true

# تنظيف Node modules
echo "🗑️ Removing node_modules..."
rm -rf apps/web/node_modules 2>/dev/null || true
rm -rf apps/web/.next 2>/dev/null || true

# تنظيف مجلدات البناء
echo "🗑️ Removing build directories..."
rm -rf dist/ build/ *.egg-info 2>/dev/null || true

echo ""
echo "✅ Clean complete!"
echo ""
echo "💡 To rebuild, run: make dev"
