# Guide GitLab CI/CD

## 📋 Vue d'Ensemble

Le fichier `.gitlab-ci.yml` configure un pipeline CI/CD avec deux stages principaux :
1. **test** : Exécute les tests avec pytest
2. **deploy** : Crée et pousse les images Docker vers le Registry GitLab

## 🔧 Configuration Requise

### Variables GitLab CI/CD

Le pipeline utilise automatiquement ces variables GitLab :
- `CI_REGISTRY` : URL du registry Docker GitLab
- `CI_REGISTRY_USER` : Utilisateur pour se connecter au registry
- `CI_REGISTRY_PASSWORD` : Token pour se connecter au registry
- `CI_REGISTRY_IMAGE` : Image de base pour le registry (auto-généré)

Ces variables sont automatiquement disponibles dans GitLab CI/CD.

## 🧪 Stage: TEST

### Jobs de Test

1. **test:auth** : Test du service Django d'authentification
   - Utilise PostgreSQL en service
   - Exécute les migrations
   - Lance pytest avec couverture de code

2. **test:transaction** : Test du service FastAPI de transaction
   - Installe les dépendances
   - Lance pytest

3. **test:fraud-detection** : Test du service FastAPI de détection de fraude
   - Installe les dépendances
   - Lance pytest

4. **test:ml-model** : Test du modèle ML
   - Vérifie que le modèle peut être chargé
   - Teste les prédictions

5. **test:integration** : Tests d'intégration
   - Teste l'intégration entre les services

### Exécution des Tests

Les tests s'exécutent sur :
- Les merge requests
- La branche `main`
- La branche `develop`

## 🚀 Stage: DEPLOY

### Jobs de Déploiement

1. **deploy:auth-service** : Build et push de l'image Docker pour Auth Service
2. **deploy:transaction-service** : Build et push de l'image Docker pour Transaction Service
3. **deploy:fraud-detection-service** : Build et push de l'image Docker pour Fraud Detection Service

### Processus de Déploiement

Pour chaque service :
1. Se connecte au Registry GitLab Docker
2. Build l'image Docker avec deux tags :
   - `$CI_COMMIT_SHORT_SHA` : Tag avec le hash du commit
   - `latest` : Tag latest
3. Push les deux tags vers le registry

### Images Créées

Les images seront disponibles dans le registry GitLab :
- `$CI_REGISTRY_IMAGE/auth-service:latest`
- `$CI_REGISTRY_IMAGE/auth-service:$CI_COMMIT_SHORT_SHA`
- `$CI_REGISTRY_IMAGE/transaction-service:latest`
- `$CI_REGISTRY_IMAGE/transaction-service:$CI_COMMIT_SHORT_SHA`
- `$CI_REGISTRY_IMAGE/fraud-detection-service:latest`
- `$CI_REGISTRY_IMAGE/fraud-detection-service:$CI_COMMIT_SHORT_SHA`

## 📝 Utilisation

### 1. Pousser le Code

```bash
git add .gitlab-ci.yml
git commit -m "Add GitLab CI/CD pipeline"
git push origin main
```

### 2. Voir le Pipeline

1. Allez dans votre projet GitLab
2. Cliquez sur **CI/CD > Pipelines**
3. Vous verrez le pipeline en cours d'exécution

### 3. Voir les Logs

Cliquez sur un job pour voir les logs en temps réel.

### 4. Récupérer les Images Docker

Une fois le pipeline terminé, les images sont disponibles dans :
- **Packages & Registries > Container Registry**

Vous pouvez les utiliser avec :
```bash
docker pull $CI_REGISTRY_IMAGE/auth-service:latest
docker pull $CI_REGISTRY_IMAGE/transaction-service:latest
docker pull $CI_REGISTRY_IMAGE/fraud-detection-service:latest
```

## 🔍 Structure du Pipeline

```
Pipeline
├── Stage: test
│   ├── test:auth
│   ├── test:transaction
│   ├── test:fraud-detection
│   ├── test:ml-model
│   └── test:integration
│
└── Stage: deploy
    ├── deploy:auth-service
    ├── deploy:transaction-service
    └── deploy:fraud-detection-service
```

## ⚙️ Personnalisation

### Modifier les Branches

Pour changer les branches qui déclenchent le pipeline, modifiez la section `only:` :

```yaml
only:
  - main
  - develop
  - feature/*
```

### Ajouter des Variables d'Environnement

Dans GitLab, allez dans **Settings > CI/CD > Variables** et ajoutez :
- `DOCKER_REGISTRY_URL` : URL du registry
- `KUBERNETES_NAMESPACE` : Namespace Kubernetes
- etc.

### Ajouter un Stage de Déploiement Kubernetes

```yaml
deploy:k8s:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl apply -f k8s/
  only:
    - main
  when: manual
```

## 🐛 Dépannage

### Les tests échouent

- Vérifiez que les fichiers de test existent
- Vérifiez que pytest est dans les requirements
- Regardez les logs pour plus de détails

### Les builds Docker échouent

- Vérifiez que les Dockerfiles existent
- Vérifiez que le registry GitLab est accessible
- Vérifiez les permissions du runner

### Les images ne sont pas poussées

- Vérifiez que `CI_REGISTRY_USER` et `CI_REGISTRY_PASSWORD` sont définis
- Vérifiez les permissions du projet GitLab
- Vérifiez que le Container Registry est activé dans GitLab

## 📚 Ressources

- [Documentation GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [GitLab Container Registry](https://docs.gitlab.com/ee/user/packages/container_registry/)
- [Docker in Docker](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html)

---

**Le pipeline est prêt à être utilisé !** 🚀

