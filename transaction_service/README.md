# Service de Transaction

Service FastAPI pour capturer et traiter les transactions. Envoie automatiquement les transactions au service de détection de fraude.

## Endpoints

### GET /
Endpoint de santé

### GET /health
Vérification de santé

### POST /transactions
Crée une nouvelle transaction et la vérifie pour fraude.

**Request:**
```json
{
  "user_id": "user123",
  "amount": 149.62,
  "merchant": "Amazon",
  "category": "Shopping",
  "description": "Purchase"
}
```

**Response:**
```json
{
  "transaction_id": "TXN_20231201120000_1234",
  "user_id": "user123",
  "amount": 149.62,
  "merchant": "Amazon",
  "status": "APPROVED",
  "is_fraud": false,
  "fraud_score": -0.123,
  "timestamp": "2023-12-01T12:00:00"
}
```

### GET /transactions/{transaction_id}
Récupère une transaction par son ID

### GET /transactions
Liste toutes les transactions (avec pagination)

### GET /users/{user_id}/transactions
Récupère toutes les transactions d'un utilisateur

## Configuration

Variables d'environnement:
- `FRAUD_DETECTION_SERVICE_URL`: URL du service de détection (défaut: http://fraud-detection-service:8002)
- `AUTH_SERVICE_URL`: URL du service d'authentification (défaut: http://auth-service:8000)

