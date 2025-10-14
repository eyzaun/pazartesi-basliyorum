# Flutter Hızlı Çalıştırma Script'i
# Kullanım: .\run.ps1

param(
    [string]$device = "",
    [switch]$release,
    [switch]$debug
)

Write-Host "=== Flutter Hızlı Çalıştırma ===" -ForegroundColor Cyan
Write-Host ""

# Cihazları listele
Write-Host "📱 Bağlı cihazlar:" -ForegroundColor Yellow
flutter devices --machine | ConvertFrom-Json | ForEach-Object {
    Write-Host "  - $($_.name) ($($_.id))" -ForegroundColor White
}

Write-Host ""

# Mod seç
$mode = "debug"
if ($release) {
    $mode = "release"
    Write-Host "🚀 Release modunda çalıştırılıyor..." -ForegroundColor Green
} else {
    Write-Host "🐛 Debug modunda çalıştırılıyor..." -ForegroundColor Yellow
}

# Cihaz seç
if ($device) {
    Write-Host "🎯 Hedef cihaz: $device" -ForegroundColor Cyan
    if ($mode -eq "release") {
        flutter run -d $device --release
    } else {
        flutter run -d $device
    }
} else {
    Write-Host "🎯 Varsayılan cihazda çalıştırılıyor..." -ForegroundColor Cyan
    if ($mode -eq "release") {
        flutter run --release
    } else {
        flutter run
    }
}
