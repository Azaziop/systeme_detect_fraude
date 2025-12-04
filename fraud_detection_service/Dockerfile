FROM python:3.9-slim

WORKDIR /app

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copier les requirements
COPY fraud_detection_service/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code du service
COPY fraud_detection_service/main.py .

# Créer les répertoires pour les modèles
RUN mkdir -p /app/ml_model/models

# Copier les modèles ML
COPY ml_model/models/random_forest_model.pkl /app/ml_model/models/

# Exposer le port
EXPOSE 8002

# Commande de démarrage
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002"]
