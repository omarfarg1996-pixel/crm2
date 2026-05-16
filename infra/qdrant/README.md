# Qdrant Vector Database for Commerce AI Core

## Overview
Qdrant provides vector storage and semantic search capabilities for AI-powered features in Commerce AI Core.

## Use Cases
1. **Customer Memory**: Store customer interaction embeddings for personalized responses
2. **Product Similarity**: Find similar products based on descriptions and attributes
3. **Message Templates**: Semantic search for relevant message templates
4. **Knowledge Base**: RAG (Retrieval-Augmented Generation) for customer support
5. **Fraud Detection**: Identify suspicious patterns via vector similarity
6. **Recommendation Engine**: Product recommendations based on embedding similarity

## Architecture
- **Collections**: Isolated vector spaces per tenant or use case
- **Points**: Individual vectors with payloads (metadata)
- **Payloads**: JSON metadata attached to vectors for filtering
- **Indexes**: HNSW for fast approximate nearest neighbor search

## Configuration Highlights
- HTTP port: 6333
- gRPC port: 6334
- HNSW index with m=16, ef_construct=100
- Max search threads: 4
- Search timeout: 30 seconds

## Multi-Tenancy Strategy
Each tenant gets isolated collections:
- `{tenant_id}_customer_memory`
- `{tenant_id}_product_embeddings`
- `{tenant_id}_message_templates`
- `{tenant_id}_knowledge_base`

## API Usage Examples

### Create Collection
```bash
curl -X PUT 'http://localhost:6333/collections/my_collection' \
  -H 'Content-Type: application/json' \
  -d '{
    "vectors": {
      "size": 1536,
      "distance": "Cosine"
    },
    "payload_schema": {
      "tenant_id": {"type": "keyword"},
      "customer_id": {"type": "keyword"}
    }
  }'
```

### Search with Filter
```bash
curl -X POST 'http://localhost:6333/collections/my_collection/points/search' \
  -H 'Content-Type: application/json' \
  -d '{
    "vector": [0.1, 0.2, ...],
    "limit": 10,
    "filter": {
      "must": [
        {"key": "tenant_id", "match": {"value": "tenant_123"}}
      ]
    }
  }'
```

## Performance Tuning
- Adjust `hnsw_index.m` for accuracy vs speed tradeoff
- Increase `max_search_threads` for high-concurrency workloads
- Enable `on_disk_payload` for large payloads to save RAM
- Monitor indexing threshold for optimal segment sizes

## Monitoring
Key metrics:
- Collection size (vectors count)
- Search latency (p95, p99)
- Indexing progress
- Memory usage
- Disk usage

## Backup & Recovery
- Snapshots stored in `/qdrant/snapshots`
- Use REST API to create/restore snapshots
- Implement regular backup schedule for production

## Security Notes
- Enable authentication in production
- Use TLS for all connections
- Implement collection-level access control
- Sanitize payloads to prevent injection attacks
