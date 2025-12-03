@echo off
echo ========================================
echo  DEMARRAGE COMPLET DU PROJET
echo ========================================
echo.
echo Ce script va demarrer tous les services necessaires.
echo.

REM Activer l'environnement virtuel à la racine
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    echo [OK] Environnement virtuel active
) else (
    echo [ATTENTION] Environnement virtuel non trouve a la racine.
    echo Le script va utiliser Python systeme.
    echo.
    echo Pour creer l'environnement virtuel:
    echo   python -m venv venv
    echo   .\venv\Scripts\activate
    echo   pip install -r auth_service\requirements-simple.txt
    echo   pip install -r transaction_service\requirements.txt
    echo   pip install -r fraud_detection_service\requirements.txt
    echo.
    pause
)

REM Verifier le modele
if not exist "ml_model\models\random_forest_model.pkl" (
    echo [ATTENTION] Modele Random Forest non trouve!
    echo.
    echo Voulez-vous continuer quand meme? (O/N)
    set /p CONTINUE=
    if /i not "%CONTINUE%"=="O" (
        echo.
        echo Telechargez d'abord le modele avec: .\telecharger_depuis_colab.bat
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo  Demarrage des Services...
echo ========================================
echo.

echo [1/3] Demarrage Auth Service (Django)...
start "🔐 Auth Service (8000)" cmd /k "cd /d %~dp0 && if exist venv\Scripts\activate.bat (call venv\Scripts\activate.bat) && cd auth_service && set USE_SQLITE=True && echo ======================================== && echo   SERVICE D'AUTHENTIFICATION && echo ======================================== && echo. && python manage.py migrate && echo. && echo Demarrage sur http://localhost:8000 && echo Swagger: http://localhost:8000/api/docs/ && echo Admin: http://localhost:8000/admin/ && echo. && python manage.py runserver 0.0.0.0:8000"

timeout /t 3 /nobreak >nul

echo [2/3] Demarrage Fraud Detection Service (FastAPI)...
start "🤖 Fraud Detection (8002)" cmd /k "cd /d %~dp0 && if exist venv\Scripts\activate.bat (call venv\Scripts\activate.bat) && cd fraud_detection_service && echo ======================================== && echo   SERVICE DE DETECTION DE FRAUDE && echo ======================================== && echo. && echo Demarrage sur http://localhost:8002 && echo Swagger: http://localhost:8002/docs && echo. && uvicorn main:app --host 0.0.0.0 --port 8002"

timeout /t 3 /nobreak >nul

echo [3/3] Demarrage Transaction Service (FastAPI)...
start "💳 Transaction Service (8001)" cmd /k "cd /d %~dp0 && if exist venv\Scripts\activate.bat (call venv\Scripts\activate.bat) && cd transaction_service && set DATABASE_URL=sqlite:///./transactions.db && set FRAUD_DETECTION_SERVICE_URL=http://localhost:8002 && set AUTH_SERVICE_URL=http://localhost:8000 && echo ======================================== && echo   SERVICE DE TRANSACTION && echo ======================================== && echo. && echo Demarrage sur http://localhost:8001 && echo Swagger: http://localhost:8001/docs && echo. && uvicorn main:app --host 0.0.0.0 --port 8001"

timeout /t 5 /nobreak >nul

echo.
echo ========================================
echo  ✅ TOUS LES SERVICES SONT DEMARRES!
echo ========================================
echo.
echo Services disponibles:
echo.
echo   🔐 Auth Service:
echo      - URL:      http://localhost:8000
echo      - Swagger:  http://localhost:8000/api/docs/
echo      - Admin:    http://localhost:8000/admin/
echo.
echo   🤖 Fraud Detection Service:
echo      - URL:      http://localhost:8002
echo      - Swagger:  http://localhost:8002/docs
echo.
echo   💳 Transaction Service:
echo      - URL:      http://localhost:8001
echo      - Swagger:  http://localhost:8001/docs
echo.
echo   🌐 Frontend:
echo      - Ouvrez:   frontend\index.html dans votre navigateur
echo.
echo ========================================
echo.
echo IMPORTANT:
echo   - Gardez toutes les fenetres ouvertes
echo   - Fermez les fenetres pour arreter les services
echo.
pause

