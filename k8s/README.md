# Déploiement Kubernetes

Ce dossier contient les configurations Kubernetes pour déployer le système de détection de fraude sur GKE (Google Kubernetes Engine) ou AKS (Azure Kubernetes Service).

## Prérequis

- `kubectl` installé et configuré
- Cluster Kubernetes (GKE ou AKS) créé et accessible
- Images Docker poussées vers un registry (GCR, ACR, Docker Hub, etc.)

## Étapes de déploiement

### 1. Construire et pousser les images Docker

```bash
# Construire les images
docker build -t fraud-detection/auth-service:latest ./auth_service
docker build -t fraud-detection/transaction-service:latest ./transaction_service
docker build -t fraud-detection/fraud-detection-service:latest ./fraud_detection_service

# Taguer pour votre registry (exemple avec GCR)
docker tag fraud-detection/auth-service:latest gcr.io/PROJECT_ID/auth-service:latest
docker tag fraud-detection/transaction-service:latest gcr.io/PROJECT_ID/transaction-service:latest
docker tag fraud-detection/fraud-detection-service:latest gcr.io/PROJECT_ID/fraud-detection-service:latest

# Pousser vers le registry
docker push gcr.io/PROJECT_ID/auth-service:latest
docker push gcr.io/PROJECT_ID/transaction-service:latest
docker push gcr.io/PROJECT_ID/fraud-detection-service:latest
```

### 2. Mettre à jour les images dans les fichiers de déploiement

Modifiez les fichiers `*-deployment.yaml` pour utiliser vos images du registry.

### 3. Entraîner le modèle ML

```bash
cd ml_model
python train_model.py
```

### 4. Créer un volume pour le modèle ML

```bash
# Créer un PVC et copier le modèle
kubectl apply -f fraud-detection-service-deployment.yaml
kubectl create job copy-ml-model --from=job/copy-ml-model-template
# Ou utiliser kubectl cp après création du pod
```

### 5. Appliquer les configurations

```bash
# Créer le namespace
kubectl apply -f namespace.yaml

# Créer les secrets (modifiez d'abord secrets.yaml avec vos valeurs)
kubectl apply -f secrets.yaml

# Créer le ConfigMap
kubectl apply -f configmap.yaml

# Déployer les services
kubectl apply -f auth-service-deployment.yaml
kubectl apply -f fraud-detection-service-deployment.yaml
kubectl apply -f transaction-service-deployment.yaml

# Créer l'ingress (optionnel)
kubectl apply -f ingress.yaml
```

### 6. Vérifier le déploiement

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

## Configuration GKE

```bash
# Se connecter à GKE
gcloud container clusters get-credentials CLUSTER_NAME --zone ZONE --project PROJECT_ID
```

## Configuration AKS

```bash
# Se connecter à AKS
az aks get-credentials --resource-group RESOURCE_GROUP --name CLUSTER_NAME
```

## Scaling

```bash
# Augmenter le nombre de replicas
kubectl scale deployment transaction-service --replicas=5 -n fraud-detection
```

## Mise à jour

```bash
# Mettre à jour une image
kubectl set image deployment/auth-service auth-service=NEW_IMAGE -n fraud-detection
kubectl rollout status deployment/auth-service -n fraud-detection
```

