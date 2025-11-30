# Modèle ML - Détection de Fraude

Ce module contient le code pour entraîner le modèle de détection de fraude utilisant l'algorithme Isolation Forest.

## Description

Le modèle utilise l'algorithme **Isolation Forest** pour détecter les transactions frauduleuses. Isolation Forest est particulièrement adapté pour la détection d'anomalies car il identifie les points qui sont "isolés" du reste des données.

## Utilisation

### 1. Installer les dépendances

```bash
pip install -r requirements.txt
```

### 2. Entraîner le modèle

```bash
python train_model.py
```

Le script va:
- Télécharger ou générer des données de transactions
- Préparer et normaliser les données
- Entraîner le modèle Isolation Forest
- Évaluer les performances
- Sauvegarder le modèle dans `models/`

### 3. Fichiers générés

Après l'entraînement, les fichiers suivants seront créés:
- `models/isolation_forest_model.pkl` - Le modèle entraîné
- `models/scaler.pkl` - Le scaler pour normaliser les features
- `models/feature_columns.json` - Les noms des colonnes de features

## Dataset

Le script peut utiliser:
1. **Dataset Kaggle**: Si vous avez le fichier `data/creditcard.csv` du dataset Credit Card Fraud Detection
2. **Données synthétiques**: Le script génère automatiquement des données si le dataset n'est pas disponible

Pour utiliser le vrai dataset Kaggle:
1. Téléchargez le dataset depuis [Kaggle](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud)
2. Placez le fichier `creditcard.csv` dans le dossier `data/`

## Caractéristiques du Modèle

- **Algorithme**: Isolation Forest
- **Nombre d'estimateurs**: 100
- **Contamination**: 0.0017 (0.17% - taux de fraude typique)
- **Features**: V1-V28 (features PCA) + Amount

## Performance

Le modèle retourne:
- `is_fraud`: Boolean indiquant si la transaction est frauduleuse
- `fraud_score`: Score d'anomalie (plus négatif = plus suspect)
- `confidence`: Niveau de confiance (0-1)

## Intégration

Le modèle est utilisé par le `fraud-detection-service` pour analyser les transactions en temps réel.

