# PowerShell Setup Script for Windows

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Fraud Traceability System - Setup Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check prerequisites
Write-Host "`nChecking prerequisites..." -ForegroundColor Yellow

function Test-Command {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

if (-not (Test-Command java)) {
    Write-Host "✗ Java: NOT FOUND" -ForegroundColor Red
    Write-Host "  Install Java 17: https://adoptium.net/" -ForegroundColor Yellow
} else {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "✓ Java: $javaVersion" -ForegroundColor Green
}

if (-not (Test-Command python)) {
    Write-Host "✗ Python: NOT FOUND" -ForegroundColor Red
    Write-Host "  Install Python 3.11+: https://www.python.org/" -ForegroundColor Yellow
} else {
    $pythonVersion = python --version
    Write-Host "✓ Python: $pythonVersion" -ForegroundColor Green
}

if (-not (Test-Command node)) {
    Write-Host "✗ Node.js: NOT FOUND" -ForegroundColor Red
    Write-Host "  Install Node.js 18+: https://nodejs.org/" -ForegroundColor Yellow
} else {
    $nodeVersion = node --version
    Write-Host "✓ Node.js: $nodeVersion" -ForegroundColor Green
}

if (-not (Test-Command npm)) {
    Write-Host "✗ npm: NOT FOUND" -ForegroundColor Red
} else {
    $npmVersion = npm --version
    Write-Host "✓ npm: $npmVersion" -ForegroundColor Green
}

# Setup Python virtual environment
Write-Host "`nSetting up Python virtual environment..." -ForegroundColor Yellow
Set-Location ai-risk-engine
if (-not (Test-Path venv)) {
    python -m venv venv
    Write-Host "Created virtual environment" -ForegroundColor Green
}
.\venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt
Write-Host "Python dependencies installed" -ForegroundColor Green
deactivate
Set-Location ..

# Setup Node.js dependencies
Write-Host "`nSetting up Node.js dependencies..." -ForegroundColor Yellow

Write-Host "Installing LEA Backend dependencies..."
Set-Location lea-backend
npm install
Set-Location ..

Write-Host "Installing LEA Frontend dependencies..."
Set-Location lea-frontend
npm install
Set-Location ..

Write-Host "Node.js dependencies installed" -ForegroundColor Green

# Create directories
Write-Host "`nCreating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path logs | Out-Null
New-Item -ItemType Directory -Force -Path cordapp\build\nodes | Out-Null
Write-Host "Directories created" -ForegroundColor Green

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Configure Corda nodes (see examples in configs/)"
Write-Host "2. Build Corda CorDapp: cd cordapp && .\gradlew.bat deployNodes"
Write-Host "3. Start services manually or use Docker Compose"
Write-Host ""
