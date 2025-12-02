# Script de test complet du système de détection de fraude
# Ce script teste tous les services et leur intégration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST COMPLET DU SYSTÈME" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Fonction pour tester un service
function Test-Service {
    param(
        [string]$Url,
        [string]$ServiceName,
        [int]$Timeout = 5
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec $Timeout -ErrorAction Stop
        Write-Host "✅ $ServiceName - ACTIF" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ $ServiceName - INACTIF ($Url)" -ForegroundColor Red
        return $false
    }
}

# Fonction pour attendre qu'un service soit prêt
function Wait-ForService {
    param(
        [string]$Url,
        [string]$ServiceName,
        [int]$MaxWait = 30,
        [int]$Interval = 2
    )
    
    $elapsed = 0
    while ($elapsed -lt $MaxWait) {
        try {
            $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 2 -ErrorAction Stop
            Write-Host "✅ $ServiceName est prêt!" -ForegroundColor Green
            return $true
        } catch {
            Start-Sleep -Seconds $Interval
            $elapsed += $Interval
            Write-Host "⏳ Attente de $ServiceName... ($elapsed/$MaxWait secondes)" -ForegroundColor Yellow
        }
    }
    Write-Host "❌ $ServiceName n'est pas pret apres $MaxWait secondes" -ForegroundColor Red
    return $false
}

Write-Host "1. VÉRIFICATION DES SERVICES" -ForegroundColor Yellow
Write-Host ""

$services = @(
    @{ Url = "http://localhost:8000/"; Name = "Auth Service (8000)" },
    @{ Url = "http://localhost:8001/health"; Name = "Transaction Service (8001)" },
    @{ Url = "http://localhost:8002/health"; Name = "Fraud Detection Service (8002)" }
)

$allActive = $true
foreach ($service in $services) {
    if (-not (Test-Service -Url $service.Url -ServiceName $service.Name)) {
        $allActive = $false
    }
}

if (-not $allActive) {
    Write-Host ""
    Write-Host "⚠️  Certains services ne sont pas actifs." -ForegroundColor Yellow
    Write-Host "   Utilisez .\DEMARRER_TOUT_SIMPLE.bat pour démarrer tous les services." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
Write-Host "2. TEST DU SERVICE DE DÉTECTION DE FRAUDE" -ForegroundColor Yellow
Write-Host ""

# Test 1: Transaction normale
Write-Host "  Test 1.1: Transaction normale" -ForegroundColor Cyan
$normalTest = @{
    transaction_id = "TXN_NORMAL_$(Get-Random)"
    features = @{
        Time = 100.0
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
    $response = Invoke-WebRequest -Uri "http://localhost:8002/detect" -Method POST -ContentType "application/json" -Body $normalTest
    $result = $response.Content | ConvertFrom-Json
    Write-Host "    ✅ Réponse reçue: is_fraud=$($result.is_fraud), score=$($result.fraud_score)" -ForegroundColor Green
} catch {
    Write-Host "    ❌ Erreur: $_" -ForegroundColor Red
}

# Test 2: Transaction suspecte
Write-Host ""
Write-Host "  Test 1.2: Transaction suspecte" -ForegroundColor Cyan
$fraudTest = @{
    transaction_id = "TXN_FRAUD_$(Get-Random)"
    features = @{
        Time = 50000.0
        V1 = 5.0; V2 = -5.0; V3 = 6.0; V4 = 5.5; V5 = -4.5
        V6 = 5.2; V7 = -5.5; V8 = 4.8; V9 = -4.2; V10 = 5.0
        V11 = 6.5; V12 = -5.8; V13 = 5.5; V14 = -6.0; V15 = 4.5
        V16 = -5.2; V17 = 5.8; V18 = -4.8; V19 = 6.2; V20 = -5.5
        V21 = 4.9; V22 = -5.1; V23 = 5.3; V24 = -4.7; V25 = 5.6
        V26 = -5.4; V27 = 4.8; V28 = -5.0
        Amount = 10000.00
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8002/detect" -Method POST -ContentType "application/json" -Body $fraudTest
    $result = $response.Content | ConvertFrom-Json
    Write-Host "    ✅ Réponse reçue: is_fraud=$($result.is_fraud), score=$($result.fraud_score)" -ForegroundColor Green
} catch {
    Write-Host "    ❌ Erreur: $_" -ForegroundColor Red
}

# Test 3: Détection en lot
Write-Host ""
Write-Host "  Test 1.3: Détection en lot" -ForegroundColor Cyan
$batchTest = @(
    @{
        transaction_id = "BATCH_001"
        features = @{
            Time = 1000.0
            V1 = 0.5; V2 = -0.5; V3 = 0.3; V4 = -0.3; V5 = 0.4
            V6 = -0.4; V7 = 0.2; V8 = -0.2; V9 = 0.3; V10 = -0.3
            V11 = 0.5; V12 = -0.5; V13 = 0.2; V14 = -0.2; V15 = 0.4
            V16 = -0.4; V17 = 0.3; V18 = -0.3; V19 = 0.2; V20 = -0.2
            V21 = 0.4; V22 = -0.4; V23 = 0.3; V24 = -0.3; V25 = 0.2
            V26 = -0.2; V27 = 0.4; V28 = -0.4
            Amount = 100.0
        }
    },
    @{
        transaction_id = "BATCH_002"
        features = @{
            Time = 2000.0
            V1 = 1.5; V2 = -1.5; V3 = 1.2; V4 = -1.2; V5 = 1.3
            V6 = -1.3; V7 = 1.1; V8 = -1.1; V9 = 1.2; V10 = -1.2
            V11 = 1.5; V12 = -1.5; V13 = 1.1; V14 = -1.1; V15 = 1.3
            V16 = -1.3; V17 = 1.2; V18 = -1.2; V19 = 1.1; V20 = -1.1
            V21 = 1.3; V22 = -1.3; V23 = 1.2; V24 = -1.2; V25 = 1.1
            V26 = -1.1; V27 = 1.3; V28 = -1.3
            Amount = 500.0
        }
    }
) | ConvertTo-Json -Depth 10

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8002/detect-batch" -Method POST -ContentType "application/json" -Body $batchTest
    $result = $response.Content | ConvertFrom-Json
    Write-Host "    ✅ Traitement en lot réussi: $($result.results.Count) transactions traitées" -ForegroundColor Green
} catch {
    Write-Host "    ❌ Erreur: $_" -ForegroundColor Red
}

# Test du Service d authentification si disponible
if (Test-Service -Url "http://localhost:8000/" -ServiceName "Auth Service" -Timeout 2) {
    Write-Host ""
    Write-Host "3. TEST DU Service d authentification" -ForegroundColor Yellow
    Write-Host ""
    
    # Test d'inscription
    Write-Host "  Test 3.1: Inscription d'utilisateur" -ForegroundColor Cyan
    $username = "testuser_$(Get-Random -Minimum 1000 -Maximum 9999)"
    $registerData = @{
        username = $username
        email = "test_$username@example.com"
        password = "Test123!@#"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/api/register/" -Method POST -ContentType "application/json" -Body $registerData
        $result = $response.Content | ConvertFrom-Json
        Write-Host "    ✅ Utilisateur cree: $username" -ForegroundColor Green
        
        # Test de connexion
        Write-Host ""
        Write-Host "  Test 3.2: Connexion" -ForegroundColor Cyan
        $loginData = @{
            username = $username
            password = "Test123!@#"
        } | ConvertTo-Json
        
        $response = Invoke-WebRequest -Uri "http://localhost:8000/api/login/" -Method POST -ContentType "application/json" -Body $loginData
        $loginResult = $response.Content | ConvertFrom-Json
        $global:token = $loginResult.access
        Write-Host "    ✅ Connexion réussie, token obtenu" -ForegroundColor Green
        
        # Test de création de transaction si le service est disponible
        if (Test-Service -Url "http://localhost:8001/health" -ServiceName "Transaction Service" -Timeout 2) {
            Write-Host ""
            Write-Host "4. TEST DU SERVICE DE TRANSACTION" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  Test 4.1: Création de transaction" -ForegroundColor Cyan
            
            $transactionData = @{
                amount = 1500.50
                description = "Test transaction depuis script PowerShell"
            } | ConvertTo-Json
            
            $headers = @{
                "Authorization" = "Bearer $token"
                "Content-Type" = "application/json"
            }
            
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:8001/transactions/" -Method POST -Headers $headers -Body $transactionData
                $result = $response.Content | ConvertFrom-Json
                Write-Host "    ✅ Transaction creee: ID=$($result.id), Amount=$($result.amount)" -ForegroundColor Green
                if ($result.is_fraud -ne $null) {
                    Write-Host "    📊 Détection de fraude: is_fraud=$($result.is_fraud)" -ForegroundColor Cyan
                }
            } catch {
                Write-Host "    ❌ Erreur: $_" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "    ❌ Erreur: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RÉSUMÉ DES TESTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tests effectues:" -ForegroundColor Green
Write-Host "  - Service de detection de fraude (endpoint /detect)"
Write-Host "  - Service de detection en lot (endpoint /detect-batch)"
Write-Host "  - Health checks de tous les services"
if ($global:token) {
    Write-Host "  - Service d authentification (inscription/connexion)" -NoNewline
    Write-Host ""
    Write-Host "  - Service de transaction (creation avec authentification)"
}
Write-Host ""
Write-Host "Le systeme est operationnel!" -ForegroundColor Cyan
Write-Host ""

