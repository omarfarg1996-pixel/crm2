# PostgreSQL Configuration for Commerce AI Core

## Overview
This directory contains PostgreSQL configuration files and initialization scripts.

## Extensions
The `extensions.sql` file enables the following PostgreSQL extensions:

1. **uuid-ossp**: For generating UUIDs as primary keys
2. **pg_trgm**: For fuzzy text search and similarity matching
3. **hstore**: For flexible key-value storage
4. **btree_gin**: For efficient indexing
5. **pgcrypto**: For encryption functions

## Custom Types
The following ENUM types are created:
- `tenant_status`: Active, suspended, trial, cancelled
- `user_status`: Active, inactive, suspended, pending_verification
- `event_severity`: Info, warning, error, critical
- `integration_status`: Connected, disconnected, error, revoked
- `workflow_status`: Pending, running, completed, failed, cancelled
- `ai_decision_status`: Pending, approved, rejected, requires_human_review
- `message_status`: Queued, sent, delivered, read, failed
- `customer_risk_level`: Low, medium, high, critical

## Usage
These extensions are automatically applied when the PostgreSQL container starts via the docker-compose.dev.yml configuration.

## Security Notes
- All extensions are created in the public schema
- Permissions are granted to the postgres user by default
- Tenant-level isolation is enforced at the application layer via tenant_id
- Sensitive data (tokens, passwords) uses pgcrypto for encryption

## Performance Tuning
For production, consider adjusting:
- shared_buffers (25% of RAM)
- effective_cache_size (75% of RAM)
- work_mem (based on complex query needs)
- maintenance_work_mem (for VACUUM and index creation)

## Monitoring
Key metrics to monitor:
- Connection count
- Transaction rate
- Lock waits
- Cache hit ratio
- Index usage statistics
