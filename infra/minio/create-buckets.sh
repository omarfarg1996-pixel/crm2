#!/bin/bash
# MinIO Bucket Creation Script for Commerce AI Core
# This script creates the required buckets for object storage

set -e

# Configuration
MINIO_ENDPOINT="${MINIO_ENDPOINT:-http://minio:9000}"
MINIO_ACCESS_KEY="${MINIO_ACCESS_KEY:-minioadmin}"
MINIO_SECRET_KEY="${MINIO_SECRET_KEY:-minioadmin}"

# Wait for MinIO to be ready
echo "⏳ Waiting for MinIO to be ready..."
until mc alias set myalias "$MINIO_ENDPOINT" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY" 2>/dev/null; do
    sleep 2
done
echo "✅ MinIO is ready!"

# Create buckets with versioning enabled
BUCKETS=(
    "commerce-ai-core-documents"
    "commerce-ai-core-media"
    "commerce-ai-core-backups"
    "commerce-ai-core-exports"
    "commerce-ai-core-temp"
)

for BUCKET in "${BUCKETS[@]}"; do
    echo "📦 Creating bucket: $BUCKET"
    mc mb --ignore-existing "myalias/$BUCKET"
    
    # Enable versioning for critical buckets
    if [[ "$BUCKET" == *"documents"* || "$BUCKET" == *"backups"* ]]; then
        echo "🔒 Enabling versioning for: $BUCKET"
        mc version enable "myalias/$BUCKET"
    fi
    
    # Set lifecycle policies for temp bucket (auto-delete after 7 days)
    if [[ "$BUCKET" == *"temp"* ]]; then
        echo "⏰ Setting lifecycle policy for: $BUCKET"
        mc ilm rule add "myalias/$BUCKET" --expire-days 7
    fi
    
    # Set public access for media bucket (optional, adjust based on needs)
    if [[ "$BUCKET" == *"media"* ]]; then
        echo "🌐 Setting public read access for: $BUCKET"
        mc anonymous set download "myalias/$BUCKET"
    fi
done

# List all buckets
echo ""
echo "📋 Created buckets:"
mc ls myalias

echo ""
echo "✅ All buckets created successfully!"
