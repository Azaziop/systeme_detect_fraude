# Script pour deployer les images Docker existantes sur Kubernetes
# Les images ont deja ete construites localement avec build_docker_images.ps1

Write-Host "Deploiement sur Kubernetes..." -ForegroundColor Cyan

# Creer le namespace
Write-Host "`nCreation du namespace..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

# Creer les secrets
Write-Host "`nCreation des secrets..." -ForegroundColor Yellow
kubectl apply -f k8s/secrets.yaml

# Creer les configmaps
Write-Host "`nCreation des configmaps..." -ForegroundColor Yellow
kubectl apply -f k8s/configmap.yaml

# Deployer les services
Write-Host "`nDeploiement des services..." -ForegroundColor Yellow
kubectl apply -f k8s/auth-service-deployment.yaml
kubectl apply -f k8s/transaction-service-deployment.yaml
kubectl apply -f k8s/fraud-detection-service-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

# Deployer les services Kubernetes
Write-Host "`nExposition des services..." -ForegroundColor Yellow
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/ingress.yaml

Write-Host "`nVerification du statut des pods..." -ForegroundColor Cyan
Start-Sleep -Seconds 3
kubectl get pods -n fraud-detection

Write-Host "`nServices disponibles:" -ForegroundColor Cyan
kubectl get services -n fraud-detection

Write-Host "`nDeploiement termine!" -ForegroundColor Green
Write-Host "Pour acceder a l'application:" -ForegroundColor White
Write-Host "  - Frontend: http://localhost" -ForegroundColor White
Write-Host "  - Auth API: http://localhost:30001" -ForegroundColor White
Write-Host "  - Transaction API: http://localhost:30002" -ForegroundColor White
Write-Host "  - Fraud Detection API: http://localhost:30003" -ForegroundColor White
