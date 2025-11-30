#!/bin/bash
# Script pour construire toutes les images Docker

echo "=== Construction des Images Docker ==="

# Construire le service d'authentification
echo "Construction de auth-service..."
docker build -t fraud-detection/auth-service:latest ./auth_service

# Construire le service de transaction
echo "Construction de transaction-service..."
docker build -t fraud-detection/transaction-service:latest ./transaction_service

# Construire le service de détection de fraude
echo "Construction de fraud-detection-service..."
docker build -t fraud-detection/fraud-detection-service:latest ./fraud_detection_service

echo "=== Construction terminée ==="
echo "Pour lancer avec Docker Compose: docker-compose up"

