#!/bin/bash

# Phase 01 Validation Script
# هذا السكربت يتحقق من اكتمال متطلبات المرحلة الأولى

echo "=========================================="
echo "Phase 01 - Project Constitution Check"
echo "=========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0

check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        if [ -s "$file" ]; then
            echo -e "${GREEN}✓${NC} $description"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo -e "${RED}✗${NC} $description (ملف فارغ)"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo -e "${RED}✗${NC} $description (ملف غير موجود)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

check_dir_not_exists() {
    local dir=$1
    local description=$2
    
    if [ -d "$dir" ]; then
        echo -e "${RED}✗${NC} $description (مجلد غير مسموح به)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    else
        echo -e "${GREEN}✓${NC} $description"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
}

check_no_pycache() {
    local pycache_count=$(find . -type d -name "__pycache__" 2>/dev/null | wc -l)
    
    if [ "$pycache_count" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} لا توجد مجلدات __pycache__"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}✗${NC} وجدت $pycache_count مجلد __pycache__"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

echo "--- التحقق من ملفات الدستور ---"
echo ""

# Check architecture files
check_file "docs/architecture/00-product-vision.md" "Product Vision"
check_file "docs/architecture/01-architecture-principles.md" "Architecture Principles"
check_file "docs/architecture/02-folder-structure.md" "Folder Structure"
check_file "docs/architecture/03-module-contract.md" "Module Contract"
check_file "docs/architecture/04-production-rules.md" "Production Rules"
check_file "docs/architecture/05-naming-conventions.md" "Naming Conventions"
check_file "docs/architecture/06-definition-of-done.md" "Definition of Done"
check_file "docs/architecture/07-release-gates.md" "Release Gates"
check_file "docs/architecture/08-risk-register.md" "Risk Register"
check_file "docs/architecture/09-ai-governance.md" "AI Governance"
check_file "docs/architecture/10-messaging-governance.md" "Messaging Governance"

echo ""
echo "--- التحقق من ملفات البحث والتقدم ---"
echo ""

check_file "docs/research/00-research-report.md" "Research Report"
check_file "docs/progress/phase-01-report.md" "Phase 01 Progress Report"

echo ""
echo "--- التحقق من عدم وجود duplicate folders ---"
echo ""

check_dir_not_exists "apps/api/src" "apps/api/src"
check_dir_not_exists "apps/ai-engine" "apps/ai-engine (يجب أن يكون ai_engine)"
check_dir_not_exists "apps/webhook-gateway" "apps/webhook-gateway (يجب أن يكون webhook_gateway)"
check_dir_not_exists "apps/temporal-worker" "apps/temporal-worker (يجب أن يكون workflow_worker)"
check_dir_not_exists "apps/temporal_worker" "apps/temporal_worker (يجب أن يكون workflow_worker)"

echo ""
echo "--- التحقق من نظافة الكود ---"
echo ""

check_no_pycache

echo ""
echo "--- التحقق من محتوى الملفات ---"
echo ""

# Check research report has required sections
if grep -q "Temporal" docs/research/00-research-report.md && \
   grep -q "LangGraph" docs/research/00-research-report.md && \
   grep -q "Shopify" docs/research/00-research-report.md && \
   grep -q "WhatsApp" docs/research/00-research-report.md && \
   grep -q "Zoho" docs/research/00-research-report.md; then
    echo -e "${GREEN}✓${NC} Research Report يحتوي على المصادر المطلوبة"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} Research Report ناقص بعض المصادر"
    ((FAIL_COUNT++))
fi

# Check research report has decisions section
if grep -q "لماذا نستخدم Temporal" docs/research/00-research-report.md || \
   grep -q "Why Temporal" docs/research/00-research-report.md; then
    echo -e "${GREEN}✓${NC} Research Report يوثق القرارات المعمارية"
    ((PASS_COUNT++))
else
    echo -e "${YELLOW}⚠${NC} Research Report قد لا يوثق جميع القرارات"
fi

# Check for Arabic comments in documentation
ARABIC_COUNT=$(grep -r "العربية\|المبدأ\|التطبيق" docs/architecture/ | wc -l)
if [ "$ARABIC_COUNT" -gt 50 ]; then
    echo -e "${GREEN}✓${NC} التوثيق يحتوي على شرح بالعربية ($ARABIC_COUNT موضع)"
    ((PASS_COUNT++))
else
    echo -e "${YELLOW}⚠${NC} التوثيق بالعربية قد يكون غير كافٍ ($ARABIC_COUNT موضع)"
fi

echo ""
echo "=========================================="
echo "ملخص النتائج"
echo "=========================================="
echo ""
echo -e "نجح: ${GREEN}$PASS_COUNT${NC}"
echo -e "فشل: ${RED}$FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✅ جميع_checks مرت بنجاح!${NC}"
    echo ""
    echo "Phase 01 مكتملة وجاهزة للانتقال لـ Phase 02"
    exit 0
else
    echo -e "${RED}❌ وجدت $FAIL_COUNT مشكلة يجب إصلاحها${NC}"
    echo ""
    echo "يرجى إصلاح المشاكل أعلاه قبل الانتقال للمرحلة التالية"
    exit 1
fi
