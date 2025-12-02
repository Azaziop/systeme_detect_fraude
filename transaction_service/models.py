"""
Modèles de base de données pour le service de transaction
"""

from sqlalchemy import Column, String, Float, Boolean, DateTime, Integer, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from datetime import datetime
import os

Base = declarative_base()


class Transaction(Base):
    """Modèle de transaction"""
    __tablename__ = 'transactions'
    
    id = Column(Integer, primary_key=True, index=True)
    transaction_id = Column(String(100), unique=True, index=True, nullable=False)
    user_id = Column(String(100), nullable=False, index=True)
    amount = Column(Float, nullable=False)
    merchant = Column(String(255), nullable=False)
    category = Column(String(100), nullable=True)
    description = Column(Text, nullable=True)
    status = Column(String(50), nullable=False, default='PENDING')  # PENDING, APPROVED, BLOCKED
    is_fraud = Column(Boolean, default=False, nullable=True)
    fraud_score = Column(Float, nullable=True)
    confidence = Column(Float, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    def to_dict(self):
        """Convertit le modèle en dictionnaire"""
        return {
            'id': self.id,
            'transaction_id': self.transaction_id,
            'user_id': self.user_id,
            'amount': self.amount,
            'merchant': self.merchant,
            'category': self.category,
            'description': self.description,
            'status': self.status,
            'is_fraud': self.is_fraud,
            'fraud_score': self.fraud_score,
            'confidence': self.confidence,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }


# Configuration de la base de données
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://postgres:postgres@localhost:5432/fraud_detection')

# Créer l'engine avec configuration optimisée (PostgreSQL attendu)
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_size=5,
    max_overflow=10,
    echo=False
)
print(f"✅ Connexion configurée: {DATABASE_URL.split('@')[1] if '@' in DATABASE_URL else DATABASE_URL}")

# Créer les tables
try:
    Base.metadata.create_all(bind=engine)
    print("✅ Tables créées avec succès dans la base de données")
except Exception as e:
    print(f"⚠️ Erreur lors de la création des tables: {e}")
    print("   Les tables peuvent déjà exister ou il y a un problème de connexion.")

# Créer la session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    """Obtient une session de base de données"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

