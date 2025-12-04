# PowerShell Script to Setup Kubeconfig for GitLab CI/CD
# Run this in PowerShell (as regular user)

param(
    [switch]$CopyToClipboard = $true,
    [switch]$SaveToFile = $false
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Kubernetes Kubeconfig Setup for GitLab CI/CD" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Path to kubeconfig
$KubeconfigPath = "$env:USERPROFILE\.kube\config"

# Verify kubeconfig exists
if (-not (Test-Path $KubeconfigPath)) {
    Write-Host "Error: Kubeconfig not found at $KubeconfigPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "1. Kubernetes is enabled in Docker Desktop" -ForegroundColor Gray
    Write-Host "2. Kubernetes is running (check Docker Desktop status)" -ForegroundColor Gray
    Write-Host "3. Run 'kubectl cluster-info' to verify connectivity" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "Found kubeconfig at: $KubeconfigPath" -ForegroundColor Green
Write-Host ""

# Verify kubectl can access the cluster
Write-Host "[*] Verifying Kubernetes access..." -ForegroundColor Cyan
try {
    $clusterInfo = kubectl cluster-info 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Kubernetes cluster is accessible" -ForegroundColor Green
    }
    else {
        Write-Host "Warning: kubectl cluster-info returned an error" -ForegroundColor Yellow
        Write-Host $clusterInfo
    }
}
catch {
    Write-Host "Warning: Could not verify cluster access. Continuing anyway..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[*] Reading and encoding kubeconfig..." -ForegroundColor Cyan

# Read kubeconfig
$KubeconfigContent = Get-Content -Path $KubeconfigPath -Raw

# Encode to base64
$KubeconfigBytes = [System.Text.Encoding]::UTF8.GetBytes($KubeconfigContent)
$KubeconfigBase64 = [Convert]::ToBase64String($KubeconfigBytes)

Write-Host "Encoded successfully" -ForegroundColor Green
Write-Host "  Length: $($KubeconfigBase64.Length) characters" -ForegroundColor Gray
Write-Host ""

# Copy to clipboard
if ($CopyToClipboard) {
    Write-Host "[*] Copying to clipboard..." -ForegroundColor Cyan
    $KubeconfigBase64 | Set-Clipboard
    Write-Host "Copied to clipboard!" -ForegroundColor Green
    Write-Host ""
}

# Optionally save to file
if ($SaveToFile) {
    $OutputFile = ".\kube_config_b64.txt"
    $KubeconfigBase64 | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "Also saved to: $OutputFile" -ForegroundColor Green
    Write-Host ""
}

# Display next steps
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS - Add to GitLab CI/CD" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Go to your GitLab project" -ForegroundColor Yellow
Write-Host "   https://gitlab.com/your-group/systeme_detect_fraude" -ForegroundColor Gray
Write-Host ""

Write-Host "2. Navigate to: Settings - CI/CD - Variables" -ForegroundColor Yellow
Write-Host ""

Write-Host "3. Click 'Add variable' button" -ForegroundColor Yellow
Write-Host ""

Write-Host "4. Fill in these values:" -ForegroundColor Yellow
Write-Host "   Key: KUBE_CONFIG" -ForegroundColor Cyan
Write-Host "   Value: paste the base64 string from clipboard" -ForegroundColor Cyan
Write-Host "   Protect variable: Check this" -ForegroundColor Cyan
Write-Host "   Mask variable: Check this" -ForegroundColor Cyan
Write-Host ""

Write-Host "5. Click 'Add variable' button" -ForegroundColor Yellow
Write-Host ""

Write-Host "6. Return to project and push to 'main' or 'develop' branch" -ForegroundColor Yellow
Write-Host "   git push origin main" -ForegroundColor Cyan
Write-Host ""

Write-Host "7. Go to CI/CD - Pipelines to watch deployment" -ForegroundColor Yellow
Write-Host ""

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "VERIFY YOUR SETUP" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "After adding the variable, you can verify by running:" -ForegroundColor Yellow
Write-Host ""
Write-Host "# Check Kubernetes is running" -ForegroundColor Cyan
Write-Host "kubectl cluster-info" -ForegroundColor Gray
Write-Host ""
Write-Host "# Check services will be deployed to:" -ForegroundColor Cyan
Write-Host "kubectl get namespace fraud-detection" -ForegroundColor Gray
Write-Host ""
Write-Host "# After pipeline runs, check pods:" -ForegroundColor Cyan
Write-Host "kubectl get pods -n fraud-detection" -ForegroundColor Gray
Write-Host ""

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Setup Complete! Kubeconfig ready for GitLab CI/CD" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
