# Script pour tester la detection avec un seuil ajuste

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST AVEC SEUIL AJUSTE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Le service utilise maintenant un seuil de 0.03 au lieu de 0.5" -ForegroundColor Yellow
Write-Host "Cela permet de detecter plus de transactions suspectes." -ForegroundColor Yellow
Write-Host ""

# Test avec les memes patterns qu'avant
$tests = @(
    @{
        name = "Valeurs extremes V11-V15"
        data = @{
            transaction_id = "FRAUD_EXTREME_001"
            features = @{
                Time = 50000.0
                V1 = 3.5; V2 = -3.5; V3 = 4.0; V4 = 3.8; V5 = -3.2
                V6 = 3.6; V7 = -3.8; V8 = 3.4; V9 = -3.0; V10 = 3.5
                V11 = 5.5; V12 = -5.8; V13 = 6.0; V14 = -6.2; V15 = 5.0
                V16 = -4.5; V17 = 4.0; V18 = -4.2; V19 = 3.8; V20 = -3.5
                V21 = 4.2; V22 = -4.0; V23 = 3.6; V24 = -3.8; V25 = 4.0
                V26 = -4.2; V27 = 3.5; V28 = -3.6
                Amount = 15000.00
            }
        }
    },
    @{
        name = "Anomalies V14/V12"
        data = @{
            transaction_id = "FRAUD_PATTERN_002"
            features = @{
                Time = 25000.0
                V1 = -1.0; V2 = 0.5; V3 = -0.8; V4 = 0.6; V5 = -0.5
                V6 = 0.4; V7 = -0.6; V8 = 0.5; V9 = -0.4; V10 = 0.3
                V11 = 2.5; V12 = -4.5; V13 = 1.8; V14 = -5.0; V15 = 2.0
                V16 = -1.5; V17 = 1.2; V18 = -1.3; V19 = 1.0; V20 = -0.8
                V21 = 1.1; V22 = -1.0; V23 = 0.9; V24 = -1.1; V25 = 1.0
                V26 = -0.9; V27 = 0.8; V28 = -0.7
                Amount = 8000.00
            }
        }
    }
)

foreach ($test in $tests) {
    Write-Host "Test: $($test.name)" -ForegroundColor Cyan
    $json = $test.data | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8002/detect" -Method POST -ContentType "application/json" -Body $json
        $result = $response.Content | ConvertFrom-Json
        
        $color = if ($result.is_fraud) { "Red" } else { "Yellow" }
        $icon = if ($result.is_fraud) { "🚨 FRAUDE DETECTEE!" } else { "⚠️  Suspect mais non-fraude" }
        
        Write-Host "  $icon" -ForegroundColor $color
        Write-Host "  is_fraud: $($result.is_fraud)" -ForegroundColor $color
        Write-Host "  fraud_score: $($result.fraud_score)" -ForegroundColor $color
        Write-Host "  confidence: $($result.confidence)" -ForegroundColor $color
        Write-Host ""
    } catch {
        Write-Host "  ❌ Erreur: $_" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUME" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Avec le seuil ajuste a 0.03:" -ForegroundColor Yellow
Write-Host "  - Les transactions avec score >= 0.03 seront detectees comme frauduleuses" -ForegroundColor White
Write-Host "  - Cela augmente la sensibilite du modele" -ForegroundColor White
Write-Host "  - Attention: cela peut aussi augmenter les faux positifs" -ForegroundColor Yellow
Write-Host ""

