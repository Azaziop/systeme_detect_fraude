#!/bin/bash

echo "========================================"
echo "  Démarrage Celery Worker"
echo "========================================"
echo

cd transaction_service

if [ ! -d "venv" ]; then
    echo "[ERREUR] Environnement virtuel non trouvé."
    echo "Exécutez d'abord: ./setup_local.sh"
    exit 1
fi

source venv/bin/activate

# Configurer Redis
export REDIS_URL=${REDIS_URL:-redis://localhost:6379/0}

echo "Configuration:"
echo "  REDIS_URL=$REDIS_URL"
echo

echo "Démarrage du worker Celery..."
echo
echo "Appuyez sur Ctrl+C pour arrêter."
echo

celery -A celery_app worker --loglevel=info

