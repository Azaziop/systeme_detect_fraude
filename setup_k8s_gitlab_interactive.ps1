# Script PowerShell - Configuration Rapide Kubernetes pour GitLab
# Usage: .\setup_k8s_gitlab.ps1 -Provider <AKS|GKE|EKS|Agent>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("AKS", "GKE", "EKS", "Agent", "DockerDesktop")]
    [string]$Provider
)

Write-Host "🚀 Configuration Kubernetes pour GitLab CI/CD" -ForegroundColor Cyan
Write-Host "Provider sélectionné: $Provider" -ForegroundColor Yellow
Write-Host ""

function Get-Base64Kubeconfig {
    $kubeconfigPath = "$env:USERPROFILE\.kube\config"
    
    if (-not (Test-Path $kubeconfigPath)) {
        Write-Host "❌ Kubeconfig non trouvé: $kubeconfigPath" -ForegroundColor Red
        return $null
    }
    
    $kubeconfig = Get-Content -Path $kubeconfigPath -Raw
    $base64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($kubeconfig))
    return $base64
}

function Test-CommandExists {
    param($Command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command $Command) { return $true }
    }
    catch { return $false }
    finally { $ErrorActionPreference = $oldPreference }
}

# Configuration Azure AKS
if ($Provider -eq "AKS") {
    Write-Host "📦 Configuration Azure Kubernetes Service (AKS)" -ForegroundColor Cyan
    
    # Vérifier az CLI
    if (-not (Test-CommandExists "az")) {
        Write-Host "❌ Azure CLI non installé" -ForegroundColor Red
        Write-Host "Installez via: winget install Microsoft.AzureCLI" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "✅ Azure CLI trouvé" -ForegroundColor Green
    
    # Login Azure
    Write-Host "`n🔐 Connexion à Azure..." -ForegroundColor Cyan
    az login
    
    # Demander les paramètres
    $resourceGroup = Read-Host "Nom du resource group (défaut: fraud-detection-rg)"
    if ([string]::IsNullOrWhiteSpace($resourceGroup)) { $resourceGroup = "fraud-detection-rg" }
    
    $clusterName = Read-Host "Nom du cluster (défaut: fraud-detection-cluster)"
    if ([string]::IsNullOrWhiteSpace($clusterName)) { $clusterName = "fraud-detection-cluster" }
    
    $location = Read-Host "Région Azure (défaut: westeurope)"
    if ([string]::IsNullOrWhiteSpace($location)) { $location = "westeurope" }
    
    # Créer le resource group
    Write-Host "`n📁 Création du resource group..." -ForegroundColor Cyan
    az group create --name $resourceGroup --location $location
    
    # Créer le cluster
    Write-Host "`n☸️ Création du cluster AKS (cela peut prendre 5-10 minutes)..." -ForegroundColor Cyan
    az aks create `
        --resource-group $resourceGroup `
        --name $clusterName `
        --node-count 2 `
        --node-vm-size Standard_B2s `
        --enable-addons monitoring `
        --generate-ssh-keys
    
    # Récupérer les credentials
    Write-Host "`n🔑 Récupération des credentials..." -ForegroundColor Cyan
    az aks get-credentials --resource-group $resourceGroup --name $clusterName --overwrite-existing
    
    # Tester la connexion
    Write-Host "`n✅ Test de connexion au cluster..." -ForegroundColor Cyan
    kubectl cluster-info
    kubectl get nodes
}

# Configuration Google GKE
elseif ($Provider -eq "GKE") {
    Write-Host "📦 Configuration Google Kubernetes Engine (GKE)" -ForegroundColor Cyan
    
    if (-not (Test-CommandExists "gcloud")) {
        Write-Host "❌ gcloud CLI non installé" -ForegroundColor Red
        Write-Host "Téléchargez depuis: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "✅ gcloud CLI trouvé" -ForegroundColor Green
    
    # Login Google Cloud
    Write-Host "`n🔐 Connexion à Google Cloud..." -ForegroundColor Cyan
    gcloud auth login
    
    $projectId = Read-Host "Project ID (défaut: fraud-detection-project)"
    if ([string]::IsNullOrWhiteSpace($projectId)) { $projectId = "fraud-detection-project" }
    
    $clusterName = Read-Host "Nom du cluster (défaut: fraud-detection-cluster)"
    if ([string]::IsNullOrWhiteSpace($clusterName)) { $clusterName = "fraud-detection-cluster" }
    
    $zone = Read-Host "Zone (défaut: europe-west1-b)"
    if ([string]::IsNullOrWhiteSpace($zone)) { $zone = "europe-west1-b" }
    
    # Créer ou sélectionner le projet
    Write-Host "`n📁 Configuration du projet..." -ForegroundColor Cyan
    gcloud config set project $projectId
    
    # Activer l'API
    Write-Host "`n🔌 Activation de l'API Kubernetes..." -ForegroundColor Cyan
    gcloud services enable container.googleapis.com
    
    # Créer le cluster
    Write-Host "`n☸️ Création du cluster GKE (cela peut prendre 5-10 minutes)..." -ForegroundColor Cyan
    gcloud container clusters create $clusterName `
        --zone $zone `
        --num-nodes 2 `
        --machine-type e2-small
    
    # Récupérer les credentials
    Write-Host "`n🔑 Récupération des credentials..." -ForegroundColor Cyan
    gcloud container clusters get-credentials $clusterName --zone $zone
    
    # Tester
    Write-Host "`n✅ Test de connexion au cluster..." -ForegroundColor Cyan
    kubectl cluster-info
    kubectl get nodes
}

# Configuration AWS EKS
elseif ($Provider -eq "EKS") {
    Write-Host "📦 Configuration Amazon Elastic Kubernetes Service (EKS)" -ForegroundColor Cyan
    
    if (-not (Test-CommandExists "eksctl")) {
        Write-Host "❌ eksctl non installé" -ForegroundColor Red
        Write-Host "Installez via: choco install eksctl" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "✅ eksctl trouvé" -ForegroundColor Green
    
    $clusterName = Read-Host "Nom du cluster (défaut: fraud-detection-cluster)"
    if ([string]::IsNullOrWhiteSpace($clusterName)) { $clusterName = "fraud-detection-cluster" }
    
    $region = Read-Host "Région AWS (défaut: eu-west-1)"
    if ([string]::IsNullOrWhiteSpace($region)) { $region = "eu-west-1" }
    
    # Créer le cluster
    Write-Host "`n☸️ Création du cluster EKS (cela peut prendre 15-20 minutes)..." -ForegroundColor Cyan
    eksctl create cluster `
        --name $clusterName `
        --region $region `
        --nodes 2 `
        --node-type t3.small
    
    # Les credentials sont automatiquement configurés
    Write-Host "`n✅ Test de connexion au cluster..." -ForegroundColor Cyan
    kubectl cluster-info
    kubectl get nodes
}

# Configuration Docker Desktop
elseif ($Provider -eq "DockerDesktop") {
    Write-Host "📦 Configuration Docker Desktop Kubernetes" -ForegroundColor Cyan
    
    Write-Host "`n⚠️ Assurez-vous que:" -ForegroundColor Yellow
    Write-Host "  1. Docker Desktop est installé et en cours d'exécution" -ForegroundColor Yellow
    Write-Host "  2. Kubernetes est activé dans Docker Desktop (Settings > Kubernetes > Enable)" -ForegroundColor Yellow
    Write-Host ""
    
    $continue = Read-Host "Docker Desktop Kubernetes est-il activé? (o/n)"
    if ($continue -ne "o" -and $continue -ne "O") {
        Write-Host "❌ Activez Kubernetes dans Docker Desktop puis relancez ce script" -ForegroundColor Red
        exit 1
    }
    
    # Vérifier la connexion
    Write-Host "`n✅ Test de connexion au cluster local..." -ForegroundColor Cyan
    kubectl config use-context docker-desktop
    kubectl cluster-info
    kubectl get nodes
    
    Write-Host "`n⚠️ IMPORTANT pour GitLab:" -ForegroundColor Yellow
    Write-Host "Docker Desktop n'est PAS accessible depuis les runners GitLab SaaS." -ForegroundColor Yellow
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  1. Utilisez l'Agent GitLab (recommandé)" -ForegroundColor Cyan
    Write-Host "  2. Exposez votre cluster via ngrok/cloudflare tunnel" -ForegroundColor Cyan
    Write-Host "  3. Utilisez un cluster cloud (AKS/GKE/EKS)" -ForegroundColor Cyan
}

# Génération du KUBE_CONFIG en base64
Write-Host "`n📋 Génération du KUBE_CONFIG pour GitLab..." -ForegroundColor Cyan

$base64 = Get-Base64Kubeconfig

if ($null -eq $base64) {
    Write-Host "❌ Impossible de générer le KUBE_CONFIG" -ForegroundColor Red
    exit 1
}

# Copier dans le presse-papier
$base64 | Set-Clipboard
Write-Host "✅ KUBE_CONFIG encodé en base64 et copié dans le presse-papier!" -ForegroundColor Green

# Afficher les instructions
Write-Host "`n" -NoNewline
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PROCHAINES ÉTAPES" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "1️⃣  Ajouter la variable dans GitLab:" -ForegroundColor Yellow
Write-Host "    https://gitlab.com/Azaziop/systeme_detect_fraude/-/settings/ci_cd" -ForegroundColor White
Write-Host ""
Write-Host "2️⃣  Dans la section 'Variables', cliquez sur 'Add variable':" -ForegroundColor Yellow
Write-Host "    - Key:   KUBE_CONFIG" -ForegroundColor White
Write-Host "    - Value: [Collez depuis le presse-papier avec Ctrl+V]" -ForegroundColor White
Write-Host "    - Type:  Variable" -ForegroundColor White
Write-Host "    - Flags: ✅ Protect variable, ✅ Mask variable" -ForegroundColor White
Write-Host ""
Write-Host "3️⃣  Déclencher le déploiement:" -ForegroundColor Yellow
Write-Host "    - Allez sur: https://gitlab.com/Azaziop/systeme_detect_fraude/-/pipelines" -ForegroundColor White
Write-Host "    - Trouvez le dernier pipeline" -ForegroundColor White
Write-Host "    - Cliquez sur le bouton ▶️ du job 'deploy:k8s'" -ForegroundColor White
Write-Host ""
Write-Host "4️⃣  Vérifier le déploiement:" -ForegroundColor Yellow
Write-Host "    kubectl get all -n fraud-detection" -ForegroundColor White
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Ouvrir automatiquement les pages nécessaires
$openBrowser = Read-Host "Voulez-vous ouvrir les pages GitLab dans le navigateur? (o/n)"
if ($openBrowser -eq "o" -or $openBrowser -eq "O") {
    Start-Process "https://gitlab.com/Azaziop/systeme_detect_fraude/-/settings/ci_cd"
    Start-Sleep -Seconds 2
    Start-Process "https://gitlab.com/Azaziop/systeme_detect_fraude/-/pipelines"
}

Write-Host "✅ Configuration terminée!" -ForegroundColor Green
