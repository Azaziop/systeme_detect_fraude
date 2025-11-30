# Guide de Test Simple Sans Docker

## Méthode la Plus Simple

### Option 1 : Script Automatique (Recommandé)

```powershell
.\test_rapide.bat
```

Ce script va :
1. Installer toutes les dépendances
2. Lancer les 3 services dans des fenêtres séparées
3. Vous pouvez tester immédiatement

### Option 2 : Installation puis Lancement Manuel

```powershell
# 1. Installer les dépendances
.\test_simple.bat

# 2. Lancer chaque service dans un terminal séparé
```

## Lancement Manuel (3 Terminaux)

### Terminal 1 - Auth Service

```powershell
cd auth_service
set USE_SQLITE=True
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

### Terminal 2 - Fraud Detection Service

```powershell
cd fraud_detection_service
uvicorn main:app --host 0.0.0.0 --port 8002
```

### Terminal 3 - Transaction Service

```powershell
cd transaction_service
set DATABASE_URL=sqlite:///./transactions.db
uvicorn main:app --host 0.0.0.0 --port 8001
```

## Vérification

Une fois les services lancés, testez :

```powershell
# Health checks
curl http://localhost:8000/api/users/
curl http://localhost:8001/health
curl http://localhost:8002/health

# Ou dans un navigateur
# http://localhost:8000/api/docs/  (Swagger Django)
# http://localhost:8001/docs       (Swagger FastAPI)
# http://localhost:8002/docs       (Swagger FastAPI)
```

## Test Complet

```powershell
python example_usage.py
```

## Notes

- **Pas besoin de PostgreSQL** : Utilise SQLite automatiquement
- **Pas besoin de Redis** : Fonctionne sans (Celery optionnel)
- **Pas besoin de Docker** : Tout fonctionne directement avec Python
- **Modèle ML** : Sera entraîné automatiquement si absent

## Dépannage

### Erreur "Module not found"
```powershell
pip install -r auth_service/requirements.txt
pip install -r transaction_service/requirements.txt
pip install -r fraud_detection_service/requirements.txt
```

### Erreur "Port already in use"
Arrêtez les autres services utilisant les ports 8000, 8001, 8002

### Erreur "Model not found"
```powershell
cd ml_model
python train_model.py
```

