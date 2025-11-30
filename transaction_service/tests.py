"""
Tests unitaires pour le service de transaction
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from .main import app, get_db
from .models import Base, Transaction

# Base de données de test
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_transactions.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Créer les tables de test
Base.metadata.create_all(bind=engine)


def override_get_db():
    """Override de la dépendance get_db pour les tests"""
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)


class TestTransactionService:
    """Tests pour le service de transaction"""
    
    def setup_method(self):
        """Setup avant chaque test"""
        # Nettoyer la base de données
        db = TestingSessionLocal()
        db.query(Transaction).delete()
        db.commit()
        db.close()
    
    def test_health_check(self):
        """Test du health check"""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "healthy"}
    
    def test_create_transaction(self):
        """Test de création d'une transaction"""
        data = {
            "user_id": "user123",
            "amount": 100.50,
            "merchant": "Amazon",
            "category": "Shopping",
            "description": "Test purchase"
        }
        response = client.post("/transactions", json=data)
        
        assert response.status_code == 200
        assert response.json()["user_id"] == "user123"
        assert response.json()["amount"] == 100.50
        assert response.json()["merchant"] == "Amazon"
        assert "transaction_id" in response.json()
        assert response.json()["status"] in ["APPROVED", "BLOCKED", "PENDING"]
    
    def test_get_transaction(self):
        """Test de récupération d'une transaction"""
        # Créer une transaction
        create_data = {
            "user_id": "user123",
            "amount": 100.50,
            "merchant": "Amazon"
        }
        create_response = client.post("/transactions", json=create_data)
        transaction_id = create_response.json()["transaction_id"]
        
        # Récupérer la transaction
        response = client.get(f"/transactions/{transaction_id}")
        
        assert response.status_code == 200
        assert response.json()["transaction_id"] == transaction_id
        assert response.json()["user_id"] == "user123"
    
    def test_get_nonexistent_transaction(self):
        """Test de récupération d'une transaction inexistante"""
        response = client.get("/transactions/NONEXISTENT")
        
        assert response.status_code == 404
    
    def test_list_transactions(self):
        """Test de liste des transactions"""
        # Créer quelques transactions
        for i in range(3):
            client.post("/transactions", json={
                "user_id": f"user{i}",
                "amount": 10.0 * (i + 1),
                "merchant": f"Merchant{i}"
            })
        
        response = client.get("/transactions?skip=0&limit=10")
        
        assert response.status_code == 200
        assert response.json()["total"] >= 3
        assert len(response.json()["transactions"]) >= 3
    
    def test_get_user_transactions(self):
        """Test de récupération des transactions d'un utilisateur"""
        user_id = "user123"
        
        # Créer des transactions pour cet utilisateur
        for i in range(2):
            client.post("/transactions", json={
                "user_id": user_id,
                "amount": 10.0 * (i + 1),
                "merchant": f"Merchant{i}"
            })
        
        # Créer une transaction pour un autre utilisateur
        client.post("/transactions", json={
            "user_id": "other_user",
            "amount": 50.0,
            "merchant": "OtherMerchant"
        })
        
        response = client.get(f"/users/{user_id}/transactions")
        
        assert response.status_code == 200
        assert response.json()["user_id"] == user_id
        assert response.json()["total"] == 2
        assert all(tx["user_id"] == user_id for tx in response.json()["transactions"])

