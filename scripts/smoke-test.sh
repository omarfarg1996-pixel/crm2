#!/bin/bash
# Commerce AI Core - Smoke Test Script
# سكريبت اختبار الدخان السريع

set -e

echo "🔬 Running smoke tests..."
echo ""

FAILED=0
PASSED=0

# اختبار 1: فحص صحة API
echo "Test 1: API Health Check"
if curl -f --silent http://localhost:8000/health | grep -q "healthy"; then
    echo "✅ PASSED: API is healthy"
    ((PASSED++))
else
    echo "❌ FAILED: API health check failed"
    ((FAILED++))
fi

# اختبار 2: فحص صحة Worker
echo "Test 2: Worker Health Check"
if curl -f --silent http://localhost:8001/health | grep -q "healthy"; then
    echo "✅ PASSED: Worker is healthy"
    ((PASSED++))
else
    echo "❌ FAILED: Worker health check failed"
    ((FAILED++))
fi

# اختبار 3: فحص صحة AI Engine
echo "Test 3: AI Engine Health Check"
if curl -f --silent http://localhost:8003/health | grep -q "healthy"; then
    echo "✅ PASSED: AI Engine is healthy"
    ((PASSED++))
else
    echo "❌ FAILED: AI Engine health check failed"
    ((FAILED++))
fi

# اختبار 4: فحص صحة Webhook Gateway
echo "Test 4: Webhook Gateway Health Check"
if curl -f --silent http://localhost:8004/health | grep -q "healthy"; then
    echo "✅ PASSED: Webhook Gateway is healthy"
    ((PASSED++))
else
    echo "❌ FAILED: Webhook Gateway health check failed"
    ((FAILED++))
fi

# اختبار 5: التحقق من OpenAPI docs
echo "Test 5: OpenAPI Documentation"
if curl -f --silent http://localhost:8000/docs | grep -q "Swagger UI"; then
    echo "✅ PASSED: OpenAPI docs available"
    ((PASSED++))
else
    echo "❌ FAILED: OpenAPI docs not available"
    ((FAILED++))
fi

echo ""
echo "================================"
echo "Smoke Test Results:"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "================================"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "❌ Smoke tests failed!"
    exit 1
fi

echo ""
echo "✅ All smoke tests passed!"
exit 0
