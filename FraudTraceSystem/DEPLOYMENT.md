# Deployment Guide

This guide covers deployment strategies for the Fraud Traceability System.

## Deployment Options

### Option 1: Local Development (Current Setup)

Best for development and testing.

**Pros:**
- Easy to debug
- Fast iteration
- Full control

**Cons:**
- Manual service management
- Not scalable
- Single machine only

**Usage:**
```bash
./scripts/setup.sh
./scripts/start-all.sh
```

### Option 2: Docker Compose

Best for staging and small-scale production.

**Pros:**
- Easy orchestration
- Consistent environments
- Easy to scale individual services

**Cons:**
- Corda nodes must run on host
- Limited by single machine

**Usage:**
```bash
docker-compose up -d
```

**Note:** Corda nodes must be started separately on the host machine.

### Option 3: Kubernetes

Best for production at scale.

**Pros:**
- Auto-scaling
- High availability
- Service discovery
- Load balancing

**Cons:**
- Complex setup
- Requires Kubernetes cluster
- Corda nodes need special handling

## Production Deployment Checklist

### Pre-Deployment

- [ ] All tests passing
- [ ] Security audit completed
- [ ] Performance testing done
- [ ] Backup strategy in place
- [ ] Monitoring configured
- [ ] Logging centralized
- [ ] Secrets management setup

### Infrastructure

- [ ] Load balancer configured
- [ ] SSL/TLS certificates installed
- [ ] Firewall rules configured
- [ ] Database setup (PostgreSQL)
- [ ] Redis/cache configured (optional)
- [ ] Message queue setup (optional)

### Corda Nodes

- [ ] Nodes deployed on dedicated servers
- [ ] RPC TLS enabled
- [ ] Network configuration verified
- [ ] Notary configuration correct
- [ ] Node identities registered
- [ ] Backup strategy for node data

### Microservices

- [ ] Environment variables configured
- [ ] Health checks enabled
- [ ] Auto-restart configured
- [ ] Resource limits set
- [ ] Logging to centralized system
- [ ] Metrics collection enabled

### Security

- [ ] Authentication enabled (JWT/OAuth)
- [ ] Authorization configured (RBAC)
- [ ] TLS/SSL enabled everywhere
- [ ] Secrets in secure storage
- [ ] API rate limiting configured
- [ ] CORS properly configured
- [ ] Input validation enabled

### Monitoring

- [ ] Application metrics (Prometheus)
- [ ] Logging (ELK stack)
- [ ] Alerting configured
- [ ] Dashboard (Grafana)
- [ ] Uptime monitoring
- [ ] Error tracking (Sentry)

## Kubernetes Deployment

### Prerequisites

- Kubernetes cluster (1.20+)
- kubectl configured
- Helm (optional, for easier deployment)

### Deploy Services

```bash
# Create namespace
kubectl create namespace fraud-trace

# Deploy AI Risk Engine
kubectl apply -f k8s/ai-risk-engine.yaml

# Deploy LEA Backend
kubectl apply -f k8s/lea-backend.yaml

# Deploy Bank API
kubectl apply -f k8s/bank-api.yaml

# Deploy LEA Frontend
kubectl apply -f k8s/lea-frontend.yaml
```

### Example Kubernetes Manifests

Create `k8s/ai-risk-engine.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ai-risk-engine
  namespace: fraud-trace
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ai-risk-engine
  template:
    metadata:
      labels:
        app: ai-risk-engine
    spec:
      containers:
      - name: ai-risk-engine
        image: fraud-trace/ai-risk-engine:latest
        ports:
        - containerPort: 5001
        env:
        - name: PORT
          value: "5001"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5001
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: ai-risk-engine
  namespace: fraud-trace
spec:
  selector:
    app: ai-risk-engine
  ports:
  - port: 5001
    targetPort: 5001
  type: ClusterIP
```

## Database Setup

### PostgreSQL

```sql
-- Create database
CREATE DATABASE fraud_trace;

-- Create user
CREATE USER fraud_user WITH PASSWORD 'secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE fraud_trace TO fraud_user;
```

### Connection String

Update `application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/fraud_trace
    username: fraud_user
    password: ${DB_PASSWORD}
```

## Environment Variables

Create `.env` file (never commit):

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=fraud_trace
DB_USER=fraud_user
DB_PASSWORD=secure_password

# Corda RPC
CORDA_RPC_HOST=localhost
CORDA_RPC_PORT=10006
CORDA_RPC_USERNAME=user1
CORDA_RPC_PASSWORD=secure_password

# Secrets
JWT_SECRET=your-secret-key
ENCRYPTION_KEY=your-encryption-key

# External Services
AI_ENGINE_URL=http://ai-risk-engine:5001
LEA_BACKEND_URL=http://lea-backend:8080
```

## CI/CD Pipeline

### GitHub Actions Example

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build Docker images
        run: |
          docker build -t ai-risk-engine ./ai-risk-engine
          docker build -t lea-backend ./lea-backend
          docker build -t bank-api ./bank-api
          docker build -t lea-frontend ./lea-frontend
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/ai-risk-engine ai-risk-engine=ai-risk-engine:latest
          kubectl set image deployment/lea-backend lea-backend=lea-backend:latest
          kubectl set image deployment/bank-api bank-api=bank-api:latest
          kubectl set image deployment/lea-frontend lea-frontend=lea-frontend:latest
```

## Rollback Procedure

```bash
# Kubernetes
kubectl rollout undo deployment/ai-risk-engine

# Docker Compose
docker-compose down
docker-compose up -d --scale ai-risk-engine=0
# Deploy previous version
docker-compose up -d
```

## Backup and Recovery

### Corda Node Backup

```bash
# Backup node data
tar -czf corda-node-backup-$(date +%Y%m%d).tar.gz \
  /path/to/corda/nodes/NodeName/persistence.mv.db \
  /path/to/corda/nodes/NodeName/certificates
```

### Database Backup

```bash
# PostgreSQL backup
pg_dump -U fraud_user fraud_trace > backup-$(date +%Y%m%d).sql
```

### Recovery

```bash
# Restore database
psql -U fraud_user fraud_trace < backup-20251117.sql

# Restore Corda node
tar -xzf corda-node-backup-20251117.tar.gz -C /path/to/corda/nodes/
```

## Performance Tuning

### JVM Settings (Bank API)

```yaml
# application.yml
spring:
  jpa:
    properties:
      hibernate:
        jdbc:
          batch_size: 20
        order_inserts: true
        order_updates: true
```

### Python Settings (AI Engine)

```python
# Use gunicorn for production
gunicorn -w 4 -b 0.0.0.0:5001 app:app
```

### Node.js Settings (LEA Backend)

```javascript
// Use PM2 for production
pm2 start server.js -i max
```

## Scaling

### Horizontal Scaling

- **AI Risk Engine**: Stateless, easy to scale
- **LEA Backend**: Stateless, scale WebSocket servers
- **Bank API**: Stateless, scale with load balancer
- **LEA Frontend**: Use CDN for static assets

### Vertical Scaling

- Increase memory for JVM services
- Increase CPU for AI model inference
- Optimize database queries

## Monitoring Production

### Key Metrics

- Request rate
- Response time (p50, p95, p99)
- Error rate
- CPU/Memory usage
- Database connection pool
- WebSocket connections

### Alerts

- High error rate (> 1%)
- High response time (> 1s p95)
- Service down
- High memory usage (> 80%)
- Database connection pool exhausted

## Troubleshooting Production

### Service Not Responding

1. Check health endpoints
2. Check logs
3. Check resource usage
4. Check network connectivity
5. Check dependencies

### High Latency

1. Check database queries
2. Check external API calls
3. Check network latency
4. Check CPU usage
5. Check garbage collection

### Memory Issues

1. Check for memory leaks
2. Increase heap size
3. Check connection pools
4. Review caching strategy

