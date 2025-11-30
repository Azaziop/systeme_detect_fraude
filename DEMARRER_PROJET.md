# Comment Démarrer le Projet Complet

## 🚀 Méthode Simple : Script Automatique

### Depuis la racine du projet

```powershell
.\test_direct.bat
```

Ce script lance automatiquement les 3 services dans des fenêtres séparées.

---

## 📋 Méthode Manuelle : 3 Terminaux

### Terminal 1 - Auth Service (Déjà lancé ✅)

Vous avez déjà ce terminal actif. Gardez-le ouvert.

```
http://localhost:8000
```

### Terminal 2 - Fraud Detection Service

Ouvrez un **nouveau terminal PowerShell** :

```powershell
cd C:\Users\zaoui\OneDrive\Desktop\detec_fraude
cd fraud_detection_service
uvicorn main:app --host 0.0.0.0 --port 8002
```

### Terminal 3 - Transaction Service

Ouvrez un **autre nouveau terminal PowerShell** :

```powershell
cd C:\Users\zaoui\OneDrive\Desktop\detec_fraude
cd transaction_service
set DATABASE_URL=sqlite:///./transactions.db
uvicorn main:app --host 0.0.0.0 --port 8001
```

---

## ✅ Vérification

Une fois les 3 services lancés, testez :

### Dans le navigateur :
- **Auth Service** : http://localhost:8000/api/docs/
- **Transaction Service** : http://localhost:8001/docs
- **Fraud Detection** : http://localhost:8002/docs

### Ou avec PowerShell :

```powershell
# Health checks
Invoke-WebRequest -Uri "http://localhost:8000/api/users/"
Invoke-WebRequest -Uri "http://localhost:8001/health"
Invoke-WebRequest -Uri "http://localhost:8002/health"
```

---

## 🧪 Test Complet

Une fois les 3 services lancés, testez le flux complet :

```powershell
# Depuis la racine du projet
python example_usage.py
```

---

## 📝 Ordre de Démarrage Recommandé

1. ✅ **Auth Service** (déjà lancé - Terminal 1)
2. **Fraud Detection Service** (Terminal 2)
3. **Transaction Service** (Terminal 3)

---

## 🎯 Test Rapide avec Swagger

1. Ouvrez http://localhost:8000/api/docs/
2. Testez l'inscription
3. Testez la connexion
4. Utilisez le token pour accéder au profil

---

## ⚠️ Si un Service ne Démarre pas

### Erreur "Module not found"
```powershell
pip install fastapi uvicorn pydantic httpx numpy sqlalchemy
```

### Erreur "Model not found" (Fraud Detection)
```powershell
cd ml_model
python train_model.py
```

### Erreur "Port already in use"
Arrêtez les autres applications utilisant les ports 8000, 8001, 8002

