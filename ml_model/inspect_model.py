"""
Script pour inspecter le modèle et voir combien de features il attend
"""

import joblib
from pathlib import Path

MODEL_DIR = Path(__file__).parent / "models"
MODEL_PATH = MODEL_DIR / "random_forest_model.pkl"

print("=" * 60)
print("  Inspection du Modèle Random Forest")
print("=" * 60)
print()

# Charger le modèle
model = joblib.load(MODEL_PATH)

print(f"Type du modèle: {type(model).__name__}")
print()

# Vérifier le nombre de features attendues
if hasattr(model, 'n_features_in_'):
    print(f"✅ Nombre de features attendues: {model.n_features_in_}")
else:
    print("⚠️  n_features_in_ non disponible")

# Vérifier les feature names si disponibles
if hasattr(model, 'feature_names_in_'):
    if model.feature_names_in_ is not None:
        print(f"\n✅ Noms des features du modèle:")
        for i, name in enumerate(model.feature_names_in_, 1):
            print(f"   {i}. {name}")
        print(f"\nTotal: {len(model.feature_names_in_)} features")
    else:
        print("\n⚠️  feature_names_in_ est None")
else:
    print("\n⚠️  feature_names_in_ non disponible")

# Vérifier le scaler aussi
SCALER_PATH = MODEL_DIR / "scaler.pkl"
if SCALER_PATH.exists():
    scaler = joblib.load(SCALER_PATH)
    print(f"\n📦 Scaler: {type(scaler).__name__}")
    if hasattr(scaler, 'n_features_in_'):
        print(f"   Features attendues par le scaler: {scaler.n_features_in_}")
    if hasattr(scaler, 'feature_names_in_') and scaler.feature_names_in_ is not None:
        print(f"   Noms des features du scaler:")
        for i, name in enumerate(scaler.feature_names_in_, 1):
            print(f"   {i}. {name}")

print("\n" + "=" * 60)

