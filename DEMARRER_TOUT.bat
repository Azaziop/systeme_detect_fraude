@echo off
echo ========================================
echo  DEMARRAGE COMPLET DU PROJET
echo ========================================
echo.
echo Ce script va demarrer tous les services necessaires.
echo.
echo Services qui vont demarrer:
echo   1. Service d'Authentification (Django) - Port 8000
echo   2. Service de Detection de Fraude (FastAPI) - Port 8002
echo   3. Service de Transaction (FastAPI) - Port 8001
echo.
echo IMPORTANT: Gardez toutes les fenetres ouvertes!
echo.
pause

REM Verifier l'environnement virtuel
if not exist "venv\Scripts\activate.bat" (
    echo [ERREUR] Environnement virtuel non trouve!
    echo Executez d'abord: setup_local.bat
    pause
    exit /b 1
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

REM Activer l'environnement virtuel
set VENV_ACTIVATE=call "%~dp0venv\Scripts\activate.bat" &&

echo [1/3] Demarrage Auth Service (Django)...
start "🔐 Auth Service (8000)" cmd /k "cd /d %~dp0auth_service && %VENV_ACTIVATE% set USE_SQLITE=True && echo ======================================== && echo   SERVICE D'AUTHENTIFICATION && echo ======================================== && echo. && python manage.py migrate && echo. && echo Demarrage sur http://localhost:8000 && echo Swagger: http://localhost:8000/api/docs/ && echo Admin: http://localhost:8000/admin/ && echo. && python manage.py runserver 0.0.0.0:8000"

timeout /t 3 /nobreak >nul

echo [2/3] Demarrage Fraud Detection Service (FastAPI)...
start "🤖 Fraud Detection (8002)" cmd /k "cd /d %~dp0fraud_detection_service && %VENV_ACTIVATE% echo ======================================== && echo   SERVICE DE DETECTION DE FRAUDE && echo ======================================== && echo. && echo Demarrage sur http://localhost:8002 && echo Swagger: http://localhost:8002/docs && echo. && uvicorn main:app --host 0.0.0.0 --port 8002"

timeout /t 3 /nobreak >nul

echo [3/3] Demarrage Transaction Service (FastAPI)...
start "💳 Transaction Service (8001)" cmd /k "cd /d %~dp0transaction_service && %VENV_ACTIVATE% set DATABASE_URL=sqlite:///./transactions.db && set FRAUD_DETECTION_SERVICE_URL=http://localhost:8002 && set AUTH_SERVICE_URL=http://localhost:8000 && echo ======================================== && echo   SERVICE DE TRANSACTION && echo ======================================== && echo. && echo Demarrage sur http://localhost:8001 && echo Swagger: http://localhost:8001/docs && echo. && uvicorn main:app --host 0.0.0.0 --port 8001"

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
echo   - Ou utilisez: .\arreter_services.bat
echo.
echo Test des services dans 5 secondes...
timeout /t 5 /nobreak >nul

echo.
echo Test de connexion...
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:8000/' -TimeoutSec 2 -UseBasicParsing; Write-Host '[OK] Auth Service: Connecte' } catch { Write-Host '[ATTENTION] Auth Service: En cours de demarrage...' }"
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:8002/' -TimeoutSec 2 -UseBasicParsing; Write-Host '[OK] Fraud Detection: Connecte' } catch { Write-Host '[ATTENTION] Fraud Detection: En cours de demarrage...' }"
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:8001/' -TimeoutSec 2 -UseBasicParsing; Write-Host '[OK] Transaction Service: Connecte' } catch { Write-Host '[ATTENTION] Transaction Service: En cours de demarrage...' }"

echo.
echo ========================================
echo  Demarrage termine!
echo ========================================
echo.
pause

