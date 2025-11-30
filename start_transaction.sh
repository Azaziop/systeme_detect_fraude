#!/bin/bash

echo "========================================"
echo "  Démarrage Transaction Service (FastAPI)"
echo "========================================"
echo

cd transaction_service

if [ ! -d "venv" ]; then
    echo "[ERREUR] Environnement virtuel non trouvé."
    echo "Exécutez d'abord: ./setup_local.sh"
    exit 1
fi

source venv/bin/activate

# Configurer les variables d'environnement
export FRAUD_DETECTION_SERVICE_URL=${FRAUD_DETECTION_SERVICE_URL:-http://localhost:8002}
export AUTH_SERVICE_URL=${AUTH_SERVICE_URL:-http://localhost:8000}
export REDIS_URL=${REDIS_URL:-redis://localhost:6379/0}
export DATABASE_URL=${DATABASE_URL:-sqlite:///./transactions.db}

echo "Configuration:"
echo "  FRAUD_DETECTION_SERVICE_URL=$FRAUD_DETECTION_SERVICE_URL"
echo "  AUTH_SERVICE_URL=$AUTH_SERVICE_URL"
echo "  DATABASE_URL=$DATABASE_URL"
echo

echo "Démarrage du serveur sur http://localhost:8001"
echo "Swagger: http://localhost:8001/docs"
echo
echo "Appuyez sur Ctrl+C pour arrêter."
echo

uvicorn main:app --host 0.0.0.0 --port 8001 --reload

