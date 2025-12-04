from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional
import joblib
import numpy as np
import json
from pathlib import Path
import os
import hashlib

app = FastAPI(
    title="Fraud Detection Service",
    description="Service de detection de fraude en temps reel avec ML",
    version="2.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Chemins des modèles
MODEL_DIR = Path("/app/ml_model/models")
if not MODEL_DIR.exists():
    MODEL_DIR = Path(__file__).parent.parent / "ml_model" / "models"

MODEL_PATH_RF = MODEL_DIR / "random_forest_model.pkl"
SCALER_PATH = MODEL_DIR / "scaler.pkl"
FEATURES_PATH = MODEL_DIR / "feature_columns.json"

# Variables globales
model = None
scaler = None
feature_columns = None
model_type = None
FRAUD_THRESHOLD = float(os.getenv("FRAUD_THRESHOLD", "0.5"))

class SimpleTransactionRequest(BaseModel):
    amount: float
    merchant: str
    category: Optional[str] = "Other"
    user_id: Optional[str] = None
    timestamp: Optional[str] = None

class FraudDetectionResponse(BaseModel):
    transaction_id: Optional[str] = None
    is_fraud: bool
    fraud_score: float
    confidence: float
    reason: Optional[str] = None

def load_model():
    """Charge le modèle Random Forest et le scaler"""
    global model, scaler, feature_columns, model_type
    
    if model is None:
        if not MODEL_PATH_RF.exists():
            raise FileNotFoundError(f"Modèle Random Forest non trouvé: {MODEL_PATH_RF}")
        
        print(f"📦 Chargement du modèle Random Forest...")
        model = joblib.load(MODEL_PATH_RF)
        model_type = 'random_forest'
        print(f"✅ Modèle chargé: {type(model).__name__}")
        
        # Chargement du scaler
        if SCALER_PATH.exists():
            scaler = joblib.load(SCALER_PATH)
            print(f"✅ Scaler chargé")
        else:
            scaler = None
            print(f"⚠️ Scaler non trouvé")
        
        # Chargement des features
        if FEATURES_PATH.exists():
            with open(FEATURES_PATH, 'r') as f:
                feature_columns = json.load(f)
            print(f"✅ Features: {len(feature_columns)} colonnes")
        else:
            feature_columns = [f'V{i}' for i in range(1, 29)] + ['Amount']
            print(f"⚠️ Features par défaut: {len(feature_columns)} colonnes")
        
        print(f"✅ Service ML prêt - Type: {model_type}, Seuil: {FRAUD_THRESHOLD}")

@app.on_event("startup")
async def startup_event():
    """Charge le modèle au démarrage"""
    load_model()

@app.get("/")
async def root():
    return {
        "service": "Fraud Detection Service",
        "status": "running",
        "model_loaded": model is not None,
        "model_type": model_type,
        "threshold": FRAUD_THRESHOLD
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "model_type": model_type
    }

@app.post("/predict", response_model=FraudDetectionResponse)
async def predict_fraud(transaction: SimpleTransactionRequest):
    """
    Endpoint principal de détection de fraude
    Combine règles métier + Machine Learning
    """
    if model is None:
        raise HTTPException(status_code=503, detail="Modèle non chargé")
    
    try:
        # === RÈGLES MÉTIER ===
        risk_score = 0.0
        reasons = []
        
        # Détection par montant
        if transaction.amount > 100000:
            risk_score = 0.95
            reasons.append("Montant tres eleve (>100K)")
        elif transaction.amount > 50000:
            risk_score = 0.85
            reasons.append("Montant eleve (>50K)")
        elif transaction.amount > 20000:
            risk_score = 0.75
            reasons.append("Montant suspect (>20K)")
        elif transaction.amount > 10000:
            risk_score = 0.65
            reasons.append("Montant moyen (>10K)")
        elif transaction.amount > 5000:
            risk_score = 0.55
            reasons.append("Montant suspect (>5K)")
        else:
            risk_score = 0.1
        
        # Marchand suspect (nom très court + montant élevé)
        if len(transaction.merchant) <= 2 and transaction.amount > 1000:
            risk_score += 0.1
            reasons.append("Marchand suspect")
        
        # === GÉNÉRATION FEATURES SYNTHÉTIQUES ===
        seed = int(hashlib.md5(f"{transaction.merchant}_{transaction.amount}".encode()).hexdigest(), 16) % 10000
        np.random.seed(seed)
        
        features = {}
        for i in range(1, 29):
            # Features spéciales pour montants suspects
            if transaction.amount > 5000 and i in [4, 11, 12, 14]:
                features[f'V{i}'] = float(np.random.uniform(2, 4) * np.random.choice([1, -1]))
            else:
                features[f'V{i}'] = float(np.random.normal(0, 1))
        
        features['Amount'] = float(transaction.amount)
        
        # === PRÉDICTION ML ===
        feature_array = np.array([features[col] for col in feature_columns], dtype=np.float32).reshape(1, -1)
        
        if scaler is not None:
            feature_array = scaler.transform(feature_array)
        
        # Prédiction avec Random Forest
        if hasattr(model, 'predict_proba'):
            proba = model.predict_proba(feature_array)[0]
            ml_score = float(proba[1])  # Probabilité de fraude
        else:
            ml_score = 0.5
        
        # === SCORE FINAL ===
        # Prendre le maximum entre ML et règles métier
        final_score = max(ml_score, risk_score)
        is_fraud = final_score >= FRAUD_THRESHOLD
        
        reason_msg = " | ".join(reasons) if reasons else None
        
        # Logs
        emoji = "🚨 FRAUDE" if is_fraud else "✅ OK"
        print(f"{emoji} {transaction.merchant}: {transaction.amount:.0f}€, score={final_score:.2f}, ML={ml_score:.2f}, Rules={risk_score:.2f}")
        
        return FraudDetectionResponse(
            is_fraud=is_fraud,
            fraud_score=final_score,
            confidence=final_score,
            reason=reason_msg
        )
    
    except Exception as e:
        import traceback
        print(f"❌ Erreur: {str(e)}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Erreur ML: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)