# 🚀 Comment Démarrer le Projet

## Méthode la Plus Simple

### Sur Windows :
Double-cliquez sur `start.bat` ou exécutez dans PowerShell :
```powershell
.\start.bat
```

### Sur Linux/Mac :
```bash
chmod +x start.sh
./start.sh
```

Le script va automatiquement :
1. ✅ Vérifier que Docker est démarré
2. ✅ Entraîner le modèle ML (si nécessaire)
3. ✅ Construire les images Docker
4. ✅ Lancer tous les services

## Méthode Manuelle (Étape par Étape)

### Étape 1 : Vérifier les Prérequis

1. **Docker Desktop** doit être installé et démarré
   - Vérifiez avec : `docker --version`
   - Si Docker n'est pas installé : [Télécharger Docker Desktop](https://www.docker.com/products/docker-desktop/)

2. **Python 3.9+** doit être installé
   - Vérifiez avec : `python --version`
   - Si Python n'est pas installé : [Télécharger Python](https://www.python.org/downloads/)

### Étape 2 : Entraîner le Modèle ML

Ouvrez un terminal dans le dossier du projet et exécutez :

```bash
cd ml_model
pip install -r requirements.txt
python train_model.py
cd ..
```

⏱️ **Temps estimé** : 1-2 minutes

✅ **Vérification** : Vérifiez que ces fichiers existent :
- `ml_model/models/isolation_forest_model.pkl`
- `ml_model/models/scaler.pkl`
- `ml_model/models/feature_columns.json`

### Étape 3 : Lancer les Services

```bash
# Construire les images Docker
docker-compose build

# Lancer les services en arrière-plan
docker-compose up -d
```

⏱️ **Temps estimé** : 3-5 minutes (première fois)

### Étape 4 : Vérifier que Tout Fonctionne

```bash
# Vérifier l'état des conteneurs
docker-compose ps
```

Vous devriez voir 3 services avec le statut "Up" :
- `auth-service`
- `transaction-service`
- `fraud-detection-service`

### Étape 5 : Tester les Services

**Option 1 : Avec le script Python**
```bash
pip install requests
python example_usage.py
```

**Option 2 : Dans un navigateur**
- Auth Service : http://localhost:8000/api/users/
- Transaction Service : http://localhost:8001/docs
- Fraud Detection : http://localhost:8002/docs

**Option 3 : Avec curl (PowerShell)**
```powershell
# Tester le service de transaction
Invoke-WebRequest -Uri "http://localhost:8001/health" -Method GET

# Créer une transaction
$body = @{
    user_id = "1"
    amount = 100.50
    merchant = "Amazon"
    category = "Shopping"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8001/transactions" -Method POST -Body $body -ContentType "application/json"
```

## Commandes Utiles

### Voir les Logs
```bash
# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f auth-service
docker-compose logs -f transaction-service
docker-compose logs -f fraud-detection-service
```

### Arrêter les Services
```bash
docker-compose down
```

### Redémarrer les Services
```bash
docker-compose restart
```

### Reconstruire Tout
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## URLs des Services

Une fois démarrés, les services sont accessibles sur :

| Service | URL | Description |
|---------|-----|-------------|
| Auth Service | http://localhost:8000 | Service d'authentification |
| Auth API Docs | http://localhost:8000/api/ | Documentation API |
| Django Admin | http://localhost:8000/admin/ | Interface admin (admin/admin123) |
| Transaction Service | http://localhost:8001 | Service de transaction |
| Transaction Docs | http://localhost:8001/docs | Documentation Swagger |
| Fraud Detection | http://localhost:8002 | Service de détection |
| Fraud Detection Docs | http://localhost:8002/docs | Documentation Swagger |

## Problèmes Courants

### ❌ "Docker n'est pas démarré"
**Solution** : 
1. Ouvrez Docker Desktop
2. Attendez que l'icône Docker soit verte
3. Réessayez

### ❌ "Port déjà utilisé"
**Solution** : Arrêtez les applications qui utilisent les ports 8000, 8001, 8002
```powershell
# Windows PowerShell
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

### ❌ "Modèle non trouvé"
**Solution** : Assurez-vous d'avoir exécuté `python train_model.py` dans le dossier `ml_model`

### ❌ "Erreur lors du build Docker"
**Solution** : 
1. Vérifiez votre connexion Internet
2. Essayez : `docker-compose build --no-cache`
3. Vérifiez les logs : `docker-compose logs`

### ❌ "Module Python non trouvé"
**Solution** : Installez les dépendances
```bash
cd ml_model
pip install -r requirements.txt
```

## Prochaines Étapes

Une fois les services démarrés :

1. **Explorer les APIs** : Visitez les URLs `/docs` pour voir les interfaces Swagger
2. **Créer un utilisateur** : Utilisez l'API d'authentification
3. **Envoyer des transactions** : Testez la détection de fraude
4. **Consulter les logs** : Suivez le flux des données

Pour plus d'informations :
- [README.md](README.md) - Documentation complète
- [QUICK_START.md](QUICK_START.md) - Guide de démarrage rapide
- [DEPLOYMENT.md](DEPLOYMENT.md) - Guide de déploiement avancé

