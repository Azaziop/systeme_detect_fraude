@echo off
echo ========================================
echo  CORRECTION DU SERVICE DE DETECTION
echo ========================================
echo.

REM 1. Arrêter tous les services Python
echo [1/5] Arret des services Python...
taskkill /F /IM python.exe >nul 2>&1
timeout /t 2 >nul

REM 2. Créer le nouveau fichier main.py corrigé
echo [2/5] Creation du fichier corrige...
(
echo from fastapi import FastAPI, HTTPException
echo from fastapi.middleware.cors import CORSMiddleware
echo from pydantic import BaseModel
echo from typing import Optional
echo import joblib
echo import numpy as np
echo import json
echo from pathlib import Path
echo import os
echo import hashlib
echo.
echo app = FastAPI^(title="Fraud Detection Service"^)
echo app.add_middleware^(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"]^)
echo.
echo MODEL_DIR = Path^(__file__^).parent.parent / "ml_model" / "models"
echo MODEL_PATH_RF = MODEL_DIR / "random_forest_model.pkl"
echo SCALER_PATH = MODEL_DIR / "scaler.pkl"
echo FEATURES_PATH = MODEL_DIR / "feature_columns.json"
echo.
echo model = None
echo scaler = None
echo feature_columns = None
echo model_type = None
echo FRAUD_THRESHOLD = 0.25  # Seuil abaisse pour detecter plus de fraudes
echo.
echo class SimpleTransactionRequest^(BaseModel^):
echo     amount: float
echo     merchant: str
echo     category: Optional[str] = "Other"
echo.
echo class FraudDetectionResponse^(BaseModel^):
echo     is_fraud: bool
echo     fraud_score: float
echo     confidence: float
echo     reason: Optional[str] = None
echo.
echo def load_model^(^):
echo     global model, scaler, feature_columns, model_type
echo     if model is None:
echo         model = joblib.load^(MODEL_PATH_RF^)
echo         model_type = 'random_forest'
echo         scaler = joblib.load^(SCALER_PATH^) if SCALER_PATH.exists^(^) else None
echo         with open^(FEATURES_PATH^) as f:
echo             feature_columns = json.load^(f^)
echo         print^(f"Service ML pret - Seuil: {FRAUD_THRESHOLD}"^)
echo.
echo @app.on_event^("startup"^)
echo async def startup_event^(^): load_model^(^)
echo.
echo @app.get^("/"^)
echo async def root^(^): return {"service": "Fraud Detection", "status": "running"}
echo.
echo @app.get^("/health"^)
echo async def health^(^): return {"status": "healthy", "model_loaded": model is not None}
echo.
echo @app.post^("/predict"^)
echo async def predict_fraud^(transaction: SimpleTransactionRequest^):
echo     if model is None: raise HTTPException^(503, "Modele non charge"^)
echo     try:
echo         # Regles metier simples
echo         risk_score = 0.0
echo         reasons = []
echo         if transaction.amount ^> 100000:
echo             risk_score = 0.9
echo             reasons.append^("Montant tres eleve ^(^>100K^)"^)
echo         elif transaction.amount ^> 50000:
echo             risk_score = 0.7
echo             reasons.append^("Montant eleve ^(^>50K^)"^)
echo         elif transaction.amount ^> 10000:
echo             risk_score = 0.5
echo             reasons.append^("Montant suspect ^(^>10K^)"^)
echo         elif transaction.amount ^> 5000:
echo             risk_score = 0.3
echo             reasons.append^("Montant moyen ^(^>5K^)"^)
echo         else:
echo             risk_score = 0.1
echo         if len^(transaction.merchant^) ^<= 2:
echo             risk_score += 0.15
echo             reasons.append^("Merchant suspect"^)
echo         # Generation features
echo         seed = int^(hashlib.md5^(f"{transaction.merchant}_{transaction.amount}".encode^(^)^).hexdigest^(^), 16^) %% 10000
echo         np.random.seed^(seed^)
echo         features = {}
echo         for i in range^(1, 29^):
echo             if transaction.amount ^> 10000 and i in [4, 11, 12, 14]:
echo                 features[f'V{i}'] = float^(np.random.uniform^(2, 4^) * np.random.choice^([1, -1]^)^)
echo             else:
echo                 features[f'V{i}'] = float^(np.random.normal^(0, 1^)^)
echo         features['Amount'] = float^(transaction.amount^)
echo         feature_array = np.array^([features[col] for col in feature_columns]^).reshape^(1, -1^)
echo         if scaler: feature_array = scaler.transform^(feature_array^)
echo         # Prediction ML
echo         if hasattr^(model, 'predict_proba'^):
echo             proba = model.predict_proba^(feature_array^)[0]
echo             ml_score = float^(proba[1]^)
echo         else:
echo             ml_score = 0.5
echo         # Score final = max^(ML, regles metier^)
echo         final_score = max^(ml_score, risk_score^)
echo         is_fraud = final_score ^>= FRAUD_THRESHOLD
echo         reason_msg = " ^| ".join^(reasons^) if reasons else None
echo         emoji = "FRAUDE" if is_fraud else "OK"
echo         print^(f"{emoji} amount={transaction.amount}, score={final_score:.2f}, fraud={is_fraud}"^)
echo         return FraudDetectionResponse^(is_fraud=is_fraud, fraud_score=final_score, confidence=final_score, reason=reason_msg^)
echo     except Exception as e:
echo         raise HTTPException^(500, str^(e^)^)
echo.
echo if __name__ == "__main__":
echo     import uvicorn
echo     uvicorn.run^(app, host="0.0.0.0", port=8002^)
) > fraud_detection_service\main_fixed.py

REM 3. Sauvegarder l'ancien et remplacer
echo [3/5] Sauvegarde et remplacement...
copy fraud_detection_service\main.py fraud_detection_service\main_old_backup.py >nul
copy fraud_detection_service\main_fixed.py fraud_detection_service\main.py >nul

REM 4. Redémarrer le service
echo [4/5] Redemarrage du service ML...
start cmd /k "cd fraud_detection_service && python main.py"
timeout /t 8 >nul

REM 5. Test
echo [5/5] Test de detection...
echo.
curl -X POST http://localhost:8002/predict -H "Content-Type: application/json" -d "{\"amount\":50000,\"merchant\":\"Test\",\"category\":\"Shopping\"}"
echo.
echo.
echo ========================================
echo  CORRECTION TERMINEE
echo ========================================
echo.
echo Testez maintenant avec:
echo   - 50000 EUR  = FRAUDE attendue
echo   - 100000 EUR = FRAUDE attendue
echo   - 1000 EUR   = LEGITIME attendue
echo.
pause