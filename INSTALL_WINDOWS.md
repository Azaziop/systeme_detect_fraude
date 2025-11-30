# Installation sur Windows - Guide de Dépannage

## Problème : Erreur lors de l'installation de pandas/numpy

Si vous rencontrez des erreurs de compilation lors de l'installation de pandas, voici plusieurs solutions :

### Solution 1 : Utiliser des versions précompilées (Recommandé)

```powershell
cd ml_model
pip install --upgrade pip
pip install pandas numpy scikit-learn joblib
python train_model.py
```

### Solution 2 : Installer Visual Studio Build Tools

Si vous voulez compiler depuis les sources :

1. Téléchargez [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
2. Installez "C++ build tools"
3. Réessayez l'installation

### Solution 3 : Utiliser un environnement virtuel

```powershell
# Créer un environnement virtuel
python -m venv venv

# Activer l'environnement
.\venv\Scripts\activate

# Installer les dépendances
cd ml_model
pip install --upgrade pip
pip install pandas numpy scikit-learn joblib
python train_model.py
```

### Solution 4 : Utiliser Conda (Alternative)

Si vous avez Anaconda ou Miniconda installé :

```powershell
conda create -n fraud-detection python=3.11
conda activate fraud-detection
conda install pandas numpy scikit-learn joblib
cd ml_model
python train_model.py
```

## Problème : Docker ne trouve pas les fichiers

Si vous avez des erreurs de build Docker, assurez-vous que :
1. Tous les fichiers sont présents
2. Docker Desktop est démarré
3. Les chemins dans docker-compose.yml sont corrects

## Alternative : Entraîner le modèle dans Docker

Si l'installation locale pose problème, vous pouvez entraîner le modèle directement dans un conteneur Docker :

```powershell
# Créer un conteneur temporaire pour entraîner le modèle
docker run -it --rm -v ${PWD}/ml_model:/app -w /app python:3.9-slim bash

# Dans le conteneur :
pip install pandas numpy scikit-learn joblib
python train_model.py
exit
```

## Vérification

Après l'installation, vérifiez que ces fichiers existent :
- `ml_model/models/isolation_forest_model.pkl`
- `ml_model/models/scaler.pkl`
- `ml_model/models/feature_columns.json`

