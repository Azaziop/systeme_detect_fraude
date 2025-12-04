@echo off
REM Script to extract and encode kubeconfig for GitLab CI/CD deployment
REM Run this in PowerShell (Admin) - DO NOT use cmd.exe

echo.
echo ====================================
echo Kubernetes Kubeconfig Setup for GitLab CI/CD
echo ====================================
echo.

setlocal enabledelayedexpansion

REM Check if kubeconfig exists
set KUBECONFIG_PATH=%USERPROFILE%\.kube\config

if not exist "%KUBECONFIG_PATH%" (
    echo Error: Kubeconfig not found at %KUBECONFIG_PATH%
    echo.
    echo Make sure Kubernetes is enabled in Docker Desktop and run:
    echo   kubectl cluster-info
    echo.
    pause
    exit /b 1
)

echo [✓] Found kubeconfig at: %KUBECONFIG_PATH%
echo.

REM Read file and encode to base64 (PowerShell call)
echo [*] Encoding kubeconfig to base64...
powershell -NoProfile -Command ^
    "$KubeConfig = Get-Content '%KUBECONFIG_PATH%' -Raw; " ^
    "$Base64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($KubeConfig)); " ^
    "$Base64 | Out-File -FilePath '%TEMP%\kube_b64.txt' -Encoding ASCII; " ^
    "Write-Host \"[✓] Encoded. Length: $($Base64.Length) characters\""

echo.
echo [*] Copying to clipboard...
powershell -NoProfile -Command ^
    "$Base64 = Get-Content '%TEMP%\kube_b64.txt'; " ^
    "$Base64 | Set-Clipboard; " ^
    "Write-Host \"[✓] Copied to clipboard!\""

echo.
echo ====================================
echo Next Steps:
echo ====================================
echo.
echo 1. Go to GitLab project:
echo    Project > Settings > CI/CD > Variables
echo.
echo 2. Click "Add variable"
echo.
echo 3. Fill in:
echo    Key:        KUBE_CONFIG
echo    Value:      (paste from clipboard)
echo    Protect:    [✓]
echo    Mask:       [✓]
echo.
echo 4. Click "Add variable"
echo.
echo 5. Push to main or develop branch to trigger deployment
echo.
echo ====================================
echo.

pause
