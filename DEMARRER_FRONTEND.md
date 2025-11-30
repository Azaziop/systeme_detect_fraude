# Comment Démarrer le Frontend

## 🚀 Méthode la Plus Simple

### 1. Lancer les Services Backend

Assurez-vous que les 3 services sont lancés :

**Terminal 1 - Auth Service**
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

### 2. Ouvrir le Frontend

**Option A : Double-clic (Simple)**
```
Double-cliquez sur : frontend/index.html
```

**Option B : Serveur local (Recommandé)**
```powershell
cd frontend
python -m http.server 3000
```

Puis ouvrez : http://localhost:3000

## 📋 Utilisation

1. **S'inscrire ou se connecter**
   - Créez un compte ou connectez-vous
   - Vous recevrez un token JWT automatiquement

2. **Créer une transaction**
   - Remplissez le formulaire
   - Cliquez sur "Créer la Transaction"
   - Le système détectera automatiquement si c'est une fraude

3. **Voir vos transactions**
   - Toutes vos transactions s'affichent automatiquement
   - Les transactions frauduleuses sont marquées en rouge

## 🎨 Fonctionnalités

- ✅ Authentification complète (inscription/connexion)
- ✅ Création de transactions
- ✅ Affichage des transactions avec statut
- ✅ Détection de fraude en temps réel
- ✅ Interface moderne et intuitive

## 🔧 Dépannage

### Erreur CORS
→ Les services doivent être lancés et CORS est déjà configuré

### "Service non accessible"
→ Vérifiez que les 3 services backend sont bien lancés

### Token expiré
→ Déconnectez-vous et reconnectez-vous

