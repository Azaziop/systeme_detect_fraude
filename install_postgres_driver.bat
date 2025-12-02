@echo off
echo ========================================
echo  Installation du driver PostgreSQL
echo ========================================
echo.

REM Activer l'environnement virtuel
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo [ERREUR] Environnement virtuel non trouve!
    pause
    exit /b 1
)

echo Tentative d'installation de psycopg (version 3)...
python -m pip install --upgrade pip
python -m pip install psycopg

echo.
echo Verification de l'installation...
python -c "import psycopg; print('psycopg installe avec succes!')" 2>nul
if errorlevel 1 (
    echo.
    echo [ERREUR] psycopg n'a pas pu etre installe.
    echo.
    echo Solutions alternatives:
    echo 1. Installer Microsoft C++ Build Tools: https://visualstudio.microsoft.com/visual-cpp-build-tools/
    echo 2. Utiliser Docker: docker-compose up -d postgres
    echo 3. Utiliser une version anterieure de Python (3.11 ou 3.12)
    pause
    exit /b 1
) else (
    echo [OK] psycopg est installe!
)

echo.
pause
