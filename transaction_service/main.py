"""
Service de Transaction
Capture les détails de transaction et les envoie au service de détection
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List
import httpx
import os
from datetime import datetime
import random
import numpy as np
from sqlalchemy.orm import Session
try:
    from .models import Transaction, get_db, SessionLocal
except ImportError:
    from models import Transaction, get_db, SessionLocal

# Celery optionnel
try:
    try:
        from .tasks import check_fraud_async
        CELERY_AVAILABLE = True
    except ImportError:
        from tasks import check_fraud_async
        CELERY_AVAILABLE = True
except ImportError:
    CELERY_AVAILABLE = False
    print("⚠️ Celery non disponible - utilisation de la vérification synchrone")

app = FastAPI(
    title="Transaction Service",
    description="Service de capture et traitement des transactions",
    version="1.0.0"
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
FRAUD_DETECTION_SERVICE_URL = os.getenv(
    "FRAUD_DETECTION_SERVICE_URL",
    "http://localhost:8002"
)
AUTH_SERVICE_URL = os.getenv(
    "AUTH_SERVICE_URL",
    "http://localhost:8000"
)

class TransactionCreate(BaseModel):
    """Modèle pour créer une transaction"""
    user_id: str
    amount: float = Field(..., gt=0, description="Montant de la transaction")
    merchant: str
    category: Optional[str] = None
    description: Optional[str] = None
    timestamp: Optional[str] = None

class TransactionResponse(BaseModel):
    """Réponse après traitement d'une transaction"""
    transaction_id: str
    user_id: str
    amount: float
    merchant: str
    status: str
    is_fraud: Optional[bool] = None
    fraud_score: Optional[float] = None
    timestamp: str

def generate_features(amount: float, merchant: str, category: str) -> dict:
    """
    Génère des features synthétiques pour la transaction
    """
    np.random.seed(int(amount * 1000) % 10000 + len(merchant))
    
    features = {}
    for i in range(1, 29):
        if i in [1, 2, 3, 4, 5]:
            features[f'V{i}'] = float(np.random.normal(0, 1))
        elif i in [6, 7, 8, 9, 10]:
            features[f'V{i}'] = float(np.random.normal(0, 2))
        else:
            features[f'V{i}'] = float(np.random.normal(0, 1.5))
    
    # Simuler des patterns de fraude pour test
    if amount > 1000:
        features['V11'] = float(np.random.normal(2, 1))
        features['V12'] = float(np.random.normal(-1, 1))
        features['V14'] = float(np.random.normal(-2, 0.8))
    
    if amount > 5000:  # Montant très élevé = plus suspect
        features['V4'] = float(np.random.normal(3, 1))
        features['V11'] = float(np.random.normal(3.5, 0.5))
    
    features['Amount'] = float(amount)
    
    return features

async def detect_fraud(transaction_data: dict) -> dict:
    """
    Envoie la transaction au service ML pour détection de fraude
    ✅ CORRECTION: Utilise le bon endpoint /predict avec les bonnes données
    """
    try:
        print(f"🔍 Envoi vers ML Service: {FRAUD_DETECTION_SERVICE_URL}/predict")
        print(f"📊 Données: amount={transaction_data.get('amount')}, merchant={transaction_data.get('merchant')}")
        
        async with httpx.AsyncClient() as client:
            # ✅ CORRECTION: Envoyer directement les données de transaction
            response = await client.post(
                f"{FRAUD_DETECTION_SERVICE_URL}/predict",  # ✅ BON ENDPOINT
                json=transaction_data,  # ✅ BONNES DONNÉES
                timeout=10.0
            )
            
            print(f"📡 Réponse ML (status={response.status_code}): {response.text}")
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ Résultat ML: is_fraud={result.get('is_fraud')}, score={result.get('fraud_score')}")
                return result
            else:
                print(f"❌ Erreur ML Service: {response.status_code}")
                return {
                    "is_fraud": False,
                    "fraud_score": 0.0,
                    "confidence": 0.0
                }
    except Exception as e:
        print(f"❌ Exception lors de la détection de fraude: {e}")
        import traceback
        traceback.print_exc()
        return {
            "is_fraud": False,
            "fraud_score": 0.0,
            "confidence": 0.0
        }

@app.get("/")
async def root():
    """Endpoint de santé"""
    return {
        "service": "Transaction Service",
        "status": "running",
        "ml_service": FRAUD_DETECTION_SERVICE_URL,
        "celery_enabled": CELERY_AVAILABLE
    }

@app.get("/health")
async def health_check():
    """Vérification de santé"""
    return {"status": "healthy"}

@app.post("/transactions", response_model=TransactionResponse)
async def create_transaction(transaction: TransactionCreate, db: Session = Depends(get_db)):
    print(f"\n🆕 Nouvelle transaction: {transaction.amount}€ chez {transaction.merchant}")
    
    # Générer un ID de transaction
    transaction_id = f"TXN_{datetime.now().strftime('%Y%m%d%H%M%S')}_{random.randint(1000, 9999)}"
    
    # Préparer les données pour le ML
    transaction_data = {
        "amount": transaction.amount,
        "merchant": transaction.merchant,
        "category": transaction.category or "Other",
        "user_id": transaction.user_id,
        "timestamp": transaction.timestamp or datetime.now().isoformat()
    }
    
    # Créer la transaction en base avec statut PENDING
    db_transaction = Transaction(
        transaction_id=transaction_id,
        user_id=transaction.user_id,
        amount=transaction.amount,
        merchant=transaction.merchant,
        category=transaction.category,
        description=transaction.description,
        status='PENDING'
    )
    db.add(db_transaction)
    db.commit()
    db.refresh(db_transaction)
    
    print(f"💾 Transaction sauvegardée: {transaction_id}")
    
    # Vérification de fraude avec le ML
    print(f"🤖 Appel du service ML...")
    fraud_result = await detect_fraud(transaction_data)
    
    # Mettre à jour la transaction avec le résultat
    is_fraud = fraud_result.get("is_fraud", False)
    fraud_score = fraud_result.get("fraud_score", 0.0)
    
    db_transaction.status = 'BLOCKED' if is_fraud else 'APPROVED'
    db_transaction.is_fraud = is_fraud
    db_transaction.fraud_score = fraud_score
    db_transaction.confidence = fraud_result.get("confidence", 0.0)
    db.commit()
    
    status_emoji = "🚫" if is_fraud else "✅"
    print(f"{status_emoji} Transaction {db_transaction.status}: is_fraud={is_fraud}, score={fraud_score:.2%}")
    
    return TransactionResponse(
        transaction_id=transaction_id,
        user_id=transaction.user_id,
        amount=transaction.amount,
        merchant=transaction.merchant,
        status=db_transaction.status,
        is_fraud=db_transaction.is_fraud,
        fraud_score=db_transaction.fraud_score,
        timestamp=db_transaction.created_at.isoformat()
    )

@app.get("/transactions/{transaction_id}")
async def get_transaction(transaction_id: str, db: Session = Depends(get_db)):
    """
    Récupère une transaction par son ID
    """
    transaction = db.query(Transaction).filter(Transaction.transaction_id == transaction_id).first()
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction non trouvée")
    
    return transaction.to_dict()

@app.get("/transactions")
async def list_transactions(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Liste les transactions
    """
    total = db.query(Transaction).count()
    transactions = db.query(Transaction).order_by(Transaction.created_at.desc()).offset(skip).limit(limit).all()
    
    print(f"📋 Liste de {len(transactions)} transactions (total: {total})")
    
    return {
        "total": total,
        "transactions": [tx.to_dict() for tx in transactions]
    }

@app.get("/users/{user_id}/transactions")
async def get_user_transactions(user_id: str, db: Session = Depends(get_db)):
    """
    Récupère toutes les transactions d'un utilisateur
    """
    transactions = db.query(Transaction).filter(Transaction.user_id == user_id).all()
    return {
        "user_id": user_id,
        "total": len(transactions),
        "transactions": [tx.to_dict() for tx in transactions]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)