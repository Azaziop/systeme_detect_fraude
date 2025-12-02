# Explication : Score Multiplié par 10

## Situation Actuelle

Après multiplication par 10 :
- **Score affiché** : 0.6000 (60%)
- **Score original du modèle** : 0.06 (6%)

## Problème

Avec un score de **0.6000**, la transaction n'est **pas détectée** comme fraude.

## Solution

Le seuil de détection doit être ajusté pour correspondre au score multiplié par 10.

### Option 1 : Seuil divisé par 10

Si vous voulez que le seuil reste à 50% (0.50), mais que cela corresponde à un score original de 5% :
- Seuil pour comparaison : `FRAUD_THRESHOLD / 10.0`
- Exemple : 0.50 / 10 = 0.05
- Donc un score de 0.60 >= 0.05 → **fraude détectée**

### Option 2 : Seuil utilisé tel quel (actuel)

Avec le seuil actuel de 0.50 :
- Score : 0.60
- Seuil : 0.50
- Comparaison : 0.60 >= 0.50 → **fraude détectée**

Si cela ne fonctionne pas, vérifiez :
1. ✅ Le service a été redémarré après modification
2. ✅ Le seuil utilisé n'est pas différent (variable d'environnement)

## Recommandation

Pour que votre transaction de **222 222 222 €** avec un score de **0.60** soit détectée comme fraude, vous avez deux options :

### Option A : Utiliser le seuil divisé par 10
```python
is_fraud = fraud_score >= (FRAUD_THRESHOLD / 10.0)
```
- Seuil 0.50 devient 0.05
- Score 0.60 >= 0.05 → fraude détectée ✅

### Option B : Utiliser un seuil plus bas directement
Ajustez la variable d'environnement :
```bash
FRAUD_THRESHOLD=0.05
```
- Seuil : 0.05
- Score 0.60 >= 0.05 → fraude détectée ✅

## Pour Redémarrer le Service

```powershell
# Arrêtez le service (Ctrl+C dans le terminal où il tourne)
# Puis redémarrez :
cd fraud_detection_service
uvicorn main:app --host 0.0.0.0 --port 8002
```
