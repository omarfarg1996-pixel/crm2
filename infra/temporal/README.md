# Temporal Configuration for Commerce AI Core

## Overview
Temporal provides durable workflow execution for Commerce AI Core, ensuring that all business processes complete reliably even in the face of failures.

## Architecture
- **Frontend**: API gateway for workflow operations
- **History**: Maintains workflow state and event history
- **Matching**: Task routing and delivery
- **Worker**: Executes workflow and activity code
- **Web UI**: Visual interface for monitoring workflows

## Dynamic Configuration
The `dynamicconfig/development.yaml` file contains runtime configuration overrides:

### Retry Policies
- Default activity retry: 3 attempts with exponential backoff
- Initial interval: 1 second
- Maximum interval: 10 seconds
- Backoff coefficient: 2.0

### Timeouts
- Workflow task timeout: 60 seconds
- Default workflow task timeout: 10 seconds
- Activity schedule-to-start timeout: 300 seconds

### Features Enabled
- List workflow queries
- Timer lazy loading
- Search attribute cache refresh
- Server version check disabled (for development)

## Usage in Commerce AI Core
Temporal workflows are used for:
1. **Retention Campaigns**: Multi-step customer engagement flows
2. **Follow-up Sequences**: Timed message sequences with conditional logic
3. **Order Confirmation**: Automated order verification flows
4. **Human Approval**: Waiting for manual review before executing actions
5. **Data Sync**: Reliable synchronization with external systems
6. **Event Replay**: Re-processing events for recovery or testing

## Monitoring
Key metrics to monitor:
- Workflow start rate
- Activity success/failure rate
- Task queue backlog
- Workflow completion latency
- Retry counts

## Development Tips
1. Use the Web UI (http://localhost:8233) to inspect workflow state
2. Enable verbose logging for debugging
3. Use signals to interact with running workflows
4. Use queries to read workflow state without modifying it
5. Test failure scenarios with activity timeouts

## Production Considerations
- Enable TLS for all connections
- Configure proper authentication and authorization
- Set up alerting on critical metrics
- Use namespace isolation for different environments
- Implement proper error handling and compensation logic
