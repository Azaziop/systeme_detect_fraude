# Dépannage Frontend

## Erreur : ERR_CONNECTION_REFUSED

### Cause
Le serveur Django (Auth Service) n'est pas lancé ou n'est pas accessible.

### Solution

**1. Vérifier que le serveur Django est lancé**

Ouvrez un terminal et vérifiez :

```powershell
# Vérifier si le serveur répond
Invoke-WebRequest -Uri "http://localhost:8000/api/users/" -Method GET
```

Si ça ne fonctionne pas, lancez le serveur :

```powershell
cd C:\Users\zaoui\OneDrive\Desktop\detec_fraude
cd auth_service
set USE_SQLITE=True
python manage.py runserver 0.0.0.0:8000
```

**2. Vérifier que le serveur écoute sur 0.0.0.0**

Le serveur doit être lancé avec `0.0.0.0` et non `127.0.0.1` pour être accessible.

---

## Erreur : 404 Not Found

### Cause
L'URL n'existe pas ou le chemin est incorrect.

### Vérification des URLs

Les URLs correctes sont :
- Inscription : `http://localhost:8000/api/register/`
- Connexion : `http://localhost:8000/api/login/`
- Profil : `http://localhost:8000/api/profile/`

### Test dans le navigateur

Ouvrez directement dans votre navigateur :
- http://localhost:8000/api/docs/ (doit afficher Swagger)
- http://localhost:8000/api/users/ (doit retourner une liste)

---

## Erreur CORS

### Cause
Le navigateur bloque les requêtes cross-origin.

### Solution

Le CORS est déjà configuré dans Django. Si vous avez encore des problèmes :

1. **Utiliser un serveur local pour le frontend** :

```powershell
cd frontend
python -m http.server 3000
```

Puis ouvrez : http://localhost:3000

2. **Vérifier les settings CORS dans Django** :

Dans `auth_service/auth_service/settings.py`, CORS_ALLOW_ALL_ORIGINS doit être True en DEBUG.

---

## Checklist de Vérification

### ✅ Services Lancés

Vérifiez que ces 3 services sont lancés :

1. **Auth Service** (port 8000)
   ```powershell
   # Test
   curl http://localhost:8000/api/users/
   ```

2. **Transaction Service** (port 8001)
   ```powershell
   # Test
   curl http://localhost:8001/health
   ```

3. **Fraud Detection Service** (port 8002)
   ```powershell
   # Test
   curl http://localhost:8002/health
   ```

### ✅ Frontend Accessible

- Si vous ouvrez `index.html` directement : peut avoir des problèmes CORS
- Si vous utilisez un serveur local (port 3000) : devrait fonctionner

---

## Solution Rapide

### 1. Lancer tous les services

**Terminal 1 - Auth**
```powershell
cd auth_service
set USE_SQLITE=True
python manage.py runserver 0.0.0.0:8000
```

**Terminal 2 - Transaction**
```powershell
cd transaction_service
set DATABASE_URL=sqlite:///./transactions.db
uvicorn main:app --host 0.0.0.0 --port 8001
```

**Terminal 3 - Fraud Detection**
```powershell
cd fraud_detection_service
uvicorn main:app --host 0.0.0.0 --port 8002
```

### 2. Lancer le frontend avec serveur local

```powershell
cd frontend
python -m http.server 3000
```

### 3. Ouvrir dans le navigateur

http://localhost:3000

---

## Test Direct des APIs

Avant d'utiliser le frontend, testez les APIs directement :

### Test Inscription (PowerShell)

```powershell
$body = @{
    username = "testuser"
    email = "test@example.com"
    password = "testpass123"
    password_confirm = "testpass123"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8000/api/register/" -Method POST -Body $body -ContentType "application/json"
```

### Test Connexion (PowerShell)

```powershell
$body = @{
    username = "testuser"
    password = "testpass123"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8000/api/login/" -Method POST -Body $body -ContentType "application/json"
```

Si ces tests fonctionnent, le problème vient du frontend ou de CORS.

