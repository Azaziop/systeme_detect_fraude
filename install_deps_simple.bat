@echo off
echo ========================================
echo  Installation des Dependances
echo ========================================
echo.

echo Installation des packages Django...
pip install Django==4.2.7
pip install djangorestframework==3.14.0
pip install djangorestframework-simplejwt==5.3.0
pip install django-cors-headers==4.3.1
pip install drf-spectacular==0.26.5

echo.
echo Installation optionnelle (pour cache Redis)...
pip install django-redis

echo.
echo Installation des packages FastAPI...
pip install fastapi uvicorn pydantic httpx numpy sqlalchemy

echo.
echo Installation des packages ML...
pip install pandas scikit-learn joblib

echo.
echo ========================================
echo  Installation terminee!
echo ========================================
echo.
pause

