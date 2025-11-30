# Commandes Rapides - Guide Simple

## Vous êtes dans : `C:\Users\zaoui\OneDrive\Desktop\detec_fraude`

### Pour lancer Auth Service

```powershell
cd auth_service
set USE_SQLITE=True
python manage.py runserver 0.0.0.0:8000
```

### Pour lancer Transaction Service

```powershell
cd transaction_service
set DATABASE_URL=sqlite:///./transactions.db
uvicorn main:app --host 0.0.0.0 --port 8001
```

### Pour lancer Fraud Detection Service

```powershell
cd fraud_detection_service
uvicorn main:app --host 0.0.0.0 --port 8002
```

## Scripts Automatiques (Depuis la racine)

```powershell
# Depuis C:\Users\zaoui\OneDrive\Desktop\detec_fraude
.\start_auth.bat
.\start_transaction.bat
.\start_fraud_detection.bat
.\test_direct.bat  # Lance tous les services
```

