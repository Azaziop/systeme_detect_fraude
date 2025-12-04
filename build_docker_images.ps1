# Script pour construire uniquement les images Docker
# Utilisez ce script si vous voulez juste construire les images localement

Write-Host "Construction des images Docker..." -ForegroundColor Cyan

# Construire les images localement
Write-Host "`nConstruction de auth-service..." -ForegroundColor Yellow
docker build -t fraud-detection-auth:latest -f auth_service/Dockerfile .

Write-Host "`nConstruction de transaction-service..." -ForegroundColor Yellow
docker build -t fraud-detection-transaction:latest -f transaction_service/Dockerfile .

Write-Host "`nConstruction de fraud-detection-service..." -ForegroundColor Yellow
docker build -t fraud-detection-ml:latest -f fraud_detection_service/Dockerfile .

Write-Host "`nConstruction de frontend..." -ForegroundColor Yellow
docker build -t fraud-detection-frontend:latest -f frontend/Dockerfile .

Write-Host "`nToutes les images sont construites!" -ForegroundColor Green

# Afficher les images
Write-Host "`nImages disponibles:" -ForegroundColor Cyan
docker images | Select-String "fraud-detection"

Write-Host "`nProchaines etapes:" -ForegroundColor Yellow
Write-Host "  1. Pour pousser vers Docker Hub: docker login puis docker push IMAGE_NAME" -ForegroundColor White
Write-Host "  2. Pour deployer sur Kubernetes: .\deploy_docker_k8s.ps1" -ForegroundColor White
Write-Host "  3. Pour demarrer avec Docker Compose: docker-compose up -d" -ForegroundColor White
