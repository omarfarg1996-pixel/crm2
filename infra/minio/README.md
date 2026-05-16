# MinIO Object Storage for Commerce AI Core

## Overview
MinIO provides S3-compatible object storage for Commerce AI Core, enabling scalable storage for documents, media, backups, and exports.

## Buckets Structure
The following buckets are created automatically:

### 1. commerce-ai-core-documents
- **Purpose**: Store customer documents, contracts, invoices
- **Versioning**: Enabled
- **Access**: Private (authenticated only)
- **Lifecycle**: No auto-expiry

### 2. commerce-ai-core-media
- **Purpose**: Product images, campaign media, avatars
- **Versioning**: Disabled (for performance)
- **Access**: Public read (configurable)
- **Lifecycle**: No auto-expiry

### 3. commerce-ai-core-backups
- **Purpose**: Database backups, configuration snapshots
- **Versioning**: Enabled
- **Access**: Private (admin only)
- **Lifecycle**: Retain for 90 days

### 4. commerce-ai-core-exports
- **Purpose**: CSV exports, reports, analytics data
- **Versioning**: Disabled
- **Access**: Private (tenant-scoped)
- **Lifecycle**: Auto-delete after 30 days

### 5. commerce-ai-core-temp
- **Purpose**: Temporary files, processing intermediates
- **Versioning**: Disabled
- **Access**: Private
- **Lifecycle**: Auto-delete after 7 days

## Access Pattern
```python
# Example: Upload a file
import boto3
from botocore.client import Config

s3_client = boto3.client(
    's3',
    endpoint_url='http://minio:9000',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin',
    config=Config(signature_version='s3v4'),
    region_name='us-east-1'
)

# Upload with tenant prefix for isolation
s3_client.upload_file(
    'local-file.pdf',
    'commerce-ai-core-documents',
    f'tenant_123/documents/invoice-001.pdf'
)
```

## Multi-Tenancy Strategy
All objects are stored with tenant prefix:
- `{tenant_id}/documents/...`
- `{tenant_id}/exports/...`
- `{tenant_id}/media/...`

Application layer enforces tenant isolation via middleware.

## Security
- Enable encryption at rest in production
- Use IAM policies for fine-grained access control
- Enable audit logging for compliance
- Use HTTPS/TLS for all connections in production

## Monitoring
Key metrics:
- Storage usage per bucket
- Request rate (PUT/GET/DELETE)
- Error rates
- Bandwidth usage

## Backup Strategy
- Daily snapshots of critical buckets
- Cross-region replication for disaster recovery (production)
- Lifecycle policies to manage storage costs
