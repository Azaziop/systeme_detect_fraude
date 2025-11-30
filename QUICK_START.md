# Guide de Démarrage Rapide

## Prérequis

Avant de commencer, assurez-vous d'avoir installé :

1. **Python 3.9+** : [Télécharger Python](https://www.python.org/downloads/)
2. **Docker Desktop** : [Télécharger Docker](https://www.docker.com/products/docker-desktop/)
3. **Git** (optionnel) : Pour cloner le projet

## Démarrage en 3 Étapes

### Étape 1 : Entraîner le Modèle ML

Le modèle doit être entraîné avant de lancer les services.

**Option A : Avec Make (si disponible sur Windows avec WSL ou Git Bash)**
```bash
make train
```

**Option B : Manuellement**
```bash
cd ml_model
pip install -r requirements.txt
python train_model.py
cd ..
```

Le script va :
- Générer des données de transactions (si le dataset Kaggle n'est pas disponible)
- Entraîner le modèle Isolation Forest
- Sauvegarder le modèle dans `ml_model/models/`

✅ **Vérification** : Vérifiez que ces fichiers existent :
- `ml_model/models/isolation_forest_model.pkl`
- `ml_model/models/scaler.pkl`
- `ml_model/models/feature_columns.json`

### Étape 2 : Lancer les Services avec Docker

**Option A : Avec Make**
```bash
make build    # Construire les images
make up       # Lancer les services
```

**Option B : Avec Docker Compose directement**
```bash
docker-compose build
docker-compose up -d
```

✅ **Vérification** : Vérifiez que les conteneurs sont en cours d'exécution :
```bash
docker-compose ps
```

Vous devriez voir 3 services :
- `auth-service` (port 8000)
- `transaction-service` (port 8001)
- `fraud-detection-service` (port 8002)

### Étape 3 : Tester les Services

**Option A : Avec le script Python**
```bash
# Installer requests si nécessaire
pip install requests

# Lancer les tests
python example_usage.py
```

**Option B : Tests manuels avec curl ou un navigateur**

1. **Vérifier la santé des services** :
   - http://localhost:8000/api/users/ (Auth Service)
   - http://localhost:8001/health (Transaction Service)
   - http://localhost:8002/health (Fraud Detection Service)

2. **Tester l'inscription** :
```bash
curl -X POST http://localhost:8000/api/register/ \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"email\":\"test@example.com\",\"password\":\"test123\",\"password_confirm\":\"test123\"}"
```

3. **Tester une transaction** :
```bash
curl -X POST http://localhost:8001/transactions \
  -H "Content-Type: application/json" \
  -d "{\"user_id\":\"1\",\"amount\":100.50,\"merchant\":\"Amazon\",\"category\":\"Shopping\"}"
```

## Voir les Logs

```bash
# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f auth-service
docker-compose logs -f transaction-service
docker-compose logs -f fraud-detection-service
```

## Arrêter les Services

```bash
# Avec Make
make down

# Ou avec Docker Compose
docker-compose down
```

## Problèmes Courants

### ❌ Erreur : "Modèle non trouvé"
**Solution** : Assurez-vous d'avoir entraîné le modèle (Étape 1)

### ❌ Erreur : "Port déjà utilisé"
**Solution** : Arrêtez les services qui utilisent les ports 8000, 8001, 8002
```bash
# Windows PowerShell
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

### ❌ Erreur : "Docker n'est pas démarré"
**Solution** : Lancez Docker Desktop et attendez qu'il soit complètement démarré

### ❌ Erreur : "Module non trouvé"
**Solution** : Installez les dépendances
```bash
cd ml_model
pip install -r requirements.txt
```

## Accès aux Interfaces

- **Auth Service API** : http://localhost:8000/api/
- **Transaction Service Docs** : http://localhost:8001/docs
- **Fraud Detection Service Docs** : http://localhost:8002/docs
- **Django Admin** : http://localhost:8000/admin/ (admin/admin123)

## Prochaines Étapes

Une fois les services lancés, vous pouvez :
1. Explorer les APIs avec les interfaces Swagger (docs)
2. Créer des utilisateurs via l'API d'authentification
3. Envoyer des transactions et voir les résultats de détection
4. Consulter les logs pour comprendre le flux

Pour plus de détails, consultez :
- [README.md](README.md) - Documentation principale
- [DEPLOYMENT.md](DEPLOYMENT.md) - Guide de déploiement avancé

