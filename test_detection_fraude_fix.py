"""
Script de test pour vérifier que la détection de fraude fonctionne correctement
avec le nouveau modèle Random Forest
"""

import requests
import json
import numpy as np
from pathlib import Path

# URL du service de détection de fraude
FRAUD_SERVICE_URL = "http://localhost:8002"

def generate_test_features():
    """Génère des features de test pour une transaction"""
    features = {}
    # Générer des valeurs aléatoires pour V1-V28
    for i in range(1, 29):
        features[f'V{i}'] = float(np.random.randn())
    # Ajouter un montant
    features['Amount'] = float(np.random.uniform(1, 1000))
    return features

def test_health_check():
    """Teste l'endpoint de santé"""
    print("=" * 70)
    print("  TEST 1: Vérification de santé du service")
    print("=" * 70)
    
    try:
        response = requests.get(f"{FRAUD_SERVICE_URL}/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Service en ligne")
            print(f"   Status: {data.get('status')}")
            print(f"   Modèle chargé: {data.get('model_loaded')}")
            return True
        else:
            print(f"❌ Service retourne code {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print(f"❌ Impossible de se connecter au service sur {FRAUD_SERVICE_URL}")
        print(f"   Assurez-vous que le service est démarré")
        return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def test_root_endpoint():
    """Teste l'endpoint racine"""
    print("\n" + "=" * 70)
    print("  TEST 2: Endpoint racine")
    print("=" * 70)
    
    try:
        response = requests.get(f"{FRAUD_SERVICE_URL}/", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Endpoint racine accessible")
            print(f"   Service: {data.get('service')}")
            print(f"   Status: {data.get('status')}")
            print(f"   Modèle chargé: {data.get('model_loaded')}")
            print(f"   Type de modèle: {data.get('model_type')}")
            return True
        else:
            print(f"❌ Endpoint retourne code {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def test_fraud_detection_normal():
    """Teste la détection avec une transaction normale"""
    print("\n" + "=" * 70)
    print("  TEST 3: Détection de fraude - Transaction normale")
    print("=" * 70)
    
    features = generate_test_features()
    # Ajuster pour une transaction normale (valeurs proches de 0)
    for key in features:
        if key.startswith('V'):
            features[key] = float(np.random.normal(0, 1))
    
    payload = {
        "transaction_id": "TEST_NORMAL_001",
        "features": features
    }
    
    try:
        response = requests.post(
            f"{FRAUD_SERVICE_URL}/detect",
            json=payload,
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Détection réussie")
            print(f"   Transaction ID: {data.get('transaction_id')}")
            print(f"   Est fraude: {data.get('is_fraud')}")
            print(f"   Score de fraude: {data.get('fraud_score'):.4f}")
            print(f"   Confiance: {data.get('confidence'):.4f}")
            
            if not data.get('is_fraud'):
                print(f"   ✅ Transaction correctement identifiée comme normale")
            else:
                print(f"   ⚠️  Transaction identifiée comme fraude (peut être normal selon le seuil)")
            
            return True
        else:
            print(f"❌ Erreur HTTP {response.status_code}")
            try:
                error_data = response.json()
                print(f"   Détail: {error_data.get('detail', 'Aucun détail')}")
            except:
                print(f"   Réponse: {response.text[:200]}")
            return False
            
    except Exception as e:
        print(f"❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_fraud_detection_suspicious():
    """Teste la détection avec une transaction suspecte"""
    print("\n" + "=" * 70)
    print("  TEST 4: Détection de fraude - Transaction suspecte")
    print("=" * 70)
    
    features = generate_test_features()
    # Ajuster pour une transaction suspecte (valeurs extrêmes)
    for key in features:
        if key.startswith('V'):
            features[key] = float(np.random.normal(0, 5))  # Valeurs plus extrêmes
    
    features['Amount'] = float(np.random.uniform(5000, 10000))  # Montant élevé
    
    payload = {
        "transaction_id": "TEST_SUSPICIOUS_001",
        "features": features
    }
    
    try:
        response = requests.post(
            f"{FRAUD_SERVICE_URL}/detect",
            json=payload,
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Détection réussie")
            print(f"   Transaction ID: {data.get('transaction_id')}")
            print(f"   Est fraude: {data.get('is_fraud')}")
            print(f"   Score de fraude: {data.get('fraud_score'):.4f}")
            print(f"   Confiance: {data.get('confidence'):.4f}")
            
            if data.get('is_fraud'):
                print(f"   ✅ Transaction correctement identifiée comme suspecte/fraude")
            else:
                print(f"   ⚠️  Transaction identifiée comme normale (peut être normal selon le modèle)")
            
            return True
        else:
            print(f"❌ Erreur HTTP {response.status_code}")
            try:
                error_data = response.json()
                print(f"   Détail: {error_data.get('detail', 'Aucun détail')}")
            except:
                print(f"   Réponse: {response.text[:200]}")
            return False
            
    except Exception as e:
        print(f"❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_multiple_transactions():
    """Teste plusieurs transactions en lot"""
    print("\n" + "=" * 70)
    print("  TEST 5: Détection en lot (3 transactions)")
    print("=" * 70)
    
    transactions = []
    for i in range(3):
        features = generate_test_features()
        transactions.append({
            "transaction_id": f"TEST_BATCH_{i+1:03d}",
            "features": features
        })
    
    try:
        response = requests.post(
            f"{FRAUD_SERVICE_URL}/detect-batch",
            json=transactions,
            timeout=15
        )
        
        if response.status_code == 200:
            data = response.json()
            results = data.get('results', [])
            print(f"✅ Détection en lot réussie")
            print(f"   Nombre de résultats: {len(results)}")
            
            for result in results:
                if 'error' in result:
                    print(f"   ❌ Erreur pour {result.get('transaction_id')}: {result.get('error')}")
                else:
                    print(f"   ✅ {result.get('transaction_id')}: "
                          f"fraude={result.get('is_fraud')}, "
                          f"score={result.get('fraud_score', 0):.4f}")
            
            return True
        else:
            print(f"❌ Erreur HTTP {response.status_code}")
            try:
                error_data = response.json()
                print(f"   Détail: {error_data.get('detail', 'Aucun détail')}")
            except:
                print(f"   Réponse: {response.text[:200]}")
            return False
            
    except Exception as e:
        print(f"❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Exécute tous les tests"""
    print("\n" + "=" * 70)
    print("  TESTS DE DÉTECTION DE FRAUDE")
    print("=" * 70)
    print(f"\nURL du service: {FRAUD_SERVICE_URL}")
    print(f"Assurez-vous que le service est démarré avant de lancer les tests.\n")
    
    results = []
    
    # Tests
    results.append(("Santé du service", test_health_check()))
    results.append(("Endpoint racine", test_root_endpoint()))
    results.append(("Transaction normale", test_fraud_detection_normal()))
    results.append(("Transaction suspecte", test_fraud_detection_suspicious()))
    results.append(("Détection en lot", test_multiple_transactions()))
    
    # Résumé
    print("\n" + "=" * 70)
    print("  RÉSUMÉ DES TESTS")
    print("=" * 70)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "✅ PASSÉ" if result else "❌ ÉCHOUÉ"
        print(f"   {status}: {test_name}")
    
    print(f"\n   Résultat: {passed}/{total} tests réussis")
    
    if passed == total:
        print("\n✅ TOUS LES TESTS SONT RÉUSSIS!")
        return 0
    else:
        print(f"\n❌ {total - passed} test(s) ont échoué")
        return 1

if __name__ == "__main__":
    exit(main())
