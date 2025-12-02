# Script PowerShell pour démarrer tous les services avec l'environnement virtuel

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEMARRAGE DES SERVICES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que l'environnement virtuel existe
if (-not (Test-Path "venv\Scripts\activate.ps1")) {
    Write-Host "ERREUR: Environnement virtuel non trouve!" -ForegroundColor Red
    Write-Host "Creez-le avec: python -m venv venv" -ForegroundColor Yellow
    exit 1
}

# Vérifier le modèle
if (-not (Test-Path "ml_model\models\random_forest_model.pkl")) {
    Write-Host "ATTENTION: Modele Random Forest non trouve!" -ForegroundColor Yellow
    Write-Host "Le service de detection de fraude peut ne pas fonctionner." -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Voulez-vous continuer quand meme? (O/N)"
    if ($continue -ne "O" -and $continue -ne "o") {
        exit 1
    }
}

Write-Host "Demarrage des services..." -ForegroundColor Yellow
Write-Host ""

# Service 1 : Auth Service (Django) - Port 8000
Write-Host "[1/3] Demarrage Auth Service (port 8000)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; if (Test-Path 'venv\Scripts\activate.ps1') { & 'venv\Scripts\activate.ps1' }; cd auth_service; Write-Host '========================================' -ForegroundColor Cyan; Write-Host '  SERVICE D''AUTHENTIFICATION' -ForegroundColor Cyan; Write-Host '========================================' -ForegroundColor Cyan; Write-Host ''; Write-Host 'Application des migrations...' -ForegroundColor Yellow; python manage.py migrate; Write-Host ''; Write-Host 'Demarrage sur http://localhost:8000' -ForegroundColor Green; Write-Host 'Swagger: http://localhost:8000/api/docs/' -ForegroundColor Green; Write-Host 'Admin: http://localhost:8000/admin/' -ForegroundColor Green; Write-Host ''; python manage.py runserver 0.0.0.0:8000" -WindowStyle Normal

Start-Sleep -Seconds 3

# Service 2 : Fraud Detection Service (FastAPI) - Port 8002
Write-Host "[2/3] Demarrage Fraud Detection Service (port 8002)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; if (Test-Path 'venv\Scripts\activate.ps1') { & 'venv\Scripts\activate.ps1' }; cd fraud_detection_service; Write-Host '========================================' -ForegroundColor Cyan; Write-Host '  SERVICE DE DETECTION DE FRAUDE' -ForegroundColor Cyan; Write-Host '========================================' -ForegroundColor Cyan; Write-Host ''; Write-Host 'Demarrage sur http://localhost:8002' -ForegroundColor Green; Write-Host 'Swagger: http://localhost:8002/docs' -ForegroundColor Green; Write-Host 'Health: http://localhost:8002/health' -ForegroundColor Green; Write-Host ''; uvicorn main:app --host 0.0.0.0 --port 8002" -WindowStyle Normal

Start-Sleep -Seconds 3

# Service 3 : Transaction Service (FastAPI) - Port 8001
Write-Host "[3/3] Demarrage Transaction Service (port 8001)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; if (Test-Path 'venv\Scripts\activate.ps1') { & 'venv\Scripts\activate.ps1' }; cd transaction_service; Write-Host '========================================' -ForegroundColor Cyan; Write-Host '  SERVICE DE TRANSACTION' -ForegroundColor Cyan; Write-Host '========================================' -ForegroundColor Cyan; Write-Host ''; Write-Host 'Demarrage sur http://localhost:8001' -ForegroundColor Green; Write-Host 'Swagger: http://localhost:8001/docs' -ForegroundColor Green; Write-Host 'Health: http://localhost:8001/health' -ForegroundColor Green; Write-Host ''; uvicorn main:app --host 0.0.0.0 --port 8001" -WindowStyle Normal

Start-Sleep -Seconds 5

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  TOUS LES SERVICES SONT DEMARRES!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Services disponibles:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Auth Service:" -ForegroundColor Yellow
Write-Host "    - URL:      http://localhost:8000" -ForegroundColor White
Write-Host "    - Swagger:  http://localhost:8000/api/docs/" -ForegroundColor White
Write-Host "    - Admin:    http://localhost:8000/admin/" -ForegroundColor White
Write-Host ""
Write-Host "  Fraud Detection Service:" -ForegroundColor Yellow
Write-Host "    - URL:      http://localhost:8002" -ForegroundColor White
Write-Host "    - Swagger:  http://localhost:8002/docs" -ForegroundColor White
Write-Host "    - Health:   http://localhost:8002/health" -ForegroundColor White
Write-Host ""
Write-Host "  Transaction Service:" -ForegroundColor Yellow
Write-Host "    - URL:      http://localhost:8001" -ForegroundColor White
Write-Host "    - Swagger:  http://localhost:8001/docs" -ForegroundColor White
Write-Host "    - Health:   http://localhost:8001/health" -ForegroundColor White
Write-Host ""
Write-Host "  Frontend:" -ForegroundColor Yellow
Write-Host "    - Ouvrez:   frontend\index.html dans votre navigateur" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "  - Gardez toutes les fenetres ouvertes" -ForegroundColor White
Write-Host "  - Fermez les fenetres pour arreter les services" -ForegroundColor White
Write-Host "  - Les services utilisent l'environnement virtuel (venv)" -ForegroundColor White
Write-Host ""

