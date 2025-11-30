@echo off
echo ========================================
echo  Creation d'un Superutilisateur Admin
echo ========================================
echo.

cd auth_service

echo Creation du superutilisateur...
echo.
echo Vous allez etre invite a entrer:
echo   - Username (ex: admin)
echo   - Email (ex: admin@example.com)
echo   - Password (entrez un mot de passe)
echo.

python manage.py createsuperuser

echo.
echo ========================================
echo  Superutilisateur cree!
echo ========================================
echo.
echo Vous pouvez maintenant vous connecter sur:
echo   http://localhost:8000/admin/
echo.
pause

