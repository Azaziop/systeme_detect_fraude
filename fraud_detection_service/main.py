from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import List, Optional
import joblib
import numpy as np
import json
from pathlib import Path
import os
import asyncio # Nécessaire pour gérer les appels asynchrones

app = FastAPI(title="Fraud Detection Service")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

# Chemins des modèles
# Dans Docker, le volume est monté à /app/ml_model/models
MODEL_DIR = Path("/app/ml_model/models")
# Fallback pour développement local
if not MODEL_DIR.exists():
    MODEL_DIR = Path(__file__).parent.parent / "ml_model" / "models"

# Chemin du modèle Random Forest
MODEL_PATH = MODEL_DIR / "random_forest_model.pkl"
SCALER_PATH = MODEL_DIR / "scaler.pkl"
FEATURES_PATH = MODEL_DIR / "feature_columns.json"

model = None
scaler = None
feature_columns = None

# Seuil de décision pour la détection de fraude (ajustable)
# Si P(Fraude) > FRAUD_THRESHOLD → Fraude (1.0), si P(Fraude) ≤ FRAUD_THRESHOLD → Normal (0.0)
FRAUD_THRESHOLD = float(os.getenv("FRAUD_THRESHOLD", "0.050"))

# Configuration de l'interprétation des classes (gardée pour la robustesse)
INVERT_CLASSES = os.getenv("INVERT_CLASSES", "false").lower() == "true"

class TransactionFeatures(BaseModel):
    """Modèle pour les features d'une transaction, aligné sur l'ordre V1...V28, Amount (et Time si inclus)"""
    # Time est inclus ici car il est dans la description des données, 
    # mais est souvent exclu du training. Ajustez si Time est utilisé ou non.
    # Dans le modèle actuel, Time est exclu de la liste feature_columns.
    Time: Optional[float] = Field(None, description="Temps écoulé depuis la première transaction")
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
    is_fraud: bool
    from fastapi import FastAPI, HTTPException
    from fastapi.middleware.cors import CORSMiddleware
    from pydantic import BaseModel, Field
    from typing import List, Optional

def load_model():
    """Charge le modèle Random Forest et le scaler"""
    global model, scaler, feature_columns
    
    import hashlib
        # Vérification et chargement du modèle
        if not MODEL_PATH.exists():
            raise FileNotFoundError(f"Modèle Random Forest non trouvé à: {MODEL_PATH}")
        
        print(f"📦 Chargement du modèle Random Forest...")
        model = joblib.load(MODEL_PATH)
        print(f"✅ Modèle chargé: {type(model).__name__}")
        
        # Chargement du scaler
        if SCALER_PATH.exists():
            scaler = joblib.load(SCALER_PATH)
            print(f"✅ Scaler chargé: {type(scaler).__name__}")
        else:
            scaler = None
            print(f"⚠️ Scaler non trouvé - utilisation sans normalisation")
        
        # Détermination des features
        if hasattr(model, 'feature_names_in_') and model.feature_names_in_ is not None:
            feature_columns = list(model.feature_names_in_)
        elif FEATURES_PATH.exists():
            with open(FEATURES_PATH, 'r') as f:
                feature_columns = json.load(f)
        else:
            # Features par défaut sans Time (V1-V28 + Amount)
            feature_columns = [f'V{i}' for i in range(1, 29)] + ['Amount']
            print(f"⚠️ Features par défaut utilisées (V1-V28, Amount)")

        print(f"✅ Modèle Random Forest chargé avec succès. Features: {len(feature_columns)} colonnes")
        print(f"   Seuil de détection: {FRAUD_THRESHOLD}")

@app.on_event("startup")
async def startup_event(): load_model()

@app.get("/")
async def root():
    """Endpoint de santé"""
    return {
        "service": "Fraud Detection Service",
        "status": "running",
        "model_loaded": model is not None,
        "model_type": "random_forest" if model is not None else None
    }

@app.post("/detect", response_model=FraudDetectionResponse)
async def detect_fraud(transaction: TransactionRequest):
    """
    Analyse une transaction et détermine si elle est frauduleuse
    Utilise Random Forest pour la détection
    """
    if model is None:
        raise HTTPException(status_code=503, detail="Modèle non chargé")
    
    try:
        # Extraire les features dans l'ordre attendu par feature_columns
        feature_dict = transaction.features.dict()
        feature_values = [feature_dict[col] for col in feature_columns]
        
        # Convertir en array numpy
        feature_array = np.array(feature_values, dtype=np.float32).reshape(1, -1)
        
        # Normaliser si scaler disponible
        if scaler is not None:
            # Le scaler attend les features dans l'ordre de feature_columns
            feature_scaled = scaler.transform(feature_array)
            feature_scaled = np.array(feature_scaled, dtype=np.float32)
        else:
            risk_score = 0.1
        
        # Prédiction des probabilités
        proba = model.predict_proba(feature_scaled)[0]
        
        # INTERPRÉTATION STANDARD (proba[1] = probabilité de fraude)
        if INVERT_CLASSES:
            # Cas où les classes sont inversées : proba[0] = fraude
            fraud_probability = float(proba[0])
        else:
            # Standard sklearn : proba[1] = fraude
            fraud_probability = float(proba[1])

        # Décision basée sur le seuil
        is_fraud = fraud_probability >= FRAUD_THRESHOLD

        # Le score et la confiance sont la probabilité de fraude
        fraud_score = fraud_probability
        confidence = fraud_probability
        
        return FraudDetectionResponse(
            transaction_id=transaction.transaction_id,
            is_fraud=is_fraud,
            fraud_score=fraud_score,
            confidence=confidence
        )
    
    except Exception as e:
        error_msg = f"Erreur lors de l'analyse de la transaction {transaction.transaction_id}: {str(e)}"
        print(f" {error_msg}")
        raise HTTPException(status_code=500, detail="Erreur interne du service de détection.")

@app.post("/detect-batch", response_model=List[FraudDetectionResponse])
async def detect_fraud_batch(transactions: List[TransactionRequest]):
    """
    Analyse plusieurs transactions en lot
    """
    # Exécuter les tâches asynchrones pour chaque transaction
    tasks = [detect_fraud(transaction) for transaction in transactions]
    
    # Exécuter toutes les tâches en parallèle
    try:
        results = await asyncio.gather(*tasks)
        return results
    except HTTPException as e:
        # Gérer les exceptions HTTPException soulevées par detect_fraud
        raise e
    except Exception as e:
        # Gérer les autres exceptions
        raise HTTPException(status_code=500, detail=f"Erreur lors du traitement par lot: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    # Le port 8002 est souvent utilisé pour les services ML.
        # Merchant suspect si nom court ET montant > 1000€
    if len(transaction.merchant) <= 2 and transaction.amount > 1000:
            risk_score += 0.1
            reasons.append("Merchant suspect")
        
        # Generation features synthétiques
        seed = int(hashlib.md5(f"{transaction.merchant}_{transaction.amount}".encode()).hexdigest(), 16) % 10000
        np.random.seed(seed)
        features = {}
        for i in range(1, 29):
            if transaction.amount > 5000 and i in [4, 11, 12, 14]:
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
        
        # Score final = maximum entre ML et règles métier
        final_score = max(ml_score, risk_score)
        is_fraud = final_score >= FRAUD_THRESHOLD
        reason_msg = " | ".join(reasons) if reasons else None
        
        emoji = "🚨 FRAUDE" if is_fraud else "✅ OK"
        print(f"{emoji} amount={transaction.amount:.0f}€, merchant={transaction.merchant}, score={final_score:.2f}")
        
        return FraudDetectionResponse(is_fraud=is_fraud, fraud_score=final_score, confidence=final_score, reason=reason_msg)
    except Exception as e:
        raise HTTPException(500, str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)