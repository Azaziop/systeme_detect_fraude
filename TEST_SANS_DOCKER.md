# Guide de Test Sans Docker

Ce guide explique comment tester le système de détection de fraude sans Docker, en lançant tous les services localement.

## Prérequis

1. **Python 3.9+** installé
2. **PostgreSQL** installé et démarré (optionnel, SQLite peut être utilisé)
3. **Redis** installé et démarré (pour Celery, optionnel pour tests basiques)

## Installation des Prérequis

### Windows

#### PostgreSQL
- Télécharger depuis : https://www.postgresql.org/download/windows/
- Installer et noter le mot de passe postgres
- Le service démarre automatiquement

#### Redis
- Télécharger depuis : https://github.com/microsoftarchive/redis/releases
- Ou utiliser WSL avec Redis
- Ou utiliser Docker juste pour Redis : `docker run -d -p 6379:6379 redis:7-alpine`

### Linux/Mac

```bash
# PostgreSQL
sudo apt-get install postgresql postgresql-contrib  # Ubuntu/Debian
brew install postgresql  # Mac

# Redis
sudo apt-get install redis-server  # Ubuntu/Debian
brew install redis  # Mac
```

## Configuration

### 1. Créer la Base de Données PostgreSQL

```bash
# Se connecter à PostgreSQL
psql -U postgres

# Créer la base de données
CREATE DATABASE fraud_detection;
\q
```

### 2. Démarrer Redis

```bash
# Windows (si installé)
redis-server

# Linux/Mac
sudo systemctl start redis  # Linux
brew services start redis  # Mac
```

## Installation des Services

### Option 1 : Script Automatique (Windows)

```powershell
.\setup_local.bat
```

### Option 2 : Installation Manuelle

#### Service d'Authentification (Django)

```bash
cd auth_service

# Créer environnement virtuel
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# Installer dépendances
pip install -r requirements.txt

# Configurer les variables d'environnement
# Créer un fichier .env ou définir les variables
set DB_HOST=localhost  # Windows
export DB_HOST=localhost  # Linux/Mac
set DB_NAME=fraud_detection
set DB_USER=postgres
set DB_PASSWORD=postgres
set REDIS_URL=redis://localhost:6379/1

# Appliquer les migrations
python manage.py migrate

# Créer un superutilisateur
python manage.py createsuperuser

# Lancer le serveur
python manage.py runserver 0.0.0.0:8000
```

#### Service de Transaction (FastAPI)

```bash
cd transaction_service

# Créer environnement virtuel
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# Installer dépendances
pip install -r requirements.txt

# Configurer les variables d'environnement
set FRAUD_DETECTION_SERVICE_URL=http://localhost:8002
set AUTH_SERVICE_URL=http://localhost:8000
set REDIS_URL=redis://localhost:6379/0
set DATABASE_URL=sqlite:///./transactions.db

# Lancer le serveur
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

#### Service de Détection de Fraude (FastAPI)

```bash
cd fraud_detection_service

# Créer environnement virtuel
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# Installer dépendances
pip install -r requirements.txt

# S'assurer que le modèle ML est entraîné
cd ../ml_model
python train_model.py
cd ../fraud_detection_service

# Lancer le serveur
uvicorn main:app --host 0.0.0.0 --port 8002 --reload
```

#### Celery Worker (Optionnel)

```bash
cd transaction_service

# Activer l'environnement virtuel
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# Configurer Redis
set REDIS_URL=redis://localhost:6379/0

# Lancer Celery worker
celery -A celery_app worker --loglevel=info
```

## Scripts Automatiques

### Windows

Utilisez les scripts fournis :
- `setup_local.bat` - Installation complète
- `start_auth.bat` - Lancer auth-service
- `start_transaction.bat` - Lancer transaction-service
- `start_fraud_detection.bat` - Lancer fraud-detection-service
- `start_celery.bat` - Lancer Celery worker

### Linux/Mac

```bash
chmod +x setup_local.sh
./setup_local.sh
```

## Ordre de Démarrage

1. **PostgreSQL** (si utilisé)
2. **Redis** (si utilisé pour Celery)
3. **Auth Service** (port 8000)
4. **Fraud Detection Service** (port 8002)
5. **Transaction Service** (port 8001)
6. **Celery Worker** (optionnel)

## Tests

### Tester les Services

```bash
# Health checks
curl http://localhost:8000/api/users/
curl http://localhost:8001/health
curl http://localhost:8002/health

# Tester avec le script Python
python example_usage.py
```

### Lancer les Tests Unitaires

```bash
# Tests Django
cd auth_service
python manage.py test

# Tests FastAPI
cd transaction_service
pytest tests.py

# Tests d'intégration
pytest tests/integration_tests.py
```

## Configuration Alternative (SQLite)

Si vous ne voulez pas utiliser PostgreSQL, vous pouvez utiliser SQLite :

### Auth Service

Dans `auth_service/auth_service/settings.py`, définir :
```python
USE_SQLITE=True
```

Ou dans les variables d'environnement :
```bash
set USE_SQLITE=True
```

### Transaction Service

Par défaut, utilise SQLite. Le fichier `transactions.db` sera créé automatiquement.

## Dépannage

### Erreur : "Module not found"
**Solution** : Activez l'environnement virtuel et installez les dépendances

### Erreur : "Connection refused" (PostgreSQL)
**Solution** : Vérifiez que PostgreSQL est démarré et que les credentials sont corrects

### Erreur : "Connection refused" (Redis)
**Solution** : Vérifiez que Redis est démarré, ou utilisez SQLite pour les tests basiques

### Erreur : "Port already in use"
**Solution** : Arrêtez les autres services utilisant les ports 8000, 8001, 8002

## URLs des Services

- **Auth Service** : http://localhost:8000
  - Swagger : http://localhost:8000/api/docs/
  - Admin : http://localhost:8000/admin/
  
- **Transaction Service** : http://localhost:8001
  - Swagger : http://localhost:8001/docs
  
- **Fraud Detection Service** : http://localhost:8002
  - Swagger : http://localhost:8002/docs

