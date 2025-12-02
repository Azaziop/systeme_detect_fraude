@echo off
echo ========================================
echo  Migration vers PostgreSQL
echo ========================================
echo.

REM Activer l'environnement virtuel
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo [ATTENTION] Environnement virtuel non trouve.
    echo Utilisation de Python systeme...
)

REM Configuration PostgreSQL
REM Modifiez ces valeurs selon votre installation PostgreSQL locale
if "%DB_HOST%"=="" set DB_HOST=localhost
if "%DB_NAME%"=="" set DB_NAME=fraud_detection
if "%DB_USER%"=="" set DB_USER=postgres
if "%DB_PASSWORD%"=="" (
    echo.
    echo ========================================
    echo  Configuration PostgreSQL requise
    echo ========================================
    echo.
    echo Le mot de passe PostgreSQL n'est pas configure.
    echo.
    set /p DB_PASSWORD="Entrez le mot de passe PostgreSQL pour l'utilisateur '%DB_USER%': "
    if "%DB_PASSWORD%"=="" (
        echo [ERREUR] Mot de passe requis!
        pause
        exit /b 1
    )
    echo.
)
if "%DB_PORT%"=="" set DB_PORT=5432

echo Configuration PostgreSQL:
echo   DB_HOST=%DB_HOST%
echo   DB_NAME=%DB_NAME%
echo   DB_USER=%DB_USER%
echo   DB_PORT=%DB_PORT%
echo   DB_PASSWORD=*** (masque)
echo.

REM Migration Auth Service (Django)
echo [1/2] Migration Auth Service...
cd auth_service
python manage.py migrate
if errorlevel 1 (
    echo [ERREUR] Migration Auth Service echouee
    cd ..
    pause
    exit /b 1
)
cd ..
echo [OK] Auth Service migre avec succes!
echo.

REM Migration Transaction Service (SQLAlchemy)
echo [2/2] Creation des tables Transaction Service...
cd transaction_service
python -c "from models import Base, engine; Base.metadata.create_all(bind=engine); print('Tables creees avec succes!')"
if errorlevel 1 (
    echo [ERREUR] Creation des tables Transaction Service echouee
    cd ..
    pause
    exit /b 1
)
cd ..
echo [OK] Transaction Service migre avec succes!
echo.

echo ========================================
echo  Migrations terminees avec succes!
echo ========================================
pause
