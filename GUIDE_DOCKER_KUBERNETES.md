# Guide de Déploiement Docker + Kubernetes

## 📋 Prérequis

1. **Docker Desktop** installé et en cours d'exécution
2. **Kubernetes activé** dans Docker Desktop (Settings → Kubernetes → Enable Kubernetes)
3. **kubectl** installé
4. Compte **Docker Hub** (pour pousser les images)

## 🚀 Option 1: Déploiement Complet (Docker + Kubernetes)

### Étape 1: Connexion à Docker Hub

```powershell
docker login
```

Entrez votre nom d'utilisateur et mot de passe Docker Hub.

### Étape 2: Modifier le nom du registry

Ouvrez `deploy_docker_k8s.ps1` et modifiez la ligne:
```powershell
$DOCKER_REGISTRY = "azaziop"  # Remplacez par VOTRE nom d'utilisateur Docker Hub
```

### Étape 3: Construire et déployer

```powershell
.\deploy_docker_k8s.ps1
```

Ce script va:
- ✅ Construire les 4 images Docker
- ✅ Les pousser vers Docker Hub
- ✅ Créer le namespace Kubernetes
- ✅ Déployer tous les services sur Kubernetes
- ✅ Configurer l'ingress

### Étape 4: Vérifier le déploiement

```powershell
# Voir les pods
kubectl get pods -n fraud-detection

# Voir les services
kubectl get services -n fraud-detection

# Voir les logs d'un pod
kubectl logs -n fraud-detection <nom-du-pod>
```

## 🐳 Option 2: Construire les Images Localement (sans push)

Si vous voulez juste construire les images Docker sans les pousser:

```powershell
.\build_docker_images.ps1
```

Puis vérifier:
```powershell
docker images
```

## 🔧 Option 3: Utiliser Docker Compose (Local Simple)

Pour un déploiement local rapide sans Kubernetes:

```powershell
docker-compose up -d
```

Arrêter:
```powershell
docker-compose down
```

## 📊 Vérification et Monitoring

### Voir le statut de tous les pods
```powershell
kubectl get all -n fraud-detection
```

### Accéder à un service
```powershell
# Port-forward pour accéder localement
kubectl port-forward -n fraud-detection svc/auth-service 8000:8000
kubectl port-forward -n fraud-detection svc/transaction-service 8001:8001
kubectl port-forward -n fraud-detection svc/fraud-detection-service 8002:8002
kubectl port-forward -n fraud-detection svc/frontend 3000:80
```

### Voir les logs en temps réel
```powershell
kubectl logs -f -n fraud-detection deployment/auth-service
kubectl logs -f -n fraud-detection deployment/transaction-service
kubectl logs -f -n fraud-detection deployment/fraud-detection-service
```

## 🔄 Mise à jour d'un service

### Reconstruire une image
```powershell
docker build -t azaziop/fraud-detection-auth:latest -f auth_service/Dockerfile .
docker push azaziop/fraud-detection-auth:latest
```

### Redémarrer le déploiement
```powershell
kubectl rollout restart deployment/auth-service -n fraud-detection
```

## 🧹 Nettoyage

### Supprimer tout le déploiement Kubernetes
```powershell
kubectl delete namespace fraud-detection
```

### Supprimer les images Docker locales
```powershell
docker rmi fraud-detection-auth:latest
docker rmi fraud-detection-transaction:latest
docker rmi fraud-detection-ml:latest
docker rmi fraud-detection-frontend:latest
```

## 🌐 URLs d'accès

Après déploiement avec ingress:
- **Frontend**: http://localhost
- **Auth API**: http://localhost/api/auth/docs
- **Transaction API**: http://localhost/api/transactions/docs
- **Fraud Detection API**: http://localhost/api/fraud/docs

## ⚠️ Dépannage

### Les pods ne démarrent pas
```powershell
kubectl describe pod -n fraud-detection <nom-pod>
kubectl logs -n fraud-detection <nom-pod>
```

### Problème de connexion à la base de données
Vérifiez que les secrets sont correctement configurés:
```powershell
kubectl get secrets -n fraud-detection
kubectl describe secret db-credentials -n fraud-detection
```

### Images non trouvées
Assurez-vous que les images sont poussées vers Docker Hub et que le nom correspond dans les fichiers YAML.

## 📝 Structure des fichiers

```
detec_fraude/
├── auth_service/
│   └── Dockerfile
├── transaction_service/
│   └── Dockerfile
├── fraud_detection_service/
│   └── Dockerfile
├── frontend/
│   └── Dockerfile
├── k8s/
│   ├── namespace.yaml
│   ├── secrets.yaml
│   ├── configmap.yaml
│   ├── *-deployment.yaml
│   └── ingress.yaml
├── deploy_docker_k8s.ps1       # Déploiement complet
├── build_docker_images.ps1      # Construction uniquement
└── docker-compose.yml           # Alternative Docker Compose
```

## 🎯 Prochaines étapes

1. **Production**: Utilisez un registry privé (Azure Container Registry, AWS ECR, etc.)
2. **CI/CD**: Intégrez la construction et le déploiement dans GitLab CI
3. **Monitoring**: Ajoutez Prometheus et Grafana
4. **Scaling**: Configurez l'autoscaling horizontal (HPA)
