# Correction du Problème Token

## Problème
Erreur : `Cannot assign "<User: testuser>": "Token.user" must be a "User" instance.`

## Cause
Le serializer créait encore un Token alors qu'on utilise maintenant JWT. De plus, `AUTH_USER_MODEL` n'était pas configuré.

## Corrections Appliquées

1. **Suppression de la création de Token dans le serializer** - Les tokens JWT sont maintenant créés dans la vue
2. **Ajout de AUTH_USER_MODEL** dans settings.py pour indiquer le modèle User personnalisé

## Pour Appliquer

### Option 1 : Redémarrer le serveur (Recommandé)

```powershell
# Arrêter le serveur (Ctrl+C)
# Puis relancer
cd auth_service
set USE_SQLITE=True
python manage.py runserver 0.0.0.0:8000
```

### Option 2 : Recréer la base de données (si nécessaire)

Si l'erreur persiste, recréez la base :

```powershell
cd auth_service
del db.sqlite3
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver 0.0.0.0:8000
```

## Test

Après redémarrage, testez à nouveau :

```powershell
$body = @{
    username = "testuser"
    email = "test@example.com"
    password = "testpass123"
    password_confirm = "testpass123"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8000/api/register/" -Method POST -Body $body -ContentType "application/json"
```

Vous devriez recevoir une réponse avec `access` et `refresh` tokens (JWT).

