.PHONY: help train build up down logs test clean

help: ## Affiche cette aide
	@echo "Commandes disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

train: ## Entraîner le modèle ML
	cd ml_model && pip install -r requirements.txt && python train_model.py

build: ## Construire toutes les images Docker
	docker-compose build

up: ## Lancer tous les services avec Docker Compose
	docker-compose up -d

down: ## Arrêter tous les services
	docker-compose down

logs: ## Voir les logs de tous les services
	docker-compose logs -f

logs-auth: ## Voir les logs du service d'authentification
	docker-compose logs -f auth-service

logs-transaction: ## Voir les logs du service de transaction
	docker-compose logs -f transaction-service

logs-fraud: ## Voir les logs du service de détection de fraude
	docker-compose logs -f fraud-detection-service

test: ## Tester les services
	python example_usage.py

clean: ## Nettoyer les fichiers temporaires et volumes Docker
	docker-compose down -v
	find . -type d -name __pycache__ -exec rm -r {} +
	find . -type f -name "*.pyc" -delete

rebuild: clean build up ## Reconstruire et relancer tous les services

