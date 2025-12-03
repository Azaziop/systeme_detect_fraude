# Script pour tester la detection de fraude avec differents patterns

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST DE DETECTION DE FRAUDE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Pattern 1: Valeurs extremes (typiques de fraudes)
Write-Host "Test 1: Valeurs extremes (V11-V15 elevees)" -ForegroundColor Yellow
$fraud1 = @{
    transaction_id = "FRAUD_EXTREME_001"
    features = @{
        Time = 50000.0
        V1 = 3.5; V2 = -3.5; V3 = 4.0; V4 = 3.8; V5 = -3.2
        V6 = 3.6; V7 = -3.8; V8 = 3.4; V9 = -3.0; V10 = 3.5
        V11 = 5.5  # Valeur tres elevee (souvent associee aux fraudes)
        V12 = -5.8  # Valeur tres negative
        V13 = 6.0   # Valeur tres elevee
        V14 = -6.2  # Valeur tres negative
        V15 = 5.0   # Valeur elevee
        V16 = -4.5; V17 = 4.0; V18 = -4.2; V19 = 3.8; V20 = -3.5
        V21 = 4.2; V22 = -4.0; V23 = 3.6; V24 = -3.8; V25 = 4.0
        V26 = -4.2; V27 = 3.5; V28 = -3.6
        Amount = 15000.00  # Montant eleve
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8002/detect" -Method POST -ContentType "application/json" -Body $fraud1
    $result = $response.Content | ConvertFrom-Json
    Write-Host "  Resultat: is_fraud=$($result.is_fraud), score=$($result.fraud_score), confidence=$($result.confidence)" -ForegroundColor $(if ($result.is_fraud) { "Red" } else { "Yellow" })
} catch {
    Write-Host "  Erreur: $_" -ForegroundColor Red
}

Write-Host ""

# Pattern 2: Anomalies dans V14 et V12 (souvent associees aux fraudes)
Write-Host "Test 2: Anomalies V14/V12 (pattern connu de fraude)" -ForegroundColor Yellow
$fraud2 = @{
    transaction_id = "FRAUD_PATTERN_002"
    features = @{
        Time = 25000.0
        V1 = -1.0; V2 = 0.5; V3 = -0.8; V4 = 0.6; V5 = -0.5
        V6 = 0.4; V7 = -0.6; V8 = 0.5; V9 = -0.4; V10 = 0.3
        V11 = 2.5
        V12 = -4.5  # Valeur tres negative (pattern de fraude)
        V13 = 1.8
        V14 = -5.0  # Valeur tres negative (pattern de fraude)
        V15 = 2.0
        V16 = -1.5; V17 = 1.2; V18 = -1.3; V19 = 1.0; V20 = -0.8
        V21 = 1.1; V22 = -1.0; V23 = 0.9; V24 = -1.1; V25 = 1.0
        V26 = -0.9; V27 = 0.8; V28 = -0.7
        Amount = 8000.00
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8002/detect" -Method POST -ContentType "application/json" -Body $fraud2
    $result = $response.Content | ConvertFrom-Json
    Write-Host "  Resultat: is_fraud=$($result.is_fraud), score=$($result.fraud_score), confidence=$($result.confidence)" -ForegroundColor $(if ($result.is_fraud) { "Red" } else { "Yellow" })
} catch {
    Write-Host "  Erreur: $_" -ForegroundColor Red
}

Write-Host ""

# Pattern 3: Toutes les valeurs sont extremes
Write-Host "Test 3: Toutes les valeurs extremes" -ForegroundColor Yellow
$fraud3 = @{
    transaction_id = "FRAUD_ALL_EXTREME_003"
    features = @{
        Time = 100000.0
        V1 = 6.0; V2 = -6.0; V3 = 7.0; V4 = 6.5; V5 = -5.5
        V6 = 6.2; V7 = -6.5; V8 = 5.8; V9 = -5.2; V10 = 6.0
        V11 = 7.5; V12 = -7.8; V13 = 8.0; V14 = -8.2; V15 = 7.0
        V16 = -6.5; V17 = 6.8; V18 = -6.2; V19 = 7.2; V20 = -6.5
        V21 = 6.9; V22 = -6.1; V23 = 6.3; V24 = -5.7; V25 = 6.6
        V26 = -6.4; V27 = 5.8; V28 = -6.0
        Amount = 25000.00
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8002/detect" -Method POST -ContentType "application/json" -Body $fraud3
    $result = $response.Content | ConvertFrom-Json
    Write-Host "  Resultat: is_fraud=$($result.is_fraud), score=$($result.fraud_score), confidence=$($result.confidence)" -ForegroundColor $(if ($result.is_fraud) { "Red" } else { "Yellow" })
} catch {
    Write-Host "  Erreur: $_" -ForegroundColor Red
}

Write-Host ""

# Pattern 4: Valeurs du dataset Kaggle (transaction frauduleuse reelle)
Write-Host "Test 4: Transaction frauduleuse du dataset Kaggle" -ForegroundColor Yellow
$fraud4 = @{
    transaction_id = "FRAUD_KAGGLE_004"
    features = @{
        Time = 406.0
        V1 = -1.359807134; V2 = -0.072781173; V3 = 2.536346738; V4 = 1.378155224; V5 = -0.338261771
        V6 = 0.462388019; V7 = 0.239598554; V8 = 0.098697901; V9 = 0.36378697; V10 = 0.090794172
        V11 = -0.551599533; V12 = -0.617800856; V13 = -0.991389847; V14 = -0.311169354; V15 = 1.468176972
        V16 = -0.470400525; V17 = 0.207971242; V18 = 0.02579058; V19 = 0.40399296; V20 = 0.251412098
        V21 = -0.018306778; V22 = 0.277837576; V23 = -0.11047391; V24 = 0.066928074; V25 = 0.128539358
        V26 = -0.189114844; V27 = 0.133558407; V28 = -0.021053053
        Amount = 2125.87
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8002/detect" -Method POST -ContentType "application/json" -Body $fraud4
    $result = $response.Content | ConvertFrom-Json
    Write-Host "  Resultat: is_fraud=$($result.is_fraud), score=$($result.fraud_score), confidence=$($result.confidence)" -ForegroundColor $(if ($result.is_fraud) { "Red" } else { "Yellow" })
} catch {
    Write-Host "  Erreur: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUME" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si aucune fraude n'est detectee, cela peut signifier:" -ForegroundColor Yellow
Write-Host "  1. Le modele a besoin d'etre reentraine avec plus de donnees frauduleuses"
Write-Host "  2. Le seuil de detection est trop eleve"
Write-Host "  3. Les valeurs de test ne correspondent pas aux patterns appris"
Write-Host ""
Write-Host "Pour ameliorer la detection:" -ForegroundColor Cyan
Write-Host "  - Reentrainer le modele avec plus d'exemples de fraudes"
Write-Host "  - Ajuster le seuil de decision du modele"
Write-Host "  - Utiliser des valeurs reelles du dataset Kaggle"
Write-Host ""

