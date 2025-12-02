# Guide: Intégrer un Modèle Random Forest depuis Google Colab

Ce guide vous explique comment récupérer votre modèle Random Forest depuis Google Colab et l'intégrer dans ce projet.

## 📋 Étape 1: Vérifier où est votre modèle dans Colab

Dans votre notebook Colab (`Untitled38.ipynb`), le modèle est probablement sauvegardé avec une commande comme:

```python
# Exemple de sauvegarde dans Colab
joblib.dump(model, 'random_forest_model.pkl')
# ou
joblib.dump(model, '/content/random_forest_model.pkl')
# ou sauvegardé dans Google Drive
joblib.dump(model, '/content/drive/MyDrive/random_forest_model.pkl')
```

## 🚀 Étape 2: Sauvegarder le modèle dans Google Drive (si pas déjà fait)

### Option A: Depuis Colab, sauvegarder directement dans Drive

```python
from google.colab import drive
import joblib
import os

# Monter Google Drive
drive.mount('/content/drive')

# Charger votre modèle (si vous l'avez déjà entraîné)
# model = ... votre modèle ...

# Sauvegarder dans Drive
model_path = '/content/drive/MyDrive/random_forest_model.pkl'
joblib.dump(model, model_path)

# Si vous avez un scaler
scaler_path = '/content/drive/MyDrive/scaler.pkl'
joblib.dump(scaler, scaler_path)

# Si vous avez les noms de colonnes
import json
feature_columns = ['V1', 'V2', ..., 'V28', 'Amount']  # Vos colonnes
features_path = '/content/drive/MyDrive/feature_columns.json'
with open(features_path, 'w') as f:
    json.dump(feature_columns, f)

print("✅ Modèle sauvegardé dans Google Drive!")
```

### Option B: Télécharger depuis Colab vers votre ordinateur

```python
from google.colab import files
import joblib

# Si le modèle est dans /content/
joblib.dump(model, 'random_forest_model.pkl')
files.download('random_forest_model.pkl')

# Si vous avez un scaler
joblib.dump(scaler, 'scaler.pkl')
files.download('scaler.pkl')
```

Puis copiez les fichiers téléchargés dans `ml_model/models/` sur votre ordinateur.

## 📥 Étape 3: Télécharger depuis Google Drive vers le projet

### Méthode 1: Utiliser le script automatique

1. **Obtenir le lien Google Drive du fichier .pkl**

   - Allez sur [drive.google.com](https://drive.google.com)
   - Trouvez votre fichier `random_forest_model.pkl`
   - Clic droit → "Partager" → "Obtenir le lien"
   - Assurez-vous que le lien est en mode "Toute personne disposant du lien"
   - Copiez le lien complet

2. **Télécharger avec le script**

   ```powershell
   cd C:\Users\zaoui\OneDrive\Desktop\detec_fraude
   .\telecharger_modele.bat
   ```

   Choisissez l'option 2 (lien partageable) et collez votre lien.

### Méthode 2: Téléchargement manuel depuis Drive

1. Allez sur [drive.google.com](https://drive.google.com)
2. Trouvez votre fichier `random_forest_model.pkl`
3. Clic droit → "Télécharger"
4. Copiez le fichier dans: `C:\Users\zaoui\OneDrive\Desktop\detec_fraude\ml_model\models\`
5. Renommez-le en `random_forest_model.pkl` si nécessaire

### Méthode 3: Utiliser gdown directement

Si vous avez le File ID du fichier dans Drive:

```powershell
cd ml_model
pip install gdown
gdown --id VOTRE_FILE_ID -O models/random_forest_model.pkl
```

## 🔍 Étape 4: Vérifier que le modèle est au bon endroit

Vérifiez que vous avez ces fichiers:

```
ml_model/
  models/
    random_forest_model.pkl  ← Votre modèle (OBLIGATOIRE)
    scaler.pkl               ← Optionnel
    feature_columns.json     ← Optionnel
```

## ✅ Étape 5: Tester le modèle

1. **Démarrer le service de détection de fraude:**

   ```powershell
   cd fraud_detection_service
   uvicorn main:app --host 0.0.0.0 --port 8002
   ```

2. **Vérifier que le modèle est chargé:**

   ```powershell
   curl http://localhost:8002/
   ```

   Vous devriez voir:
   ```json
   {
     "service": "Fraud Detection Service",
     "status": "running",
     "model_loaded": true,
     "model_type": "random_forest"
   }
   ```

## 🐍 Code Colab Complet pour Exporter le Modèle

Si vous voulez créer un script Colab pour exporter tout automatiquement:

```python
# ============================================
# Script Colab: Exporter Modèle vers Drive
# ============================================

from google.colab import drive
import joblib
import json
from pathlib import Path

# 1. Monter Google Drive
drive.mount('/content/drive')

# 2. Définir les chemins
DRIVE_MODEL_DIR = '/content/drive/MyDrive/fraud_detection_model'
os.makedirs(DRIVE_MODEL_DIR, exist_ok=True)

# 3. Sauvegarder le modèle (remplacez 'model' par votre variable)
model_path = f'{DRIVE_MODEL_DIR}/random_forest_model.pkl'
joblib.dump(model, model_path)
print(f"✅ Modèle sauvegardé: {model_path}")

# 4. Sauvegarder le scaler (si vous en avez un)
if 'scaler' in locals():
    scaler_path = f'{DRIVE_MODEL_DIR}/scaler.pkl'
    joblib.dump(scaler, scaler_path)
    print(f"✅ Scaler sauvegardé: {scaler_path}")

# 5. Sauvegarder les noms de colonnes (si vous les avez)
if 'feature_columns' in locals():
    features_path = f'{DRIVE_MODEL_DIR}/feature_columns.json'
    with open(features_path, 'w') as f:
        json.dump(feature_columns, f)
    print(f"✅ Features sauvegardées: {features_path}")

# 6. Afficher les liens pour partager
print("\n" + "="*60)
print("📁 Fichiers sauvegardés dans Google Drive:")
print(f"   {DRIVE_MODEL_DIR}")
print("\n📋 Pour partager:")
print("   1. Allez sur drive.google.com")
print("   2. Trouvez le dossier 'fraud_detection_model'")
print("   3. Clic droit sur chaque fichier → Partager → Obtenir le lien")
print("="*60)
```

## 🔗 Obtenir le Lien Google Drive

### Pour un fichier unique:

1. Allez sur [drive.google.com](https://drive.google.com)
2. Naviguez jusqu'à votre fichier `random_forest_model.pkl`
3. Clic droit → **"Partager"**
4. Cliquez sur **"Modifier"** à côté de "Accès restreint"
5. Sélectionnez **"Toute personne disposant du lien"**
6. Cliquez sur **"Copier le lien"**
7. Le lien ressemble à: `https://drive.google.com/file/d/FILE_ID/view?usp=sharing`

### Pour un dossier (si vous avez plusieurs fichiers):

1. Clic droit sur le dossier → **"Partager"**
2. Même processus que ci-dessus
3. Utilisez le script avec l'option "lien partageable"

## ⚠️ Dépannage

### Erreur: "Fichier non trouvé dans Drive"

- Vérifiez que le fichier existe bien dans Drive
- Vérifiez que le lien est en mode "Toute personne disposant du lien"
- Essayez de télécharger manuellement depuis Drive

### Erreur: "Modèle non chargé" au démarrage

- Vérifiez que `random_forest_model.pkl` est dans `ml_model/models/`
- Vérifiez que le nom est exactement `random_forest_model.pkl` (pas `random_forest_model (1).pkl`)
- Vérifiez les permissions du fichier

### Le modèle ne fonctionne pas

- Vérifiez que c'est bien un Random Forest sauvegardé avec `joblib`
- Testez dans Colab: `model = joblib.load('votre_modele.pkl')` pour vérifier qu'il se charge

## 📝 Exemple de Notebook Colab Complet

Si vous voulez, je peux vous créer un notebook Colab complet qui:
1. Entraîne le modèle
2. Le sauvegarde dans Drive
3. Génère les liens de partage

Dites-moi si vous voulez que je crée ce notebook!

