#!/bin/bash
# Script pour tester les services

echo "=== Test des Services ==="

# Attendre que les services soient prêts
echo "Attente du démarrage des services..."
sleep 10

# Test Auth Service
echo "Test Auth Service..."
curl -X POST http://localhost:8000/api/register/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"testpass123","password_confirm":"testpass123"}'

# Test Transaction Service
echo -e "\nTest Transaction Service..."
curl http://localhost:8001/health

# Test Fraud Detection Service
echo -e "\nTest Fraud Detection Service..."
curl http://localhost:8002/health

echo -e "\n=== Tests terminés ==="

