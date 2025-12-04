FROM python:3.9-slim

WORKDIR /app

# Installer les dépendances système (gcc + libpq-dev pour psycopg2-binary compatibility)
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copier les requirements
COPY auth_service/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code du service
COPY auth_service . .

# Script de démarrage
COPY auth_service/start.sh .
RUN chmod +x start.sh
# Remove potential Windows CRLF line endings that break shell execution in image
RUN sed -i 's/\r$//' start.sh || true

# Exposer le port
EXPOSE 8000

# Commande de démarrage
CMD ["sh", "start.sh"]

