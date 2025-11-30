@echo off
echo ========================================
echo  Demarrage de Tous les Services
echo ========================================
echo.
echo Les services vont demarrer dans 3 fenetres separees.
echo.
echo IMPORTANT: Gardez toutes les fenetres ouvertes!
echo.
pause

echo Demarrage Auth Service...
start "Auth Service (8000)" cmd /k "cd auth_service && set USE_SQLITE=True && python manage.py runserver 0.0.0.0:8000"

timeout /t 5 /nobreak >nul

echo Demarrage Fraud Detection Service...
start "Fraud Detection (8002)" cmd /k "cd fraud_detection_service && uvicorn main:app --host 0.0.0.0 --port 8002"

timeout /t 5 /nobreak >nul

echo Demarrage Transaction Service...
start "Transaction Service (8001)" cmd /k "cd transaction_service && set DATABASE_URL=sqlite:///./transactions.db && uvicorn main:app --host 0.0.0.0 --port 8001"

echo.
echo ========================================
echo  Services Demarres!
echo ========================================
echo.
echo Services disponibles:
echo   - Auth:        http://localhost:8000/api/docs/
echo   - Transaction: http://localhost:8001/docs
echo   - Fraud:       http://localhost:8002/docs
echo.
echo Fermez les fenetres pour arreter les services.
echo.
timeout /t 3 /nobreak >nul

echo Test des services...
timeout /t 5 /nobreak >nul
curl http://localhost:8000/api/users/ 2>nul
curl http://localhost:8001/health 2>nul
curl http://localhost:8002/health 2>nul

echo.
echo Test termine!
pause

