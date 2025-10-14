# APK Kurulum Script'i
# Kullanım: .\install.ps1

Write-Host "=== Flutter APK Kurulum ===" -ForegroundColor Cyan
Write-Host ""

$adbPath = "E:\Android\Sdk\platform-tools\adb.exe"

# APK dosyalarını bul
$releaseApk = "build\app\outputs\flutter-apk\app-release.apk"
$debugApk = "build\app\outputs\flutter-apk\app-debug.apk"

Write-Host "📱 Bağlı cihazlar:" -ForegroundColor Yellow
& $adbPath devices

Write-Host ""
Write-Host "Hangi APK'yi kurmak istiyorsunuz?" -ForegroundColor Cyan
Write-Host "1. Release APK (küçük boyut, optimize edilmiş)" -ForegroundColor Green
Write-Host "2. Debug APK (hot reload, debugging)" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Seçiminiz (1 veya 2)"

$apkPath = $releaseApk
if ($choice -eq "2") {
    $apkPath = $debugApk
    Write-Host "🐛 Debug APK kuruluyor..." -ForegroundColor Yellow
} else {
    Write-Host "🚀 Release APK kuruluyor..." -ForegroundColor Green
}

if (Test-Path $apkPath) {
    Write-Host ""
    Write-Host "📦 Kuruluyor: $apkPath" -ForegroundColor Cyan
    & $adbPath install -r $apkPath
    Write-Host ""
    Write-Host "✅ Kurulum tamamlandı!" -ForegroundColor Green
} else {
    Write-Host "❌ APK bulunamadı: $apkPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Önce build alın:" -ForegroundColor Yellow
    Write-Host "  flutter build apk --release" -ForegroundColor White
}

Write-Host ""
Write-Host "Kapatmak için Enter'a basın..."
Read-Host
