"""
Script pour vérifier comment le modèle interprète les classes
et déterminer si 0 = normal ou 1 = normal
"""

import joblib
import numpy as np
from pathlib import Path

MODEL_DIR = Path(__file__).parent / "models"
MODEL_PATH = MODEL_DIR / "random_forest_model.pkl"

def verifier_interpretation():
    """Vérifie l'interprétation des classes du modèle"""
    
    print("=" * 70)
    print("  VÉRIFICATION DE L'INTERPRÉTATION DU MODÈLE")
    print("=" * 70)
    print()
    
    if not MODEL_PATH.exists():
        print(f"❌ Modèle non trouvé: {MODEL_PATH}")
        return
    
    # Charger le modèle
    model = joblib.load(MODEL_PATH)
    print(f"✅ Modèle chargé: {type(model).__name__}")
    
    # Vérifier si c'est un RandomForestClassifier
    from sklearn.ensemble import RandomForestClassifier
    if not isinstance(model, RandomForestClassifier):
        print(f"⚠️  Ce n'est pas un RandomForestClassifier, mais {type(model).__name__}")
    
    # Vérifier les classes
    if hasattr(model, 'classes_'):
        classes = model.classes_
        print(f"\n📋 Classes du modèle: {classes}")
        print(f"   Nombre de classes: {len(classes)}")
        
        # Générer des données de test
        n_features = model.n_features_in_ if hasattr(model, 'n_features_in_') else 29
        
        print(f"\n🧪 Test avec des données synthétiques...")
        print(f"   Nombre de features: {n_features}")
        
        # Créer plusieurs transactions de test
        test_cases = [
            ("Transaction très normale", np.zeros((1, n_features))),
            ("Transaction normale", np.random.randn(1, n_features) * 0.5),
            ("Transaction suspecte", np.random.randn(1, n_features) * 3),
        ]
        
        for name, test_data in test_cases:
            try:
                prediction = model.predict(test_data)[0]
                proba = model.predict_proba(test_data)[0]
                
                print(f"\n   {name}:")
                print(f"      Prediction: {prediction} (classe {prediction})")
                print(f"      Probabilités: {proba}")
                for i, prob in enumerate(proba):
                    print(f"         Classe {classes[i]}: {prob:.4f} ({prob*100:.2f}%)")
                
                # Interprétation
                if len(proba) == 2:
                    if proba[0] > proba[1]:
                        print(f"      → Classe {classes[0]} est plus probable (prob={proba[0]:.4f})")
                    else:
                        print(f"      → Classe {classes[1]} est plus probable (prob={proba[1]:.4f})")
                        
            except Exception as e:
                print(f"   ❌ Erreur avec {name}: {e}")
    
    # Vérifier l'ordre standard
    print(f"\n" + "=" * 70)
    print("  INTERPRÉTATION STANDARD")
    print("=" * 70)
    print()
    print("Dans sklearn RandomForestClassifier:")
    print("  - predict_proba() retourne [prob_classe_0, prob_classe_1]")
    print("  - predict() retourne la classe prédite (0 ou 1)")
    print()
    print("Si le modèle a été entraîné avec:")
    print("  - Class 0 = normal")
    print("  - Class 1 = fraude")
    print()
    print("Alors:")
    print("  - proba[0] = probabilité d'être normal (0.00 à 1.00)")
    print("  - proba[1] = probabilité d'être fraude (0.00 à 1.00)")
    print()
    print("  - prediction = 0 → transaction normale")
    print("  - prediction = 1 → transaction frauduleuse")
    print()
    print("  - proba[1] = 0.00 → 0% de chance d'être fraude → NORMAL")
    print("  - proba[1] = 1.00 → 100% de chance d'être fraude → FRAUDE")
    
    print(f"\n" + "=" * 70)

if __name__ == "__main__":
    verifier_interpretation()
