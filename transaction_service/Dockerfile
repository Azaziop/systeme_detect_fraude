# Use slim image but install build deps required by some DB drivers
FROM python:3.9-slim

WORKDIR /app

# Installer dépendances système (gcc + libpq pour psycopg2 if wheel not available)
RUN apt-get update && apt-get install -y \
	gcc \
	libpq-dev \
	&& rm -rf /var/lib/apt/lists/*

# Copier les requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code du service
COPY . .

# Exposer le port
EXPOSE 8001

# Commande de démarrage par défaut (peut être overridé pour Celery)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
