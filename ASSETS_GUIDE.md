# 🎨 Assets ve Icon Dosyaları Kılavuzu

Bu dosyalar image/icon dosyaları olduğundan kod olarak oluşturulamaz. Aşağıda nasıl edineceğiniz anlatılmıştır.

---

## 📱 Android Launcher Icons

### Gerekli Dosyalar
```
android/app/src/main/res/
├── mipmap-hdpi/
│   └── ic_launcher.png (72x72)
├── mipmap-mdpi/
│   └── ic_launcher.png (48x48)
├── mipmap-xhdpi/
│   └── ic_launcher.png (96x96)
├── mipmap-xxhdpi/
│   └── ic_launcher.png (144x144)
└── mipmap-xxxhdpi/
    └── ic_launcher.png (192x192)
```

### Otomatik Oluşturma
`flutter_launcher_icons` paketi ile otomatik oluşturabilirsiniz:

1. **pubspec.yaml'e ekleyin:**
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/images/app_icon.png"
  adaptive_icon_background: "#6C63FF"
  adaptive_icon_foreground: "assets/images/app_icon_foreground.png"
```

2. **1024x1024 PNG icon hazırlayın** ve `assets/images/app_icon.png` olarak kaydedin.

3. **Komutu çalıştırın:**
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

---

## 🌐 Web Favicon

### web/favicon.png
- **Boyut**: 192x192 piksel
- **Format**: PNG
- **Renk**: Şeffaf arka plan (recommended)

### Nasıl Oluşturulur?

**Seçenek 1: Online Tool**
1. https://favicon.io/favicon-converter/ adresine gidin
2. 512x512 veya daha büyük bir logo yükleyin
3. Generate edin ve indirin
4. `favicon.png` olarak `web/` klasörüne koyun

**Seçenek 2: Photoshop/GIMP**
1. 192x192 piksel canvas oluşturun
2. Logo/icon'unuzu ortaya yerleştirin
3. PNG olarak export edin

**Geçici Çözüm:**
Emoji kullanarak basit bir favicon:
```bash
# 📅 emoji'sini favicon olarak kullanabilirsiniz
# https://favicon.io/emoji-favicons/ adresinden "📅" aratın
```

---

## 🔑 Google Sign-In Icon

### assets/icons/google.png
- **Boyut**: 24x24 veya 48x48 piksel
- **Format**: PNG
- **Renk**: Google'ın resmi "G" logosu

### Nasıl Edinilir?

**Seçenek 1: Resmi Google Brand Resources**
1. https://about.google/brand-resource-center/ adresine gidin
2. Google "G" logosunu indirin
3. 24x24 piksel boyutuna ölçeklendirin
4. `assets/icons/google.png` olarak kaydedin

**Seçenek 2: Emoji/Icon Kullanın**
Code'da şu şekilde değişiklik yapabilirsiniz:
```dart
// Yerine
icon: Image.asset('assets/icons/google.png', height: 24),

// Bunu kullanın (emoji)
icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
```

---

## 🎨 App Icon Tasarım Önerileri

### Temel Özellikler
- **Basit ve Anlaşılır**: Karmaşık detaylardan kaçının
- **Yüksek Kontrast**: Küçük boyutlarda da okunabilir olmalı
- **Merkezi**: İcon merkeze yerleştirilmeli
- **Şeffaf Kenar**: Adaptive icon için önemli

### Renk Paleti (Mevcut Tema)
- Primary: `#6C63FF` (Mor)
- Secondary: `#03DAC6` (Turkuaz)
- Accent: `#FF6B6B` (Kırmızı)

### Örnek Icon Fikirleri
1. 📅 Takvim + Check işareti
2. ✅ Check mark + Pazartesi "P" harfi
3. 🎯 Hedef simgesi + Alışkanlık göstergesi
4. 📊 İlerleme çubuğu + Takvim

---

## 🛠️ Hızlı Kurulum Scripti

Tüm icon'ları otomatik oluşturmak için:

```bash
# 1. flutter_launcher_icons yükle
flutter pub add flutter_launcher_icons --dev

# 2. pubspec.yaml'e config ekle (yukarıdaki gibi)

# 3. 1024x1024 app icon hazırla (Canva, Figma, vb.)

# 4. Icon'ları oluştur
flutter pub run flutter_launcher_icons

# 5. Web favicon için
# https://favicon.io/favicon-converter/ kullan
```

---

## 📦 Placeholder Icon'lar (Geliştirme İçin)

Geliştirme sırasında placeholder kullanabilirsiniz:

### Android Launcher
Flutter varsayılan icon'u zaten var, değiştirmeden test edebilirsiniz.

### Web Favicon
Hiç yoksa tarayıcı varsayılan icon'u gösterir, sorun değil.

### Google Icon
Code'da emoji ("G") kullanarak geçici çözüm yapabilirsiniz.

---

## ✅ Checklist

- [ ] 1024x1024 app icon tasarlandı
- [ ] `flutter_launcher_icons` ile Android icon'ları oluşturuldu
- [ ] Web favicon (192x192) oluşturuldu ve `web/` klasörüne kondu
- [ ] Google icon (24x24) `assets/icons/` klasörüne kondu
- [ ] `pubspec.yaml`'da assets tanımları yapıldı:
  ```yaml
  flutter:
    assets:
      - assets/images/
      - assets/icons/
  ```

---

## 🎓 Öğretici Kaynaklar

### Icon Oluşturma Tools
- **Canva**: https://canva.com (ücretsiz)
- **Figma**: https://figma.com (ücretsiz)
- **GIMP**: https://gimp.org (ücretsiz, desktop)
- **Photopea**: https://photopea.com (ücretsiz, browser)

### Icon Inspiration
- **Dribbble**: https://dribbble.com/tags/app-icon
- **Behance**: https://behance.net/search/projects?search=app%20icon
- **Material Design**: https://material.io/design/iconography

### Flutter Icon Tools
- **flutter_launcher_icons**: https://pub.dev/packages/flutter_launcher_icons
- **flutter_native_splash**: https://pub.dev/packages/flutter_native_splash

---

## 🚀 Production Hazırlık

Production'a geçmeden önce:

1. ✅ Tüm platform icon'ları oluşturuldu
2. ✅ Icon'lar optimize edildi (dosya boyutu)
3. ✅ Tüm boyutlarda test edildi
4. ✅ Brand guidelines'a uygun
5. ✅ Telif hakkı sorunsuz

---

## 💡 İpuçları

- **SVG Kullanın**: Vektör formatı kaynak olarak kullanın, raster'a çevirirken kalite kaybı olmaz
- **Adaptive Icons**: Android için adaptive icon kullanın (API 26+)
- **Test Edin**: Farklı cihaz ve boyutlarda test edin
- **Consistency**: Tüm platformlarda tutarlı tasarım

---

**Not**: Bu dosyalar olmadan da uygulama çalışır, ancak professional görünüm için gereklidir.