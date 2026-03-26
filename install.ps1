$ErrorActionPreference = "Stop"

# --- CONFIGURAZIONE ---
$repoOwner = "xellafe"
$repoName  = "quack-click"
$branch    = "main"
$baseUrl   = "https://raw.githubusercontent.com/$repoOwner/$repoName/$branch"

# --- SETUP ---
$dir = Join-Path $env:TEMP "keyboard-clicker"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

Write-Host "Downloading..." -ForegroundColor Cyan
Invoke-WebRequest "$baseUrl/click.wav"          -OutFile (Join-Path $dir "click.wav")
Invoke-WebRequest "$baseUrl/keyboard-click.ps1" -OutFile (Join-Path $dir "keyboard-click.ps1")

Write-Host "Avvio in background..." -ForegroundColor Green
Start-Process powershell -ArgumentList @(
    "-WindowStyle", "Hidden",
    "-ExecutionPolicy", "Bypass",
    "-File", (Join-Path $dir "keyboard-click.ps1")
) -WindowStyle Hidden

Write-Host "Attivo! Per fermarlo: Stop-Process -Name powershell" -ForegroundColor Yellow
