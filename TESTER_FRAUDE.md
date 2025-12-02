# Guide Rapide : Tester une Transaction Frauduleuse

## 📋 Étapes pour tester

### 1. Démarrer le service de détection de fraude

**Option A : Directement avec Python**
```powershell
cd fraud_detection_service
uvicorn main:app --host 0.0.0.0 --port 8002
```

**Option B : Avec Docker**
```powershell
docker-compose up fraud-detection-service
```

### 2. Lancer le test

Dans un **nouveau terminal** (laissez le service tourner dans le premier) :

```powershell
cd c:\Users\zaoui\OneDrive\Desktop\detec_fraude
python test_fraude_simple.py
```

## 📊 Résultat attendu

Le script va tester deux transactions :

1. **Transaction frauduleuse** :
   - Valeurs extrêmes (V1-V28 entre -10 et 10)
   - Montant élevé (10000)
   - **Devrait être détectée comme fraude** si score > 50%

2. **Transaction normale** :
   - Valeurs normales (V1-V28 proches de 0)
   - Montant normal (150)
   - **Devrait être identifiée comme normale**

## ✅ Exemple de sortie

```
======================================================================
  TEST TRANSACTION FRAUDULEUSE
======================================================================

📤 Envoi de la transaction suspecte...
   Montant: 10000.0

✅ Analyse réussie!

📊 RÉSULTATS:
   Transaction ID: TXN_FRAUDE_TEST_001
   Est Fraude: True
   Score de Fraude: 0.8500 (85.00%)

🚨 FRAUDE DÉTECTÉE!
   ✅ Le système fonctionne correctement!
```

## ⚠️ Si le service n'est pas démarré

Vous verrez cette erreur :
```
❌ Impossible de se connecter au service
```

**Solution** : Assurez-vous que le service tourne sur `http://localhost:8002`

## 🔧 Si le score est < 50%

Si la transaction n'est pas détectée comme fraude même avec des valeurs extrêmes :

1. **Vérifiez le seuil** dans `fraud_detection_service/main.py` (ligne 40)
   - Doit être à `0.50` (50%) par défaut

2. **Testez avec un seuil plus bas temporairement** :
   ```powershell
   $env:FRAUD_THRESHOLD="0.30"
   python test_fraude_simple.py
   ```

3. **Les valeurs peuvent ne pas être assez suspectes** pour votre modèle spécifique
