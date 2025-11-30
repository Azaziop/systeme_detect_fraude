#!/bin/bash
# Script pour entraîner le modèle ML

echo "=== Entraînement du Modèle de Détection de Fraude ==="

cd ml_model

# Créer un environnement virtuel si nécessaire
if [ ! -d "venv" ]; then
    echo "Création de l'environnement virtuel..."
    python3 -m venv venv
fi

# Activer l'environnement virtuel
source venv/bin/activate

# Installer les dépendances
echo "Installation des dépendances..."
pip install -r requirements.txt

# Entraîner le modèle
echo "Entraînement du modèle..."
python train_model.py

echo "=== Entraînement terminé ==="

