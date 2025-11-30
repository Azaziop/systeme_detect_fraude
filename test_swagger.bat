@echo off
echo ========================================
echo  Test Swagger - Verification
echo ========================================
echo.

echo Verification de l'installation de drf-spectacular...
pip show drf-spectacular >nul 2>&1
if errorlevel 1 (
    echo Installation de drf-spectacular...
    pip install drf-spectacular
)

echo.
echo URLs disponibles:
echo   http://localhost:8000/api/schema/     - Schema OpenAPI
echo   http://localhost:8000/api/docs/       - Swagger UI
echo   http://localhost:8000/api/redoc/      - ReDoc
echo   http://localhost:8000/api/register/   - Inscription
echo   http://localhost:8000/api/login/      - Connexion
echo.
echo Si le serveur Django est deja lance, redemarrez-le pour appliquer les changements.
echo.
pause

