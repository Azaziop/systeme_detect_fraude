# Script de déploiement Docker + Kubernetes
# Ce script construit les images Docker et les déploie sur Kubernetes

Write-Host "🐳 Construction des images Docker..." -ForegroundColor Cyan

# Nom du registry Docker (modifiez selon votre registry)
$DOCKER_REGISTRY = "azaziop"  # Utilisez votre nom d'utilisateur Docker Hub
$VERSION = "latest"

# Construire les images
Write-Host "`n📦 Construction de l'image auth-service..." -ForegroundColor Yellow
docker build -t ${DOCKER_REGISTRY}/fraud-detection-auth:${VERSION} -f auth_service/Dockerfile .

Write-Host "`n📦 Construction de l'image transaction-service..." -ForegroundColor Yellow
docker build -t ${DOCKER_REGISTRY}/fraud-detection-transaction:${VERSION} -f transaction_service/Dockerfile .

Write-Host "`n📦 Construction de l'image fraud-detection-service..." -ForegroundColor Yellow
docker build -t ${DOCKER_REGISTRY}/fraud-detection-ml:${VERSION} -f fraud_detection_service/Dockerfile .

Write-Host "`n📦 Construction de l'image frontend..." -ForegroundColor Yellow
docker build -t ${DOCKER_REGISTRY}/fraud-detection-frontend:${VERSION} -f frontend/Dockerfile .

# Pousser les images vers Docker Hub
Write-Host "`n🚀 Push des images vers Docker Hub..." -ForegroundColor Cyan
Write-Host "⚠️  Assurez-vous d'être connecté avec: docker login" -ForegroundColor Yellow

docker push ${DOCKER_REGISTRY}/fraud-detection-auth:${VERSION}
docker push ${DOCKER_REGISTRY}/fraud-detection-transaction:${VERSION}
docker push ${DOCKER_REGISTRY}/fraud-detection-ml:${VERSION}
docker push ${DOCKER_REGISTRY}/fraud-detection-frontend:${VERSION}

Write-Host "`n✅ Images Docker construites et poussées!" -ForegroundColor Green

# Déploiement Kubernetes
Write-Host "`n☸️  Déploiement sur Kubernetes..." -ForegroundColor Cyan

# Créer le namespace
Write-Host "📦 Création du namespace..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

# Créer les secrets et configmaps
Write-Host "🔐 Application des secrets et configmaps..." -ForegroundColor Yellow
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/frontend-configmap.yaml

# Déployer les services
Write-Host "🚀 Déploiement des services..." -ForegroundColor Yellow
kubectl apply -f k8s/auth-service-deployment.yaml
kubectl apply -f k8s/transaction-service-deployment.yaml
kubectl apply -f k8s/fraud-detection-service-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

# Déployer l'ingress
Write-Host "🌐 Déploiement de l'ingress..." -ForegroundColor Yellow
kubectl apply -f k8s/ingress.yaml

Write-Host "`n✅ Déploiement Kubernetes terminé!" -ForegroundColor Green
Write-Host "`n📊 Vérification du statut des pods..." -ForegroundColor Cyan
kubectl get pods -n fraud-detection

Write-Host "`n📊 Services disponibles:" -ForegroundColor Cyan
kubectl get services -n fraud-detection

Write-Host "`n🎉 Déploiement complet!" -ForegroundColor Green
Write-Host "Pour acceder a l'application:" -ForegroundColor White
Write-Host "  - Frontend: http://localhost (via ingress)" -ForegroundColor White
Write-Host "  - Auth API: http://localhost/api/auth" -ForegroundColor White
Write-Host "  - Transaction API: http://localhost/api/transactions" -ForegroundColor White
Write-Host "  - Fraud Detection API: http://localhost/api/fraud" -ForegroundColor White
