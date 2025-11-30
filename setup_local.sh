#!/bin/bash

echo "========================================"
echo "  Installation Locale (Sans Docker)"
echo "========================================"
echo

# Vérifier Python
if ! command -v python3 &> /dev/null; then
    echo "[ERREUR] Python 3 n'est pas installé."
    exit 1
fi

echo "[1/4] Installation Auth Service..."
cd auth_service
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
cd ..

echo
echo "[2/4] Installation Transaction Service..."
cd transaction_service
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
cd ..

echo
echo "[3/4] Installation Fraud Detection Service..."
cd fraud_detection_service
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
cd ..

echo
echo "[4/4] Vérification du modèle ML..."
if [ ! -f "ml_model/models/isolation_forest_model.pkl" ]; then
    echo "Le modèle n'existe pas. Entraînement..."
    cd ml_model
    pip install -r requirements.txt
    python train_model.py
    cd ..
fi

echo
echo "========================================"
echo "  Installation terminée!"
echo "========================================"
echo
echo "Pour lancer les services:"
echo "  ./start_auth.sh"
echo "  ./start_transaction.sh"
echo "  ./start_fraud_detection.sh"
echo "  ./start_celery.sh (optionnel)"
echo

