# Guide : Environnement Virtuel Python

## 🤔 Qu'est-ce qu'un Environnement Virtuel ?

Un **environnement virtuel** (virtual environment) est un espace isolé où vous installez des packages Python spécifiques à un projet, sans affecter les autres projets ou votre installation Python globale.

### Analogie Simple
Imaginez que vous avez plusieurs projets :
- **Projet A** a besoin de la version 1.0 d'une bibliothèque
- **Projet B** a besoin de la version 2.0 de la même bibliothèque

Sans environnement virtuel, vous ne pouvez installer qu'une seule version globalement. Avec des environnements virtuels, chaque projet a sa propre "boîte" isolée avec ses propres versions.

## 📦 Pourquoi Utiliser un Environnement Virtuel ?

### ✅ Avantages

1. **Isolation** : Chaque projet a ses propres dépendances
2. **Pas de conflits** : Différentes versions de packages peuvent coexister
3. **Propreté** : Votre Python système reste propre
4. **Reproductibilité** : Facilite le partage et le déploiement
5. **Sécurité** : Évite de casser d'autres projets

### ❌ Sans Environnement Virtuel

- Tous les packages sont installés globalement
- Risque de conflits entre projets
- Difficile de gérer les versions
- Peut casser d'autres projets

## 🛠️ Comment Utiliser un Environnement Virtuel ?

### 1. Créer un Environnement Virtuel

```powershell
# Dans le dossier de votre projet
python -m venv venv
```

Cela crée un dossier `venv` avec :
- Un Python isolé
- Un gestionnaire de packages (pip) isolé
- Un espace pour installer des packages

### 2. Activer l'Environnement Virtuel

**Sur Windows (PowerShell) :**
```powershell
.\venv\Scripts\activate.ps1
```

**Sur Windows (CMD) :**
```cmd
venv\Scripts\activate.bat
```

**Sur Linux/Mac :**
```bash
source venv/bin/activate
```

### 3. Vérifier que c'est Activé

Quand l'environnement est activé, vous verrez `(venv)` au début de votre ligne de commande :

```powershell
(venv) PS C:\Users\zaoui\OneDrive\Desktop\detec_fraude>
```

### 4. Installer des Packages

Une fois activé, installez vos packages normalement :

```powershell
pip install fastapi uvicorn
```

Les packages seront installés **uniquement** dans cet environnement virtuel.

### 5. Désactiver l'Environnement

```powershell
deactivate
```

## 📁 Structure de Votre Projet

```
detec_fraude/
├── venv/                    # ← Environnement virtuel (créé par vous)
│   ├── Scripts/
│   │   ├── activate.ps1     # Script d'activation
│   │   └── python.exe       # Python isolé
│   └── Lib/
│       └── site-packages/   # Packages installés ici
├── auth_service/
├── transaction_service/
├── fraud_detection_service/
└── ...
```

## 🎯 Dans Votre Projet

### Votre Projet a Déjà un Environnement Virtuel

Vous avez un dossier `venv/` à la racine de votre projet. C'est votre environnement virtuel !

### Comment l'Activer

**Option 1 : Depuis la racine du projet**
```powershell
# Vous êtes déjà ici : C:\Users\zaoui\OneDrive\Desktop\detec_fraude
.\venv\Scripts\activate.ps1
```

**Option 2 : Utiliser le Python de l'environnement virtuel directement**
```powershell
# Sans activer, utilisez directement le Python de venv
.\venv\Scripts\python.exe -m uvicorn fraud_detection_service.main:app --host 0.0.0.0 --port 8002
```

### Pourquoi uvicorn n'était pas reconnu ?

Quand vous avez tapé `uvicorn`, Windows ne le trouvait pas car :
1. L'environnement virtuel n'était **pas activé**
2. `uvicorn` est installé dans `venv`, pas globalement

### Solution : Activer l'Environnement

```powershell
# 1. Activer l'environnement virtuel
.\venv\Scripts\activate.ps1

# 2. Maintenant uvicorn sera reconnu
cd fraud_detection_service
uvicorn main:app --host 0.0.0.0 --port 8002
```

## 🔧 Commandes Utiles

### Voir les Packages Installés
```powershell
pip list
```

### Installer depuis requirements.txt
```powershell
pip install -r requirements.txt
```

### Créer un requirements.txt
```powershell
pip freeze > requirements.txt
```

### Vérifier où sont installés les packages
```powershell
pip show uvicorn
```

## ⚠️ Erreurs Courantes

### "uvicorn n'est pas reconnu"
**Solution** : Activez l'environnement virtuel d'abord
```powershell
.\venv\Scripts\activate.ps1
```

### "Activation script cannot be loaded"
**Solution** : Autoriser l'exécution de scripts
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Module not found"
**Solution** : Installez le package dans l'environnement virtuel activé
```powershell
pip install nom_du_module
```

## 📝 Résumé pour Votre Cas

1. **Vous avez déjà un `venv/`** → C'est votre environnement virtuel
2. **Pour démarrer le service** :
   ```powershell
   # Activer l'environnement
   .\venv\Scripts\activate.ps1
   
   # Aller dans le dossier du service
   cd fraud_detection_service
   
   # Démarrer (maintenant uvicorn sera reconnu)
   uvicorn main:app --host 0.0.0.0 --port 8002
   ```

3. **Ou utiliser directement le Python de venv** :
   ```powershell
   cd fraud_detection_service
   ..\venv\Scripts\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8002
   ```

---

**En résumé** : Un environnement virtuel est une "boîte isolée" pour votre projet, où tous les packages Python sont installés séparément du reste de votre système. C'est une bonne pratique pour éviter les conflits ! 🎯

