@echo off
echo ========================================
echo  Configuration PostgreSQL Locale
echo ========================================
echo.
echo Ce script vous aide a configurer PostgreSQL pour les migrations.
echo.
echo Si vous n'avez pas encore cree la base de donnees, executez dans psql:
echo   CREATE DATABASE fraud_detection;
echo.
echo Entrez les informations de connexion PostgreSQL:
echo.

set /p DB_HOST="Host (localhost par defaut): "
if "%DB_HOST%"=="" set DB_HOST=localhost

set /p DB_PORT="Port (5432 par defaut): "
if "%DB_PORT%"=="" set DB_PORT=5432

set /p DB_USER="Utilisateur (postgres par defaut): "
if "%DB_USER%"=="" set DB_USER=postgres

set /p DB_PASSWORD="Mot de passe: "
if "%DB_PASSWORD%"=="" (
    echo [ERREUR] Le mot de passe est obligatoire!
    pause
    exit /b 1
)

set /p DB_NAME="Nom de la base (fraud_detection par defaut): "
if "%DB_NAME%"=="" set DB_NAME=fraud_detection

echo.
echo Configuration:
echo   DB_HOST=%DB_HOST%
echo   DB_PORT=%DB_PORT%
echo   DB_USER=%DB_USER%
echo   DB_NAME=%DB_NAME%
echo.
echo Test de connexion...
echo.

REM Tester la connexion avec psql si disponible
where psql >nul 2>&1
if not errorlevel 1 (
    echo "SELECT 1;" | psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% >nul 2>&1
    if errorlevel 1 (
        echo [ERREUR] Impossible de se connecter a PostgreSQL
        echo Verifiez vos identifiants et que PostgreSQL est demarre.
        pause
        exit /b 1
    ) else (
        echo [OK] Connexion reussie!
    )
) else (
    echo [INFO] psql non trouve, test de connexion ignore.
)

echo.
echo Les variables d'environnement sont configurees pour cette session.
echo Vous pouvez maintenant executer: migrate_postgres.bat
echo.
echo Ou executez directement:
echo   set DB_HOST=%DB_HOST%
echo   set DB_PORT=%DB_PORT%
echo   set DB_USER=%DB_USER%
echo   set DB_PASSWORD=%DB_PASSWORD%
echo   set DB_NAME=%DB_NAME%
echo   migrate_postgres.bat
echo.
pause
