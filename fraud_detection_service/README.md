# Service de Détection de Fraude

Service FastAPI qui utilise un modèle Isolation Forest pour détecter les transactions frauduleuses en temps réel.

## Endpoints

### GET /
Endpoint de santé basique

### GET /health
Vérification de santé du service

### POST /detect
Analyse une transaction et détermine si elle est frauduleuse.

**Request:**
```json
{
  "transaction_id": "TXN_123456",
  "features": {
    "V1": -1.359807134,
    "V2": -0.072781173,
    "V3": 2.536346738,
    ...
    "V28": 0.133558377,
    "Amount": 149.62
  }
}
```

**Response:**
```json
{
  "transaction_id": "TXN_123456",
  "is_fraud": false,
  "fraud_score": -0.123,
  "confidence": 0.85
}
```

### POST /detect-batch
Analyse plusieurs transactions en lot.

## Utilisation

```bash
# Lancer le service
uvicorn main:app --host 0.0.0.0 --port 8002

# Avec Docker
docker build -t fraud-detection-service .
docker run -p 8002:8002 fraud-detection-service
```

## Prérequis

Le modèle ML doit être entraîné et disponible dans `../ml_model/models/`

