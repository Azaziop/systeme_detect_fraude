"""
Service de Détection de Fraude en Temps Réel
Utilise le modèle Isolation Forest pour analyser les transactions
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

MODEL_PATH = MODEL_DIR / "isolation_forest_model.pkl"
SCALER_PATH = MODEL_DIR / "scaler.pkl"
FEATURES_PATH = MODEL_DIR / "feature_columns.json"

# Variables globales pour le modèle
model = None
scaler = None
feature_columns = None

class TransactionFeatures(BaseModel):
    """Modèle pour les features d'une transaction"""
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
    """Charge le modèle et le scaler"""
    global model, scaler, feature_columns
    
    if model is None:
        if not MODEL_PATH.exists():
            error_msg = f"Modèle non trouvé: {MODEL_PATH}\n"
            error_msg += f"MODEL_DIR: {MODEL_DIR}\n"
            error_msg += f"MODEL_DIR existe: {MODEL_DIR.exists()}\n"
            if MODEL_DIR.exists():
                error_msg += f"Contenu de MODEL_DIR: {list(MODEL_DIR.iterdir())}\n"
            raise FileNotFoundError(error_msg)
        
        if not SCALER_PATH.exists():
            raise FileNotFoundError(f"Scaler non trouvé: {SCALER_PATH}")
        
        if not FEATURES_PATH.exists():
            raise FileNotFoundError(f"Features non trouvées: {FEATURES_PATH}")
        
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        
        with open(FEATURES_PATH, 'r') as f:
            feature_columns = json.load(f)
        
        print(f"Modèle chargé avec succès depuis: {MODEL_PATH}")

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
        "model_loaded": model is not None
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
    """
    if model is None or scaler is None:
        raise HTTPException(status_code=503, detail="Modèle non chargé")
    
    try:
        # Extraire les features dans l'ordre attendu
        feature_dict = transaction.features.dict()
        feature_values = [feature_dict[col] for col in feature_columns]
        feature_array = np.array(feature_values).reshape(1, -1)
        
        # Normaliser
        feature_scaled = scaler.transform(feature_array)
        
        # Prédiction
        prediction = model.predict(feature_scaled)[0]
        score = model.score_samples(feature_scaled)[0]
        
        # Isolation Forest: -1 = anomalie (fraude), 1 = normal
        is_fraud = prediction == -1
        
        # Convertir le score en probabilité (plus négatif = plus suspect)
        # Normaliser entre 0 et 1
        fraud_score = float(score)
        confidence = abs(fraud_score) / 10.0  # Approximation de la confiance
        confidence = min(confidence, 1.0)
        
        return FraudDetectionResponse(
            transaction_id=transaction.transaction_id,
            is_fraud=is_fraud,
            fraud_score=fraud_score,
            confidence=confidence
        )
    
    except Exception as e:
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

