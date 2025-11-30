"""
Tâches Celery pour le service de transaction
"""

import httpx
import os
try:
    from .celery_app import celery_app
except ImportError:
    from celery_app import celery_app

FRAUD_DETECTION_SERVICE_URL = os.getenv(
    "FRAUD_DETECTION_SERVICE_URL",
    "http://fraud-detection-service:8002"
)


@celery_app.task(name='transaction_service.check_fraud', bind=True, max_retries=3)
def check_fraud_async(self, transaction_id: str, features: dict):
    """
    Tâche asynchrone pour vérifier une transaction pour fraude
    
    Args:
        transaction_id: ID de la transaction
        features: Features de la transaction pour le modèle ML
    
    Returns:
        dict: Résultat de la détection de fraude
    """
    try:
        with httpx.Client(timeout=10.0) as client:
            payload = {
                "transaction_id": transaction_id,
                "features": features
            }
            response = client.post(
                f"{FRAUD_DETECTION_SERVICE_URL}/detect",
                json=payload
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                # Retry en cas d'erreur
                raise Exception(f"Service de détection retourné {response.status_code}")
    
    except Exception as exc:
        # Retry avec backoff exponentiel
        raise self.retry(exc=exc, countdown=2 ** self.request.retries)


@celery_app.task(name='transaction_service.batch_check_fraud')
def batch_check_fraud_async(transactions: list):
    """
    Tâche asynchrone pour vérifier plusieurs transactions en lot
    
    Args:
        transactions: Liste de transactions à vérifier
    
    Returns:
        list: Résultats de détection pour chaque transaction
    """
    results = []
    for transaction in transactions:
        result = check_fraud_async.delay(
            transaction['transaction_id'],
            transaction['features']
        )
        results.append({
            'transaction_id': transaction['transaction_id'],
            'task_id': result.id
        })
    return results

