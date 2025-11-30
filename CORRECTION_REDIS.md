# Correction du Problème Redis

## Problème
Erreur `ModuleNotFoundError: No module named 'django_redis'` car le package n'est pas installé mais configuré dans settings.py.

## Solution Appliquée

### 1. Fallback Automatique
Le code a été modifié pour utiliser un cache local (LocMemCache) si `django-redis` n'est pas installé. Cela permet de tester sans Redis.

### 2. Installation Optionnelle
Pour utiliser Redis (optionnel), installez :
```powershell
pip install django-redis
```

## Options

### Option 1 : Sans Redis (Recommandé pour test simple)
Ne faites rien, le cache local sera utilisé automatiquement.

### Option 2 : Avec Redis
```powershell
pip install django-redis
```

Puis démarrez Redis (optionnel) :
```powershell
# Si Redis est installé
redis-server
```

## Test

Après la correction, relancez Django :
```powershell
cd auth_service
set USE_SQLITE=True
python manage.py runserver 0.0.0.0:8000
```

Le serveur devrait démarrer sans erreur, même sans Redis installé.

