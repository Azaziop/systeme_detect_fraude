# Guide de Dépannage

## Problème : Erreur lors de l'installation de pandas/numpy

### Symptômes
```
ERROR: Failed to build 'pandas' when installing build dependencies
Unknown compiler(s): [['icl'], ['cl'], ['cc'], ['gcc'], ['clang']]
```

### Solutions

#### Solution 1 : Utiliser des versions précompilées (Rapide)

```powershell
cd ml_model
pip install --upgrade pip
pip install pandas numpy scikit-learn joblib
python train_model.py
```

Ou utilisez le script :
```powershell
.\train_model_simple.bat
```

#### Solution 2 : Utiliser un environnement virtuel

```powershell
# Créer l'environnement
python -m venv venv

# Activer
.\venv\Scripts\activate

# Installer
cd ml_model
pip install pandas numpy scikit-learn joblib
python train_model.py
```

#### Solution 3 : Installer Visual Studio Build Tools

1. Téléchargez : https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
2. Installez "C++ build tools"
3. Redémarrez votre terminal
4. Réessayez

#### Solution 4 : Utiliser Conda

```powershell
conda create -n fraud python=3.11
conda activate fraud
conda install pandas numpy scikit-learn joblib
cd ml_model
python train_model.py
```

## Problème : Docker ne trouve pas les fichiers

### Symptômes
```
failed to solve: "/main.py": not found
```

### Solution
Les fichiers ont été corrigés. Réessayez :
```powershell
docker-compose build
```

## Problème : Port déjà utilisé

### Solution Windows PowerShell
```powershell
# Trouver le processus
netstat -ano | findstr :8000

# Arrêter le processus (remplacez PID par le numéro trouvé)
taskkill /PID <PID> /F
```

## Problème : Docker Desktop n'est pas démarré

### Solution
1. Ouvrez Docker Desktop
2. Attendez que l'icône soit verte
3. Vérifiez avec : `docker info`

## Problème : Le modèle n'est pas trouvé par le service

### Solution
Assurez-vous que le modèle est entraîné :
```powershell
# Vérifier que ces fichiers existent
dir ml_model\models\isolation_forest_model.pkl
dir ml_model\models\scaler.pkl
dir ml_model\models\feature_columns.json
```

Si ils n'existent pas :
```powershell
cd ml_model
python train_model.py
```

## Problème : Les services ne démarrent pas

### Vérifications
1. Docker Desktop est démarré
2. Les ports 8000, 8001, 8002 sont libres
3. Le modèle ML est entraîné
4. Les images Docker sont construites

### Voir les logs
```powershell
docker-compose logs -f
```

### Reconstruire tout
```powershell
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Besoin d'aide ?

Consultez :
- [INSTALL_WINDOWS.md](INSTALL_WINDOWS.md) - Guide d'installation Windows
- [DEMARRAGE.md](DEMARRAGE.md) - Guide de démarrage
- [QUICK_START.md](QUICK_START.md) - Démarrage rapide

