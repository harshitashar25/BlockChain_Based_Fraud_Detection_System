# Documentation Index

Welcome to the Fraud Traceability System documentation! This index helps you navigate all available resources.

## 🚀 Quick Links

- **[Getting Started](GETTING_STARTED.md)** - Start here! Complete guide to get up and running
- **[Quick Start](QUICKSTART.md)** - 5-minute quick start guide
- **[Project Summary](PROJECT_SUMMARY.md)** - Overview of what's been built

## 📚 Core Documentation

### Main Documentation
- **[README.md](README.md)** - Complete system documentation
  - Architecture overview
  - Installation instructions
  - Configuration guide
  - API endpoints
  - Troubleshooting

### Guides
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Comprehensive getting started guide
- **[QUICKSTART.md](QUICKSTART.md)** - Fast track to running the system
- **[INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)** - Integration testing and component interaction
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production deployment strategies
- **[SECURITY.md](SECURITY.md)** - Security best practices and guidelines

### Reference
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - What's implemented and project structure
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

## 🛠️ Component Documentation

### Corda CorDapp
- **Location**: `cordapp/`
- **States**: `cordapp/contracts/src/main/kotlin/com/quadra/fraud/states/`
- **Contracts**: `cordapp/contracts/src/main/kotlin/com/quadra/fraud/contracts/`
- **Flows**: `cordapp/workflows/src/main/kotlin/com/quadra/fraud/flows/`

### Bank API (Spring Boot)
- **Location**: `bank-api/`
- **Configuration**: `bank-api/src/main/resources/application.yml`
- **Main Code**: `bank-api/src/main/kotlin/com/quadra/bankapi/`

### AI Risk Engine (Python Flask)
- **Location**: `ai-risk-engine/`
- **Main File**: `ai-risk-engine/app.py`
- **README**: `ai-risk-engine/README.md`

### LEA Backend (Node.js)
- **Location**: `lea-backend/`
- **Main File**: `lea-backend/server.js`
- **README**: `lea-backend/README.md`

### LEA Frontend (React)
- **Location**: `lea-frontend/`
- **Source**: `lea-frontend/src/`
- **README**: `lea-frontend/README.md`

## 🔧 Scripts and Utilities

### Setup Scripts
- **Linux/macOS**: `scripts/setup.sh`
- **Windows**: `scripts/setup.ps1`
- **Prerequisites Check**: `scripts/check-prerequisites.sh`

### Management Scripts
- **Start All**: `scripts/start-all.sh`
- **Stop All**: `scripts/stop-all.sh`
- **Test System**: `scripts/test-system.sh`

### Using Make (Linux/macOS)
```bash
make help          # Show all commands
make setup         # Setup dependencies
make start         # Start services
make stop          # Stop services
make test          # Run tests
make status        # Check status
```

## 📋 Configuration Files

### Example Configurations
- **Corda Node**: `configs/node.conf.example`
- **Bank API**: `bank-api/src/main/resources/application.yml`
- **Docker Compose**: `docker-compose.yml`

## 🐳 Docker

- **Docker Compose**: `docker-compose.yml`
- **Dockerfiles**: Each service has its own Dockerfile
- **Deployment**: See [DEPLOYMENT.md](DEPLOYMENT.md)

## 🧪 Testing

### Unit Tests
- **Corda Contracts**: `cordapp/contracts/src/test/kotlin/`
- **AI Engine**: `ai-risk-engine/test_risk_engine.py`

### Integration Tests
- **Script**: `scripts/test-system.sh`
- **Guide**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)

## 📖 Learning Path

### For New Users
1. Start with [GETTING_STARTED.md](GETTING_STARTED.md)
2. Follow [QUICKSTART.md](QUICKSTART.md) to run the system
3. Read [README.md](README.md) for full details

### For Developers
1. Review [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) for architecture
2. Explore code in each component directory
3. Read component-specific READMEs
4. Check [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for integration details

### For DevOps/Deployment
1. Read [DEPLOYMENT.md](DEPLOYMENT.md) for deployment strategies
2. Review [SECURITY.md](SECURITY.md) for security considerations
3. Check Docker configurations
4. Review Kubernetes examples

## 🔍 Finding Information

### By Topic

**Installation & Setup**
- [GETTING_STARTED.md](GETTING_STARTED.md)
- [QUICKSTART.md](QUICKSTART.md)
- `scripts/setup.sh`

**Configuration**
- [README.md](README.md) - Configuration section
- `configs/node.conf.example`
- `bank-api/src/main/resources/application.yml`

**API Documentation**
- [README.md](README.md) - API Endpoints section
- Component READMEs

**Testing**
- [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
- `scripts/test-system.sh`
- Component test files

**Deployment**
- [DEPLOYMENT.md](DEPLOYMENT.md)
- `docker-compose.yml`
- Kubernetes examples in DEPLOYMENT.md

**Security**
- [SECURITY.md](SECURITY.md)
- Security sections in [README.md](README.md)

**Troubleshooting**
- [README.md](README.md) - Troubleshooting section
- [GETTING_STARTED.md](GETTING_STARTED.md) - Troubleshooting section
- Component READMEs

## 📁 Project Structure

```
FraudTraceSystem/
├── cordapp/              # Corda blockchain application
├── bank-api/             # Spring Boot microservice
├── ai-risk-engine/       # Python Flask AI service
├── lea-backend/          # Node.js WebSocket server
├── lea-frontend/         # React dashboard
├── scripts/              # Helper scripts
├── configs/              # Configuration examples
├── docker-compose.yml    # Docker orchestration
└── Documentation files   # All .md files
```

## 🆘 Getting Help

1. **Check Documentation**: Start with relevant guide above
2. **Review Logs**: Check `logs/` directory
3. **Run Tests**: Use `scripts/test-system.sh`
4. **Check Health**: Use health endpoints or `make status`
5. **Review Configuration**: Verify all config files

## 📝 Contributing

When adding features or making changes:
1. Update relevant documentation
2. Add tests
3. Update [CHANGELOG.md](CHANGELOG.md)
4. Follow code style guidelines
5. Update this index if adding new docs

## 🔗 External Resources

- **Corda Documentation**: https://docs.corda.net/
- **Spring Boot**: https://spring.io/projects/spring-boot
- **React**: https://react.dev/
- **Docker**: https://docs.docker.com/
- **Kubernetes**: https://kubernetes.io/docs/

## 📊 Documentation Status

- ✅ Getting Started Guide
- ✅ Quick Start Guide
- ✅ Main README
- ✅ Integration Guide
- ✅ Deployment Guide
- ✅ Security Guide
- ✅ Project Summary
- ✅ Changelog
- ✅ Component READMEs
- ✅ Configuration Examples
- ✅ Script Documentation

---

**Last Updated**: 2025-11-17  
**Version**: 1.0.0

