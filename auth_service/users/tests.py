"""
Tests unitaires pour le service d'authentification
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

User = get_user_model()


class UserRegistrationTests(TestCase):
    """Tests pour l'inscription d'utilisateurs"""
    
    def setUp(self):
        self.client = APIClient()
        self.register_url = '/api/register/'
    
    def test_register_user_success(self):
        """Test d'inscription réussie"""
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'password_confirm': 'testpass123',
            'phone': '+1234567890'
        }
        response = self.client.post(self.register_url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
        self.assertIn('user', response.data)
        self.assertEqual(response.data['user']['username'], 'testuser')
    
    def test_register_user_password_mismatch(self):
        """Test d'inscription avec mots de passe différents"""
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'password_confirm': 'differentpass',
        }
        response = self.client.post(self.register_url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_register_user_duplicate_email(self):
        """Test d'inscription avec email déjà utilisé"""
        User.objects.create_user(
            username='existing',
            email='test@example.com',
            password='pass123'
        )
        
        data = {
            'username': 'newuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'password_confirm': 'testpass123',
        }
        response = self.client.post(self.register_url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class UserLoginTests(TestCase):
    """Tests pour la connexion d'utilisateurs"""
    
    def setUp(self):
        self.client = APIClient()
        self.login_url = '/api/login/'
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
    
    def test_login_success(self):
        """Test de connexion réussie"""
        data = {
            'username': 'testuser',
            'password': 'testpass123'
        }
        response = self.client.post(self.login_url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
        self.assertIn('user', response.data)
    
    def test_login_invalid_credentials(self):
        """Test de connexion avec identifiants invalides"""
        data = {
            'username': 'testuser',
            'password': 'wrongpassword'
        }
        response = self.client.post(self.login_url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_login_nonexistent_user(self):
        """Test de connexion avec utilisateur inexistant"""
        data = {
            'username': 'nonexistent',
            'password': 'password123'
        }
        response = self.client.post(self.login_url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class UserProfileTests(TestCase):
    """Tests pour le profil utilisateur"""
    
    def setUp(self):
        self.client = APIClient()
        self.profile_url = '/api/profile/'
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
    
    def test_get_profile_authenticated(self):
        """Test de récupération du profil avec authentification"""
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        
        response = self.client.get(self.profile_url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['username'], 'testuser')
    
    def test_get_profile_unauthenticated(self):
        """Test de récupération du profil sans authentification"""
        response = self.client.get(self.profile_url)
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class UserVerificationTests(TestCase):
    """Tests pour la vérification d'utilisateurs"""
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
    
    def test_verify_existing_user(self):
        """Test de vérification d'un utilisateur existant"""
        url = f'/api/users/{self.user.id}/verify/'
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['valid'])
        self.assertEqual(response.data['user_id'], str(self.user.id))
    
    def test_verify_nonexistent_user(self):
        """Test de vérification d'un utilisateur inexistant"""
        url = '/api/users/99999/verify/'
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertFalse(response.data['valid'])

