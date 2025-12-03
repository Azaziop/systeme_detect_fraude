"""
Script pour tester que le modèle Random Forest peut être chargé correctement
"""

import joblib
import json
from pathlib import Path
import numpy as np

MODEL_DIR = Path(__file__).parent / "models"
MODEL_PATH = MODEL_DIR / "random_forest_model.pkl"
SCALER_PATH = MODEL_DIR / "scaler.pkl"
FEATURES_PATH = MODEL_DIR / "feature_columns.json"

def test_model():
    """Teste le chargement et la prédiction du modèle"""
    
    print("=" * 60)
    print("  Test du Modèle Random Forest")
    print("=" * 60)
    print()
    
    # 1. Vérifier que le fichier existe
    if not MODEL_PATH.exists():
        print(f"❌ ERREUR: Modèle non trouvé à {MODEL_PATH}")
        return False
    
    print(f"✅ Modèle trouvé: {MODEL_PATH}")
    
    # 2. Charger le modèle
    try:
        print("\n📦 Chargement du modèle...")
        model = joblib.load(MODEL_PATH)
        print(f"✅ Modèle chargé: {type(model).__name__}")
    except Exception as e:
        print(f"❌ ERREUR lors du chargement: {e}")
        return False
    
    # 3. Vérifier les méthodes du modèle
    print("\n🔍 Vérification des méthodes du modèle...")
    has_predict = hasattr(model, 'predict')
    has_predict_proba = hasattr(model, 'predict_proba')
    
    print(f"   predict: {'✅' if has_predict else '❌'}")
    print(f"   predict_proba: {'✅' if has_predict_proba else '❌'}")
    
    if not has_predict:
        print("❌ Le modèle n'a pas de méthode predict()")
        return False
    
    # 4. Charger le scaler (optionnel)
    scaler = None
    if SCALER_PATH.exists():
        try:
            print("\n📦 Chargement du scaler...")
            scaler = joblib.load(SCALER_PATH)
            print(f"✅ Scaler chargé: {type(scaler).__name__}")
        except Exception as e:
            print(f"⚠️  Erreur lors du chargement du scaler: {e}")
    else:
        print("\n⚠️  Scaler non trouvé (optionnel)")
    
    # 5. Charger les features (optionnel)
    feature_columns = None
    if FEATURES_PATH.exists():
        try:
            print("\n📦 Chargement des features...")
            with open(FEATURES_PATH, 'r') as f:
                feature_columns = json.load(f)
            print(f"✅ Features chargées: {len(feature_columns)} colonnes")
            print(f"   Colonnes: {feature_columns[:5]}... (premières 5)")
        except Exception as e:
            print(f"⚠️  Erreur lors du chargement des features: {e}")
    else:
        print("\n⚠️  Features non trouvées, utilisation par défaut (V1-V28, Amount)")
        feature_columns = [f'V{i+1}' for i in range(28)] + ['Amount']
    
    # 6. Tester une prédiction
    print("\n🧪 Test de prédiction...")
    try:
        # Créer des données de test avec toutes les features
        n_features = len(feature_columns)
        test_data = np.random.randn(1, n_features)
        
        # Normaliser si scaler disponible
        # Gérer le cas où le scaler n'a pas Time mais le modèle l'a
        if scaler is not None:
            if hasattr(scaler, 'feature_names_in_') and scaler.feature_names_in_ is not None:
                # Le scaler a des noms de features
                scaler_features = list(scaler.feature_names_in_)
                if 'Time' in feature_columns and 'Time' not in scaler_features:
                    # Extraire Time et normaliser le reste
                    time_value = test_data[0, 0]
                    other_features = test_data[0, 1:].reshape(1, -1)
                    other_scaled = scaler.transform(other_features)
                    test_data_scaled = np.column_stack([np.array([[time_value]]), other_scaled])
                else:
                    # Toutes les features sont dans le scaler
                    test_data_scaled = scaler.transform(test_data)
            elif scaler.n_features_in_ < n_features:
                # Le scaler a moins de features (probablement pas Time)
                time_value = test_data[0, 0]
                other_features = test_data[0, 1:].reshape(1, -1)
                other_scaled = scaler.transform(other_features)
                test_data_scaled = np.column_stack([np.array([[time_value]]), other_scaled])
            else:
                test_data_scaled = scaler.transform(test_data)
        else:
            test_data_scaled = test_data
        
        # Prédiction
        prediction = model.predict(test_data_scaled)[0]
        print(f"✅ Prédiction réussie: {prediction}")
        
        # Probabilités si disponible
        if has_predict_proba:
            proba = model.predict_proba(test_data_scaled)[0]
            print(f"✅ Probabilités: {proba}")
            print(f"   Classe 0 (normal): {proba[0]:.4f}")
            print(f"   Classe 1 (fraude): {proba[1]:.4f}")
        
        print(f"\n✅ Le modèle fonctionne correctement!")
        return True
        
    except Exception as e:
        print(f"❌ ERREUR lors de la prédiction: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_model()
    print("\n" + "=" * 60)
    if success:
        print("✅ TEST RÉUSSI - Le modèle est prêt à être utilisé!")
    else:
        print("❌ TEST ÉCHOUÉ - Vérifiez les erreurs ci-dessus")
    print("=" * 60)

