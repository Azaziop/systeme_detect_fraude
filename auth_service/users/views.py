from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from .serializers import (
    UserSerializer,
    UserRegistrationSerializer,
    LoginSerializer
)

User = get_user_model()


class UserRegistrationView(generics.CreateAPIView):
    """Vue pour l'inscription d'un utilisateur"""
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Générer les tokens JWT
        refresh = RefreshToken.for_user(user)
        access_token = refresh.access_token
        
        return Response({
            'user': UserSerializer(user).data,
            'access': str(access_token),
            'refresh': str(refresh),
            'message': 'Utilisateur créé avec succès'
        }, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def login_view(request):
    """Vue pour la connexion avec JWT"""
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.validated_data['user']
        
        # Générer les tokens JWT
        refresh = RefreshToken.for_user(user)
        access_token = refresh.access_token
        
        return Response({
            'access': str(access_token),
            'refresh': str(refresh),
            'user': UserSerializer(user).data,
            'message': 'Connexion réussie'
        })
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def logout_view(request):
    """Vue pour la déconnexion avec JWT"""
    # Note: Pour blacklister les tokens, il faudrait installer
    # 'rest_framework_simplejwt.token_blacklist' mais ce n'est pas nécessaire
    # pour un test simple. Les tokens expireront naturellement.
    
    # Supprimer le token legacy si existe
    try:
        request.user.auth_token.delete()
    except:
        pass
    
    return Response({'message': 'Déconnexion réussie'})


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def user_profile(request):
    """Vue pour le profil utilisateur"""
    serializer = UserSerializer(request.user)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def verify_user(request, user_id):
    """Vérifie si un utilisateur existe et est actif"""
    try:
        user = User.objects.get(id=user_id, is_active=True)
        return Response({
            'valid': True,
            'user_id': str(user.id),
            'username': user.username
        })
    except User.DoesNotExist:
        return Response({
            'valid': False,
            'message': 'Utilisateur non trouvé ou inactif'
        }, status=status.HTTP_404_NOT_FOUND)


class UserListView(generics.ListAPIView):
    """Liste des utilisateurs"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

