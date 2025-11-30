@echo off
echo ========================================
echo  Installation Auth Service
echo ========================================
echo.

cd auth_service

echo Installation des dependances...
pip install Django==4.2.7
pip install djangorestframework==3.14.0
pip install djangorestframework-simplejwt==5.3.0
pip install django-cors-headers==4.3.1
pip install drf-spectacular==0.26.5

echo.
echo ========================================
echo  Installation terminee!
echo ========================================
echo.
echo Vous pouvez maintenant lancer:
echo   set USE_SQLITE=True
echo   python manage.py runserver 0.0.0.0:8000
echo.
pause

