# 🌐 Web Deployment - Pazartesi Başlıyorum

## ✅ Deployment Tamamlandı!

**Live URL:** https://pazartesi-basliyorum.web.app

## 🔧 Firebase Console'da Yapılması Gerekenler

### 1. Google OAuth Yapılandırması (ÖNEMLİ!)

**Hata:** `Erişim engellendi: Yetkilendirme hatası - origin_mismatch`

**Çözüm:** Firebase Console'da OAuth redirect URI'leri eklenmeli:

#### Adımlar:

1. **Firebase Console'a Git:**
   - https://console.firebase.google.com/project/pazartesi-basliyorum/overview

2. **Authentication > Settings > Authorized domains:**
   - `pazartesi-basliyorum.web.app` ✅ (Zaten ekli olmalı)
   - `pazartesi-basliyorum.firebaseapp.com` ✅ (Zaten ekli olmalı)

3. **Google Cloud Console'a Git:**
   - https://console.cloud.google.com/apis/credentials?project=pazartesi-basliyorum
   
4. **OAuth 2.0 Client ID'yi düzenle:**
   - Client ID: `167069643931-...` (OAuth 2.0 istemcisi)
   - **Yetkili JavaScript kaynakları** bölümüne ekle:
     ```
     https://pazartesi-basliyorum.web.app
     https://pazartesi-basliyorum.firebaseapp.com
     ```
   
   - **Yetkili yönlendirme URI'leri** bölümüne ekle:
     ```
     https://pazartesi-basliyorum.web.app/__/auth/handler
     https://pazartesi-basliyorum.firebaseapp.com/__/auth/handler
     ```

5. **Kaydet** butonuna tıkla

6. **5-10 dakika bekle** (OAuth ayarlarının yayılması için)

7. **Web sitesini yeniden dene:**
   - https://pazartesi-basliyorum.web.app

## 📦 Web Build Bilgileri

### Firebase Konfigürasyonu
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyBXT19zTsNlUu8gNSC7AcMrsq4Zdgcf-4Q",
  authDomain: "pazartesi-basliyorum.firebaseapp.com",
  projectId: "pazartesi-basliyorum",
  storageBucket: "pazartesi-basliyorum.firebasestorage.app",
  messagingSenderId: "167069643931",
  appId: "1:167069643931:web:a5a72c718ce7ff3bd4c23e",
  measurementId: "G-C5JCZFJJXP"
};
```

### Build İstatistikleri
- **Build Time:** ~37.8s
- **Files Deployed:** 33 files
- **Font Optimization:**
  - CupertinoIcons: 257KB → 1.4KB (99.4% reduction)
  - MaterialIcons: 1.6MB → 14.9KB (99.1% reduction)

## 🚀 Deployment Komutları

### Web için Build
```bash
flutter clean
flutter build web --release
```

### Firebase Hosting'e Deploy
```bash
firebase login
firebase deploy --only hosting
```

### Tek Komutla Build + Deploy
```bash
flutter build web --release && firebase deploy --only hosting
```

## 📱 Platform Karşılaştırması

| Platform | Durum | URL/Dosya |
|----------|-------|-----------|
| 🌐 Web | ✅ Deployed | https://pazartesi-basliyorum.web.app |
| 📱 Android APK | ✅ Built | `build/app/outputs/flutter-apk/app-release.apk` |
| 📦 Android AAB | ✅ Built | `build/app/outputs/bundle/release/app-release.aab` |
| 🍎 iOS | ⏳ Not built | N/A |

## 🔥 Firebase Services Kullanımı

### Web'de Desteklenen Servisler
- ✅ Firebase Authentication (Email, Google Sign-In)
- ✅ Cloud Firestore
- ✅ Firebase Storage
- ✅ Firebase Analytics
- ⚠️ Firebase Messaging (Web push notifications - opsiyonel)

### Web'de DESTEKLENMEYEN Servisler
- ❌ Flutter Local Notifications (Native only)
- ❌ Background sync (Limited support)
- ❌ Hive (Web için alternative: shared_preferences_web)

## ⚠️ Bilinen Sınırlamalar

### 1. Offline-First Sync
Web'de Hive çalışmaz. Alternative:
- IndexedDB kullanımı
- `shared_preferences_web` package
- Firebase Firestore offline persistence

### 2. Background Notifications
Web'de background notifications sınırlı:
- Sadece service worker ile çalışır
- Push notifications için FCM web token gerekli

### 3. Image Picker
Web'de dosya seçici farklı çalışır:
- Drag & drop desteklenir
- Camera access browser permissions gerektirir

## 🧪 Test Checklist

Web deployment'tan sonra test edilmesi gerekenler:

- [ ] Email ile kayıt/giriş
- [ ] Google ile giriş (OAuth düzeltildikten sonra)
- [ ] Habit oluşturma
- [ ] Check-in yapma
- [ ] Profil fotoğrafı yükleme
- [ ] Statistics sayfası
- [ ] Achievements sayfası
- [ ] Social features (friend ekle, habit share)
- [ ] Offline çalışma (limited)
- [ ] Responsive design (mobile, tablet, desktop)

## 📊 Performans

### Lighthouse Scores (Expected)
- Performance: 90+
- Accessibility: 95+
- Best Practices: 90+
- SEO: 100
- PWA: 90+

Test için: https://pagespeed.web.dev/

## 🔒 Güvenlik

### CORS ve API Key
- API Key web'de görünür (normal)
- Firebase Console'dan API restrictions ekleyin:
  - HTTP referrers: `pazartesi-basliyorum.web.app/*`
  - Application restrictions: HTTP referrers

### Firebase Security Rules
Firestore ve Storage rules zaten ayarlanmış:
- `firestore.rules` - Database güvenliği
- `storage.rules` - File upload güvenliği

## 📝 Notlar

1. **Deployment sonrası 5-10 dakika beklenmeli** (CDN propagation)
2. **Cache temizlemek için:** Browser'da `Ctrl+Shift+R` (Hard refresh)
3. **Eski versiyon görünüyorsa:** `firebase hosting:disable` sonra `firebase deploy --only hosting`
4. **Analytics çalışmıyor:** Google Analytics property oluşturun ve measurementId'yi ekleyin

## 🆘 Troubleshooting

### OAuth Hatası Devam Ediyorsa
```bash
# 1. Firebase cache'i temizle
firebase logout
firebase login

# 2. Yeniden deploy
flutter clean
flutter build web --release
firebase deploy --only hosting
```

### Build Hatası
```bash
# Dependencies'i güncelle
flutter pub get
flutter pub upgrade

# Build runner'ı çalıştır
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📞 İletişim

**Developer:** Lonca Games  
**Web App:** https://pazartesi-basliyorum.web.app  
**Firebase Project:** pazartesi-basliyorum  
**Repository:** https://github.com/eyzaun/pazartesi-basliyorum

---

**Son Güncelleme:** 13 Ekim 2025  
**Deployment:** Successful ✅  
**OAuth Fix:** Pending ⏳ (Google Cloud Console'da yapılmalı)
