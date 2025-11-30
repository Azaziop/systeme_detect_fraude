# Correction - Celery Optionnel

## Problème
Erreur : `ModuleNotFoundError: No module named 'celery'`

## Solution Appliquée
Celery est maintenant **optionnel**. Le service fonctionne avec ou sans Celery :

- **Avec Celery** : Traitement asynchrone (meilleur pour production)
- **Sans Celery** : Traitement synchrone (parfait pour les tests)

## Comportement

Le service détecte automatiquement si Celery est disponible :
- Si Celery est installé → Utilise le traitement asynchrone
- Si Celery n'est pas installé → Utilise le traitement synchrone direct

## Installation Optionnelle de Celery

Si vous voulez utiliser Celery (optionnel) :

```powershell
pip install celery redis
```

Puis lancez un worker Celery dans un terminal séparé :
```powershell
cd transaction_service
celery -A celery_app worker --loglevel=info
```

## Test Sans Celery

Le service fonctionne parfaitement sans Celery. Vous pouvez tester immédiatement :

```powershell
.\start_transaction_simple.bat
```

Le service utilisera la vérification synchrone directe, ce qui est parfait pour les tests.

