# Guide : Démarrer Tous les Services avec l'Environnement Virtuel

## 🎯 Vue d'Ensemble

Ce guide vous explique comment démarrer tous les services (Auth, Transaction, Fraud Detection) en utilisant l'environnement virtuel Python.

## 📋 Prérequis

- ✅ Python installé
- ✅ Environnement virtuel créé (`venv/` à la racine)
- ✅ Dépendances installées dans `venv`

## 🚀 Méthode 1 : Script Automatique (Recommandé)

### Utiliser le Script Batch

```powershell
.\DEMARRER_TOUT_SIMPLE.bat
```

Ce script fait automatiquement :
1. ✅ Active l'environnement virtuel
2. ✅ Vérifie le modèle ML
3. ✅ Démarre les 3 services dans des fenêtres séparées
4. ✅ Affiche les URLs de chaque service

**Avantages** :
- ✅ Tout automatique
- ✅ Une seule commande
- ✅ Gère l'environnement virtuel pour vous

## 🛠️ Méthode 2 : Démarrage Manuel avec Environnement Virtuel

### Étape 1 : Activer l'Environnement Virtuel

**Option A : PowerShell**
```powershell
# Depuis la racine du projet
.\venv\Scripts\activate.ps1
```

**Option B : Si erreur d'exécution de script**
```powershell
# Autoriser l'exécution de scripts (une seule fois)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Puis activer
.\venv\Scripts\activate.ps1
```

**Option C : CMD (Invite de commandes)**
```cmd
venv\Scripts\activate.bat
```

### Vérification

Vous devriez voir `(venv)` au début de votre ligne de commande :
```powershell
(venv) PS C:\Users\zaoui\OneDrive\Desktop\detec_fraude>
```

### Étape 2 : Démarrer les Services

#### Service 1 : Auth Service (Django) - Port 8000

**Ouvrir une première fenêtre PowerShell/Terminal :**

```powershell
# Activer l'environnement virtuel
.\venv\Scripts\activate.ps1

# Aller dans le dossier auth_service
cd auth_service

# Appliquer les migrations (première fois seulement)
python manage.py migrate

# Démarrer le service
python manage.py runserver 0.0.0.0:8000
```

**URLs** :
- Service : http://localhost:8000
- Swagger : http://localhost:8000/api/docs/
- Admin : http://localhost:8000/admin/

#### Service 2 : Fraud Detection Service (FastAPI) - Port 8002

**Ouvrir une deuxième fenêtre PowerShell/Terminal :**

```powershell
# Activer l'environnement virtuel
.\venv\Scripts\activate.ps1

# Aller dans le dossier fraud_detection_service
cd fraud_detection_service

# Démarrer le service
uvicorn main:app --host 0.0.0.0 --port 8002
```

**URLs** :
- Service : http://localhost:8002
- Swagger : http://localhost:8002/docs
- Health : http://localhost:8002/health

#### Service 3 : Transaction Service (FastAPI) - Port 8001

**Ouvrir une troisième fenêtre PowerShell/Terminal :**

```powershell
# Activer l'environnement virtuel
.\venv\Scripts\activate.ps1

# Aller dans le dossier transaction_service
cd transaction_service

# Démarrer le service
uvicorn main:app --host 0.0.0.0 --port 8001
```

**URLs** :
- Service : http://localhost:8001
- Swagger : http://localhost:8001/docs
- Health : http://localhost:8001/health

## 🔧 Méthode 3 : Sans Activer l'Environnement (Alternative)

Si vous ne voulez pas activer l'environnement, utilisez directement le Python de `venv` :

### Service 1 : Auth Service
```powershell
cd auth_service
..\venv\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

### Service 2 : Fraud Detection Service
```powershell
cd fraud_detection_service
..\venv\Scripts\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8002
```

### Service 3 : Transaction Service
```powershell
cd transaction_service
..\venv\Scripts\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8001
```

## ✅ Vérification que les Services Fonctionnent

### Test Rapide avec PowerShell

```powershell
# Test Auth Service
Invoke-WebRequest -Uri http://localhost:8000/ -Method GET

# Test Transaction Service
Invoke-WebRequest -Uri http://localhost:8001/health -Method GET

# Test Fraud Detection Service
Invoke-WebRequest -Uri http://localhost:8002/health -Method GET
```

### Ou Ouvrir dans le Navigateur

- Auth : http://localhost:8000
- Transaction : http://localhost:8001/health
- Fraud Detection : http://localhost:8002/health

## 🎯 Script PowerShell Complet (Optionnel)

Créez un fichier `demarrer_services.ps1` :

```powershell
# Script pour démarrer tous les services avec l'environnement virtuel

Write-Host "Démarrage des services..." -ForegroundColor Cyan

# Service 1 : Auth
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; .\venv\Scripts\activate.ps1; cd auth_service; python manage.py migrate; python manage.py runserver 0.0.0.0:8000"

Start-Sleep -Seconds 3

# Service 2 : Fraud Detection
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; .\venv\Scripts\activate.ps1; cd fraud_detection_service; uvicorn main:app --host 0.0.0.0 --port 8002"

Start-Sleep -Seconds 3

# Service 3 : Transaction
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; .\venv\Scripts\activate.ps1; cd transaction_service; uvicorn main:app --host 0.0.0.0 --port 8001"

Write-Host "Tous les services sont en cours de démarrage!" -ForegroundColor Green
```

**Utilisation** :
```powershell
.\demarrer_services.ps1
```

## 🛑 Arrêter les Services

### Méthode 1 : Fermer les Fenêtres
Fermez simplement les fenêtres PowerShell/Terminal où les services tournent.

### Méthode 2 : Arrêter par Port
```powershell
# Trouver le processus sur le port 8000
netstat -ano | findstr :8000

# Arrêter le processus (remplacez PID par le numéro trouvé)
taskkill /PID <PID> /F
```

### Méthode 3 : Script d'Arrêt
```powershell
# Arrêter tous les processus Python
Get-Process python* | Stop-Process -Force
```

## ⚠️ Problèmes Courants

### "uvicorn n'est pas reconnu"
**Solution** : Activez l'environnement virtuel d'abord
```powershell
.\venv\Scripts\activate.ps1
```

### "Activation script cannot be loaded"
**Solution** :
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Port déjà utilisé"
**Solution** : Arrêtez le service qui utilise le port
```powershell
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

### "Module not found"
**Solution** : Installez les dépendances dans l'environnement virtuel
```powershell
.\venv\Scripts\activate.ps1
pip install -r requirements.txt
```

## 📊 Résumé des Ports

| Service | Port | URL |
|---------|------|-----|
| Auth Service | 8000 | http://localhost:8000 |
| Transaction Service | 8001 | http://localhost:8001 |
| Fraud Detection Service | 8002 | http://localhost:8002 |

## 🎯 Ordre de Démarrage Recommandé

1. **Auth Service** (port 8000) - Doit démarrer en premier
2. **Fraud Detection Service** (port 8002) - Peut démarrer en parallèle
3. **Transaction Service** (port 8001) - Dépend des deux autres

## 💡 Astuce : Garder les Fenêtres Visibles

Quand vous démarrez les services, gardez les fenêtres ouvertes pour voir les logs en temps réel. Cela vous aide à déboguer en cas de problème.

---

**Bon démarrage ! 🚀**

