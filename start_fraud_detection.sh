#!/bin/bash

echo "========================================"
echo "  Démarrage Fraud Detection Service"
echo "========================================"
echo

cd fraud_detection_service

if [ ! -d "venv" ]; then
    echo "[ERREUR] Environnement virtuel non trouvé."
    echo "Exécutez d'abord: ./setup_local.sh"
    exit 1
fi

source venv/bin/activate

# Vérifier que le modèle existe
if [ ! -f "../ml_model/models/isolation_forest_model.pkl" ]; then
    echo "[ERREUR] Modèle ML non trouvé."
    echo "Entraînez d'abord le modèle: cd ml_model && python train_model.py"
    exit 1
fi

echo "Démarrage du serveur sur http://localhost:8002"
echo "Swagger: http://localhost:8002/docs"
echo
echo "Appuyez sur Ctrl+C pour arrêter."
echo

uvicorn main:app --host 0.0.0.0 --port 8002 --reload

