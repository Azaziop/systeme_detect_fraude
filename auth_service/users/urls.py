from django.urls import path
from . import views

urlpatterns = [
    path('register/', views.UserRegistrationView.as_view(), name='register'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('profile/', views.user_profile, name='profile'),
    path('users/', views.UserListView.as_view(), name='user-list'),
    path('users/<int:user_id>/verify/', views.verify_user, name='verify-user'),
]

