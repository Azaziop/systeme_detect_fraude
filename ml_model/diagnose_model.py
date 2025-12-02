"""
Script pour diagnostiquer le modèle Random Forest et identifier les problèmes de compatibilité
"""

import joblib
import json
import numpy as np
from pathlib import Path
import traceback

MODEL_DIR = Path(__file__).parent / "models"
MODEL_PATH = MODEL_DIR / "random_forest_model.pkl"
SCALER_PATH = MODEL_DIR / "scaler.pkl"
FEATURES_PATH = MODEL_DIR / "feature_columns.json"

def diagnose_model():
    """Diagnostique le modèle et identifie les problèmes"""
    
    print("=" * 70)
    print("  DIAGNOSTIC DU MODÈLE RANDOM FOREST")
    print("=" * 70)
    print()
    
    # 1. Vérifier l'existence des fichiers
    print("📁 Vérification des fichiers...")
    print(f"   Répertoire: {MODEL_DIR}")
    print(f"   Existe: {MODEL_DIR.exists()}")
    
    if MODEL_DIR.exists():
        files = list(MODEL_DIR.glob("*"))
        print(f"   Fichiers dans le répertoire:")
        for f in files:
            print(f"     - {f.name}")
    
    if not MODEL_PATH.exists():
        print(f"\n❌ ERREUR: Modèle non trouvé à {MODEL_PATH}")
        print(f"   Veuillez placer random_forest_model.pkl dans {MODEL_DIR}")
        return False
    
    print(f"   ✅ Modèle trouvé: {MODEL_PATH}")
    
    # 2. Charger et analyser le modèle
    print("\n📦 Analyse du modèle...")
    try:
        model = joblib.load(MODEL_PATH)
        print(f"   Type: {type(model).__name__}")
        
        # Nombre de features
        if hasattr(model, 'n_features_in_'):
            n_features_model = model.n_features_in_
            print(f"   ✅ Features attendues: {n_features_model}")
        else:
            print(f"   ⚠️  n_features_in_ non disponible")
            n_features_model = None
        
        # Noms des features
        model_feature_names = None
        if hasattr(model, 'feature_names_in_'):
            if model.feature_names_in_ is not None:
                model_feature_names = list(model.feature_names_in_)
                print(f"   ✅ Noms des features du modèle ({len(model_feature_names)}):")
                for i, name in enumerate(model_feature_names, 1):
                    print(f"      {i}. {name}")
            else:
                print(f"   ⚠️  feature_names_in_ est None")
        else:
            print(f"   ⚠️  feature_names_in_ non disponible")
        
        # Méthodes disponibles
        has_predict = hasattr(model, 'predict')
        has_predict_proba = hasattr(model, 'predict_proba')
        print(f"\n   Méthodes disponibles:")
        print(f"      predict: {'✅' if has_predict else '❌'}")
        print(f"      predict_proba: {'✅' if has_predict_proba else '❌'}")
        
    except Exception as e:
        print(f"   ❌ Erreur lors du chargement: {e}")
        traceback.print_exc()
        return False
    
    # 3. Analyser le scaler
    print("\n📦 Analyse du scaler...")
    scaler = None
    scaler_feature_names = None
    scaler_n_features = None
    
    if SCALER_PATH.exists():
        try:
            scaler = joblib.load(SCALER_PATH)
            print(f"   Type: {type(scaler).__name__}")
            
            if hasattr(scaler, 'n_features_in_'):
                scaler_n_features = scaler.n_features_in_
                print(f"   ✅ Features attendues: {scaler_n_features}")
            
            if hasattr(scaler, 'feature_names_in_') and scaler.feature_names_in_ is not None:
                scaler_feature_names = list(scaler.feature_names_in_)
                print(f"   ✅ Noms des features ({len(scaler_feature_names)}):")
                for i, name in enumerate(scaler_feature_names, 1):
                    print(f"      {i}. {name}")
        except Exception as e:
            print(f"   ⚠️  Erreur lors du chargement: {e}")
    else:
        print(f"   ⚠️  Scaler non trouvé (optionnel)")
    
    # 4. Analyser feature_columns.json
    print("\n📦 Analyse des features...")
    feature_columns = None
    if FEATURES_PATH.exists():
        try:
            with open(FEATURES_PATH, 'r') as f:
                feature_columns = json.load(f)
            print(f"   ✅ Features chargées ({len(feature_columns)}):")
            print(f"      {feature_columns}")
        except Exception as e:
            print(f"   ⚠️  Erreur lors du chargement: {e}")
    else:
        print(f"   ⚠️  feature_columns.json non trouvé")
        feature_columns = [f'V{i+1}' for i in range(28)] + ['Amount']
        print(f"   Utilisation des features par défaut ({len(feature_columns)}):")
        print(f"      {feature_columns}")
    
    # 5. Vérifier la compatibilité
    print("\n🔍 Vérification de compatibilité...")
    
    issues = []
    
    # Vérifier nombre de features
    if n_features_model is not None and feature_columns is not None:
        if n_features_model != len(feature_columns):
            issues.append(f"❌ Incompatibilité: Le modèle attend {n_features_model} features, mais {len(feature_columns)} sont définies")
        else:
            print(f"   ✅ Nombre de features compatible: {n_features_model}")
    
    # Vérifier les noms de features
    if model_feature_names is not None and feature_columns is not None:
        if set(model_feature_names) != set(feature_columns):
            missing = set(model_feature_names) - set(feature_columns)
            extra = set(feature_columns) - set(model_feature_names)
            if missing:
                issues.append(f"❌ Features manquantes dans feature_columns.json: {missing}")
            if extra:
                issues.append(f"❌ Features supplémentaires dans feature_columns.json: {extra}")
        else:
            print(f"   ✅ Noms des features compatibles")
    
    # Vérifier le scaler
    if scaler_n_features is not None and n_features_model is not None:
        if scaler_n_features != n_features_model:
            issues.append(f"⚠️  Le scaler attend {scaler_n_features} features, le modèle en attend {n_features_model}")
    
    if scaler_feature_names is not None and model_feature_names is not None:
        if set(scaler_feature_names) != set(model_feature_names):
            issues.append(f"⚠️  Les noms de features du scaler ne correspondent pas à ceux du modèle")
    
    # 6. Résumé et recommandations
    print("\n" + "=" * 70)
    print("  RÉSUMÉ")
    print("=" * 70)
    
    if issues:
        print("\n❌ PROBLÈMES DÉTECTÉS:")
        for issue in issues:
            print(f"   {issue}")
    else:
        print("\n✅ Aucun problème de compatibilité détecté!")
    
    # 7. Tester une prédiction
    print("\n🧪 Test de prédiction...")
    try:
        # Déterminer le nombre de features à utiliser
        if n_features_model is not None:
            n_features = n_features_model
        elif feature_columns is not None:
            n_features = len(feature_columns)
        else:
            n_features = 29  # V1-V28 + Amount par défaut
        
        # Créer des données de test
        test_data = np.random.randn(1, n_features).astype(np.float32)
        print(f"   Données de test créées: shape {test_data.shape}")
        
        # Si le modèle a des noms de features, utiliser un DataFrame
        if model_feature_names is not None:
            try:
                import pandas as pd
                test_df = pd.DataFrame(test_data, columns=model_feature_names)
                prediction = model.predict(test_df)[0]
                print(f"   ✅ Prédiction réussie: {prediction}")
                
                if has_predict_proba:
                    proba = model.predict_proba(test_df)[0]
                    print(f"   ✅ Probabilités: normal={proba[0]:.4f}, fraude={proba[1]:.4f}")
            except ImportError:
                print(f"   ⚠️  pandas non disponible, utilisation sans DataFrame")
                prediction = model.predict(test_data)[0]
                print(f"   ✅ Prédiction réussie: {prediction}")
        else:
            prediction = model.predict(test_data)[0]
            print(f"   ✅ Prédiction réussie: {prediction}")
            
            if has_predict_proba:
                proba = model.predict_proba(test_data)[0]
                print(f"   ✅ Probabilités: normal={proba[0]:.4f}, fraude={proba[1]:.4f}")
        
        print("\n✅ Le modèle peut effectuer des prédictions!")
        
    except Exception as e:
        print(f"\n❌ ERREUR lors du test de prédiction: {e}")
        traceback.print_exc()
        issues.append(f"❌ Le modèle ne peut pas faire de prédiction: {e}")
    
    # 8. Générer feature_columns.json si nécessaire
    if model_feature_names is not None and not FEATURES_PATH.exists():
        print("\n💡 Recommandation: Créer feature_columns.json...")
        try:
            with open(FEATURES_PATH, 'w') as f:
                json.dump(model_feature_names, f, indent=2)
            print(f"   ✅ feature_columns.json créé avec les features du modèle")
        except Exception as e:
            print(f"   ⚠️  Impossible de créer feature_columns.json: {e}")
    
    print("\n" + "=" * 70)
    
    return len(issues) == 0

if __name__ == "__main__":
    success = diagnose_model()
    if not success:
        print("\n❌ Des problèmes ont été détectés. Veuillez les corriger avant d'utiliser le modèle.")
    else:
        print("\n✅ Le modèle est prêt à être utilisé!")
