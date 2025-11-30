# Service d'Authentification

Service Django REST Framework pour gérer l'authentification et les utilisateurs.

## Endpoints

### POST /api/register/
Inscription d'un nouvel utilisateur

**Request:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "securepass123",
  "password_confirm": "securepass123",
  "phone": "+1234567890"
}
```

**Response:**
```json
{
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "phone": "+1234567890"
  },
  "token": "abc123...",
  "message": "Utilisateur créé avec succès"
}
```

### POST /api/login/
Connexion

**Request:**
```json
{
  "username": "john_doe",
  "password": "securepass123"
}
```

**Response:**
```json
{
  "token": "abc123...",
  "user": {...},
  "message": "Connexion réussie"
}
```

### POST /api/logout/
Déconnexion (nécessite authentification)

### GET /api/profile/
Profil utilisateur (nécessite authentification)

### GET /api/users/{user_id}/verify/
Vérifie si un utilisateur existe et est actif

## Utilisation

```bash
# Migrations
python manage.py migrate

# Créer un superutilisateur
python manage.py createsuperuser

# Lancer le serveur
python manage.py runserver 0.0.0.0:8000
```

## Authentification

Le service utilise Token Authentication. Inclure le token dans les headers:
```
Authorization: Token abc123...
```

