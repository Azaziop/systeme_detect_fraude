FROM python:3.9-slim

WORKDIR /app

# Copier les requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code du service
COPY . .

# Exposer le port
EXPOSE 8001

# Commande de démarrage par défaut (peut être overridé pour Celery)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
