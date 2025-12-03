@echo off
chcp 65001 >nul
echo.
echo ========================================
echo 🔄 REDÉMARRAGE COMPLET DU SYSTÈME
echo ========================================
echo.

REM 1. Arrêter tous les services existants
echo 🛑 Arrêt des services existants...
taskkill /F /IM python.exe 2>nul
taskkill /F /IM uvicorn.exe 2>nul
timeout /t 3 >nul

REM 2. Vérifier que les ports sont libres
echo.
echo 🔍 Vérification des ports...
netstat -ano | findstr ":8000 :8001 :8002" && (
    echo ⚠️ ATTENTION: Certains ports sont encore occupés!
    echo Arrêt forcé...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8000 :8001 :8002"') do taskkill /F /PID %%a 2>nul
    timeout /t 2 >nul
)

echo.
echo ========================================
echo 🚀 DÉMARRAGE DES SERVICES
echo ========================================

REM 3. Service d'authentification (port 8000)
echo.
echo [1/3] 🔐 Démarrage du service d'authentification...
start "Auth Service (8000)" cmd /k "cd auth_service && python manage.py runserver 0.0.0.0:8000"
timeout /t 3 >nul

REM 4. Service de transactions (port 8001)
echo [2/3] 💳 Démarrage du service de transactions...
start "Transaction Service (8001)" cmd /k "cd transaction_service && python main.py"
timeout /t 3 >nul

REM 5. Service de détection de fraude (port 8002)
echo [3/3] 🤖 Démarrage du service ML de détection...
start "Fraud Detection ML (8002)" cmd /k "cd fraud_detection_service && python main.py"
timeout /t 3 >nul

echo.
echo ========================================
echo ⏳ Attente du démarrage des services...
echo ========================================
timeout /t 5 >nul

REM 6. Vérifier que les services sont démarrés
echo.
echo 🔍 Vérification des services...
echo.

curl -s http://localhost:8000/api/health >nul 2>&1 && (
    echo ✅ Service Auth        : http://localhost:8000 - OK
) || (
    echo ❌ Service Auth        : http://localhost:8000 - ERREUR
)

curl -s http://localhost:8001/health >nul 2>&1 && (
    echo ✅ Service Transaction : http://localhost:8001 - OK
) || (
    echo ❌ Service Transaction : http://localhost:8001 - ERREUR
)

curl -s http://localhost:8002/health >nul 2>&1 && (
    echo ✅ Service ML          : http://localhost:8002 - OK
) || (
    echo ❌ Service ML          : http://localhost:8002 - ERREUR
)

echo.
echo ========================================
echo 📋 INFORMATIONS IMPORTANTES
echo ========================================
echo.
echo 🌐 Frontend: Ouvrez index.html dans votre navigateur
echo 📊 Swagger Auth       : http://localhost:8000/swagger/
echo 📊 Swagger Transaction: http://localhost:8001/docs
echo 📊 Swagger ML         : http://localhost:8002/docs
echo.
echo 🔧 Logs disponibles dans les 3 fenêtres CMD ouvertes
echo.
echo ⚠️  Pour arrêter: Fermez les 3 fenêtres CMD ou utilisez arreter_services.bat
echo.

pause