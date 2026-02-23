# Script khởi động bot an toàn
# Chạy: .\start.ps1

Write-Host "🚀 Starting Telegram Bot..." -ForegroundColor Green

# Kiểm tra .env
if (-not (Test-Path .env)) {
    Write-Host "❌ File .env không tồn tại!" -ForegroundColor Red
    exit 1
}

# Tắt các process node cũ
$oldProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
if ($oldProcesses) {
    Write-Host "🛑 Stopping old bot processes..." -ForegroundColor Yellow
    Stop-Process -Name node -Force
    Start-Sleep -Seconds 2
}

# Kiểm tra node_modules
if (-not (Test-Path node_modules)) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    npm install
}

# Khởi động bot
Write-Host "✅ Starting bot..." -ForegroundColor Green
npm start
