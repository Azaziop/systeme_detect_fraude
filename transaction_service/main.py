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
    allow_origins=["*"],  # En développement, autoriser toutes les origines
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

# Utiliser la base de données au lieu du stockage en mémoire

def generate_features(amount: float) -> dict:
    """
    Génère des features synthétiques pour la transaction
    Dans un vrai système, ces features seraient calculées à partir des données historiques
    """
    np.random.seed(int(amount * 1000) % 10000)
    
    # Générer des features V1-V28 (simulation)
    features = {}
    for i in range(1, 29):
        # Simuler des distributions réalistes
        if i in [1, 2, 3, 4, 5]:
            features[f'V{i}'] = float(np.random.normal(0, 1))
        elif i in [6, 7, 8, 9, 10]:
            features[f'V{i}'] = float(np.random.normal(0, 2))
        else:
            features[f'V{i}'] = float(np.random.normal(0, 1.5))
    
    # Ajuster certaines features en fonction du montant
    if amount > 1000:
        features['V11'] = float(np.random.normal(2, 1))
        features['V12'] = float(np.random.normal(-1, 1))
    
    features['Amount'] = float(amount)
    
    return features

async def verify_user_token(user_id: str) -> bool:
    """
    Vérifie le token utilisateur avec le service d'authentification
    """
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{AUTH_SERVICE_URL}/api/users/{user_id}/verify",
                timeout=5.0
            )
            return response.status_code == 200
    except Exception:
        # En mode développement, accepter tous les utilisateurs
        return True

async def detect_fraud(transaction_id: str, features: dict) -> dict:
    """
    Envoie la transaction au service de détection de fraude
    """
    try:
        async with httpx.AsyncClient() as client:
            payload = {
                "transaction_id": transaction_id,
                "features": features
            }
            response = await client.post(
                f"{FRAUD_DETECTION_SERVICE_URL}/detect",
                json=payload,
                timeout=10.0
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                return {
                    "is_fraud": False,
                    "fraud_score": 0.0,
                    "confidence": 0.0
                }
    except Exception as e:
        print(f"Erreur lors de la détection de fraude: {e}")
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
        "status": "running"
    }

@app.get("/health")
async def health_check():
    """Vérification de santé"""
    return {"status": "healthy"}

@app.post("/transactions", response_model=TransactionResponse)
async def create_transaction(transaction: TransactionCreate, db: Session = Depends(get_db)):
    """
    Crée une nouvelle transaction et la vérifie pour fraude (asynchrone avec Celery)
    """
    try:
        # Générer un ID de transaction
        transaction_id = f"TXN_{datetime.now().strftime('%Y%m%d%H%M%S')}_{random.randint(1000, 9999)}"
        
        # Générer les features pour le modèle ML
        features = generate_features(transaction.amount)
        
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
        db.flush()  # Flush pour obtenir l'ID sans commit
        db.commit()  # Commit pour sauvegarder la transaction
        db.refresh(db_transaction)  # Rafraîchir pour obtenir les valeurs par défaut (created_at, etc.)
        
        # Vérification de fraude (asynchrone avec Celery si disponible, sinon synchrone)
        if CELERY_AVAILABLE:
            # Utiliser Celery pour traitement asynchrone
            task = check_fraud_async.delay(transaction_id, features)
            try:
                fraud_result = task.get(timeout=10)
            except Exception as e:
                print(f"Erreur Celery: {e}")
                fraud_result = await detect_fraud(transaction_id, features)
        else:
            # Vérification synchrone directe
            fraud_result = await detect_fraud(transaction_id, features)
        
        # Mettre à jour la transaction avec le résultat
        if fraud_result:
            db_transaction.status = 'BLOCKED' if fraud_result.get("is_fraud", False) else 'APPROVED'
            db_transaction.is_fraud = fraud_result.get("is_fraud", False)
            db_transaction.fraud_score = fraud_result.get("fraud_score", 0.0)
            db_transaction.confidence = fraud_result.get("confidence", 0.0)
            db.commit()  # Commit pour sauvegarder les modifications
            db.refresh(db_transaction)  # Rafraîchir pour obtenir les valeurs mises à jour
            
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
        else:
            # En cas d'erreur, garder PENDING
            return TransactionResponse(
                transaction_id=transaction_id,
                user_id=transaction.user_id,
                amount=transaction.amount,
                merchant=transaction.merchant,
                status='PENDING',
                is_fraud=None,
                fraud_score=None,
                timestamp=db_transaction.created_at.isoformat()
            )
    except Exception as e:
        # Rollback en cas d'erreur
        db.rollback()
        error_msg = f"Erreur lors de la création de la transaction: {str(e)}"
        print(f"❌ {error_msg}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=error_msg)

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
    transactions = db.query(Transaction).offset(skip).limit(limit).all()
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
