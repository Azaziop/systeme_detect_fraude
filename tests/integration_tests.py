"""
Tests d'intégration pour le workflow complet
"""

import pytest
import httpx
import time

BASE_URL_AUTH = "http://localhost:8000"
BASE_URL_TRANSACTION = "http://localhost:8001"
BASE_URL_FRAUD = "http://localhost:8002"


class TestCompleteWorkflow:
    """Tests du workflow complet du système"""
    
    def test_complete_transaction_flow(self):
        """Test du flux complet : inscription -> transaction -> détection"""
        # 1. Inscription d'un utilisateur
        register_data = {
            "username": "testuser_workflow",
            "email": "workflow@example.com",
            "password": "testpass123",
            "password_confirm": "testpass123"
        }
        
        with httpx.Client() as client:
            # Inscription
            register_response = client.post(
                f"{BASE_URL_AUTH}/api/register/",
                json=register_data,
                timeout=10.0
            )
            assert register_response.status_code in [200, 201]
            user_data = register_response.json()
            assert "access" in user_data or "token" in user_data
            user_id = user_data.get("user", {}).get("id")
            
            # 2. Créer une transaction
            transaction_data = {
                "user_id": str(user_id) if user_id else "1",
                "amount": 150.75,
                "merchant": "Test Merchant",
                "category": "Shopping"
            }
            
            transaction_response = client.post(
                f"{BASE_URL_TRANSACTION}/transactions",
                json=transaction_data,
                timeout=10.0
            )
            assert transaction_response.status_code == 200
            transaction_result = transaction_response.json()
            assert "transaction_id" in transaction_result
            assert transaction_result["status"] in ["APPROVED", "BLOCKED", "PENDING"]
            
            # 3. Vérifier que la transaction est sauvegardée
            transaction_id = transaction_result["transaction_id"]
            get_response = client.get(
                f"{BASE_URL_TRANSACTION}/transactions/{transaction_id}",
                timeout=10.0
            )
            assert get_response.status_code == 200
            assert get_response.json()["transaction_id"] == transaction_id
    
    def test_fraud_detection_service(self):
        """Test du service de détection de fraude"""
        import numpy as np
        
        # Générer des features de test
        features = {}
        for i in range(1, 29):
            features[f'V{i}'] = float(np.random.normal(0, 1))
        features['Amount'] = 100.0
        
        with httpx.Client() as client:
            response = client.post(
                f"{BASE_URL_FRAUD}/detect",
                json={
                    "transaction_id": "TEST_TXN_001",
                    "features": features
                },
                timeout=10.0
            )
            assert response.status_code == 200
            result = response.json()
            assert "is_fraud" in result
            assert "fraud_score" in result
            assert "confidence" in result
    
    def test_authentication_flow(self):
        """Test du flux d'authentification complet"""
        with httpx.Client() as client:
            # 1. Inscription
            register_data = {
                "username": "auth_test_user",
                "email": "auth@example.com",
                "password": "testpass123",
                "password_confirm": "testpass123"
            }
            register_response = client.post(
                f"{BASE_URL_AUTH}/api/register/",
                json=register_data,
                timeout=10.0
            )
            assert register_response.status_code in [200, 201]
            
            # 2. Connexion
            login_data = {
                "username": "auth_test_user",
                "password": "testpass123"
            }
            login_response = client.post(
                f"{BASE_URL_AUTH}/api/login/",
                json=login_data,
                timeout=10.0
            )
            assert login_response.status_code == 200
            login_result = login_response.json()
            assert "access" in login_result or "token" in login_result
            
            # 3. Accéder au profil avec le token
            token = login_result.get("access") or login_result.get("token")
            headers = {"Authorization": f"Bearer {token}"} if "access" in login_result else {"Authorization": f"Token {token}"}
            
            profile_response = client.get(
                f"{BASE_URL_AUTH}/api/profile/",
                headers=headers,
                timeout=10.0
            )
            assert profile_response.status_code == 200

