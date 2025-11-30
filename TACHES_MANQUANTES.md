# Tâches Manquantes à Implémenter

## 🔴 Priorité Haute

### 1. FDS-16 : Implémenter JWT au lieu de Token Authentication

**Fichiers à modifier :**
- `auth_service/users/views.py`
- `auth_service/auth_service/settings.py`
- `auth_service/requirements.txt`

**Actions :**
- Installer `djangorestframework-simplejwt`
- Configurer JWT dans settings.py
- Modifier les vues pour utiliser JWT

### 2. FDS-10 : Configurer PostgreSQL

**Fichiers à modifier :**
- `auth_service/auth_service/settings.py`
- `docker-compose.yml` (ajouter service PostgreSQL)

**Actions :**
- Ajouter psycopg2 dans requirements.txt
- Configurer DATABASES pour PostgreSQL
- Créer service PostgreSQL dans docker-compose

### 3. FDS-28 : Créer un modèle Transaction avec base de données

**Fichiers à créer/modifier :**
- `transaction_service/models.py` (nouveau)
- `transaction_service/database.py` (nouveau)
- `transaction_service/main.py` (modifier)

**Actions :**
- Créer modèle Transaction avec SQLAlchemy
- Configurer base de données (SQLite ou PostgreSQL)
- Migrer le stockage en mémoire vers la base de données

### 4. FDS-31 & FDS-32 : Configurer Celery pour tâches asynchrones

**Fichiers à créer/modifier :**
- `transaction_service/celery_app.py` (nouveau)
- `transaction_service/tasks.py` (nouveau)
- `transaction_service/main.py` (modifier)
- `docker-compose.yml` (ajouter Redis et Celery worker)

**Actions :**
- Installer Celery et Redis
- Créer l'application Celery
- Créer tâche asynchrone pour vérification fraude
- Configurer Redis dans docker-compose

---

## 🟡 Priorité Moyenne

### 5. FDS-1 : Ajouter notebook Jupyter pour exploration

**Fichiers à créer :**
- `ml_model/exploration.ipynb`

**Actions :**
- Créer notebook pour exploration des données
- Ajouter visualisations
- Documenter les insights

### 6. FDS-3 : Améliorer l'analyse et exploration des données

**Fichiers à modifier :**
- `ml_model/train_model.py`

**Actions :**
- Ajouter analyse statistique détaillée
- Visualisations des distributions
- Analyse du déséquilibre des classes

### 7. FDS-11 : Configurer Redis pour le cache

**Fichiers à modifier :**
- `auth_service/auth_service/settings.py`
- `docker-compose.yml`

**Actions :**
- Installer django-redis
- Configurer cache Redis
- Ajouter service Redis dans docker-compose

### 8. FDS-18 : Créer des tests unitaires complets

**Fichiers à créer :**
- `auth_service/users/tests.py`
- `transaction_service/tests.py`
- `fraud_detection_service/tests.py`

**Actions :**
- Tests pour tous les endpoints
- Tests de validation
- Tests d'intégration

### 9. FDS-19 : Ajouter documentation Swagger pour Django

**Fichiers à modifier :**
- `auth_service/auth_service/settings.py`
- `auth_service/auth_service/urls.py`

**Actions :**
- Installer drf-yasg ou drf-spectacular
- Configurer Swagger
- Ajouter annotations aux vues

### 10. FDS-26 : Ajouter monitoring Prometheus/Grafana

**Fichiers à créer :**
- `monitoring/prometheus.yml`
- `monitoring/grafana/`
- Modifier `docker-compose.yml`

**Actions :**
- Ajouter métriques Prometheus aux services
- Configurer Grafana dashboards
- Ajouter services dans docker-compose

### 11. FDS-34 : Tests de workflow complet

**Fichiers à créer :**
- `tests/integration_tests.py`

**Actions :**
- Tests end-to-end du flux complet
- Tests de scénarios réels
- Tests de performance

---

## 🟢 Priorité Basse

### 12. FDS-27 : Migrer Transaction Service vers Django (optionnel)

**Note :** Le service utilise actuellement FastAPI, ce qui est fonctionnel. La migration vers Django n'est nécessaire que si spécifiquement requis.

---

## Plan d'Implémentation Recommandé

### Phase 1 : Infrastructure (Semaine 1)
1. Configurer PostgreSQL (FDS-10)
2. Configurer Redis (FDS-11)
3. Créer modèle Transaction (FDS-28)

### Phase 2 : Authentification (Semaine 1-2)
4. Implémenter JWT (FDS-16)
5. Tests unitaires Auth (FDS-18)
6. Documentation Swagger (FDS-19)

### Phase 3 : Transactions Asynchrones (Semaine 2)
7. Configurer Celery (FDS-31)
8. Tâche Celery pour fraude (FDS-32)
9. Tests workflow (FDS-34)

### Phase 4 : Amélioration ML (Semaine 3)
10. Notebook Jupyter (FDS-1)
11. Améliorer analyse (FDS-3)
12. Monitoring (FDS-26)

