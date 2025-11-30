# Vérification des Services

## Erreur "Failed to fetch" - Service de Transaction

### Causes Possibles

1. **Service de transaction non lancé**
2. **Problème CORS**
3. **Service Fraud Detection non lancé** (nécessaire pour les transactions)

## Solution

### 1. Vérifier que tous les services sont lancés

**Terminal 1 - Auth Service** (port 8000)
```powershell
cd auth_service
set USE_SQLITE=True
python manage.py runserver 0.0.0.0:8000
```

**Terminal 2 - Transaction Service** (port 8001)
```powershell
cd transaction_service
set DATABASE_URL=sqlite:///./transactions.db
uvicorn main:app --host 0.0.0.0 --port 8001
```

**Terminal 3 - Fraud Detection Service** (port 8002) ⚠️ **IMPORTANT**
```powershell
cd fraud_detection_service
uvicorn main:app --host 0.0.0.0 --port 8002
```

### 2. Test Rapide

Testez chaque service individuellement :

```powershell
# Auth Service
Invoke-WebRequest -Uri "http://localhost:8000/api/users/" -Method GET

# Transaction Service
Invoke-WebRequest -Uri "http://localhost:8001/health" -Method GET

# Fraud Detection Service
Invoke-WebRequest -Uri "http://localhost:8002/health" -Method GET
```

### 3. Test de Transaction Complète

```powershell
$body = @{
    user_id = "1"
    amount = 100.50
    merchant = "Amazon"
    category = "Shopping"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8001/transactions" -Method POST -Body $body -ContentType "application/json"
```

## Note Importante

⚠️ **Le service Fraud Detection (port 8002) doit être lancé** pour que les transactions fonctionnent, car le service de transaction l'appelle pour détecter les fraudes.

## CORS

J'ai ajouté la configuration CORS dans le service de transaction. Si vous avez encore des problèmes :

1. Utilisez un serveur local pour le frontend :
```powershell
cd frontend
python -m http.server 3000
```

2. Ouvrez : http://localhost:3000 au lieu de `file://`

