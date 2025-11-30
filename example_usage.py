"""
Script d'exemple pour tester les services de détection de fraude
"""

import requests
import json
import random
import numpy as np

# URLs des services
AUTH_SERVICE_URL = "http://localhost:8000"
TRANSACTION_SERVICE_URL = "http://localhost:8001"
FRAUD_DETECTION_SERVICE_URL = "http://localhost:8002"

def generate_transaction_features(amount: float, is_fraud: bool = False) -> dict:
    """Génère des features pour une transaction"""
    np.random.seed(int(amount * 1000) % 10000)
    
    features = {}
    for i in range(1, 29):
        if is_fraud:
            # Features suspectes pour les fraudes
            if i in [11, 12, 13, 14, 15]:
                features[f'V{i}'] = float(np.random.normal(3, 1))
            else:
                features[f'V{i}'] = float(np.random.normal(0, 2))
        else:
            # Features normales
            if i in [1, 2, 3, 4, 5]:
                features[f'V{i}'] = float(np.random.normal(0, 1))
            else:
                features[f'V{i}'] = float(np.random.normal(0, 1.5))
    
    features['Amount'] = float(amount)
    return features

def test_auth_service():
    """Test du service d'authentification"""
    print("\n=== Test Auth Service ===")
    
    # Inscription
    register_data = {
        "username": "testuser",
        "email": "test@example.com",
        "password": "testpass123",
        "password_confirm": "testpass123",
        "phone": "+1234567890"
    }
    
    try:
        response = requests.post(f"{AUTH_SERVICE_URL}/api/register/", json=register_data)
        if response.status_code == 201:
            print("✓ Inscription réussie")
            token = response.json().get('token')
            user_id = response.json().get('user', {}).get('id')
            return token, user_id
        else:
            print(f"✗ Erreur inscription: {response.status_code}")
            print(response.json())
    except Exception as e:
        print(f"✗ Erreur: {e}")
    
    return None, None

def test_transaction_service(user_id: str):
    """Test du service de transaction"""
    print("\n=== Test Transaction Service ===")
    
    # Créer une transaction normale
    transaction_data = {
        "user_id": str(user_id) if user_id else "1",
        "amount": 100.50,
        "merchant": "Amazon",
        "category": "Shopping",
        "description": "Purchase test"
    }
    
    try:
        response = requests.post(
            f"{TRANSACTION_SERVICE_URL}/transactions",
            json=transaction_data
        )
        if response.status_code == 200:
            result = response.json()
            print(f"✓ Transaction créée: {result['transaction_id']}")
            print(f"  Statut: {result['status']}")
            print(f"  Fraude détectée: {result.get('is_fraud', False)}")
            return result
        else:
            print(f"✗ Erreur transaction: {response.status_code}")
            print(response.json())
    except Exception as e:
        print(f"✗ Erreur: {e}")
    
    return None

def test_fraud_detection_service():
    """Test direct du service de détection de fraude"""
    print("\n=== Test Fraud Detection Service ===")
    
    # Transaction normale
    normal_features = generate_transaction_features(100.0, is_fraud=False)
    normal_request = {
        "transaction_id": "TXN_TEST_NORMAL",
        "features": normal_features
    }
    
    # Transaction suspecte
    fraud_features = generate_transaction_features(5000.0, is_fraud=True)
    fraud_request = {
        "transaction_id": "TXN_TEST_FRAUD",
        "features": fraud_features
    }
    
    try:
        # Test transaction normale
        response = requests.post(
            f"{FRAUD_DETECTION_SERVICE_URL}/detect",
            json=normal_request
        )
        if response.status_code == 200:
            result = response.json()
            print(f"✓ Transaction normale analysée")
            print(f"  Fraude: {result['is_fraud']}")
            print(f"  Score: {result['fraud_score']:.4f}")
        
        # Test transaction suspecte
        response = requests.post(
            f"{FRAUD_DETECTION_SERVICE_URL}/detect",
            json=fraud_request
        )
        if response.status_code == 200:
            result = response.json()
            print(f"✓ Transaction suspecte analysée")
            print(f"  Fraude: {result['is_fraud']}")
            print(f"  Score: {result['fraud_score']:.4f}")
    except Exception as e:
        print(f"✗ Erreur: {e}")

def main():
    """Fonction principale"""
    print("=== Test du Système de Détection de Fraude ===\n")
    
    # Vérifier que les services sont disponibles
    services_ok = True
    for name, url in [
        ("Auth Service", AUTH_SERVICE_URL),
        ("Transaction Service", TRANSACTION_SERVICE_URL),
        ("Fraud Detection Service", FRAUD_DETECTION_SERVICE_URL)
    ]:
        try:
            response = requests.get(f"{url}/health", timeout=2)
            if response.status_code == 200:
                print(f"✓ {name} est disponible")
            else:
                print(f"✗ {name} répond mais avec erreur")
                services_ok = False
        except:
            print(f"✗ {name} n'est pas disponible à {url}")
            services_ok = False
    
    if not services_ok:
        print("\n⚠ Certains services ne sont pas disponibles.")
        print("Assurez-vous que les services sont lancés avec: docker-compose up")
        return
    
    # Tests
    token, user_id = test_auth_service()
    test_transaction_service(user_id)
    test_fraud_detection_service()
    
    print("\n=== Tests terminés ===")

if __name__ == "__main__":
    main()

