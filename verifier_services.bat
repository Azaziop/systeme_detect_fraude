@echo off
echo ========================================
echo  Verification des Services
echo ========================================
echo.

echo [1/3] Test Auth Service (port 8000)...
curl -s http://localhost:8000/api/users/ >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Auth Service n'est pas accessible
    echo Lancez: cd auth_service ^&^& python manage.py runserver 0.0.0.0:8000
) else (
    echo [OK] Auth Service fonctionne
)

echo.
echo [2/3] Test Transaction Service (port 8001)...
curl -s http://localhost:8001/health >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Transaction Service n'est pas accessible
    echo Lancez: cd transaction_service ^&^& uvicorn main:app --host 0.0.0.0 --port 8001
) else (
    echo [OK] Transaction Service fonctionne
)

echo.
echo [3/3] Test Fraud Detection Service (port 8002)...
curl -s http://localhost:8002/health >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Fraud Detection Service n'est pas accessible
    echo Lancez: cd fraud_detection_service ^&^& uvicorn main:app --host 0.0.0.0 --port 8002
) else (
    echo [OK] Fraud Detection Service fonctionne
)

echo.
echo ========================================
echo  Verification terminee
echo ========================================
echo.
pause

