#!/bin/bash
# Commerce AI Core - Phase 03 Validation Script
# سكريبت التحقق من اكتمال المرحلة الثالثة

echo "🔍 Validating Phase 03: Database Foundation & Infrastructure"
echo "=============================================================="
echo ""

PASSED=0
FAILED=0

check_file() {
    local FILE="$1"
    local DESC="$2"
    
    if [ -f "$FILE" ] && [ -s "$FILE" ]; then
        echo "✅ $DESC"
        PASSED=$((PASSED + 1))
    else
        echo "❌ $DESC (missing or empty)"
        FAILED=$((FAILED + 1))
    fi
}

check_dir() {
    local DIR="$1"
    local DESC="$2"
    
    if [ -d "$DIR" ]; then
        echo "✅ $DESC"
        PASSED=$((PASSED + 1))
    else
        echo "❌ $DESC (directory missing)"
        FAILED=$((FAILED + 1))
    fi
}

echo "--- Infrastructure Files ---"
check_file "infra/postgres/extensions.sql" "PostgreSQL extensions script"
check_file "infra/postgres/README.md" "PostgreSQL documentation"
check_file "infra/redis/redis.conf" "Redis configuration"
check_file "infra/temporal/dynamicconfig/development.yaml" "Temporal dynamic config"
check_file "infra/temporal/README.md" "Temporal documentation"
check_file "infra/qdrant/config.yaml" "Qdrant configuration"
check_file "infra/qdrant/README.md" "Qdrant documentation"
check_file "infra/minio/create-buckets.sh" "MinIO bucket creation script"
check_file "infra/minio/README.md" "MinIO documentation"

echo ""
echo "--- Docker Files ---"
check_file "infra/docker/api.Dockerfile" "API Dockerfile"
check_file "infra/docker/web.Dockerfile" "Web Dockerfile"
check_file "infra/docker/worker.Dockerfile" "Worker Dockerfile"
check_file "infra/docker/workflow-worker.Dockerfile" "Workflow Worker Dockerfile"
check_file "infra/docker/ai-engine.Dockerfile" "AI Engine Dockerfile"
check_file "infra/docker/webhook-gateway.Dockerfile" "Webhook Gateway Dockerfile"

echo ""
echo "--- Application Skeletons ---"
check_file "apps/api/app/main.py" "API main application"
check_file "apps/api/app/config.py" "API configuration"
check_file "apps/worker/app/main.py" "Worker main application"
check_file "apps/workflow_worker/app/main.py" "Workflow Worker main"
check_file "apps/ai_engine/app/main.py" "AI Engine main application"
check_file "apps/webhook_gateway/app/main.py" "Webhook Gateway main"

echo ""
echo "--- Scripts ---"
check_file "scripts/dev.sh" "Development startup script"
check_file "scripts/health.sh" "Health check script"
check_file "scripts/stop.sh" "Stop services script"
check_file "scripts/clean.sh" "Clean build artifacts script"
check_file "scripts/smoke-test.sh" "Smoke test script"

echo ""
echo "--- Directory Structure ---"
check_dir "apps/api/alembic/versions" "Alembic migrations directory"
check_dir "packages/database/models" "Database models directory"
check_dir "packages/database/repositories" "Database repositories directory"

echo ""
echo "=============================================================="
echo "Validation Results:"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "=============================================================="

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "❌ Phase 03 validation FAILED!"
    exit 1
fi

echo ""
echo "✅ Phase 03 validation PASSED!"
echo ""
echo "Next steps:"
echo "1. Run 'make dev' to start all services"
echo "2. Run 'bash scripts/smoke-test.sh' to verify services"
echo "3. Proceed to Phase 04: Database Models & Migrations"
exit 0
