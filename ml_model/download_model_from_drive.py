"""
Script pour télécharger un modèle Random Forest depuis Google Drive
"""

import os
import gdown
from pathlib import Path
import joblib
import json

# Configuration
MODEL_DIR = Path(__file__).parent / "models"
MODEL_DIR.mkdir(exist_ok=True)

def download_from_drive(file_id: str, output_path: Path):
    """
    Télécharge un fichier depuis Google Drive
    
    Args:
        file_id: ID du fichier Google Drive (depuis l'URL partagée)
        output_path: Chemin où sauvegarder le fichier
    """
    # URL de téléchargement direct
    url = f"https://drive.google.com/uc?id={file_id}"
    
    print(f"Téléchargement depuis Google Drive...")
    print(f"URL: {url}")
    print(f"Destination: {output_path}")
    
    try:
        gdown.download(url, str(output_path), quiet=False)
        print(f"✅ Téléchargement réussi: {output_path}")
        return True
    except Exception as e:
        print(f"❌ Erreur lors du téléchargement: {e}")
        return False

def download_model_from_shareable_link(shareable_link: str, output_path: Path):
    """
    Télécharge un fichier depuis un lien partageable Google Drive
    
    Args:
        shareable_link: Lien partageable Google Drive
        output_path: Chemin où sauvegarder le fichier
    """
    print(f"Téléchargement depuis le lien partageable...")
    print(f"Lien: {shareable_link}")
    print(f"Destination: {output_path}")
    
    try:
        gdown.download(shareable_link, str(output_path), quiet=False, fuzzy=True)
        print(f"✅ Téléchargement réussi: {output_path}")
        return True
    except Exception as e:
        print(f"❌ Erreur lors du téléchargement: {e}")
        return False

def verify_model(model_path: Path):
    """
    Vérifie que le modèle peut être chargé
    """
    try:
        model = joblib.load(model_path)
        print(f"✅ Modèle chargé avec succès")
        print(f"   Type: {type(model).__name__}")
        
        # Vérifier si c'est un Random Forest
        if hasattr(model, 'predict_proba'):
            print(f"   ✅ Supporte predict_proba (Random Forest)")
        else:
            print(f"   ⚠️  Ne supporte pas predict_proba")
        
        return True
    except Exception as e:
        print(f"❌ Erreur lors du chargement du modèle: {e}")
        return False

def main():
    """
    Fonction principale
    """
    print("=" * 60)
    print("  Téléchargement du Modèle Random Forest depuis Google Drive")
    print("=" * 60)
    print()
    
    # Demander le type d'entrée
    print("Choisissez une option:")
    print("1. Utiliser un File ID Google Drive")
    print("2. Utiliser un lien partageable Google Drive")
    print("3. Copier manuellement le fichier")
    
    choice = input("\nVotre choix (1/2/3): ").strip()
    
    model_path = MODEL_DIR / "random_forest_model.pkl"
    scaler_path = MODEL_DIR / "scaler.pkl"
    features_path = MODEL_DIR / "feature_columns.json"
    
    if choice == "1":
        file_id = input("Entrez le File ID Google Drive: ").strip()
        if download_from_drive(file_id, model_path):
            verify_model(model_path)
    
    elif choice == "2":
        shareable_link = input("Entrez le lien partageable Google Drive: ").strip()
        if download_model_from_shareable_link(shareable_link, model_path):
            verify_model(model_path)
    
    elif choice == "3":
        print("\nInstructions pour copier manuellement:")
        print(f"1. Téléchargez votre modèle depuis Google Drive")
        print(f"2. Copiez-le dans: {model_path}")
        print(f"3. Si vous avez un scaler, copiez-le dans: {scaler_path}")
        print(f"4. Si vous avez un fichier feature_columns.json, copiez-le dans: {features_path}")
        print("\nAppuyez sur Entrée après avoir copié les fichiers...")
        input()
        
        if model_path.exists():
            verify_model(model_path)
        else:
            print(f"❌ Fichier non trouvé: {model_path}")
    
    else:
        print("❌ Choix invalide")
        return
    
    # Vérifier les fichiers nécessaires
    print("\n" + "=" * 60)
    print("  Vérification des fichiers")
    print("=" * 60)
    
    files_status = {
        "Modèle": model_path.exists(),
        "Scaler": scaler_path.exists(),
        "Features": features_path.exists()
    }
    
    for name, exists in files_status.items():
        status = "✅" if exists else "❌"
        print(f"{status} {name}: {files_status[name]}")
    
    if not files_status["Scaler"]:
        print("\n⚠️  Scaler non trouvé. Le service utilisera le modèle sans scaler.")
        print("   Assurez-vous que vos données sont déjà normalisées.")
    
    if not files_status["Features"]:
        print("\n⚠️  Fichier feature_columns.json non trouvé.")
        print("   Le service utilisera les features par défaut (V1-V28, Amount).")
    
    print("\n" + "=" * 60)
    print("  Téléchargement terminé!")
    print("=" * 60)

if __name__ == "__main__":
    main()

