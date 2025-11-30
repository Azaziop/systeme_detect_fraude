# Système de Détection de Fraude en Temps Réel

Ce projet implémente un système complet de détection de fraude en temps réel avec microservices, conteneurisation Docker et déploiement Kubernetes.

## Architecture

Le système est composé de 3 services principaux :

1. **Service d'Authentification** (Django) - Gestion des utilisateurs et authentification
2. **Service de Transaction** (FastAPI) - Capture et envoi des transactions
3. **Service de Détection de Fraude** (FastAPI) - Analyse en temps réel avec modèle ML (Isolation Forest)

## Structure du Projet

```
detec_fraude/
├── ml_model/              # Modèle ML et préparation des données
├── auth_service/          # Service d'authentification (Django)
├── transaction_service/   # Service de transaction (FastAPI)
├── fraud_detection_service/ # Service de détection (FastAPI)
├── docker-compose.yml     # Orchestration Docker
└── k8s/                   # Configurations Kubernetes
```

## 🚀 Démarrage Rapide

**Pour démarrer rapidement, consultez le [Guide de Démarrage Rapide](QUICK_START.md)**

### Démarrage Automatique (Windows)
```bash
start.bat
```

### Démarrage Automatique (Linux/Mac)
```bash
chmod +x start.sh
./start.sh
```

## Prérequis

- Python 3.9+
- Docker & Docker Compose
- kubectl (pour Kubernetes - optionnel)
- Accès à GKE ou AKS (optionnel, pour le déploiement cloud)

## Installation Django (Développement Local)

Pour installer et utiliser Django localement sans Docker :

```powershell
# Installation complète automatique
.\setup_django_dev.bat

# Ou installation étape par étape
.\install_django.bat
.\run_django.bat
```

Voir [README_DJANGO.md](README_DJANGO.md) pour plus de détails.

## Installation et Utilisation

### Méthode 1: Avec Makefile (Recommandé)

```bash
# Entraîner le modèle ML
make train

# Construire et lancer tous les services
make build
make up

# Voir les logs
make logs

# Tester les services
make test

# Arrêter les services
make down
```

### Méthode 2: Commandes Manuelles

#### 1. Préparer le modèle ML

```bash
cd ml_model
pip install -r requirements.txt
python train_model.py
```

#### 2. Lancer avec Docker Compose

```bash
# Construire les images
docker-compose build

# Lancer les services
docker-compose up -d

# Voir les logs
docker-compose logs -f
```

#### 3. Déployer sur Kubernetes

Voir le guide complet dans [DEPLOYMENT.md](DEPLOYMENT.md)

```bash
# Appliquer les configurations
kubectl apply -f k8s/
```

## Services

- **Auth Service**: http://localhost:8000
  - API Docs: http://localhost:8000/api/
  - Admin: http://localhost:8000/admin/ (admin/admin123)
  
- **Transaction Service**: http://localhost:8001
  - API Docs: http://localhost:8001/docs
  
- **Fraud Detection Service**: http://localhost:8002
  - API Docs: http://localhost:8002/docs

## Tests

Un script d'exemple est fourni pour tester les services:

```bash
# Installer requests si nécessaire
pip install requests

# Lancer les tests
python example_usage.py
```

## Commandes Disponibles (Makefile)

```bash
make help          # Afficher toutes les commandes
make train         # Entraîner le modèle ML
make build         # Construire les images Docker
make up            # Lancer les services
make down          # Arrêter les services
make logs          # Voir les logs
make test          # Tester les services
make clean         # Nettoyer les fichiers temporaires
make rebuild       # Reconstruire et relancer
```

## Documentation

- [Guide de Déploiement](DEPLOYMENT.md) - Instructions détaillées pour le déploiement
- [Structure du Projet](PROJECT_STRUCTURE.md) - Vue d'ensemble de l'architecture
- [Service d'Authentification](auth_service/README.md)
- [Service de Transaction](transaction_service/README.md)
- [Service de Détection](fraud_detection_service/README.md)
- [Modèle ML](ml_model/README.md)
- [Kubernetes](k8s/README.md)

## Architecture

Le système suit une architecture microservices:

1. **Service d'Authentification** (Django REST Framework)
   - Gestion des utilisateurs
   - Authentification par token
   - API REST

2. **Service de Transaction** (FastAPI)
   - Capture des transactions
   - Communication avec le service de détection
   - Gestion du statut des transactions

3. **Service de Détection de Fraude** (FastAPI)
   - Analyse en temps réel avec Isolation Forest
   - Retour du score de fraude
   - API de détection

## Technologies Utilisées

- **Backend**: Python 3.9+
- **ML**: scikit-learn, Isolation Forest
- **Frameworks**: Django REST Framework, FastAPI
- **Containerisation**: Docker, Docker Compose
- **Orchestration**: Kubernetes (GKE/AKS)
- **Base de données**: SQLite (Django), en mémoire (FastAPI)

## Prochaines Étapes

- [ ] Ajouter une base de données PostgreSQL/MySQL
- [ ] Implémenter Redis pour le cache
- [ ] Ajouter des métriques Prometheus
- [ ] Configurer Grafana pour le monitoring
- [ ] Ajouter des tests unitaires et d'intégration
- [ ] Implémenter l'authentification JWT
- [ ] Ajouter la gestion des erreurs et retry logic

