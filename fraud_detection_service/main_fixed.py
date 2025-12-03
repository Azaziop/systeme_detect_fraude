from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import joblib
import numpy as np
import json
from pathlib import Path
import os
import hashlib

app = FastAPI(title="Fraud Detection Service")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

MODEL_DIR = Path(__file__).parent.parent / "ml_model" / "models"
MODEL_PATH_RF = MODEL_DIR / "random_forest_model.pkl"
SCALER_PATH = MODEL_DIR / "scaler.pkl"
FEATURES_PATH = MODEL_DIR / "feature_columns.json"

model = None
scaler = None
feature_columns = None
model_type = None
FRAUD_THRESHOLD = 0.25  # Seuil abaisse pour detecter plus de fraudes

class SimpleTransactionRequest(BaseModel):
    amount: float
    merchant: str
    category: Optional[str] = "Other"

class FraudDetectionResponse(BaseModel):
    is_fraud: bool
    fraud_score: float
    confidence: float
    reason: Optional[str] = None

def load_model():
    global model, scaler, feature_columns, model_type
    if model is None:
        model = joblib.load(MODEL_PATH_RF)
        model_type = 'random_forest'
        scaler = joblib.load(SCALER_PATH) if SCALER_PATH.exists() else None
        with open(FEATURES_PATH) as f:
            feature_columns = json.load(f)
        print(f"Service ML pret - Seuil: {FRAUD_THRESHOLD}")

@app.on_event("startup")
async def startup_event(): load_model()

@app.get("/")
async def root(): return {"service": "Fraud Detection", "status": "running"}

@app.get("/health")
async def health(): return {"status": "healthy", "model_loaded": model is not None}

@app.post("/predict")
async def predict_fraud(transaction: SimpleTransactionRequest):
    if model is None: raise HTTPException(503, "Modele non charge")
    try:
        # Regles metier simples
        risk_score = 0.0
        reasons = []
        if transaction.amount > 100000:
            risk_score = 0.9
            reasons.append("Montant tres eleve ^(^>100K^)")
        elif transaction.amount > 50000:
            risk_score = 0.7
            reasons.append("Montant eleve ^(^>50K^)")
        elif transaction.amount > 10000:
            risk_score = 0.5
            reasons.append("Montant suspect ^(^>10K^)")
        elif transaction.amount > 5000:
            risk_score = 0.3
            reasons.append("Montant moyen ^(^>5K^)")
        else:
            risk_score = 0.1
        if len(transaction.merchant) <= 2:
            risk_score += 0.15
            reasons.append("Merchant suspect")
        # Generation features
        seed = int(hashlib.md5(f"{transaction.merchant}_{transaction.amount}".encode()).hexdigest(), 16) % 10000
        np.random.seed(seed)
        features = {}
        for i in range(1, 29):
            if transaction.amount > 10000 and i in [4, 11, 12, 14]:
                features[f'V{i}'] = float(np.random.uniform(2, 4) * np.random.choice([1, -1]))
            else:
                features[f'V{i}'] = float(np.random.normal(0, 1))
        features['Amount'] = float(transaction.amount)
        feature_array = np.array([features[col] for col in feature_columns]).reshape(1, -1)
        if scaler: feature_array = scaler.transform(feature_array)
        # Prediction ML
        if hasattr(model, 'predict_proba'):
            proba = model.predict_proba(feature_array)[0]
            ml_score = float(proba[1])
        else:
            ml_score = 0.5
        # Score final = max(ML, regles metier)
        final_score = max(ml_score, risk_score)
        is_fraud = final_score >= FRAUD_THRESHOLD
        reason_msg = " ^| ".join(reasons) if reasons else None
        emoji = "FRAUDE" if is_fraud else "OK"
        print(f"{emoji} amount={transaction.amount}, score={final_score:.2f}, fraud={is_fraud}")
        return FraudDetectionResponse(is_fraud=is_fraud, fraud_score=final_score, confidence=final_score, reason=reason_msg)
    except Exception as e:
        raise HTTPException(500, str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
