#!/bin/bash

echo "========================================"
echo "  Démarrage du Système de Détection de Fraude"
echo "========================================"
echo

# Vérifier si Docker est en cours d'exécution
if ! docker info > /dev/null 2>&1; then
    echo "[ERREUR] Docker n'est pas démarré ou n'est pas accessible."
    echo "Veuillez démarrer Docker et réessayer."
    exit 1
fi

echo "[1/3] Vérification du modèle ML..."
if [ ! -f "ml_model/models/isolation_forest_model.pkl" ]; then
    echo "Le modèle n'existe pas. Entraînement en cours..."
    cd ml_model
    pip install -r requirements.txt
    python train_model.py
    cd ..
    if [ $? -ne 0 ]; then
        echo "[ERREUR] Échec de l'entraînement du modèle."
        exit 1
    fi
    echo "[OK] Modèle entraîné avec succès!"
else
    echo "[OK] Modèle déjà présent."
fi

echo
echo "[2/3] Construction des images Docker..."
docker-compose build
if [ $? -ne 0 ]; then
    echo "[ERREUR] Échec de la construction des images."
    exit 1
fi
echo "[OK] Images construites avec succès!"

echo
echo "[3/3] Démarrage des services..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "[ERREUR] Échec du démarrage des services."
    exit 1
fi

echo
echo "========================================"
echo "  Services démarrés avec succès!"
echo "========================================"
echo
echo "Services disponibles:"
echo "  - Auth Service:        http://localhost:8000"
echo "  - Transaction Service:  http://localhost:8001"
echo "  - Fraud Detection:      http://localhost:8002"
echo
echo "Pour voir les logs: docker-compose logs -f"
echo "Pour arrêter: docker-compose down"

