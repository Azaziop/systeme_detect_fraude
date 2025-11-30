# Corrections Appliquées

## Problèmes Résolus

### 1. ✅ Auth Service - Conflit de related_name
**Problème** : Conflit entre le modèle User personnalisé et le modèle User de Django auth.

**Solution** : Ajout de `related_name='custom_user_set'` pour les champs `groups` et `user_permissions` dans le modèle User.

**Fichiers modifiés** :
- `auth_service/users/models.py`
- `auth_service/users/migrations/0002_fix_related_names.py` (nouvelle migration)

### 2. ✅ Transaction Service - Module numpy manquant
**Problème** : `ModuleNotFoundError: No module named 'numpy'`

**Solution** : Ajout de `numpy==1.24.3` dans `transaction_service/requirements.txt`

**Fichier modifié** :
- `transaction_service/requirements.txt`

### 3. ✅ Fraud Detection Service - Chemin du modèle incorrect
**Problème** : `FileNotFoundError: Modèle non trouvé: /ml_model/models/isolation_forest_model.pkl`

**Solution** : Correction du chemin pour utiliser `/app/ml_model/models` (où le volume est monté) avec fallback pour le développement local.

**Fichier modifié** :
- `fraud_detection_service/main.py`

## Comment Appliquer les Corrections

### Option 1 : Script automatique
```powershell
.\fix_issues.bat
```

### Option 2 : Manuellement

1. **Arrêter les services** :
```powershell
docker-compose down
```

2. **Vérifier que le modèle ML existe** :
```powershell
dir ml_model\models\isolation_forest_model.pkl
```

Si le fichier n'existe pas, entraînez le modèle :
```powershell
.\train_model_simple.bat
```

3. **Reconstruire les images** :
```powershell
docker-compose build --no-cache
```

4. **Redémarrer les services** :
```powershell
docker-compose up -d
```

5. **Vérifier les logs** :
```powershell
docker-compose logs -f
```

## Vérification

Après redémarrage, vérifiez que tous les services fonctionnent :

```powershell
# Vérifier l'état des conteneurs
docker-compose ps

# Tester les endpoints
curl http://localhost:8000/api/users/
curl http://localhost:8001/health
curl http://localhost:8002/health
```

Tous les services devraient répondre avec un statut 200.

## Si les Problèmes Persistent

1. **Supprimer les volumes Docker** :
```powershell
docker-compose down -v
```

2. **Nettoyer les images** :
```powershell
docker-compose build --no-cache --pull
```

3. **Vérifier que le modèle ML est bien entraîné** :
```powershell
dir ml_model\models\
```

Vous devriez voir :
- `isolation_forest_model.pkl`
- `scaler.pkl`
- `feature_columns.json`

4. **Relancer** :
```powershell
docker-compose up -d
```

