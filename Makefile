# Commerce AI Core - Makefile
# أوامر موحدة لإدارة المشروع خلال دورة التطوير الكاملة

.PHONY: help dev stop clean build test lint format typecheck migrate reset-db health smoke-test docs

# ============================================
# Help
# ============================================
help: ## عرض قائمة الأوامر المتاحة
	@echo "Commerce AI Core - قائمة الأوامر"
	@echo "================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ============================================
# Development Environment
# ============================================
dev: ## تشغيل بيئة التطوير المحلية
	@echo "🚀 تشغيل بيئة التطوير..."
	@docker compose -f docker-compose.dev.yml up -d
	@echo "✅ الخدمات تعمل الآن. انتظر 30 ثانية ثم شغل health-check"

dev-logs: ## عرض logs جميع الخدمات
	@docker compose -f docker-compose.dev.yml logs -f

dev-restart: ## إعادة تشغيل جميع الخدمات
	@docker compose -f docker-compose.dev.yml restart

stop: ## إيقاف جميع الخدمات
	@echo "🛑 إيقاف الخدمات..."
	@docker compose -f docker-compose.dev.yml down

clean: ## تنظيف البيئة وإزالة containers و volumes
	@echo "🧹 تنظيف البيئة..."
	@docker compose -f docker-compose.dev.yml down -v
	@docker compose -f docker-compose.observability.yml down -v 2>/dev/null || true
	@rm -rf __pycache__ */__pycache__ */*/__pycache__ */*/*/__pycache__
	@rm -rf .pytest_cache */.pytest_cache */*/.pytest_cache
	@rm -rf .mypy_cache */.mypy_cache */*/.mypy_cache
	@rm -rf htmlcov */htmlcov */*/htmlcov
	@rm -rf .coverage */.coverage */*/.coverage
	@rm -rf coverage.xml */coverage.xml */*/coverage.xml
	@rm -rf dist */dist */*/dist
	@rm -rf build */build */*/build
	@rm -rf *.egg-info */*.egg-info */*/*.egg-info
	@rm -rf node_modules */node_modules */*/node_modules
	@rm -rf .next */.next */*/.next
	@rm -rf minio_data postgres_data redis_data qdrant_storage temporal_data
	@echo "✅ تم التنظيف بنجاح"

# ============================================
# Docker Commands
# ============================================
build: ## بناء جميع صور Docker
	@echo "🔨 بناء صور Docker..."
	@docker compose -f docker-compose.dev.yml build

build-no-cache: ## بناء صور Docker بدون cache
	@echo "🔨 بناء صور Docker بدون cache..."
	@docker compose -f docker-compose.dev.yml build --no-cache

pull: ## سحب الصور الجاهزة (Temporal, Postgres, etc.)
	@docker compose -f docker-compose.dev.yml pull

push: ## دفع الصور إلى registry (يتطلب TAG)
ifndef TAG
	$(error TAG غير محدد. استخدم: make push TAG=latest)
endif
	@echo "📤 دفع الصور مع tag: $(TAG)"
	@docker tag commerce-ai-core-api:latest commerce-ai-core/api:$(TAG)
	@docker tag commerce-ai-core-worker:latest commerce-ai-core/worker:$(TAG)
	@docker tag commerce-ai-core-workflow-worker:latest commerce-ai-core/workflow-worker:$(TAG)
	@docker tag commerce-ai-core-ai-engine:latest commerce-ai-core/ai-engine:$(TAG)
	@docker tag commerce-ai-core-webhook-gateway:latest commerce-ai-core/webhook-gateway:$(TAG)
	@docker tag commerce-ai-core-web:latest commerce-ai-core/web:$(TAG)
	@docker push commerce-ai-core/api:$(TAG)
	@docker push commerce-ai-core/worker:$(TAG)
	@docker push commerce-ai-core/workflow-worker:$(TAG)
	@docker push commerce-ai-core/ai-engine:$(TAG)
	@docker push commerce-ai-core/webhook-gateway:$(TAG)
	@docker push commerce-ai-core/web:$(TAG)

# ============================================
# Database & Migrations
# ============================================
migrate: ## تشغيل Alembic migrations
	@echo "🔄 تشغيل migrations..."
	@docker compose -f docker-compose.dev.yml exec api alembic upgrade head

migrate-status: ## عرض حالة migrations
	@docker compose -f docker-compose.dev.yml exec api alembic current

migrate-down: ## التراجع عن migration واحدة
	@echo "⬇️ التراجع عن migration..."
	@docker compose -f docker-compose.dev.yml exec api alembic downgrade -1

reset-db: ## إعادة تعيين قاعدة البيانات (تحذف كل البيانات!)
	@echo "⚠️  تحذير: هذا سيحذف كل البيانات!"
	@read -p "هل أنت متأكد؟ (yes/no): " confirm && \
	if [ "$$confirm" = "yes" ]; then \
		docker compose -f docker-compose.dev.yml down -v; \
		docker compose -f docker-compose.dev.yml up -d postgres; \
		sleep 10; \
		docker compose -f docker-compose.dev.yml exec api alembic upgrade head; \
		echo "✅ تم إعادة تعيين قاعدة البيانات"; \
	else \
		echo "❌ تم الإلغاء"; \
	fi

create-migration: ## إنشاء migration جديدة (يتطلب NAME)
ifndef NAME
	$(error NAME غير محدد. استخدم: make create-migration NAME=add_user_table)
endif
	@echo "📝 إنشاء migration: $(NAME)"
	@docker compose -f docker-compose.dev.yml exec api alembic revision --autogenerate -m "$(NAME)"

# ============================================
# Testing
# ============================================
test: ## تشغيل جميع الاختبارات
	@echo "🧪 تشغيل جميع الاختبارات..."
	@bash scripts/test.sh

test-unit: ## تشغيل اختبارات unit فقط
	@echo "🧪 تشغيل unit tests..."
	@bash scripts/test-unit.sh

test-integration: ## تشغيل اختبارات integration فقط
	@echo "🧪 تشغيل integration tests..."
	@bash scripts/test-integration.sh

test-e2e: ## تشغيل اختبارات e2e فقط
	@echo "🧪 تشغيل e2e tests..."
	@bash scripts/test-e2e.sh

test-ai-evals: ## تشغيل تقييمات AI
	@echo "🤖 تشغيل AI evaluations..."
	@bash scripts/test-ai-evals.sh

test-coverage: ## تشغيل الاختبارات مع coverage report
	@echo "📊 تشغيل الاختبارات مع coverage..."
	@docker compose -f docker-compose.dev.yml exec api pytest --cov=apps --cov=packages --cov-report=html --cov-report=term-missing
	@echo "📄 تقرير Coverage متاح في htmlcov/index.html"

# ============================================
# Code Quality
# ============================================
lint: ## تشغيل linter على الكود
	@echo "🔍 تشغيل linter..."
	@bash scripts/lint.sh

format: ## تنسيق الكود باستخدام Black و Prettier
	@echo "🎨 تنسيق الكود..."
	@bash scripts/format.sh

typecheck: ## التحقق من الأنواع باستخدام mypy
	@echo "🔎 التحقق من الأنواع..."
	@bash scripts/typecheck.sh

check-all: ## تشغيل جميع فحوصات الجودة
	@echo "✅ تشغيل جميع الفحوصات..."
	@make lint
	@make format
	@make typecheck
	@echo "✅ اكتملت جميع الفحوصات"

# ============================================
# Health Checks
# ============================================
health: ## فحص صحة جميع الخدمات
	@echo "💚 فحص صحة الخدمات..."
	@bash scripts/health.sh

smoke-test: ## تشغيل smoke tests أساسية
	@echo "💨 تشغيل smoke tests..."
	@bash scripts/smoke-test.sh

# ============================================
# Frontend
# ============================================
web-dev: ## تشغيل frontend في وضع التطوير
	@echo "🌐 تشغيل frontend..."
	@cd apps/web && pnpm install && pnpm dev

web-build: ## بناء frontend للإنتاج
	@echo "🏗️ بناء frontend..."
	@cd apps/web && pnpm install && pnpm build

web-lint: ## فحص frontend code
	@echo "🔍 فحص frontend..."
	@cd apps/web && pnpm lint

# ============================================
# Documentation
# ============================================
docs: ## توليد الوثائق
	@echo "📚 توليد الوثائق..."
	@mkdir -p docs/generated
	@echo "Documentation generation placeholder"

api-docs: ## توليد API documentation
	@echo "📖 توليد API docs..."
	@docker compose -f docker-compose.dev.yml exec api python -m fastapi.openapi.main app/main.py --output docs/generated/openapi.json 2>/dev/null || echo "API not running, skip"

# ============================================
# Observability
# ============================================
observability-up: ## تشغيل أدوات المراقبة (Prometheus, Grafana, Loki)
	@echo "📊 تشغيل observability stack..."
	@docker compose -f docker-compose.observability.yml up -d

observability-down: ## إيقاف أدوات المراقبة
	@echo "📉 إيقاف observability stack..."
	@docker compose -f docker-compose.observability.yml down

observability-logs: ## عرض logs أدوات المراقبة
	@docker compose -f docker-compose.observability.yml logs -f

# ============================================
# Utilities
# ============================================
shell-api: ## الدخول إلى shell داخل container الـ API
	@docker compose -f docker-compose.dev.yml exec api /bin/bash

shell-worker: ## الدخول إلى shell داخل container الـ Worker
	@docker compose -f docker-compose.dev.yml exec worker /bin/bash

shell-ai: ## الدخول إلى shell داخل container الـ AI Engine
	@docker compose -f docker-compose.dev.yml exec ai-engine /bin/bash

db-shell: ## الدخول إلى PostgreSQL shell
	@docker compose -f docker-compose.dev.yml exec postgres psql -U postgres -d commerce_ai_core

redis-cli: ## الدخول إلى Redis CLI
	@docker compose -f docker-compose.dev.yml exec redis redis-cli

temporal-ui: ## فتح Temporal UI في المتصفح
	@echo "🔗 افتح http://localhost:8233 في المتصفح"

grafana-ui: ## فتح Grafana UI في المتصفح
	@echo "🔗 افتح http://localhost:3000 في المتصفح (admin/admin)"

prometheus-ui: ## فتح Prometheus UI في المتصفح
	@echo "🔗 افتح http://localhost:9090 في المتصفح"

qdrant-ui: ## فتح Qdrant Dashboard
	@echo "🔗 افتح http://localhost:6333/dashboard في المتصفح"

minio-ui: ## فتح MinIO Console
	@echo "🔗 افتح http://localhost:9001 في المتصفح (minioadmin/minioadminpassword)"

backup-db: ## عمل backup لقاعدة البيانات
	@echo "💾 عمل backup..."
	@mkdir -p backups
	@docker compose -f docker-compose.dev.yml exec postgres pg_dump -U postgres commerce_ai_core > backups/backup-$$(date +%Y%m%d-%H%M%S).sql

restore-db: ## استعادة backup (يتطلب FILE)
ifndef FILE
	$(error FILE غير محدد. استخدم: make restore-db FILE=backups/backup-20240101-120000.sql)
endif
	@echo "📥 استعادة backup: $(FILE)"
	@cat $(FILE) | docker compose -f docker-compose.dev.yml exec -T postgres psql -U postgres -d commerce_ai_core

# ============================================
# Phase Checks
# ============================================
check-phase01: ## التحقق من اكتمال Phase 01
	@bash scripts/check-phase01.sh

check-phase02: ## التحقق من اكتمال Phase 02
	@bash scripts/check-phase02.sh

# ============================================
# Default
# ============================================
default: help
