#!/bin/bash
# Commerce AI Core - Health Check Script
# سكريبت فحص صحة جميع الخدمات

set -e

echo "🏥 Checking service health..."
echo ""

SERVICES=(
    "API:http://localhost:8000/health"
    "Worker:http://localhost:8001/health"
    "Workflow Worker:http://localhost:8002/health"
    "AI Engine:http://localhost:8003/health"
    "Webhook Gateway:http://localhost:8004/health"
    "Web Frontend:http://localhost:3000/health"
)

FAILED=0
PASSED=0

for SERVICE in "${SERVICES[@]}"; do
    NAME="${SERVICE%%:*}"
    URL="${SERVICE##*:}"
    
    if curl -f --silent --max-time 5 "$URL" > /dev/null 2>&1; then
        echo "✅ $NAME is healthy"
        ((PASSED++))
    else
        echo "❌ $NAME is not responding"
        ((FAILED++))
    fi
done

echo ""
echo "================================"
echo "Total: $((PASSED + FAILED)) services"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "================================"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "⚠️ Some services are not healthy yet."
    echo "They may still be starting up. Try again in a few seconds."
    exit 1
fi

echo ""
echo "✅ All services are healthy!"
exit 0
