@echo off
echo ========================================
echo  Installation Transaction Service
echo ========================================
echo.

cd transaction_service

echo Installation des dependances...
pip install fastapi uvicorn[standard] pydantic httpx numpy sqlalchemy celery redis

echo.
echo ========================================
echo  Installation terminee!
echo ========================================
echo.
echo Vous pouvez maintenant lancer:
echo   uvicorn main:app --host 0.0.0.0 --port 8001
echo.
pause

