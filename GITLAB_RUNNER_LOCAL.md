# Guide: Déploiement Local Automatique via GitLab CI/CD

Ce guide explique comment configurer un GitLab Runner local pour que votre pipeline GitLab déploie automatiquement sur votre machine Windows.

## 🎯 Vue d'Ensemble

Au lieu d'utiliser les runners SaaS de GitLab (qui tournent sur leurs serveurs), vous allez installer un runner sur votre machine locale qui:
- ✅ Écoute les nouveaux commits sur GitLab
- ✅ Exécute automatiquement le pipeline
- ✅ Déploie les services directement sur votre machine locale

## 📋 Prérequis

- ✅ Windows 10/11
- ✅ PowerShell 5.1+
- ✅ Droits administrateur
- ✅ Projet GitLab accessible

## 🚀 Étape 1: Installer GitLab Runner sur Windows

### Télécharger GitLab Runner

```powershell
# Créer le dossier pour GitLab Runner
New-Item -Path "C:\GitLab-Runner" -ItemType Directory -Force
cd C:\GitLab-Runner

# Télécharger la dernière version
Invoke-WebRequest -Uri "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe" -OutFile "gitlab-runner.exe"
```

### Installer comme Service Windows

```powershell
# Installer le service (exécuter en tant qu'administrateur)
.\gitlab-runner.exe install

# Démarrer le service
.\gitlab-runner.exe start
```

## 🔧 Étape 2: Enregistrer le Runner avec Votre Projet GitLab

### Obtenir le Token d'Enregistrement

1. Allez sur votre projet GitLab:
   https://gitlab.com/Azaziop/systeme_detect_fraude

2. **Settings** → **CI/CD** → **Runners**

3. Développez **Specific runners**

4. Notez:
   - **Registration token**: `glrt-xxxxxxxxxxxxx`
   - **Coordinator URL**: `https://gitlab.com/`

### Enregistrer le Runner

```powershell
# Exécuter en tant qu'administrateur
cd C:\GitLab-Runner

.\gitlab-runner.exe register

# Répondre aux questions:
# GitLab instance URL: https://gitlab.com/
# Registration token: [collez le token depuis GitLab]
# Description: Windows Local Runner
# Tags: windows,local,shell
# Executor: shell
```

### Vérifier l'Enregistrement

```powershell
# Lister les runners
.\gitlab-runner.exe list

# Vérifier le status
.\gitlab-runner.exe status
```

Vous devriez maintenant voir votre runner dans GitLab (Settings → CI/CD → Runners) avec un point vert.

## 📝 Étape 3: Créer un Job de Déploiement Local

Je vais modifier votre `.gitlab-ci.yml` pour ajouter un job de déploiement local:

### Nouveau Job: `deploy:local`

Ce job va:
1. Activer l'environnement virtuel
2. Installer/mettre à jour les dépendances
3. Appliquer les migrations Django
4. Redémarrer les services

Voici le code à ajouter:

```yaml
# Déploiement local sur Windows via GitLab Runner local
deploy:local:
  stage: deploy
  tags:
    - windows
    - local
    - shell
  before_script:
    - Write-Host "Déploiement local sur Windows..." -ForegroundColor Cyan
  script:
    # Activer l'environnement virtuel
    - |
      if (Test-Path ".\venv\Scripts\Activate.ps1") {
        & .\venv\Scripts\Activate.ps1
        Write-Host "✓ Environnement virtuel activé" -ForegroundColor Green
      } else {
        Write-Host "✗ Environnement virtuel non trouvé" -ForegroundColor Red
        exit 1
      }
    
    # Installer/mettre à jour les dépendances
    - Write-Host "Installation des dépendances..." -ForegroundColor Cyan
    - pip install --upgrade pip
    - pip install -r auth_service/requirements.txt
    - pip install -r transaction_service/requirements.txt
    - pip install -r fraud_detection_service/requirements.txt
    
    # Migrations Django
    - Write-Host "Application des migrations Django..." -ForegroundColor Cyan
    - cd auth_service
    - python manage.py migrate --noinput
    - cd ..
    
    # Arrêter les anciens services s'ils tournent
    - Write-Host "Arrêt des anciens services..." -ForegroundColor Cyan
    - |
      Get-Process | Where-Object {$_.Path -like "*uvicorn*" -or $_.CommandLine -like "*manage.py*"} | Stop-Process -Force -ErrorAction SilentlyContinue
    
    # Redémarrer les services en arrière-plan
    - Write-Host "Démarrage des services..." -ForegroundColor Cyan
    
    # Auth Service
    - Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\auth_service'; & '$PWD\venv\Scripts\python.exe' manage.py runserver 0.0.0.0:8000"
    
    # Transaction Service
    - Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\transaction_service'; & '$PWD\venv\Scripts\python.exe' -m uvicorn main:app --host 0.0.0.0 --port 8001"
    
    # Fraud Detection Service
    - Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\fraud_detection_service'; & '$PWD\venv\Scripts\python.exe' -m uvicorn main:app --host 0.0.0.0 --port 8002"
    
    - Start-Sleep -Seconds 5
    
    # Vérifier que les services sont démarrés
    - Write-Host "Vérification des services..." -ForegroundColor Cyan
    - |
      try {
        Invoke-WebRequest -Uri "http://localhost:8000" -TimeoutSec 5 -UseBasicParsing | Out-Null
        Write-Host "✓ Auth Service: OK" -ForegroundColor Green
      } catch {
        Write-Host "✗ Auth Service: ERREUR" -ForegroundColor Red
      }
    - |
      try {
        Invoke-WebRequest -Uri "http://localhost:8001/health" -TimeoutSec 5 -UseBasicParsing | Out-Null
        Write-Host "✓ Transaction Service: OK" -ForegroundColor Green
      } catch {
        Write-Host "✗ Transaction Service: ERREUR" -ForegroundColor Red
      }
    - |
      try {
        Invoke-WebRequest -Uri "http://localhost:8002/health" -TimeoutSec 5 -UseBasicParsing | Out-Null
        Write-Host "✓ Fraud Detection Service: OK" -ForegroundColor Green
      } catch {
        Write-Host "✗ Fraud Detection Service: ERREUR" -ForegroundColor Red
      }
    
    - Write-Host "`n✓ Déploiement local terminé!" -ForegroundColor Green
    - Write-Host "Auth: http://localhost:8000" -ForegroundColor Cyan
    - Write-Host "Transaction: http://localhost:8001" -ForegroundColor Cyan
    - Write-Host "Fraud Detection: http://localhost:8002" -ForegroundColor Cyan
  
  rules:
    - if: '$CI_COMMIT_BRANCH == "main" || $CI_COMMIT_BRANCH == "develop"'
      when: on_success
  
  environment:
    name: local-development
    url: http://localhost:8000
  
  allow_failure: false
```

## 🎯 Étape 4: Configuration du Runner

### Configurer l'Exécution en PowerShell

Éditez `C:\GitLab-Runner\config.toml`:

```toml
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "Windows Local Runner"
  url = "https://gitlab.com/"
  token = "votre-token-runner"
  executor = "shell"
  shell = "powershell"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
```

### Redémarrer le Runner

```powershell
.\gitlab-runner.exe restart
```

## ✅ Étape 5: Tester le Déploiement Automatique

### Faire un Commit

```powershell
# Faire un petit changement
echo "# Test deployment" >> README.md
git add README.md
git commit -m "test: trigger local deployment"
git push origin main
```

### Suivre le Pipeline

1. Allez sur GitLab: https://gitlab.com/Azaziop/systeme_detect_fraude/-/pipelines
2. Vous devriez voir un nouveau pipeline en cours
3. Le job `deploy:local` devrait s'exécuter sur votre runner local
4. Les services vont redémarrer automatiquement

### Vérifier les Services

```powershell
# Vérifier que les services tournent
Get-Process | Where-Object {$_.Path -like "*python*"}

# Tester les endpoints
Invoke-WebRequest -Uri http://localhost:8000
Invoke-WebRequest -Uri http://localhost:8001/health
Invoke-WebRequest -Uri http://localhost:8002/health
```

## 🔄 Workflow Automatique

Désormais, à chaque push sur `main` ou `develop`:

1. ✅ GitLab détecte le commit
2. ✅ Le runner local récupère le code
3. ✅ Les dépendances sont mises à jour
4. ✅ Les migrations sont appliquées
5. ✅ Les services redémarrent automatiquement
6. ✅ Vous recevez une notification (optionnel)

## 🛡️ Sécurité

### Protéger le Runner

```powershell
# Limiter l'accès au runner à votre projet uniquement
# Dans GitLab: Settings → CI/CD → Runners → Edit
# Décochez "Run untagged jobs"
# Cochez "Lock to current projects"
```

### Variables d'Environnement Locales

Créez un fichier `.env.local` à la racine:

```env
# .env.local
DATABASE_URL=postgresql://localhost/fraud_detection
JWT_SECRET=your-local-secret
DEBUG=True
```

Dans `.gitlab-ci.yml`, chargez ces variables:

```yaml
before_script:
  - |
    if (Test-Path ".env.local") {
      Get-Content .env.local | ForEach-Object {
        if ($_ -match "^([^=]+)=(.*)$") {
          [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
      }
    }
```

## 📊 Monitoring

### Voir les Logs en Temps Réel

Sur GitLab, dans le job en cours, cliquez sur le bouton de logs pour voir:
- Installation des dépendances
- Migrations
- Démarrage des services
- Tests de santé

### Logs Locaux

Les services s'ouvrent dans des fenêtres PowerShell séparées où vous pouvez voir les logs en direct.

## 🛑 Arrêter les Services

### Via Script

```powershell
# Arrêter tous les services Python
Get-Process | Where-Object {$_.Path -like "*python*"} | Stop-Process -Force
```

### Manuellement

Fermez les fenêtres PowerShell des services.

## 🔧 Dépannage

### Runner ne démarre pas

```powershell
# Vérifier le status
C:\GitLab-Runner\gitlab-runner.exe status

# Voir les logs
C:\GitLab-Runner\gitlab-runner.exe --debug run
```

### Jobs ne s'exécutent pas sur le runner local

Vérifiez que:
1. Le runner a le tag `windows` et `local`
2. Le job dans `.gitlab-ci.yml` a les mêmes tags
3. Le runner est actif (point vert dans GitLab)

### Erreur "Access Denied"

Exécutez PowerShell en tant qu'administrateur et relancez le runner:

```powershell
Start-Process powershell -Verb RunAs
cd C:\GitLab-Runner
.\gitlab-runner.exe restart
```

### Services ne démarrent pas

Vérifiez:
- Le venv existe et est correct
- Les ports 8000, 8001, 8002 ne sont pas déjà utilisés
- Les dépendances sont installées

## 🚀 Aller Plus Loin

### Notifications

Ajoutez dans `.gitlab-ci.yml`:

```yaml
after_script:
  - |
    $status = if ($CI_JOB_STATUS -eq "success") { "✅ SUCCÈS" } else { "❌ ÉCHEC" }
    Write-Host "$status - Déploiement local $CI_COMMIT_SHORT_SHA"
```

### Tests Automatiques

Ajoutez un job de test avant le déploiement:

```yaml
test:local:
  stage: test
  tags:
    - windows
    - local
  script:
    - pytest tests/
  only:
    - main
    - develop
```

### Rollback Automatique

En cas d'échec, revenez à la version précédente:

```yaml
deploy:local:
  after_script:
    - |
      if ($CI_JOB_STATUS -eq "failed") {
        Write-Host "Rollback vers le commit précédent..." -ForegroundColor Yellow
        git reset --hard HEAD~1
        # Redémarrer les services...
      }
```

## 📚 Ressources

- [GitLab Runner Windows Documentation](https://docs.gitlab.com/runner/install/windows.html)
- [GitLab CI/CD Configuration](https://docs.gitlab.com/ee/ci/yaml/)
- [Shell Executor](https://docs.gitlab.com/runner/executors/shell.html)

---

**Avec cette configuration, chaque push déploie automatiquement sur votre machine locale! 🎉**
