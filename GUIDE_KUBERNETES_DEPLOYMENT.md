# Guide de Déploiement Kubernetes pour GitLab CI/CD

Ce guide vous explique comment configurer un cluster Kubernetes accessible et le connecter à votre pipeline GitLab.

## 📋 Vue d'Ensemble

Votre pipeline GitLab a besoin d'accéder à un cluster Kubernetes pour déployer les services. Actuellement, le job `deploy:k8s` est configuré en mode manuel et skip si le cluster n'est pas accessible.

## 🎯 Options de Cluster Kubernetes

### Option 1: Azure Kubernetes Service (AKS) - Recommandé pour Production

**Avantages:**
- Géré par Microsoft Azure
- Facile à configurer avec Azure CLI
- Intégration native avec GitLab
- Scalabilité automatique

**Étapes:**

1. **Installer Azure CLI**
```powershell
# Télécharger depuis https://aka.ms/installazurecliwindows
# Ou via winget
winget install Microsoft.AzureCLI
```

2. **Se connecter à Azure**
```powershell
az login
```

3. **Créer un groupe de ressources**
```powershell
az group create --name fraud-detection-rg --location westeurope
```

4. **Créer le cluster AKS**
```powershell
# Cluster minimal (gratuit pendant 12 mois avec Azure Free)
az aks create `
  --resource-group fraud-detection-rg `
  --name fraud-detection-cluster `
  --node-count 2 `
  --node-vm-size Standard_B2s `
  --enable-addons monitoring `
  --generate-ssh-keys

# Attendre 5-10 minutes pour la création
```

5. **Récupérer les credentials**
```powershell
az aks get-credentials --resource-group fraud-detection-rg --name fraud-detection-cluster

# Vérifier la connexion
kubectl cluster-info
kubectl get nodes
```

6. **Générer le KUBE_CONFIG pour GitLab**
```powershell
# Encoder le kubeconfig en base64
$kubeconfig = Get-Content -Path "$env:USERPROFILE\.kube\config" -Raw
$base64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($kubeconfig))
$base64 | Set-Clipboard
Write-Host "✅ KUBE_CONFIG copié dans le presse-papier"
```

### Option 2: Google Kubernetes Engine (GKE)

**Avantages:**
- Géré par Google Cloud
- Excellent support pour conteneurs
- Niveau gratuit disponible

**Étapes:**

1. **Installer gcloud CLI**
```powershell
# Télécharger depuis https://cloud.google.com/sdk/docs/install
```

2. **Se connecter et créer un projet**
```powershell
gcloud auth login
gcloud projects create fraud-detection-project --name="Fraud Detection"
gcloud config set project fraud-detection-project
```

3. **Activer l'API Kubernetes**
```powershell
gcloud services enable container.googleapis.com
```

4. **Créer le cluster**
```powershell
gcloud container clusters create fraud-detection-cluster `
  --zone europe-west1-b `
  --num-nodes 2 `
  --machine-type e2-small

# Récupérer les credentials
gcloud container clusters get-credentials fraud-detection-cluster --zone europe-west1-b
```

5. **Générer KUBE_CONFIG**
```powershell
$kubeconfig = Get-Content -Path "$env:USERPROFILE\.kube\config" -Raw
$base64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($kubeconfig))
$base64 | Set-Clipboard
```

### Option 3: Amazon EKS

**Avantages:**
- Géré par AWS
- Intégration avec l'écosystème AWS

**Étapes:**

1. **Installer AWS CLI et eksctl**
```powershell
# AWS CLI: https://aws.amazon.com/cli/
# eksctl: https://github.com/weksctl/eksctl
```

2. **Configurer AWS**
```powershell
aws configure
```

3. **Créer le cluster**
```powershell
eksctl create cluster `
  --name fraud-detection-cluster `
  --region eu-west-1 `
  --nodes 2 `
  --node-type t3.small

# Récupérer les credentials
aws eks update-kubeconfig --name fraud-detection-cluster --region eu-west-1
```

4. **Générer KUBE_CONFIG**
```powershell
$kubeconfig = Get-Content -Path "$env:USERPROFILE\.kube\config" -Raw
$base64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($kubeconfig))
$base64 | Set-Clipboard
```

### Option 4: Agent GitLab Kubernetes (Recommandé pour Sécurité)

**Avantages:**
- Pas besoin d'exposer l'API Kubernetes publiquement
- Plus sécurisé
- Fonctionne avec Docker Desktop ou tout cluster local

**Étapes:**

1. **Dans GitLab, créer un agent**
   - Allez sur votre projet → Infrastructure → Kubernetes clusters
   - Cliquez sur "Connect a cluster (agent)"
   - Nommez l'agent: `fraud-detection-agent`
   - Créez le fichier `.gitlab/agents/fraud-detection-agent/config.yaml`

2. **Créer la configuration de l'agent**
```powershell
New-Item -Path ".gitlab\agents\fraud-detection-agent" -ItemType Directory -Force
```

3. **Créer le fichier de configuration**
```yaml
# .gitlab/agents/fraud-detection-agent/config.yaml
ci_access:
  projects:
    - id: Azaziop/systeme_detect_fraude
      
kubernetes:
  - context: docker-desktop  # ou le nom de votre contexte
```

4. **Installer l'agent dans votre cluster**
```powershell
# GitLab vous donnera la commande helm exacte avec le token
helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install fraud-detection-agent gitlab/gitlab-agent `
  --namespace gitlab-agent `
  --create-namespace `
  --set config.token=<VOTRE_TOKEN> `
  --set config.kasAddress=wss://kas.gitlab.com
```

5. **Modifier le job CI pour utiliser l'agent**
   - Dans `.gitlab-ci.yml`, section `deploy:k8s`, remplacer la configuration kubeconfig par:
```yaml
before_script:
  - kubectl config use-context Azaziop/systeme_detect_fraude:fraud-detection-agent
```

## 🔧 Configuration de la Variable KUBE_CONFIG dans GitLab

### Méthode 1: Via l'Interface Web (Recommandée)

1. **Accéder aux Settings**
   - Ouvrez https://gitlab.com/Azaziop/systeme_detect_fraude
   - Allez dans **Settings** → **CI/CD**
   - Développez la section **Variables**

2. **Ajouter la variable**
   - Cliquez sur **Add variable**
   - **Key**: `KUBE_CONFIG`
   - **Value**: Collez le base64 généré précédemment (Ctrl+V)
   - **Type**: Variable
   - **Environment scope**: All (default)
   - **Flags**:
     - ✅ Protect variable (coché) - uniquement sur branches protégées
     - ✅ Mask variable (coché) - cache dans les logs
     - ❌ Expand variable reference (décoché)
   - Cliquez sur **Add variable**

3. **Vérifier**
   - La variable devrait apparaître dans la liste
   - Status: Protected, Masked

### Méthode 2: Via GitLab CLI (glab)

```powershell
# Installer glab
winget install GitLab.glab

# Se connecter
glab auth login

# Ajouter la variable
$base64 = Get-Clipboard
glab variable set KUBE_CONFIG -v $base64 --protected --masked
```

## 🚀 Déclencher le Déploiement Kubernetes

### Via l'Interface Web

1. **Accéder au Pipeline**
   - Ouvrez https://gitlab.com/Azaziop/systeme_detect_fraude/-/pipelines
   - Trouvez le dernier pipeline (commit `b2ca5781` ou plus récent)

2. **Lancer le job manuel**
   - Cliquez sur le pipeline
   - Trouvez le stage **deploy**
   - Vous verrez le job `deploy:k8s` avec un bouton ▶️ (play)
   - Cliquez sur le bouton pour lancer le job

3. **Suivre l'exécution**
   - Cliquez sur le job pour voir les logs en temps réel
   - Vérifiez que:
     - ✅ Kubeconfig configuré
     - ✅ Cluster accessible
     - ✅ Namespace créé
     - ✅ Déploiements appliqués
     - ✅ Pods en cours d'exécution

### Via GitLab CLI

```powershell
# Lister les pipelines
glab ci list

# Lancer le job manuel du dernier pipeline
glab ci run deploy:k8s

# Voir les logs
glab ci trace
```

## ✅ Vérification Post-Déploiement

### Sur GitLab

Vérifiez les logs du job pour confirmer:
```
✓ Kubernetes deployment completed successfully
```

### Localement avec kubectl

```powershell
# Se connecter au cluster
kubectl config use-context <votre-contexte>

# Vérifier le namespace
kubectl get namespace fraud-detection

# Vérifier les déploiements
kubectl get deployments -n fraud-detection
kubectl get pods -n fraud-detection
kubectl get services -n fraud-detection

# Vérifier l'ingress
kubectl get ingress -n fraud-detection

# Logs d'un service
kubectl logs -n fraud-detection -l app=auth-service --tail=50
kubectl logs -n fraud-detection -l app=transaction-service --tail=50
kubectl logs -n fraud-detection -l app=fraud-detection-service --tail=50
```

## 🌐 Accéder aux Services Déployés

### Si vous utilisez un cluster cloud (AKS/GKE/EKS)

```powershell
# Obtenir l'IP publique de l'ingress
kubectl get ingress -n fraud-detection

# Ou via les services LoadBalancer
kubectl get services -n fraud-detection
```

L'URL sera affichée dans la colonne EXTERNAL-IP.

### Si vous utilisez Docker Desktop

```powershell
# Les services seront accessibles via localhost
# Auth Service: http://localhost/auth ou http://localhost:8000
# Transaction Service: http://localhost/transactions ou http://localhost:8001
# Fraud Detection: http://localhost/fraud ou http://localhost:8002
```

### Tester les endpoints

```powershell
# Health checks
Invoke-WebRequest -Uri "http://<EXTERNAL-IP>/auth/health" -Method GET
Invoke-WebRequest -Uri "http://<EXTERNAL-IP>/transactions/health" -Method GET
Invoke-WebRequest -Uri "http://<EXTERNAL-IP>/fraud/health" -Method GET

# Swagger docs
Start-Process "http://<EXTERNAL-IP>/auth/api/docs/"
Start-Process "http://<EXTERNAL-IP>/transactions/docs"
Start-Process "http://<EXTERNAL-IP>/fraud/docs"
```

## 🔄 Mises à Jour et Redéploiements

### Déploiement Automatique

Chaque push sur `main` ou `develop` va:
1. ✅ Build les images Docker
2. ✅ Push vers GitLab Container Registry
3. ⏸️ Attendre déclenchement manuel du job `deploy:k8s`

### Déploiement Manuel

1. Poussez vos changements: `git push origin main`
2. Attendez que les jobs de build se terminent
3. Déclenchez manuellement `deploy:k8s`

### Rollback en cas de problème

```powershell
# Voir l'historique des déploiements
kubectl rollout history deployment/auth-service -n fraud-detection

# Revenir à la version précédente
kubectl rollout undo deployment/auth-service -n fraud-detection
kubectl rollout undo deployment/transaction-service -n fraud-detection
kubectl rollout undo deployment/fraud-detection-service -n fraud-detection
```

## 🛡️ Sécurité et Bonnes Pratiques

### 1. Protéger les Secrets

```powershell
# Créer des secrets Kubernetes pour les données sensibles
kubectl create secret generic fraud-detection-secrets `
  --from-literal=DATABASE_PASSWORD=<password> `
  --from-literal=JWT_SECRET=<secret> `
  -n fraud-detection
```

### 2. Limiter les Ressources

Dans vos manifests K8s, ajoutez:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### 3. Health Checks

Assurez-vous que vos déploiements ont:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 30
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 10
  periodSeconds: 5
```

### 4. Monitoring

```powershell
# Installer Prometheus et Grafana (optionnel)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

## 🆘 Dépannage

### Job échoue: "Unable to connect to the server"

**Cause**: Le kubeconfig est incorrect ou le cluster n'est pas accessible depuis GitLab.

**Solution**:
1. Vérifiez que le cluster a une IP publique ou utilisez l'agent GitLab
2. Régénérez le KUBE_CONFIG et mettez à jour la variable GitLab
3. Vérifiez les règles de firewall du cluster

### Job échoue: "context deadline exceeded"

**Cause**: Les images Docker sont trop lentes à démarrer ou les pods n'ont pas assez de ressources.

**Solution**:
1. Augmentez le timeout dans `.gitlab-ci.yml`: `--timeout=10m`
2. Vérifiez les ressources du cluster: `kubectl top nodes`
3. Vérifiez les logs des pods: `kubectl logs -n fraud-detection <pod-name>`

### Images non trouvées

**Cause**: Le cluster ne peut pas accéder au GitLab Container Registry.

**Solution**:
```powershell
# Créer un secret pour le registry GitLab
kubectl create secret docker-registry gitlab-registry `
  --docker-server=registry.gitlab.com `
  --docker-username=<votre-username> `
  --docker-password=<token> `
  --docker-email=<votre-email> `
  -n fraud-detection

# Ajouter dans vos déploiements:
# imagePullSecrets:
#   - name: gitlab-registry
```

## 📚 Ressources Supplémentaires

- [GitLab Kubernetes Agent Documentation](https://docs.gitlab.com/ee/user/clusters/agent/)
- [Azure AKS Documentation](https://docs.microsoft.com/azure/aks/)
- [Google GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

**Prochaines étapes recommandées:**
1. ✅ Choisir une option de cluster (AKS recommandé pour démarrer)
2. ✅ Créer le cluster
3. ✅ Configurer KUBE_CONFIG dans GitLab
4. ✅ Déclencher le déploiement
5. ✅ Vérifier que les services sont accessibles
6. 🚀 Profiter de votre système de détection de fraude déployé!
