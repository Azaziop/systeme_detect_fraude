# Guide d'Installation et Utilisation de Django

Ce guide explique comment installer et utiliser Django localement (sans Docker) pour ce projet.

## Installation Rapide

### Option 1 : Installation Automatique Complète

```powershell
.\setup_django_dev.bat
```

Ce script va :
1. ✅ Créer un environnement virtuel
2. ✅ Installer Django et toutes les dépendances
3. ✅ Appliquer les migrations
4. ✅ Créer un superutilisateur (admin/admin123)

### Option 2 : Installation Étape par Étape

```powershell
# 1. Installer Django et dépendances
.\install_django.bat

# 2. Lancer Django
.\run_django.bat
```

## Installation Manuelle

### 1. Créer un environnement virtuel

```powershell
python -m venv venv
```

### 2. Activer l'environnement virtuel

```powershell
.\venv\Scripts\activate
```

### 3. Installer les dépendances

```powershell
cd auth_service
pip install -r requirements.txt
```

### 4. Appliquer les migrations

```powershell
python manage.py migrate
```

### 5. Créer un superutilisateur

```powershell
python manage.py createsuperuser
```

### 6. Lancer le serveur

```powershell
python manage.py runserver
```

## Utilisation

### Lancer le Serveur

**Avec le script automatique :**
```powershell
.\run_django.bat
```

**Manuellement :**
```powershell
.\venv\Scripts\activate
cd auth_service
python manage.py runserver
```

### Accès aux Interfaces

Une fois le serveur lancé :

- **API REST** : http://localhost:8000/api/
- **Django Admin** : http://localhost:8000/admin/
  - Username : `admin`
  - Password : `admin123`
- **Documentation API** : http://localhost:8000/api/

### Commandes Django Utiles

```powershell
# Activer l'environnement virtuel
.\venv\Scripts\activate

# Aller dans le dossier auth_service
cd auth_service

# Créer de nouvelles migrations
python manage.py makemigrations

# Appliquer les migrations
python manage.py migrate

# Créer un superutilisateur
python manage.py createsuperuser

# Lancer le shell Django
python manage.py shell

# Collecter les fichiers statiques
python manage.py collectstatic
```

## Structure du Projet Django

```
auth_service/
├── manage.py              # Script de gestion Django
├── auth_service/          # Configuration du projet
│   ├── settings.py       # Paramètres Django
│   ├── urls.py           # URLs principales
│   └── wsgi.py           # WSGI config
└── users/                # Application utilisateurs
    ├── models.py         # Modèle User
    ├── views.py          # Vues API
    ├── serializers.py    # Serializers
    └── urls.py           # URLs de l'app
```

## Endpoints API Disponibles

- `POST /api/register/` - Inscription
- `POST /api/login/` - Connexion
- `POST /api/logout/` - Déconnexion
- `GET /api/profile/` - Profil utilisateur
- `GET /api/users/` - Liste des utilisateurs
- `GET /api/users/{id}/verify/` - Vérifier un utilisateur

## Dépannage

### Erreur : "ModuleNotFoundError: No module named 'django'"

**Solution** : Activez l'environnement virtuel
```powershell
.\venv\Scripts\activate
```

### Erreur : "No such table: users_user"

**Solution** : Appliquez les migrations
```powershell
cd auth_service
python manage.py migrate
```

### Erreur : "Port 8000 already in use"

**Solution** : Utilisez un autre port
```powershell
python manage.py runserver 8001
```

### Réinitialiser la Base de Données

```powershell
cd auth_service
del db.sqlite3
python manage.py migrate
python manage.py createsuperuser
```

## Développement vs Production

### Développement (Local)
- Base de données : SQLite3
- Serveur : `python manage.py runserver`
- Debug : Activé

### Production (Docker)
- Base de données : SQLite3 (peut être changé pour PostgreSQL)
- Serveur : Gunicorn ou uWSGI
- Debug : Désactivé

## Intégration avec les Autres Services

Le service Django fonctionne indépendamment mais peut communiquer avec :

- **Transaction Service** (port 8001) : Pour vérifier les utilisateurs
- **Fraud Detection Service** (port 8002) : Non utilisé directement

Pour tester l'intégration complète, utilisez Docker Compose :
```powershell
docker-compose up
```

