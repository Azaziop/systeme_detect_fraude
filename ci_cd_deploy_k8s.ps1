# Script de déploiement CI/CD pour Kubernetes
# Ce script reproduit exactement ce que fait le pipeline GitLab CI/CD

param(
    [switch]$BuildOnly,
    [switch]$DeployOnly,
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     CI/CD - Déploiement Kubernetes Fraud Detection        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Variables
$AUTH_IMAGE = "fraud-detection-auth:latest"
$TRANSACTION_IMAGE = "fraud-detection-transaction:latest"
$FRAUD_IMAGE = "fraud-detection-ml:latest"
$FRONTEND_IMAGE = "fraud-detection-frontend:latest"

# ============================================
# STAGE: BUILD
# ============================================

if (-not $DeployOnly) {
    Write-Host "🐳 ÉTAPE 1/3: Construction des images Docker" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "📦 1/4 Building Auth Service..." -ForegroundColor Cyan
    docker build -t $AUTH_IMAGE -f auth_service/Dockerfile .
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "❌ Échec de la construction de l'image Auth Service" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Auth Service image built" -ForegroundColor Green
    Write-Host ""

    Write-Host "📦 2/4 Building Transaction Service..." -ForegroundColor Cyan
    docker build -t $TRANSACTION_IMAGE -f transaction_service/Dockerfile .
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "❌ Échec de la construction de l'image Transaction Service" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Transaction Service image built" -ForegroundColor Green
    Write-Host ""

    Write-Host "📦 3/4 Building Fraud Detection Service..." -ForegroundColor Cyan
    docker build -t $FRAUD_IMAGE -f fraud_detection_service/Dockerfile .
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "❌ Échec de la construction de l'image Fraud Detection Service" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Fraud Detection Service image built" -ForegroundColor Green
    Write-Host ""

    Write-Host "📦 4/4 Building Frontend..." -ForegroundColor Cyan
    docker build -t $FRONTEND_IMAGE -f frontend/Dockerfile .
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "❌ Échec de la construction de l'image Frontend" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Frontend image built" -ForegroundColor Green
    Write-Host ""

    Write-Host "🏷️ Tagging images for Kubernetes..." -ForegroundColor Cyan
    docker tag $AUTH_IMAGE systeme_detect_fraude-auth-service:latest
    docker tag $TRANSACTION_IMAGE systeme_detect_fraude-transaction-service:latest
    docker tag $FRAUD_IMAGE systeme_detect_fraude-fraud-detection-service:latest
    docker tag $FRONTEND_IMAGE systeme_detect_fraude-frontend:latest
    Write-Host "✓ All images tagged" -ForegroundColor Green
    Write-Host ""

    Write-Host "📋 Available images:" -ForegroundColor Cyan
    docker images | Select-String "fraud-detection|systeme_detect_fraude"
    Write-Host ""

    Write-Host "✅ Build completed successfully!" -ForegroundColor Green
    Write-Host ""
}

if ($BuildOnly) {
    Write-Host "🎉 Build terminé (mode BuildOnly activé)" -ForegroundColor Green
    exit 0
}

# ============================================
# STAGE: DEPLOY
# ============================================

Write-Host "☸️ ÉTAPE 2/3: Déploiement sur Kubernetes" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

Write-Host "🔍 Vérification du cluster Kubernetes..." -ForegroundColor Cyan
kubectl cluster-info
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Impossible de se connecter au cluster Kubernetes" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "📝 Application des manifestes Kubernetes..." -ForegroundColor Cyan
$manifests = @(
    @{Name="Namespace"; File="k8s/namespace.yaml"},
    @{Name="Secrets"; File="k8s/secrets.yaml"},
    @{Name="ConfigMap"; File="k8s/configmap.yaml"},
    @{Name="PostgreSQL"; File="k8s/postgres-deployment.yaml"},
    @{Name="Auth Service"; File="k8s/auth-service-deployment.yaml"},
    @{Name="Transaction Service"; File="k8s/transaction-service-deployment.yaml"},
    @{Name="Fraud Detection Service"; File="k8s/fraud-detection-service-deployment.yaml"},
    @{Name="Frontend"; File="k8s/frontend-deployment.yaml"}
)

foreach ($manifest in $manifests) {
    Write-Host "  → $($manifest.Name)..." -ForegroundColor Gray
    kubectl apply -f $manifest.File
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Échec de l'application de $($manifest.Name)" -ForegroundColor Red
        exit 1
    }
}
Write-Host "✓ Tous les manifestes appliqués" -ForegroundColor Green
Write-Host ""

Write-Host "⏳ Attente du déploiement (30s)..." -ForegroundColor Cyan
Start-Sleep -Seconds 30
Write-Host ""

Write-Host "📊 État des pods:" -ForegroundColor Cyan
kubectl get pods -n fraud-detection
Write-Host ""

Write-Host "🔄 Vérification du rollout..." -ForegroundColor Cyan
kubectl rollout status deployment/auth-service -n fraud-detection --timeout=120s
kubectl rollout status deployment/transaction-service -n fraud-detection --timeout=120s
kubectl rollout status deployment/fraud-detection-service -n fraud-detection --timeout=120s
kubectl rollout status deployment/frontend -n fraud-detection --timeout=120s
Write-Host ""

Write-Host "🌐 Services disponibles:" -ForegroundColor Cyan
kubectl get svc -n fraud-detection
Write-Host ""

Write-Host "✅ Déploiement Kubernetes terminé!" -ForegroundColor Green
Write-Host ""

# ============================================
# STAGE: SMOKE TESTS
# ============================================

if (-not $SkipTests) {
    Write-Host "🧪 ÉTAPE 3/3: Tests de fumée" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "🔗 Démarrage des port-forwards..." -ForegroundColor Cyan
    $pf1 = Start-Process powershell -PassThru -WindowStyle Hidden -ArgumentList "-Command", "kubectl port-forward svc/auth-service 8000:8000 -n fraud-detection"
    $pf2 = Start-Process powershell -PassThru -WindowStyle Hidden -ArgumentList "-Command", "kubectl port-forward svc/transaction-service 8001:8001 -n fraud-detection"
    $pf3 = Start-Process powershell -PassThru -WindowStyle Hidden -ArgumentList "-Command", "kubectl port-forward svc/fraud-detection-service 8002:8002 -n fraud-detection"
    $pf4 = Start-Process powershell -PassThru -WindowStyle Hidden -ArgumentList "-Command", "kubectl port-forward svc/frontend-service 3000:80 -n fraud-detection"
    
    Write-Host "⏳ Attente de l'initialisation (10s)..." -ForegroundColor Cyan
    Start-Sleep -Seconds 10
    Write-Host ""

    Write-Host "✅ Test des endpoints..." -ForegroundColor Cyan
    $allPassed = $true

    # Test Auth Service
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000" -TimeoutSec 5 -UseBasicParsing
        Write-Host "  ✓ Auth Service (8000) - Status $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Auth Service (8000) - Erreur: $($_.Exception.Message)" -ForegroundColor Red
        $allPassed = $false
    }

    # Test Transaction Service
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8001/health" -TimeoutSec 5 -UseBasicParsing
        Write-Host "  ✓ Transaction Service (8001) - Status $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Transaction Service (8001) - Erreur: $($_.Exception.Message)" -ForegroundColor Red
        $allPassed = $false
    }

    # Test Fraud Detection Service
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8002/health" -TimeoutSec 5 -UseBasicParsing
        Write-Host "  ✓ Fraud Detection Service (8002) - Status $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Fraud Detection Service (8002) - Erreur: $($_.Exception.Message)" -ForegroundColor Red
        $allPassed = $false
    }

    # Test Frontend
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 -UseBasicParsing
        Write-Host "  ✓ Frontend (3000) - Status $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Frontend (3000) - Erreur: $($_.Exception.Message)" -ForegroundColor Red
        $allPassed = $false
    }

    Write-Host ""
    Write-Host "🧹 Nettoyage des port-forwards..." -ForegroundColor Cyan
    Stop-Process -Id $pf1.Id -Force -ErrorAction SilentlyContinue
    Stop-Process -Id $pf2.Id -Force -ErrorAction SilentlyContinue
    Stop-Process -Id $pf3.Id -Force -ErrorAction SilentlyContinue
    Stop-Process -Id $pf4.Id -Force -ErrorAction SilentlyContinue
    Write-Host ""

    if ($allPassed) {
        Write-Host "✅ Tous les tests de fumée ont réussi!" -ForegroundColor Green
    } else {
        Write-Host "❌ Certains tests ont échoué" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              🎉 Déploiement terminé avec succès! 🎉        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 Pour accéder aux services:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward svc/auth-service 8000:8000 -n fraud-detection" -ForegroundColor Gray
Write-Host "  kubectl port-forward svc/transaction-service 8001:8001 -n fraud-detection" -ForegroundColor Gray
Write-Host "  kubectl port-forward svc/fraud-detection-service 8002:8002 -n fraud-detection" -ForegroundColor Gray
Write-Host "  kubectl port-forward svc/frontend-service 3000:80 -n fraud-detection" -ForegroundColor Gray
Write-Host ""
Write-Host "🌐 Frontend accessible sur: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
