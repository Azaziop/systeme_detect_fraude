#!/bin/bash

echo "========================================"
echo "  Démarrage Auth Service (Django)"
echo "========================================"
echo

cd auth_service

if [ ! -d "venv" ]; then
    echo "[ERREUR] Environnement virtuel non trouvé."
    echo "Exécutez d'abord: ./setup_local.sh"
    exit 1
fi

source venv/bin/activate

# Configurer les variables d'environnement
export DB_HOST=${DB_HOST:-localhost}
export DB_NAME=${DB_NAME:-fraud_detection}
export DB_USER=${DB_USER:-postgres}
export DB_PASSWORD=${DB_PASSWORD:-postgres}
export USE_SQLITE=${USE_SQLITE:-True}
export REDIS_URL=${REDIS_URL:-redis://localhost:6379/1}

echo "Configuration:"
echo "  DB_HOST=$DB_HOST"
echo "  USE_SQLITE=$USE_SQLITE"
echo

echo "Application des migrations..."
python manage.py migrate

echo
echo "Démarrage du serveur sur http://localhost:8000"
echo "Swagger: http://localhost:8000/api/docs/"
echo "Admin: http://localhost:8000/admin/"
echo
echo "Appuyez sur Ctrl+C pour arrêter."
echo

python manage.py runserver 0.0.0.0:8000

