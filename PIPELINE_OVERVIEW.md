# Pipeline CI/CD - Vue d'ensemble

## 📊 Workflow Complet

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         GIT PUSH (main branch)                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         STAGE 1: LINT (CI)                              │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │
│  │   Python     │  │  Dockerfile  │  │   Security   │                 │
│  │   Linting    │  │   Linting    │  │   Scanner    │                 │
│  │  (flake8)    │  │  (hadolint)  │  │(safety/bandit)│                 │
│  └──────────────┘  └──────────────┘  └──────────────┘                 │
│       ✓                  ✓                  ✓                           │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         STAGE 2: TEST (CI)                              │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │
│  │     Auth     │  │ Transaction  │  │    Fraud     │  │    ML    │  │
│  │   Service    │  │   Service    │  │  Detection   │  │  Model   │  │
│  │    Tests     │  │    Tests     │  │    Tests     │  │  Tests   │  │
│  │  (pytest)    │  │  (pytest)    │  │  (pytest)    │  │(unittest)│  │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────┘  │
│       ✓                  ✓                  ✓                ✓         │
│    Coverage           Coverage           Coverage                      │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    STAGE 3: INTEGRATION (CI)                            │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │           API Integration Tests                                 │  │
│  │  • Service-to-service communication                            │  │
│  │  • Database connectivity                                        │  │
│  │  • End-to-end workflows                                         │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                              ✓                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                          ┌─────────┴─────────┐
                          │   All Tests Pass? │
                          └─────────┬─────────┘
                                    │ YES
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      STAGE 4: BUILD (CD)                                │
├─────────────────────────────────────────────────────────────────────────┤
│  🐳 Docker Image Building                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │
│  │     Auth     │  │ Transaction  │  │    Fraud     │  │ Frontend │  │
│  │   Service    │  │   Service    │  │  Detection   │  │  (React) │  │
│  │   Image      │  │    Image     │  │    Image     │  │   Image  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────┘  │
│       ✓                  ✓                  ✓                ✓         │
│  🏷️ Tagged for Kubernetes                                              │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     STAGE 5: DEPLOY (CD)                                │
├─────────────────────────────────────────────────────────────────────────┤
│  ☸️ Kubernetes Deployment                                               │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  1. Apply namespace                                             │  │
│  │  2. Apply secrets (PostgreSQL credentials)                      │  │
│  │  3. Apply configmap (service URLs)                              │  │
│  │  4. Deploy PostgreSQL                                           │  │
│  │  5. Deploy Auth Service                                         │  │
│  │  6. Deploy Transaction Service                                  │  │
│  │  7. Deploy Fraud Detection Service                              │  │
│  │  8. Deploy Frontend                                             │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                              ✓                                          │
│  📊 Rollout Status Verification                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     STAGE 6: SMOKE TESTS (CD)                           │
├─────────────────────────────────────────────────────────────────────────┤
│  🧪 Post-Deployment Validation                                          │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  • Auth Service health check (http://localhost:8000)           │  │
│  │  • Transaction Service health check (http://localhost:8001)    │  │
│  │  • Fraud Detection health check (http://localhost:8002)        │  │
│  │  • Frontend accessibility (http://localhost:3000)              │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                              ✓                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                          ┌─────────────────┐
                          │  ✅ DEPLOYMENT   │
                          │    SUCCESSFUL   │
                          └─────────────────┘
```

---

## 🔄 Types de Pipelines

### 1. **Push sur main** → Pipeline Complet
```
lint → test → integration → build → deploy → smoke
```
- Tous les stages s'exécutent
- Déploiement automatique sur Kubernetes
- Tests de fumée pour validation

### 2. **Merge Request** → Pipeline CI uniquement
```
lint → test → integration
```
- Pas de build ni de déploiement
- Validation de la qualité du code
- Tests automatiques

### 3. **Push sur develop** → Tests + Déploiement local
```
lint → test → deploy:local
```
- Tests de qualité
- Déploiement sur environnement local
- Pas de déploiement Kubernetes

---

## 📈 Métriques et Rapports

### Artifacts générés
- **Coverage Reports** : Rapports HTML de couverture de code (1 semaine)
- **Test Results** : Résultats détaillés des tests
- **Docker Images** : Images taguées pour Kubernetes

### Badges disponibles
- 🟢 **Pipeline Status** : État du dernier pipeline
- 📊 **Coverage** : Pourcentage de couverture de code
- 🔒 **Security** : Résultats des scans de sécurité

---

## ⚙️ Configuration

### Variables d'environnement GitLab CI
```yaml
DOCKER_DRIVER: overlay2
PYTHON_VERSION: "3.9"
AUTH_IMAGE: fraud-detection-auth:latest
TRANSACTION_IMAGE: fraud-detection-transaction:latest
FRAUD_IMAGE: fraud-detection-ml:latest
FRONTEND_IMAGE: fraud-detection-frontend:latest
```

### Secrets Kubernetes (configurés dans secrets.yaml)
- `postgres-password` : Mot de passe PostgreSQL

### Tags du Runner
- `windows` : Exécution sur Windows
- `local` : Runner local
- `shell` : Exécuteur shell PowerShell
- `saas-linux-small-amd64` : Runner SaaS GitLab (pour tests)

---

## 🎯 Points de Contrôle Qualité

### CI (Continuous Integration)
- ✅ Pas d'erreurs de syntaxe (lint)
- ✅ Pas de vulnérabilités critiques (security)
- ✅ Tous les tests unitaires passent (test)
- ✅ Couverture de code > 70% (recommandé)
- ✅ Tests d'intégration réussis (integration)

### CD (Continuous Deployment)
- ✅ Images Docker construites avec succès
- ✅ Tous les manifestes Kubernetes appliqués
- ✅ Tous les pods en état Running (1/1 Ready)
- ✅ Tous les services répondent (smoke tests)

---

## 🚨 Gestion des Échecs

### Si un stage échoue

1. **Lint fails** → Pipeline s'arrête
   - Corriger les problèmes de qualité de code
   - Re-push après correction

2. **Tests fail** → Pipeline s'arrête
   - Analyser les logs de tests
   - Corriger les bugs
   - Re-push après correction

3. **Build fails** → CD n'est pas exécuté
   - Vérifier les Dockerfiles
   - Vérifier Docker Desktop
   - Re-lancer le pipeline

4. **Deploy fails** → Smoke tests non exécutés
   - Vérifier Kubernetes cluster
   - Vérifier les manifestes
   - Rollback possible manuellement

5. **Smoke tests fail** → Warning uniquement
   - Les services sont déployés mais potentiellement non fonctionnels
   - Vérifier les logs des pods
   - Redéploiement possible

---

## 🔧 Maintenance du Pipeline

### Mise à jour des tests
```bash
# Ajouter des tests dans les fichiers
auth_service/tests.py
transaction_service/tests.py
fraud_detection_service/tests.py

# Push → Les tests sont automatiquement exécutés
git push gitlab main
```

### Mise à jour des images Docker
```bash
# Modifier les Dockerfiles
# Push → Les images sont automatiquement reconstruites
git push gitlab main
```

### Mise à jour de la configuration Kubernetes
```bash
# Modifier les manifestes k8s/
# Push → Déploiement automatique avec les nouvelles configs
git push gitlab main
```

---

## 📞 Support et Dépannage

### Logs du Pipeline
```bash
# Voir sur GitLab
https://gitlab.com/Azaziop/systeme_detect_fraude/-/pipelines

# Logs détaillés de chaque job disponibles
```

### Vérification locale
```powershell
# Reproduire le pipeline localement
.\ci_cd_deploy_k8s.ps1

# Tests unitaires
cd auth_service
pytest --cov=.

# Lint
flake8 auth_service transaction_service fraud_detection_service
```

---

**Dernière mise à jour** : 4 décembre 2025  
**Version du pipeline** : 2.0 (CI/CD complet)
