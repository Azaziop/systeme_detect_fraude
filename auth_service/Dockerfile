FROM python:3.9-slim

WORKDIR /app

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copier les requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code du service
COPY . .

# Script de démarrage
COPY start.sh .
RUN chmod +x start.sh

# Exposer le port
EXPOSE 8000

# Commande de démarrage
CMD ["./start.sh"]

