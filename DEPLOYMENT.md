# Guide de Déploiement

Ce guide explique comment déployer le système de détection de fraude.

## Prérequis

- Docker et Docker Compose installés
- Python 3.9+ (pour l'entraînement du modèle)
- kubectl (pour Kubernetes)
- Accès à un cluster Kubernetes (GKE ou AKS)

## Étape 1: Entraîner le Modèle ML

Avant de déployer les services, vous devez entraîner le modèle ML:

```bash
cd ml_model
pip install -r requirements.txt
python train_model.py
```

Cela générera:
- `ml_model/models/isolation_forest_model.pkl`
- `ml_model/models/scaler.pkl`
- `ml_model/models/feature_columns.json`

## Étape 2: Déploiement Local avec Docker Compose

### 2.1 Construire les images

```bash
docker-compose build
```

### 2.2 Lancer les services

```bash
docker-compose up -d
```

### 2.3 Vérifier les services

```bash
# Vérifier les logs
docker-compose logs -f

# Vérifier les services
curl http://localhost:8000/api/users/  # Auth Service
curl http://localhost:8001/health      # Transaction Service
curl http://localhost:8002/health      # Fraud Detection Service
```

### 2.4 Arrêter les services

```bash
docker-compose down
```

## Étape 3: Déploiement sur Kubernetes

### 3.1 Préparer les images Docker

Vous devez pousser vos images vers un registry Docker accessible depuis votre cluster:

**Pour GKE (Google Container Registry):**
```bash
# Configurer Docker pour utiliser gcloud
gcloud auth configure-docker

# Taguer les images
docker tag fraud-detection/auth-service:latest gcr.io/PROJECT_ID/auth-service:latest
docker tag fraud-detection/transaction-service:latest gcr.io/PROJECT_ID/transaction-service:latest
docker tag fraud-detection/fraud-detection-service:latest gcr.io/PROJECT_ID/fraud-detection-service:latest

# Pousser les images
docker push gcr.io/PROJECT_ID/auth-service:latest
docker push gcr.io/PROJECT_ID/transaction-service:latest
docker push gcr.io/PROJECT_ID/fraud-detection-service:latest
```

**Pour AKS (Azure Container Registry):**
```bash
# Se connecter à ACR
az acr login --name REGISTRY_NAME

# Taguer les images
docker tag fraud-detection/auth-service:latest REGISTRY_NAME.azurecr.io/auth-service:latest
docker tag fraud-detection/transaction-service:latest REGISTRY_NAME.azurecr.io/transaction-service:latest
docker tag fraud-detection/fraud-detection-service:latest REGISTRY_NAME.azurecr.io/fraud-detection-service:latest

# Pousser les images
docker push REGISTRY_NAME.azurecr.io/auth-service:latest
docker push REGISTRY_NAME.azurecr.io/transaction-service:latest
docker push REGISTRY_NAME.azurecr.io/fraud-detection-service:latest
```

### 3.2 Mettre à jour les fichiers de déploiement

Modifiez les fichiers dans `k8s/*-deployment.yaml` pour utiliser vos images du registry.

### 3.3 Copier le modèle ML vers le cluster

```bash
# Créer un pod temporaire pour copier le modèle
kubectl create -f k8s/fraud-detection-service-deployment.yaml
kubectl wait --for=condition=ready pod -l app=fraud-detection-service -n fraud-detection

# Copier le modèle
kubectl cp ml_model/models/ fraud-detection/fraud-detection-service-XXXXX:/app/ml_model/
```

### 3.4 Appliquer les configurations Kubernetes

```bash
# Créer le namespace
kubectl apply -f k8s/namespace.yaml

# Créer les secrets (modifiez d'abord avec vos valeurs)
kubectl apply -f k8s/secrets.yaml

# Créer le ConfigMap
kubectl apply -f k8s/configmap.yaml

# Déployer les services
kubectl apply -f k8s/auth-service-deployment.yaml
kubectl apply -f k8s/fraud-detection-service-deployment.yaml
kubectl apply -f k8s/transaction-service-deployment.yaml

# Créer l'ingress (optionnel)
kubectl apply -f k8s/ingress.yaml
```

### 3.5 Vérifier le déploiement

```bash
# Vérifier les pods
kubectl get pods -n fraud-detection

# Vérifier les services
kubectl get services -n fraud-detection

# Voir les logs
kubectl logs -f deployment/auth-service -n fraud-detection
kubectl logs -f deployment/transaction-service -n fraud-detection
kubectl logs -f deployment/fraud-detection-service -n fraud-detection
```

## Étape 4: Tests

### Tester l'authentification

```bash
# S'inscrire
curl -X POST http://localhost:8000/api/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "testpass123",
    "password_confirm": "testpass123"
  }'

# Se connecter
curl -X POST http://localhost:8000/api/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "testpass123"
  }'
```

### Tester une transaction

```bash
curl -X POST http://localhost:8001/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "1",
    "amount": 100.50,
    "merchant": "Amazon",
    "category": "Shopping"
  }'
```

## Scaling

Pour augmenter le nombre de replicas:

```bash
kubectl scale deployment transaction-service --replicas=5 -n fraud-detection
```

## Monitoring

Considérez d'ajouter:
- Prometheus pour les métriques
- Grafana pour la visualisation
- ELK Stack pour les logs

## Sécurité

- Changez les secrets dans `k8s/secrets.yaml`
- Utilisez HTTPS en production
- Configurez des Network Policies
- Activez l'authentification mutuelle TLS entre services

