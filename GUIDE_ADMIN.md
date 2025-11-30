# Guide d'Accès à l'Admin Django

## Créer un Superutilisateur

### Méthode 1 : Script Automatique

```powershell
.\create_admin.bat
```

### Méthode 2 : Commande Manuelle

```powershell
cd auth_service
python manage.py createsuperuser
```

Vous serez invité à entrer :
- **Username** : (ex: `admin`)
- **Email** : (ex: `admin@example.com`)
- **Password** : (entrez un mot de passe sécurisé)
- **Password (again)** : (confirmez le mot de passe)

## Se Connecter

1. Allez sur : http://localhost:8000/admin/
2. Entrez votre **username** et **password**
3. Cliquez sur "Log in"

## Utilisation de l'Admin

Une fois connecté, vous pouvez :
- Voir et gérer les utilisateurs
- Voir les tokens d'authentification
- Gérer les groupes et permissions
- Accéder à toutes les données de l'application

## Créer un Superutilisateur Automatiquement (Optionnel)

Si vous voulez créer un superutilisateur avec des valeurs par défaut, vous pouvez utiliser :

```powershell
cd auth_service
python manage.py shell
```

Puis dans le shell Python :
```python
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superutilisateur créé: admin / admin123')
```

## Dépannage

### Erreur "Superuser already exists"
→ Le superutilisateur existe déjà. Utilisez les identifiants existants.

### Mot de passe oublié
```powershell
cd auth_service
python manage.py changepassword admin
```

### Créer un autre superutilisateur
```powershell
cd auth_service
python manage.py createsuperuser
```

