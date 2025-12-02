"""
Script simple pour tester une transaction frauduleuse
Utilise uniquement urllib (intégré à Python, pas besoin d'installer requests)
"""

import urllib.request
import urllib.error
import json

# URL du service de détection de fraude
FRAUD_SERVICE_URL = "http://localhost:8002"

def send_request(url, data):
    """Envoie une requête POST avec urllib"""
    json_data = json.dumps(data).encode('utf-8')
    
    req = urllib.request.Request(
        url,
        data=json_data,
        headers={'Content-Type': 'application/json'},
        method='POST'
    )
    
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            return response.status, json.loads(response.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        return e.code, None
    except urllib.error.URLError as e:
        raise ConnectionError(f"Impossible de se connecter: {e.reason}")

def test_transaction_fraude():
    """Test avec une transaction frauduleuse"""
    
    print("=" * 70)
    print("  TEST TRANSACTION FRAUDULEUSE")
    print("=" * 70)
    print()
    
    # Transaction frauduleuse avec des valeurs très suspectes
    fraud_transaction = {
        "transaction_id": "TXN_FRAUDE_TEST_001",
        "features": {
            "V1": 5.0,      # Valeur très élevée
            "V2": -5.0,     # Valeur très négative
            "V3": 8.0,      # Valeur extrême
            "V4": -8.0,     # Valeur extrême négative
            "V5": 6.0,
            "V6": -6.0,
            "V7": 7.0,
            "V8": -7.0,
            "V9": 4.0,
            "V10": -4.0,
            "V11": 9.0,     # V11-V15 souvent importantes pour la détection de fraude
            "V12": -9.0,
            "V13": 10.0,
            "V14": -10.0,
            "V15": 8.5,
            "V16": -8.5,
            "V17": 7.5,
            "V18": -7.5,
            "V19": 6.5,
            "V20": -6.5,
            "V21": 5.5,
            "V22": -5.5,
            "V23": 4.5,
            "V24": -4.5,
            "V25": 3.5,
            "V26": -3.5,
            "V27": 2.5,
            "V28": -2.5,
            "Amount": 10000.0  # Montant très élevé
        }
    }
    
    print("📤 Envoi de la transaction suspecte...")
    print(f"   Montant: {fraud_transaction['features']['Amount']}")
    print(f"   Features: Valeurs extrêmes (V1-V28 entre -10 et 10)")
    print()
    
    try:
        status, result = send_request(
            f"{FRAUD_SERVICE_URL}/detect",
            fraud_transaction
        )
        
        if status == 200 and result:
            print("✅ Analyse réussie!")
            print()
            print(f"📊 RÉSULTATS:")
            print(f"   Transaction ID: {result['transaction_id']}")
            print(f"   Est Fraude: {result['is_fraud']}")
            print(f"   Score de Fraude: {result['fraud_score']:.4f} ({result['fraud_score']*100:.2f}%)")
            print(f"   Confiance: {result['confidence']:.4f}")
            print()
            
            # Interprétation
            if result['is_fraud']:
                print("🚨 FRAUDE DÉTECTÉE!")
                print("   ✅ Le système fonctionne correctement!")
                print(f"   Le modèle a détecté une probabilité de fraude de {result['fraud_score']*100:.2f}%")
            else:
                print(f"⚠️  Non détecté comme fraude")
                print(f"   Score obtenu: {result['fraud_score']*100:.2f}%")
                print(f"   Seuil requis: 50.00% (0.50)")
                print()
                print("   💡 Raisons possibles:")
                print("      - Le modèle n'a peut-être pas été entraîné avec ce type de valeurs")
                print("      - Les valeurs peuvent ne pas être assez suspectes pour ce modèle")
                print("      - Le modèle peut être conservateur")
                print()
                print("   💡 Pour forcer une détection:")
                print("      - Essayez des valeurs encore plus extrêmes")
                print("      - Ou ajustez temporairement le seuil avec: $env:FRAUD_THRESHOLD='0.30'")
        else:
            print(f"❌ Erreur HTTP {status}")
            if result:
                print(f"   Détail: {result.get('detail', 'Aucun détail')}")
            
    except ConnectionError as e:
        print(f"❌ {e}")
        print()
        print("   Assurez-vous que le service est démarré:")
        print("   - cd fraud_detection_service")
        print("   - uvicorn main:app --host 0.0.0.0 --port 8002")
        print()
        print("   Ou utilisez Docker:")
        print("   - docker-compose up fraud-detection-service")
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
    
    print()
    print("=" * 70)


def test_transaction_normale():
    """Test avec une transaction normale pour comparaison"""
    
    print("=" * 70)
    print("  TEST TRANSACTION NORMALE (pour comparaison)")
    print("=" * 70)
    print()
    
    # Transaction normale avec des valeurs standard
    normal_transaction = {
        "transaction_id": "TXN_NORMALE_TEST_001",
        "features": {
            "V1": -0.1,
            "V2": 0.2,
            "V3": -0.15,
            "V4": 0.1,
            "V5": -0.05,
            "V6": 0.15,
            "V7": -0.2,
            "V8": 0.05,
            "V9": -0.1,
            "V10": 0.1,
            "V11": -0.15,
            "V12": 0.05,
            "V13": -0.1,
            "V14": 0.2,
            "V15": -0.05,
            "V16": 0.1,
            "V17": -0.15,
            "V18": 0.05,
            "V19": -0.1,
            "V20": 0.1,
            "V21": -0.05,
            "V22": 0.15,
            "V23": -0.1,
            "V24": 0.05,
            "V25": -0.1,
            "V26": 0.1,
            "V27": -0.05,
            "V28": 0.05,
            "Amount": 150.0  # Montant normal
        }
    }
    
    print("📤 Envoi de la transaction normale...")
    print(f"   Montant: {normal_transaction['features']['Amount']}")
    print()
    
    try:
        status, result = send_request(
            f"{FRAUD_SERVICE_URL}/detect",
            normal_transaction
        )
        
        if status == 200 and result:
            print("✅ Analyse réussie!")
            print()
            print(f"📊 RÉSULTATS:")
            print(f"   Transaction ID: {result['transaction_id']}")
            print(f"   Est Fraude: {result['is_fraud']}")
            print(f"   Score de Fraude: {result['fraud_score']:.4f} ({result['fraud_score']*100:.2f}%)")
            print(f"   Confiance: {result['confidence']:.4f}")
            print()
            
            if not result['is_fraud']:
                print("✅ Transaction normale - Correctement identifiée!")
            else:
                print("⚠️  Faux positif - Transaction normale détectée comme fraude")
        else:
            print(f"❌ Erreur HTTP {status}")
            
    except Exception as e:
        print(f"❌ Erreur: {e}")
    
    print()
    print("=" * 70)


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  TESTS DE DÉTECTION DE FRAUDE")
    print("=" * 70)
    print()
    print(f"Service: {FRAUD_SERVICE_URL}")
    print()
    
    # Test 1: Transaction frauduleuse
    test_transaction_fraude()
    
    print()
    
    # Test 2: Transaction normale (pour comparaison)
    test_transaction_normale()
    
    print("\n✅ Tests terminés!")
    print()
