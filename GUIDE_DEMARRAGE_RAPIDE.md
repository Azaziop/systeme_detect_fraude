# Guide de Démarrage Rapide - Sans Docker

## Vous êtes dans le mauvais dossier !

Si vous êtes dans `auth_service/auth_service`, vous devez remonter d'un niveau.

## Solution Rapide

### Depuis PowerShell (où vous êtes actuellement)

```powershell
# Remonter d'un niveau
cd ..

# Maintenant vous êtes dans auth_service/
# Lancer le serveur
set USE_SQLITE=True
python manage.py runserver 0.0.0.0:8000
```

### Ou utiliser le script automatique

```powershell
# Depuis la racine du projet
cd C:\Users\zaoui\OneDrive\Desktop\detec_fraude

# Lancer le script
.\start_auth.bat
```

## Structure des Dossiers

```
detec_fraude/
├── auth_service/          ← Vous devez être ICI
│   ├── manage.py          ← Fichier à exécuter
│   ├── auth_service/      ← Vous étiez ICI (trop profond)
│   └── users/
├── transaction_service/
└── fraud_detection_service/
```

## Commandes Correctes

### Depuis la racine du projet

```powershell
cd C:\Users\zaoui\OneDrive\Desktop\detec_fraude
cd auth_service
set USE_SQLITE=True
python manage.py runserver 0.0.0.0:8000
```

### Depuis auth_service/auth_service (où vous êtes)

```powershell
cd ..
set USE_SQLITE=True
python manage.py runserver 0.0.0.0:8000
```

## Scripts Disponibles

Depuis la racine du projet :

```powershell
.\start_auth.bat              # Lancer auth service
.\start_transaction.bat       # Lancer transaction service
.\start_fraud_detection.bat   # Lancer fraud detection
.\test_direct.bat             # Lancer tous les services
```

