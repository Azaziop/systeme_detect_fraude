"""
Service de Détection de Fraude en Temps Réel
Supporte Isolation Forest et Random Forest pour analyser les transactions
"""

from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import List, Optional
import joblib
import numpy as np
import json
from pathlib import Path
import os

app = FastAPI(
    title="Fraud Detection Service",
    description="Service de détection de fraude en temps réel",
    version="1.0.0"
)

# Chemins des modèles
# Dans Docker, le volume est monté à /app/ml_model/models
MODEL_DIR = Path("/app/ml_model/models")
# Fallback pour développement local
if not MODEL_DIR.exists():
    MODEL_DIR = Path(__file__).parent.parent / "ml_model" / "models"

# Essayer d'abord Random Forest, puis Isolation Forest
MODEL_PATH_RF = MODEL_DIR / "random_forest_model.pkl"
MODEL_PATH_IF = MODEL_DIR / "isolation_forest_model.pkl"
SCALER_PATH = MODEL_DIR / "scaler.pkl"
FEATURES_PATH = MODEL_DIR / "feature_columns.json"

# Variables globales pour le modèle
model = None
scaler = None
feature_columns = None
model_type = None  # 'random_forest' ou 'isolation_forest'

# Seuil de décision pour la détection de fraude (ajustable)
# Par défaut 0.03 (au lieu de 0.5) pour plus de sensibilité
FRAUD_THRESHOLD = float(os.getenv("FRAUD_THRESHOLD", "0.03"))

class TransactionFeatures(BaseModel):
    """Modèle pour les features d'une transaction"""
    # Time a été supprimé du modèle - le modèle n'utilise plus cette feature
    V1: float
    V2: float
    V3: float
    V4: float
    V5: float
    V6: float
    V7: float
    V8: float
    V9: float
    V10: float
    V11: float
    V12: float
    V13: float
    V14: float
    V15: float
    V16: float
    V17: float
    V18: float
    V19: float
    V20: float
    V21: float
    V22: float
    V23: float
    V24: float
    V25: float
    V26: float
    V27: float
    V28: float
    Amount: float = Field(..., description="Montant de la transaction")

class TransactionRequest(BaseModel):
    """Requête pour analyser une transaction"""
    transaction_id: str
    features: TransactionFeatures

class FraudDetectionResponse(BaseModel):
    """Réponse de détection de fraude"""
    transaction_id: str
    is_fraud: bool
    fraud_score: float
    confidence: float

def load_model():
    """Charge le modèle et le scaler (Random Forest ou Isolation Forest)"""
    global model, scaler, feature_columns, model_type
    
    if model is None:
        # Déterminer quel modèle utiliser (priorité à Random Forest)
        model_path = None
        if MODEL_PATH_RF.exists():
            model_path = MODEL_PATH_RF
            model_type = 'random_forest'
            print(f"📦 Chargement du modèle Random Forest...")
        elif MODEL_PATH_IF.exists():
            model_path = MODEL_PATH_IF
            model_type = 'isolation_forest'
            print(f"📦 Chargement du modèle Isolation Forest...")
        else:
            error_msg = f"Aucun modèle trouvé!\n"
            error_msg += f"Recherché:\n"
            error_msg += f"  - Random Forest: {MODEL_PATH_RF}\n"
            error_msg += f"  - Isolation Forest: {MODEL_PATH_IF}\n"
            error_msg += f"MODEL_DIR: {MODEL_DIR}\n"
            error_msg += f"MODEL_DIR existe: {MODEL_DIR.exists()}\n"
            if MODEL_DIR.exists():
                error_msg += f"Contenu de MODEL_DIR: {list(MODEL_DIR.iterdir())}\n"
            raise FileNotFoundError(error_msg)
        
        # Charger le modèle
        model = joblib.load(model_path)
        print(f"✅ Modèle chargé: {type(model).__name__}")
        
        # Charger le scaler (optionnel pour Random Forest)
        if SCALER_PATH.exists():
            scaler = joblib.load(SCALER_PATH)
            print(f"✅ Scaler chargé")
        else:
            scaler = None
            print(f"⚠️  Scaler non trouvé - utilisation sans normalisation")
        
        # Charger les features (optionnel)
        if FEATURES_PATH.exists():
            with open(FEATURES_PATH, 'r') as f:
                feature_columns = json.load(f)
            print(f"✅ Features chargées: {len(feature_columns)} colonnes")
        else:
            # Features par défaut si non spécifiées (V1-V28 + Amount, sans Time)
            feature_columns = [f'V{i+1}' for i in range(28)] + ['Amount']
            print(f"⚠️  Features par défaut utilisées: {len(feature_columns)} colonnes")
        
        print(f"✅ Modèle chargé avec succès depuis: {model_path}")
        print(f"   Type: {model_type}")

@app.on_event("startup")
async def startup_event():
    """Charge le modèle au démarrage"""
    load_model()

@app.get("/")
async def root():
    """Endpoint de santé"""
    return {
        "service": "Fraud Detection Service",
        "status": "running",
        "model_loaded": model is not None,
        "model_type": model_type if model is not None else None
    }

@app.get("/health")
async def health_check():
    """Vérification de santé"""
    return {
        "status": "healthy",
        "model_loaded": model is not None
    }

@app.post("/detect", response_model=FraudDetectionResponse)
async def detect_fraud(transaction: TransactionRequest):
    """
    Analyse une transaction et détermine si elle est frauduleuse
    Supporte Random Forest et Isolation Forest
    """
    if model is None:
        raise HTTPException(status_code=503, detail="Modèle non chargé")
    
    try:
        # Extraire les features dans l'ordre attendu
        feature_dict = transaction.features.dict()
        feature_values = [feature_dict[col] for col in feature_columns]
        
        # Convertir en array numpy avec type float32 pour éviter les overflows
        feature_array = np.array(feature_values, dtype=np.float32).reshape(1, -1)
        
        # Vérifier les valeurs infinies ou NaN
        if not np.isfinite(feature_array).all():
            raise ValueError("Les features contiennent des valeurs infinies ou NaN")
        
        # Normaliser si scaler disponible
        # Note: Le scaler peut avoir moins de features que le modèle (ex: pas de Time)
        if scaler is not None:
            # Si le scaler a moins de features, extraire seulement celles qu'il attend
            if hasattr(scaler, 'feature_names_in_') and scaler.feature_names_in_ is not None:
                # Le scaler a des noms de features, utiliser ceux-ci
                scaler_features = list(scaler.feature_names_in_)
                scaler_values = [feature_dict[col] for col in scaler_features]
                scaler_array = np.array(scaler_values, dtype=np.float32).reshape(1, -1)
                
                # Vérifier les valeurs avant transformation
                if not np.isfinite(scaler_array).all():
                    raise ValueError("Les features pour le scaler contiennent des valeurs infinies ou NaN")
                
                # Transformer avec le scaler (supprimer les warnings en utilisant un DataFrame pandas si possible)
                try:
                    import pandas as pd
                    scaler_df = pd.DataFrame(scaler_array, columns=scaler_features)
                    scaler_scaled = scaler.transform(scaler_df)
                    scaler_scaled = np.array(scaler_scaled, dtype=np.float32)
                except ImportError:
                    # Fallback si pandas n'est pas disponible
                    scaler_scaled = scaler.transform(scaler_array)
                    scaler_scaled = np.array(scaler_scaled, dtype=np.float32)
                
                # Time n'est plus utilisé - utiliser directement les features scalées
                feature_scaled = scaler_scaled
            else:
                # Le scaler n'a pas de noms - utiliser directement toutes les features (sans Time)
                # Time n'est plus dans le modèle, donc feature_array ne contient que V1-V28 + Amount
                feature_scaled = scaler.transform(feature_array)
                feature_scaled = np.array(feature_scaled, dtype=np.float32)
        else:
            feature_scaled = feature_array
        
        # Vérifier les valeurs après transformation
        if not np.isfinite(feature_scaled).all():
            raise ValueError("Les features transformées contiennent des valeurs infinies ou NaN")
        
        # Vérifier que le nombre de features correspond
        if hasattr(model, 'n_features_in_'):
            if feature_scaled.shape[1] != model.n_features_in_:
                raise ValueError(
                    f"Nombre de features incorrect: attendu {model.n_features_in_}, "
                    f"reçu {feature_scaled.shape[1]}"
                )
        
        # Prédiction selon le type de modèle
        if model_type == 'random_forest':
            # Random Forest: predict retourne 0 (normal) ou 1 (fraude)
            # Utiliser un DataFrame si le modèle attend des noms de colonnes
            try:
                if hasattr(model, 'feature_names_in_') and model.feature_names_in_ is not None:
                    import pandas as pd
                    feature_df = pd.DataFrame(feature_scaled, columns=model.feature_names_in_)
                    prediction = model.predict(feature_df)[0]
                else:
                    prediction = model.predict(feature_scaled)[0]
            except Exception as e:
                # Fallback si pandas n'est pas disponible ou erreur
                prediction = model.predict(feature_scaled)[0]
            
            # Obtenir les probabilités si disponible
            if hasattr(model, 'predict_proba'):
                try:
                    if hasattr(model, 'feature_names_in_') and model.feature_names_in_ is not None:
                        import pandas as pd
                        feature_df = pd.DataFrame(feature_scaled, columns=model.feature_names_in_)
                        proba = model.predict_proba(feature_df)[0]
                    else:
                        proba = model.predict_proba(feature_scaled)[0]
                except Exception as e:
                    # Fallback si pandas n'est pas disponible ou erreur
                    proba = model.predict_proba(feature_scaled)[0]
                
                # proba[0] = probabilité classe 0 (normal), proba[1] = probabilité classe 1 (fraude)
                fraud_probability = float(proba[1]) if len(proba) > 1 else float(proba[0])
                confidence = fraud_probability
                fraud_score = fraud_probability
                
                # Utiliser le seuil ajustable au lieu de la prédiction binaire par défaut
                # Cela permet de détecter plus de fraudes avec des probabilités faibles
                is_fraud = fraud_probability >= FRAUD_THRESHOLD
            else:
                # Fallback si predict_proba n'est pas disponible
                is_fraud = bool(prediction == 1)
                fraud_score = 1.0 if is_fraud else 0.0
                confidence = fraud_score
        
        else:  # isolation_forest
            # Isolation Forest: -1 = anomalie (fraude), 1 = normal
            prediction = model.predict(feature_scaled)[0]
            is_fraud = prediction == -1
            
            # Obtenir le score d'anomalie
            if hasattr(model, 'score_samples'):
                score = model.score_samples(feature_scaled)[0]
                fraud_score = float(score)
                # Convertir le score en probabilité (plus négatif = plus suspect)
                confidence = abs(fraud_score) / 10.0
                confidence = min(confidence, 1.0)
            else:
                fraud_score = -1.0 if is_fraud else 1.0
                confidence = 0.8 if is_fraud else 0.2
        
        return FraudDetectionResponse(
            transaction_id=transaction.transaction_id,
            is_fraud=is_fraud,
            fraud_score=fraud_score,
            confidence=confidence
        )
    
    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Erreur de validation: {str(e)}")
    except Exception as e:
        import traceback
        error_detail = f"Erreur lors de l'analyse: {str(e)}\n{traceback.format_exc()}"
        print(f"❌ Erreur détaillée: {error_detail}")
        raise HTTPException(status_code=500, detail=f"Erreur lors de l'analyse: {str(e)}")

@app.post("/detect-batch")
async def detect_fraud_batch(transactions: List[TransactionRequest]):
    """
    Analyse plusieurs transactions en lot
    """
    if model is None or scaler is None:
        raise HTTPException(status_code=503, detail="Modèle non chargé")
    
    results = []
    for transaction in transactions:
        try:
            result = await detect_fraud(transaction)
            results.append(result)
        except Exception as e:
            results.append({
                "transaction_id": transaction.transaction_id,
                "error": str(e)
            })
    
    return {"results": results}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)

