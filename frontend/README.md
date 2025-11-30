# Frontend - Gestion de Transactions

Interface web simple pour gérer les transactions et tester le système de détection de fraude.

## Utilisation

### Option 1 : Ouvrir directement dans le navigateur

1. Assurez-vous que les services sont lancés :
   - Auth Service : http://localhost:8000
   - Transaction Service : http://localhost:8001
   - Fraud Detection Service : http://localhost:8002

2. Ouvrez `index.html` dans votre navigateur :
   ```
   Double-cliquez sur frontend/index.html
   ```

### Option 2 : Servir avec un serveur local

```powershell
# Depuis le dossier frontend
cd frontend
python -m http.server 3000
```

Puis ouvrez : http://localhost:3000

## Fonctionnalités

### 🔐 Authentification
- Inscription de nouveaux utilisateurs
- Connexion avec username/password
- Gestion des tokens JWT

### 💸 Création de Transactions
- Formulaire pour créer une transaction
- Montant, marchand, catégorie, description
- Détection automatique de fraude

### 📋 Liste des Transactions
- Affichage de toutes vos transactions
- Statut : APPROVED, BLOCKED, PENDING
- Indication de fraude détectée
- Score de fraude

## Interface

- **Design moderne** avec dégradé violet
- **Responsive** - fonctionne sur mobile et desktop
- **Messages en temps réel** pour les notifications
- **Codes couleur** :
  - 🟢 Vert : Transaction approuvée
  - 🔴 Rouge : Transaction bloquée (fraude)
  - 🟡 Orange : Transaction en attente

## Configuration

Si vos services tournent sur d'autres ports, modifiez dans `app.js` :

```javascript
const AUTH_URL = 'http://localhost:8000';
const TRANSACTION_URL = 'http://localhost:8001';
const FRAUD_DETECTION_URL = 'http://localhost:8002';
```

## Dépannage

### Erreur CORS
Si vous avez des erreurs CORS, assurez-vous que CORS est activé dans Django settings.

### Services non accessibles
Vérifiez que tous les services sont bien lancés et accessibles.

### Token expiré
Si le token expire, déconnectez-vous et reconnectez-vous.

