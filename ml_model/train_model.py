"""
Script pour entraîner le modèle de détection de fraude avec Random Forest et Isolation Forest
Utilise le dataset Credit Card Fraud Detection de Kaggle
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier, IsolationForest
from sklearn.preprocessing import StandardScaler
import joblib
import os
from pathlib import Path

# Configuration
MODEL_DIR = Path(__file__).parent / "models"
MODEL_DIR.mkdir(exist_ok=True)
MODEL_PATH_RF = MODEL_DIR / "random_forest_model.pkl"
MODEL_PATH_IF = MODEL_DIR / "isolation_forest_model.pkl"
SCALER_PATH = MODEL_DIR / "scaler.pkl"

def download_dataset():
    """
    Télécharge ou génère un dataset de transactions
    Si le dataset n'existe pas, génère des données synthétiques
    """
    dataset_path = Path(__file__).parent / "data" / "creditcard.csv"
    dataset_path.parent.mkdir(exist_ok=True)
    
    if not dataset_path.exists():
        print("Dataset non trouvé. Génération de données synthétiques...")
        generate_synthetic_data(dataset_path)
    
    return dataset_path

def generate_synthetic_data(output_path):
    """
    Génère des données synthétiques de transactions
    Simule les caractéristiques du dataset Credit Card Fraud Detection
    """
    np.random.seed(42)
    n_samples = 10000
    n_features = 28  # V1-V28 comme dans le dataset original
    
    # Générer des features normalisées
    features = np.random.randn(n_samples, n_features)
    
    # Créer un DataFrame
    data = pd.DataFrame(features, columns=[f'V{i+1}' for i in range(n_features)])
    
    # Ajouter Amount et Time
    data['Time'] = np.random.uniform(0, 172792, n_samples)
    data['Amount'] = np.random.exponential(88, n_samples)
    
    # Générer des labels (0 = normal, 1 = fraude)
    # Environ 0.17% de fraude (comme dans le dataset réel)
    fraud_indices = np.random.choice(n_samples, size=int(n_samples * 0.0017), replace=False)
    data['Class'] = 0
    data.loc[fraud_indices, 'Class'] = 1
    
    # Sauvegarder
    data.to_csv(output_path, index=False)
    print(f"Données synthétiques générées: {output_path}")
    return data

def prepare_data(df):
    """
    Prépare les données pour l'entraînement
    """
    # Séparer features et target
    feature_columns = [col for col in df.columns if col not in ['Class', 'Time']]
    X = df[feature_columns].copy()
    y = df['Class'].copy()
    
    # Normaliser les features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    return X_scaled, y, scaler, feature_columns

def train_isolation_forest(X, contamination=0.0017):
    """
    Entraîne un modèle Isolation Forest
    """
    model = IsolationForest(
        n_estimators=100,
        max_samples='auto',
        contamination=contamination,
        random_state=42,
        n_jobs=-1
    )
    
    model.fit(X)
    return model

def train_random_forest(X, y):
    """
    Entraîne un modèle Random Forest pour la classification
    """
    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=20,
        min_samples_split=10,
        min_samples_leaf=5,
        random_state=42,
        n_jobs=-1,
        class_weight='balanced'  # Pour gérer le déséquilibre des classes
    )
    
    model.fit(X, y)
    return model

def evaluate_model(model, X, y):
    """
    Évalue le modèle
    """
    predictions = model.predict(X)
    # Isolation Forest retourne -1 pour anomalies, 1 pour normal
    # Convertir en 0 (normal) et 1 (fraude)
    predictions_binary = (predictions == -1).astype(int)
    
    from sklearn.metrics import classification_report, confusion_matrix
    
    print("\n=== Évaluation du Modèle ===")
    print("\nMatrice de confusion:")
    print(confusion_matrix(y, predictions_binary))
    print("\nRapport de classification:")
    print(classification_report(y, predictions_binary))
    
    return predictions_binary

def main():
    """
    Fonction principale pour entraîner le modèle
    """
    print("=== Entraînement des Modèles de Détection de Fraude ===\n")
    
    # 1. Charger ou générer les données
    print("1. Chargement des données...")
    dataset_path = download_dataset()
    df = pd.read_csv(dataset_path)
    print(f"   Dataset chargé: {len(df)} transactions")
    print(f"   Fraudes: {df['Class'].sum()} ({df['Class'].mean()*100:.2f}%)")
    
    # 2. Préparer les données
    print("\n2. Préparation des données...")
    X, y, scaler, feature_columns = prepare_data(df)
    print(f"   Features: {len(feature_columns)}")
    
    # 3. Entraîner Random Forest
    print("\n3. Entraînement du modèle Random Forest...")
    model_rf = train_random_forest(X, y)
    print("   Modèle Random Forest entraîné avec succès!")
    
    # 4. Entraîner Isolation Forest
    print("\n4. Entraînement du modèle Isolation Forest...")
    model_if = train_isolation_forest(X)
    print("   Modèle Isolation Forest entraîné avec succès!")
    
    # 5. Évaluer les modèles
    print("\n5. Évaluation des modèles...")
    print("\n   === Random Forest ===")
    evaluate_model(model_rf, X, y)
    print("\n   === Isolation Forest ===")
    predictions_if = model_if.predict(X)
    predictions_binary_if = (predictions_if == -1).astype(int)
    from sklearn.metrics import classification_report, confusion_matrix
    print("Matrice de confusion:")
    print(confusion_matrix(y, predictions_binary_if))
    print("Rapport de classification:")
    print(classification_report(y, predictions_binary_if))
    
    # 6. Sauvegarder les modèles et le scaler
    print("\n6. Sauvegarde des modèles...")
    joblib.dump(model_rf, MODEL_PATH_RF)
    joblib.dump(model_if, MODEL_PATH_IF)
    joblib.dump(scaler, SCALER_PATH)
    
    # Sauvegarder aussi les noms des colonnes
    import json
    with open(MODEL_DIR / "feature_columns.json", "w") as f:
        json.dump(feature_columns, f)
    
    print(f"   Modèle Random Forest sauvegardé: {MODEL_PATH_RF}")
    print(f"   Modèle Isolation Forest sauvegardé: {MODEL_PATH_IF}")
    print(f"   Scaler sauvegardé: {SCALER_PATH}")
    print(f"   Features sauvegardées: {MODEL_DIR / 'feature_columns.json'}")
    print("\n=== Entraînement des modèles terminé avec succès! ===")
    
    # 7. Afficher les statistiques des modèles
    print(f"\n=== Statistiques des Modèles ===")
    print(f"Random Forest: {model_rf.n_estimators} arbres, profondeur max: {model_rf.max_depth}")
    print(f"Isolation Forest: {model_if.n_estimators} arbres")
    print(f"Scaler: StandardScaler appliqué sur {len(feature_columns)} features")

if __name__ == "__main__":
    main()

