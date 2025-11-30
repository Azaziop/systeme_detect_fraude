# Structure du Projet

```
detec_fraude/
│
├── ml_model/                          # Modèle ML
│   ├── train_model.py                 # Script d'entraînement
│   ├── requirements.txt               # Dépendances Python
│   ├── models/                        # Modèles sauvegardés (générés)
│   │   ├── .gitkeep
│   │   ├── isolation_forest_model.pkl # Modèle entraîné
│   │   ├── scaler.pkl                 # Scaler pour normalisation
│   │   └── feature_columns.json       # Noms des colonnes
│   └── README.md                      # Documentation du modèle
│
├── auth_service/                      # Service d'authentification (Django)
│   ├── manage.py                      # Script Django
│   ├── Dockerfile                     # Image Docker
│   ├── start.sh                       # Script de démarrage
│   ├── requirements.txt               # Dépendances Python
│   ├── auth_service/                  # Configuration Django
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── users/                         # App utilisateurs
│   │   ├── models.py                  # Modèle User
│   │   ├── views.py                   # Vues API
│   │   ├── serializers.py             # Serializers
│   │   ├── urls.py                    # Routes API
│   │   └── migrations/                # Migrations DB
│   └── README.md                      # Documentation
│
├── transaction_service/               # Service de transaction (FastAPI)
│   ├── main.py                        # Application FastAPI
│   ├── Dockerfile                     # Image Docker
│   ├── requirements.txt               # Dépendances Python
│   └── README.md                      # Documentation
│
├── fraud_detection_service/         # Service de détection (FastAPI)
│   ├── main.py                        # Application FastAPI
│   ├── Dockerfile                     # Image Docker
│   ├── requirements.txt               # Dépendances Python
│   └── README.md                      # Documentation
│
├── k8s/                              # Configurations Kubernetes
│   ├── namespace.yaml                 # Namespace
│   ├── configmap.yaml                 # Configuration
│   ├── secrets.yaml                   # Secrets
│   ├── auth-service-deployment.yaml   # Déploiement auth
│   ├── transaction-service-deployment.yaml
│   ├── fraud-detection-service-deployment.yaml
│   ├── ingress.yaml                   # Ingress
│   └── README.md                      # Guide Kubernetes
│
├── scripts/                          # Scripts utilitaires
│   ├── train_model.sh                 # Entraîner le modèle
│   ├── build_images.sh                # Construire les images
│   └── test_services.sh               # Tester les services
│
├── docker-compose.yml                 # Orchestration Docker
├── Makefile                           # Commandes simplifiées
├── example_usage.py                   # Exemples d'utilisation
├── README.md                          # Documentation principale
├── DEPLOYMENT.md                      # Guide de déploiement
└── .gitignore                         # Fichiers ignorés par Git
```

## Flux de Données

1. **Utilisateur** → `auth-service` (Django) : Authentification
2. **Transaction** → `transaction-service` (FastAPI) : Capture transaction
3. **Transaction** → `fraud-detection-service` (FastAPI) : Analyse ML
4. **Résultat** → `transaction-service` : Retour du statut (APPROVED/BLOCKED)

## Ports

- **8000**: Auth Service (Django)
- **8001**: Transaction Service (FastAPI)
- **8002**: Fraud Detection Service (FastAPI)

## Technologies

- **ML**: scikit-learn, Isolation Forest
- **Auth**: Django REST Framework
- **API**: FastAPI
- **Containerisation**: Docker, Docker Compose
- **Orchestration**: Kubernetes (GKE/AKS)

