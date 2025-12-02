# Interprétation des Probabilités de Détection de Fraude

## Comment fonctionne l'interprétation

Dans un modèle Random Forest pour la détection de fraude :

### Classes standard (sklearn)

Le modèle est généralement entraîné avec :
- **Classe 0** = Transaction normale
- **Classe 1** = Transaction frauduleuse

### Probabilités retournées

Quand le modèle fait une prédiction avec `predict_proba()`, il retourne un tableau de probabilités :

```python
proba = model.predict_proba(features)[0]
# proba = [prob_classe_0, prob_classe_1]
```

**Interprétation :**
- `proba[0]` = Probabilité d'être **classe 0 (NORMAL)**
- `proba[1]` = Probabilité d'être **classe 1 (FRAUDE)**

### Probabilité de fraude (fraud_probability)

Le code utilise `proba[1]` comme **probabilité de fraude** :

```python
fraud_probability = proba[1]  # Probabilité d'être fraude
```

**Cela signifie :**
- `fraud_probability = 0.00` → 0% de chance d'être fraude → **TRANSACTION NORMALE** ✅
- `fraud_probability = 0.50` → 50% de chance d'être fraude → **INCERTAIN**
- `fraud_probability = 1.00` → 100% de chance d'être fraude → **TRANSACTION FRAUDULEUSE** ⚠️

### Décision finale

La décision est prise en comparant `fraud_probability` avec le seuil `FRAUD_THRESHOLD` :

```python
is_fraud = fraud_probability >= FRAUD_THRESHOLD
```

**Exemples avec FRAUD_THRESHOLD = 0.03 :**
- `fraud_probability = 0.00` → `0.00 >= 0.03` → **False** → Transaction normale ✅
- `fraud_probability = 0.02` → `0.02 >= 0.03` → **False** → Transaction normale ✅
- `fraud_probability = 0.05` → `0.05 >= 0.03` → **True** → Transaction frauduleuse ⚠️
- `fraud_probability = 1.00` → `1.00 >= 0.03` → **True** → Transaction frauduleuse ⚠️

## Résumé

✅ **CORRECT** : `fraud_probability = 0.00` → Normal, `fraud_probability = 1.00` → Fraude

C'est exactement ce que fait le code actuel !

## Vérification

Pour vérifier comment votre modèle interprète les classes, vous pouvez utiliser :

```bash
cd ml_model
python verifier_interpretation.py
```

Ce script va :
1. Charger votre modèle
2. Tester avec différentes transactions
3. Afficher les probabilités retournées
4. Expliquer l'interprétation

## Si votre modèle a les classes inversées

Si votre modèle a été entraîné avec les classes inversées (0 = fraude, 1 = normal), vous pouvez activer l'inversion :

**Sur Windows :**
```powershell
$env:INVERT_CLASSES="true"
```

**Sur Linux/Mac :**
```bash
export INVERT_CLASSES=true
```

**Dans docker-compose.yml :**
```yaml
environment:
  - INVERT_CLASSES=true
```

## Exemples concrets

### Exemple 1 : Transaction normale

```python
proba = [0.95, 0.05]  # 95% normal, 5% fraude
fraud_probability = proba[1] = 0.05
is_fraud = 0.05 >= 0.03 → True (détectée comme fraude si seuil bas)
```

### Exemple 2 : Transaction très normale

```python
proba = [0.99, 0.01]  # 99% normal, 1% fraude
fraud_probability = proba[1] = 0.01
is_fraud = 0.01 >= 0.03 → False (détectée comme normale)
```

### Exemple 3 : Transaction frauduleuse

```python
proba = [0.10, 0.90]  # 10% normal, 90% fraude
fraud_probability = proba[1] = 0.90
is_fraud = 0.90 >= 0.03 → True (détectée comme fraude)
```

### Exemple 4 : Transaction très frauduleuse

```python
proba = [0.00, 1.00]  # 0% normal, 100% fraude
fraud_probability = proba[1] = 1.00
is_fraud = 1.00 >= 0.03 → True (détectée comme fraude)
```

## Ajustement du seuil

Le seuil par défaut est `0.03` (3%), ce qui signifie qu'une transaction avec 3% ou plus de probabilité d'être fraude sera considérée comme suspecte.

Vous pouvez l'ajuster :

**Seuil plus bas (plus sensible, plus de fraudes détectées) :**
```bash
export FRAUD_THRESHOLD=0.01  # 1%
```

**Seuil plus élevé (moins sensible, moins de faux positifs) :**
```bash
export FRAUD_THRESHOLD=0.10  # 10%
```

## Conclusion

Le code actuel interprète correctement les probabilités :
- **0.00 = Normal** ✅
- **1.00 = Fraude** ✅

Si vous observez un comportement différent, utilisez `verifier_interpretation.py` pour diagnostiquer le problème.
