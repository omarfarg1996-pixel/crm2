#!/bin/bash
# Commerce AI Core - Development Startup Script
# سكريبت تشغيل بيئة التطوير

set -e

echo "🚀 Starting Commerce AI Core Development Environment..."

# التحقق من وجود Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# التحقق من وجود Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# تحديد أمر Docker Compose المناسب
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# إنشاء ملف .env إذا لم يكن موجودًا
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
fi

# تنظيف الحاويات القديمة
echo "🧹 Cleaning up old containers..."
$COMPOSE_CMD -f docker-compose.dev.yml down --remove-orphans 2>/dev/null || true

# بدء الخدمات
echo "🐳 Starting all services..."
$COMPOSE_CMD -f docker-compose.dev.yml up -d

# انتظار جاهزية الخدمات
echo "⏳ Waiting for services to be ready..."
sleep 10

# فحص صحة الخدمات
echo "🏥 Checking service health..."
bash scripts/health.sh || echo "⚠️ Some services may still be starting up..."

echo ""
echo "✅ Development environment is ready!"
echo ""
echo "📍 Service URLs:"
echo "   - API:           http://localhost:8000"
echo "   - API Docs:      http://localhost:8000/docs"
echo "   - Web Frontend:  http://localhost:3000"
echo "   - Temporal UI:   http://localhost:8233"
echo "   - Qdrant:        http://localhost:6333"
echo "   - MinIO Console: http://localhost:9001"
echo "   - Grafana:       http://localhost:3001"
echo ""
echo "📋 Useful commands:"
echo "   - make logs     # View all logs"
echo "   - make stop     # Stop all services"
echo "   - make clean    # Clean and rebuild"
echo "   - make migrate  # Run database migrations"
echo ""
