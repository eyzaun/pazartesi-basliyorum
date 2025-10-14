# Wi-Fi üzerinden Flutter cihaz bağlantısı için basit script
# Kullanım: .\wifi-connect.ps1

Write-Host "=== Flutter Wi-Fi Cihaz Bağlantısı ===" -ForegroundColor Cyan
Write-Host ""

# ADB path
$adbPath = "E:\Android\Sdk\platform-tools\adb.exe"

# ADB var mı kontrol et
if (-not (Test-Path $adbPath)) {
    Write-Host "❌ ADB bulunamadı: $adbPath" -ForegroundColor Red
    Write-Host "Flutter SDK path'inden adb bulunuyor..." -ForegroundColor Yellow
    
    # Flutter'ın kendi adb'sini kullan
    $flutterPath = (Get-Command flutter -ErrorAction SilentlyContinue).Source
    if ($flutterPath) {
        $flutterDir = Split-Path (Split-Path $flutterPath)
        $adbPath = Join-Path $flutterDir "bin\cache\artifacts\engine\android-arm-release\adb.exe"
    }
}

Write-Host "🔍 Bağlı cihazları kontrol ediyorum..." -ForegroundColor Yellow
& $adbPath devices

Write-Host ""
Write-Host "📱 USB ile telefonu bağlayın ve Enter'a basın..." -ForegroundColor Green
Read-Host

# TCP moduna geç
Write-Host "🔄 TCP moduna geçiliyor (port 5555)..." -ForegroundColor Yellow
& $adbPath tcpip 5555
Start-Sleep -Seconds 2

# IP adresini al
Write-Host "🌐 Telefon IP adresi alınıyor..." -ForegroundColor Yellow
$ipAddress = & $adbPath shell ip addr show wlan0 | Select-String -Pattern "inet\s+(\d+\.\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }

if ($ipAddress) {
    Write-Host "✅ IP Adresi bulundu: $ipAddress" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔌 Artık USB kabloyu çıkarabilirsiniz!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📡 Wi-Fi bağlantısı kuruluyor..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    
    & $adbPath connect "${ipAddress}:5555"
    
    Write-Host ""
    Write-Host "🎉 Bağlantı tamamlandı!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Test için: flutter devices" -ForegroundColor Cyan
} else {
    Write-Host "❌ IP adresi alınamadı!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manuel olarak bağlanın:" -ForegroundColor Yellow
    Write-Host "1. Telefon Ayarlar → Wi-Fi → IP adresini not edin" -ForegroundColor White
    Write-Host "2. Şu komutu çalıştırın: $adbPath connect IP_ADRESI:5555" -ForegroundColor White
}

Write-Host ""
Write-Host "Kapatmak için Enter'a basın..."
Read-Host
