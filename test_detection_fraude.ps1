# Script de test pour verifier la detection de fraude
# Test avec une transaction normale et une transaction frauduleuse

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST DE DETECTION DE FRAUDE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verifier que le service est actif
Write-Host "Verification du service..." -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri http://localhost:8002/health -Method GET -TimeoutSec 3
    $healthData = $health.Content | ConvertFrom-Json
    if ($healthData.model_loaded) {
        Write-Host "✅ Service actif et modele charge" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Service actif mais modele non charge" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Service non accessible sur http://localhost:8002" -ForegroundColor Red
    Write-Host "   Demarrez le service avec: .\demarrer_services.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST 1: TRANSACTION NORMALE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Transaction normale (valeurs faibles, montant normal)
$normalTransaction = @{
    transaction_id = "TEST_NORMAL_001"
    features = @{
        V1 = 0.1; V2 = -0.2; V3 = 0.15; V4 = -0.1; V5 = 0.2
        V6 = -0.15; V7 = 0.1; V8 = -0.2; V9 = 0.15; V10 = -0.1
        V11 = 0.2; V12 = -0.15; V13 = 0.1; V14 = -0.2; V15 = 0.15
        V16 = -0.1; V17 = 0.2; V18 = -0.15; V19 = 0.1; V20 = -0.2
        V21 = 0.15; V22 = -0.1; V23 = 0.2; V24 = -0.15; V25 = 0.1
        V26 = -0.2; V27 = 0.15; V28 = -0.1
        Amount = 50.00
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri http://localhost:8002/detect -Method POST -ContentType "application/json" -Body $normalTransaction -TimeoutSec 10
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "Resultat:" -ForegroundColor White
    Write-Host "  Transaction ID: $($result.transaction_id)" -ForegroundColor Cyan
    Write-Host "  is_fraud: $($result.is_fraud)" -ForegroundColor $(if ($result.is_fraud) { "Red" } else { "Green" })
    Write-Host "  fraud_score: $($result.fraud_score)" -ForegroundColor Cyan
    Write-Host "  confidence: $($result.confidence)" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not $result.is_fraud) {
        Write-Host "✅ RESULTAT ATTENDU: Transaction normale non detectee comme fraude" -ForegroundColor Green
    } else {
        Write-Host "⚠️  ATTENTION: Transaction normale detectee comme fraude (faux positif)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur lors du test: $_" -ForegroundColor Red
    Write-Host "   Detail: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST 2: TRANSACTION FRAUDULEUSE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Transaction frauduleuse (valeurs extremes, montant eleve)
$fraudTransaction = @{
    transaction_id = "TEST_FRAUD_001"
    features = @{
        V1 = 3.5; V2 = -3.5; V3 = 4.0; V4 = 3.8; V5 = -3.2
        V6 = 3.6; V7 = -3.8; V8 = 3.4; V9 = -3.0; V10 = 3.5
        V11 = 5.5  # Valeur tres elevee (souvent associee aux fraudes)
        V12 = -5.8  # Valeur tres negative
        V13 = 6.0   # Valeur tres elevee
        V14 = -6.2  # Valeur tres negative (pattern de fraude)
        V15 = 5.0   # Valeur elevee
        V16 = -4.5; V17 = 4.0; V18 = -4.2; V19 = 3.8; V20 = -3.5
        V21 = 4.2; V22 = -4.0; V23 = 3.6; V24 = -3.8; V25 = 4.0
        V26 = -4.2; V27 = 3.5; V28 = -3.6
        Amount = 15000.00  # Montant eleve
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri http://localhost:8002/detect -Method POST -ContentType "application/json" -Body $fraudTransaction -TimeoutSec 10
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "Resultat:" -ForegroundColor White
    Write-Host "  Transaction ID: $($result.transaction_id)" -ForegroundColor Cyan
    Write-Host "  is_fraud: $($result.is_fraud)" -ForegroundColor $(if ($result.is_fraud) { "Red" } else { "Yellow" })
    Write-Host "  fraud_score: $($result.fraud_score)" -ForegroundColor Cyan
    Write-Host "  confidence: $($result.confidence)" -ForegroundColor Cyan
    Write-Host ""
    
    if ($result.is_fraud) {
        Write-Host "✅ RESULTAT ATTENDU: Fraude detectee correctement!" -ForegroundColor Green
        Write-Host "   Score de fraude: $($result.fraud_score) (seuil: 0.03)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  ATTENTION: Transaction suspecte non detectee comme fraude" -ForegroundColor Yellow
        Write-Host "   Score: $($result.fraud_score) (seuil: 0.03)" -ForegroundColor Yellow
        if ($result.fraud_score -ge 0.03) {
            Write-Host "   ⚠️  Le score est >= seuil mais is_fraud=False" -ForegroundColor Red
            Write-Host "      Verifiez la configuration du seuil dans le service" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "❌ Erreur lors du test: $_" -ForegroundColor Red
    Write-Host "   Detail: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUME DES TESTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Les deux tests ont ete effectues:" -ForegroundColor White
Write-Host "  1. Transaction normale (montant: 50€)" -ForegroundColor White
Write-Host "  2. Transaction suspecte (montant: 15000€, valeurs extremes)" -ForegroundColor White
Write-Host ""
Write-Host "Verifiez les resultats ci-dessus pour confirmer que:" -ForegroundColor Yellow
Write-Host "  ✅ Les transactions normales ne sont PAS detectees comme frauduleuses" -ForegroundColor White
Write-Host "  ✅ Les transactions suspectes SONT detectees comme frauduleuses" -ForegroundColor White
Write-Host ""

