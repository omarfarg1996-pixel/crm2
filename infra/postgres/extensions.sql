# PostgreSQL Extensions for Commerce AI Core
# This file contains extensions that need to be enabled on database startup

-- Enable UUID extension for generating unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pg_trgm for fuzzy text search and similarity matching
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Enable hstore for flexible key-value storage in JSON-like structures
CREATE EXTENSION IF NOT EXISTS "hstore";

-- Enable btree_gin for efficient indexing of common data types
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- Enable pgcrypto for encryption functions (used in token storage)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom enum types for consistent status tracking
DO $$ BEGIN
    -- Tenant status types
    CREATE TYPE tenant_status AS ENUM ('active', 'suspended', 'trial', 'cancelled');
    
    -- User status types
    CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended', 'pending_verification');
    
    -- Event severity levels
    CREATE TYPE event_severity AS ENUM ('info', 'warning', 'error', 'critical');
    
    -- Integration status
    CREATE TYPE integration_status AS ENUM ('connected', 'disconnected', 'error', 'revoked');
    
    -- Workflow execution status
    CREATE TYPE workflow_status AS ENUM ('pending', 'running', 'completed', 'failed', 'cancelled');
    
    -- AI decision status
    CREATE TYPE ai_decision_status AS ENUM ('pending', 'approved', 'rejected', 'requires_human_review');
    
    -- Message status
    CREATE TYPE message_status AS ENUM ('queued', 'sent', 'delivered', 'read', 'failed');
    
    -- Customer risk level
    CREATE TYPE customer_risk_level AS ENUM ('low', 'medium', 'high', 'critical');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Grant necessary permissions (will be refined per tenant in application)
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres;

COMMENT ON EXTENSION "uuid-ossp" IS 'Generates universally unique identifiers (UUIDs)';
COMMENT ON EXTENSION "pg_trgm" IS 'Provides text similarity measurement using trigram matching';
COMMENT ON EXTENSION "hstore" IS 'Data type for storing sets of key/value pairs';
COMMENT ON EXTENSION "btree_gin" IS 'GIN operator classes for common data types';
COMMENT ON EXTENSION "pgcrypto" IS 'Cryptographic functions for PostgreSQL';
