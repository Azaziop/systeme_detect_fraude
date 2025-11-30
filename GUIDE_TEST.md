# Guide de Test - Système de Détection de Fraude

## 🚀 Méthode 1 : Interface Swagger (La Plus Simple)

### 1. Ouvrir Swagger dans le navigateur

```
http://localhost:8000/api/docs/
```

### 2. Tester l'inscription

1. Cliquez sur `POST /api/register/`
2. Cliquez sur "Try it out"
3. Modifiez le JSON :
```json
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "testpass123",
  "password_confirm": "testpass123"
}
```
4. Cliquez sur "Execute"
5. Vous verrez la réponse avec le token JWT

### 3. Tester la connexion

1. Cliquez sur `POST /api/login/`
2. Cliquez sur "Try it out"
3. Entrez :
```json
{
  "username": "testuser",
  "password": "testpass123"
}
```
4. Cliquez sur "Execute"
5. Vous recevrez un access token et refresh token

### 4. Tester le profil (avec authentification)

1. Cliquez sur `GET /api/profile/`
2. Cliquez sur "Authorize" en haut
3. Entrez : `Bearer VOTRE_ACCESS_TOKEN`
4. Cliquez sur "Execute"

---

## 🖥️ Méthode 2 : PowerShell/curl

### Tester l'inscription

```powershell
$body = @{
    username = "testuser"
    email = "test@example.com"
    password = "testpass123"
    password_confirm = "testpass123"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8000/api/register/" -Method POST -Body $body -ContentType "application/json"
```

### Tester la connexion

```powershell
$body = @{
    username = "testuser"
    password = "testpass123"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:8000/api/login/" -Method POST -Body $body -ContentType "application/json"
$response.Content
```

### Tester le profil (avec token)

```powershell
# Récupérer le token depuis la réponse précédente
$token = "VOTRE_ACCESS_TOKEN_ICI"

$headers = @{
    Authorization = "Bearer $token"
}

Invoke-WebRequest -Uri "http://localhost:8000/api/profile/" -Method GET -Headers $headers
```

---

## 🐍 Méthode 3 : Script Python

### Utiliser le script d'exemple

```powershell
# Depuis la racine du projet
python example_usage.py
```

Ce script teste automatiquement :
- Inscription
- Connexion
- Création de transaction
- Détection de fraude

---

## 📋 Test Complet avec Tous les Services

### 1. Lancer tous les services

**Terminal 1 - Auth Service** (déjà lancé ✅)
```powershell
cd auth_service
set USE_SQLITE=True
python manage.py runserver 0.0.0.0:8000
```

**Terminal 2 - Fraud Detection Service**
```powershell
cd fraud_detection_service
uvicorn main:app --host 0.0.0.0 --port 8002
```

**Terminal 3 - Transaction Service**
```powershell
cd transaction_service
set DATABASE_URL=sqlite:///./transactions.db
uvicorn main:app --host 0.0.0.0 --port 8001
```

### 2. Tester le flux complet

```powershell
# Tester une transaction complète
python example_usage.py
```

---

## ✅ Vérifications Rapides

### Health Checks

```powershell
# Auth Service
Invoke-WebRequest -Uri "http://localhost:8000/api/users/" -Method GET

# Transaction Service (si lancé)
Invoke-WebRequest -Uri "http://localhost:8001/health" -Method GET

# Fraud Detection (si lancé)
Invoke-WebRequest -Uri "http://localhost:8002/health" -Method GET
```

### Test JWT Token

```powershell
# 1. Obtenir un token
$loginBody = @{
    username = "testuser"
    password = "testpass123"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:8000/api/login/" -Method POST -Body $loginBody -ContentType "application/json"
$json = $response.Content | ConvertFrom-Json
$token = $json.access

# 2. Utiliser le token
$headers = @{ Authorization = "Bearer $token" }
Invoke-WebRequest -Uri "http://localhost:8000/api/profile/" -Method GET -Headers $headers
```

---

## 🎯 Scénarios de Test

### Scénario 1 : Inscription et Connexion
1. Inscription via `/api/register/`
2. Connexion via `/api/login/`
3. Accès au profil via `/api/profile/` avec token

### Scénario 2 : Transaction Complète
1. Créer un utilisateur
2. Créer une transaction via Transaction Service
3. Vérifier la détection de fraude

### Scénario 3 : Test de Fraude
1. Créer une transaction avec montant suspect
2. Vérifier que le système détecte la fraude

---

## 📝 URLs Utiles

- **Swagger Django** : http://localhost:8000/api/docs/
- **ReDoc Django** : http://localhost:8000/api/redoc/
- **Swagger Transaction** : http://localhost:8001/docs (si lancé)
- **Swagger Fraud Detection** : http://localhost:8002/docs (si lancé)
- **Django Admin** : http://localhost:8000/admin/

---

## 🔧 Dépannage

### Erreur 401 (Non autorisé)
→ Vérifiez que vous utilisez le bon token JWT avec "Bearer " devant

### Erreur 404
→ Vérifiez que le service est bien lancé sur le bon port

### Erreur de connexion
→ Vérifiez que tous les services sont démarrés

