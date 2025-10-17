# Pazartesi Başlıyorum — Kod ve Konfigürasyon Analiz Raporu

Tarih: 2025-10-16

Bu dosya, projeyi baştan sona tarayıp elde ettiğim bulguları, dosya görev açıklamalarını, kullanılan bağımlılıkları, konfigürasyon kanıtlarını ve önemli önerileri düzenli bir rapor halinde içerir.

## Özet
- Proje: Flutter uygulaması — "Pazartesi Başlıyorum" (alışkanlık takip uygulaması).
- Mimari: Clean Architecture (Domain / Data / Presentation), Riverpod ile durum yönetimi, Hive ile yerel kuyruk/önbellek, Firebase (Auth, Firestore, Storage, Messaging) backend, offline-first için bir SyncService.
- Platformlar: Android, iOS, Web, (Windows/macOS için de `firebase_options.dart` içinde yapılandırma mevcut).

## Yapılanlar (kısa)
- Proje envanteri çıkarıldı (dizinler, önemli dosyalar).
- `pubspec.yaml`, `l10n.yaml`, `firebase_options.dart`, Android ve Web konfigürasyonları incelendi.
- `lib/` altındaki `core`, `features`, `shared` dizinleri okunup önemli dosyaların işlevleri çıkartıldı.
- Derleme/hata taraması yapıldı; bulunan bir import hatası düzeltildi (`habits_provider.dart`).
- Offline-first sinkronizasyon, bildirim servisleri ve auth akışının çalışma şekli belgelendi.

---

## 1) Proje kök yapısı
Kök dizin önemli dosyaları:
- `pubspec.yaml` — bağımlılıklar, assets, generate: true
- `README.md` — proje açıklaması, nasıl çalıştırılır, mimari notları
- `lib/` — uygulama kaynak kodu (entry: `main.dart`)
- `android/` — Android proje ve Gradle konfigürasyonları (`google-services.json`, `key.properties`)
- `ios/` — iOS klasörü (Info.plist vb.)
- `web/` — Web build ve `index.html` (Firebase web config gömülü)
- `assets/` — resimler ve ikonlar (`assets/images/`, `assets/icons/`)
- `l10n.yaml`, `lib/l10n` — yerelleştirme (ARB ve üretilmiş dart localization dosyaları)

Bu liste, workspace taraması ve dosya okuma (read_file) sonuçlarına dayanır.

---

## 2) Bağımlılıklar (kaynak: `pubspec.yaml`)
Öne çıkan paketler:
- firebase: `cloud_firestore`, `firebase_auth`, `firebase_core`, `firebase_messaging`, `firebase_storage`
- `flutter_riverpod`
- `hive`, `hive_flutter`, `hive_generator` (dev)
- `freezed_annotation`, `freezed` (dev)
- `json_annotation`, `json_serializable` (dev)
- `build_runner` (dev)
- `google_sign_in`
- `flutter_local_notifications`
- `timezone`, `rxdart`, `uuid`
- UI/yararlı paketler: `cached_network_image`, `fl_chart`, `shimmer`, `table_calendar`, `flutter_slidable`
- Multimedia & device: `audioplayers`, `just_audio`, `geolocator`, `permission_handler`, `image_picker`, `flutter_image_compress`

Not: Tam bağımlılık listesi `pubspec.yaml`'de bulunmaktadır.

---

## 3) Giriş (Entry) ve ana servisler
- `lib/main.dart`:
  - Firebase initialization: `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
  - Hive initialization: `Hive.initFlutter()` ve `Hive.registerAdapter(SyncQueueItemAdapter())`
  - Timezone initialization: `tz.initializeTimeZones()`
  - ProviderScope ile Riverpod başlatma
  - Notification ve PushNotification servislerinin initialize edilmesi

- `lib/firebase_options.dart`: FlutterFire CLI tarafından üretilmiş; platform bazlı Firebase seçenekleri (apiKey, appId, projectId).

---

## 4) Core servisler
- `lib/core/services/notification_service.dart` — Lokal bildirimler (flutter_local_notifications + timezone)
- `lib/core/services/push_notification_service.dart` — FCM işlemleri (token alma, mesaj dinleme, Firestore'a token kaydetme)
- `lib/core/services/sync_service.dart` — Offline-first SyncService (Hive `sync_queue` kutusu, Firestore'a create/update/delete işlemleri, retry mekanizması)
- `lib/core/services/sync_queue_item.dart` — Hive model (queue öğesi)
- `lib/core/routing/app_router.dart` — Tüm route'ları yöneten merkezi router
- `lib/core/theme/app_theme.dart` — Light/Dark tema konfigürasyonları

---

## 5) Clean Architecture: features dizinleri örnekleri
Her feature (`auth`, `habits`, `social`, `achievements`, `goals`, `profile`) genelde şu yapıyı takip ediyor:
- `domain/` — entities, repositories, usecases
- `data/` — datasources (remote/local), models, repository implementations
- `presentation/` — screens, widgets, providers (Riverpod)

Örnek: `habits` feature
- `lib/features/habits/domain/entities` — `habit.dart`, `habit_log.dart`, `streak_recovery.dart`, `timer_session.dart`
- `lib/features/habits/data/models` — `habit_model.dart`, `habit_log_model.dart`, `streak_recovery_model.dart`, `timer_session_model.dart`
- `lib/features/habits/data/datasources` — `habit_remote_datasource.dart`, `timer_session_remote_datasource.dart`
- `lib/features/habits/data/repositories` — `habit_repository_impl.dart`, `offline_first_habit_repository.dart`, `timer_session_repository_impl.dart`
- `lib/features/habits/presentation/screens` — `home_screen.dart`, `today_screen.dart`, `create_habit_screen.dart`, `edit_habit_screen.dart`, `habit_detail_screen.dart`, `habit_timer_screen.dart` vb.
- `lib/features/habits/presentation/widgets` — kartlar, grafik kartları, sheet'ler, progress ring vb.
- `lib/features/habits/presentation/providers` — `habits_provider.dart`, `habitActionProvider` (StateNotifier)

Bu yapı, kod içindeki dosya içeriklerinden ve import hiyerarşisinden çıkarıldı.

---

## 6) Offline-first akış (özet)
- Local queue: `SyncQueueItem` (Hive) ile işlemler kuyruğa eklenir (`SyncService.queueOperation`)
- `SyncService` connectivity değişikliklerini dinler; online olunca `syncPendingOperations()` çağırır
- `_syncOperation` içindeki `_syncCreate/_syncUpdate/_syncDelete` Firestore koleksiyonlarına yazar
- Retry mekanizması: `retryCount`, max 3 deneme. Başarısız işlemler `getFailedOperations()` ile izlenir

---

## 7) Authentication
- Firebase Auth ve Google Sign-In kullanılıyor
- `auth_remote_datasource.dart` ve `auth_repository_impl.dart` ile auth işlemleri gerçekleştiriliyor
- `auth_provider.dart` içinde provider'lar: `firebaseAuthProvider`, `firestoreProvider`, `googleSignInProvider`, `authRepositoryProvider`, `authStateProvider`, `currentUserProvider`
- `presentation/screens` içinde sign-in/sign-up/onboarding akışı implemente edilmiştir

---

## 8) Bildirimler
- Lokal: `notification_service.dart` (zonedSchedule, Darwin/Android init)
- Push: `push_notification_service.dart` (FCM token alınıp Firestore `users` dokümanına kaydediliyor)
- Web: `web/index.html` içinde Firebase SDK scriptleri ve web config var

---

## 9) Localization
- `l10n.yaml` -> `lib/l10n` ARB dosyaları (`app_tr.arb`, `app_en.arb`) ve `app_localizations.dart` (generated) var
- `MaterialApp` içinde `localizationsDelegates` ve `supportedLocales` ayarlı; default `Locale('tr')`

---

## 10) Assets
- `assets/icons/`
- `assets/images/`
- `pubspec.yaml` içinde assets tanımları mevcut
- Uygulamada örnek asset kullanımı: `assets/icons/google_logo.png` (Sign In ekranında) — eğer asset yoksa `errorBuilder` fallback uygulanıyor

---

## 11) Platform konfigürasyon
- `android/app/google-services.json` — Firebase proje numarası (`167069643931`), `project_id: pazartesi-basliyorum`, `apiKey` ve OAuth client ID'ler ile SHA sertifika hash'leri
- `android/key.properties` — keystore parolaları açık şekilde tutulmuş: `storePassword=542.Ezu.143.` (uyarı: bu bir secret'tır)
- `android/app/build.gradle` — `com.google.gms.google-services` plugin, release signing config keystoreProperties ile
- `web/index.html` — web firebase config (apiKey, authDomain, projectId, appId, measurementId)
- `lib/firebase_options.dart` — platform bazlı FirebaseOptions (apiKey, appId, projectId)

### Android manifest (örnek önemli öğeler)
`android/app/src/main/AndroidManifest.xml` içeriğinden önemli parçalar:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<application android:label="Pazartesi Başlıyorum" android:icon="@mipmap/ic_launcher" android:usesCleartextTraffic="true">
  <activity android:name=".MainActivity" android:exported="true" android:launchMode="singleTop" android:theme="@style/LaunchTheme">
    <intent-filter>
      <action android:name="android.intent.action.MAIN"/>
      <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
  </activity>
</application>
```

Not: Manifest, uygulamanın bildirim ve ağ izinlerini içerir; `POST_NOTIFICATIONS` özellikle Android 13+ için tanımlanmıştır.

### iOS
- Repo içinde `ios/Runner/Info.plist` dosyası çalıştırılabilir read erişiminde bulunamadı (dosya mevcut değil veya farklı bir yol). Bu nedenle iOS Info.plist içeriği rapora eklenemedi. Eğer bu dosyayı görmek isterseniz lütfen workspace'e ekleyin veya yolunu doğrulayın.

### Web
- `web/manifest.json` içinde PWA ikonları ve meta bilgiler bulunuyor (Icon-192, Icon-512 ve maskable ikonlar listelenmiş).
- `web/index.html` içinde Firebase SDK ve web config (apiKey: `AIzaSyBXT19zTsNlUu8gNSC7AcMrsq4Zdgcf-4Q`, projectId: `pazartesi-basliyorum`, appId: `1:167069643931:web:a5a72c718ce7ff3bd4c23e`) gömülü.

---

## 18) Assets detayları (okunanlar)
Assets dizinleri okundu ve içeriği listelendi:

- `assets/icons/`
  - `google.png`
  - `.gitkeep`

- `assets/images/`
  - `.gitkeep`

- `web/` ile ilişkili varlıklar:
  - `web/favicon.png`
  - `web/manifest.json` (PWA ikonları: `icons/Icon-192.png`, `icons/Icon-512.png`, `icons/Icon-maskable-192.png`, `icons/Icon-maskable-512.png`)

Not: `assets/icons/google.png` uygulamada Google sign-in ikonuna referans veren varlıktır. Eğer projede başka spesifik image dosyaları varsa onları da listeleyebilirim (şu an sadece `.gitkeep` ve `google.png` görünüyor).


---

## 12) Bulunan hata ve düzeltme
- Hata: `lib/features/habits/presentation/providers/habits_provider.dart` içinde hatalı import: `hide firestoreProvider` (olmayan bir isim gizleme)
- Düzeltme: `hide firestoreProvider` kaldırıldı. (Dosya güncellendi)
- Sonrasında statik hata taraması "No errors found." döndü.

---

## 13) Güvenlik uyarıları
- `android/key.properties` içinde keystore parolası açık şekilde duruyor. Bu ciddi bir risk olabilir.
- `upload-keystore.jks` repo içindeyse yine risklidir. Tavsiye: üretim keystore ve parolalarını repo dışında gizli yönetimlere taşıyın.
- `firebase_options.dart` ve `web/index.html` içinde API anahtarları var — web API key'leri genelde public kabul edilse de, hassas credential'lar için dikkat edilmelidir.

---

## 14) Öneriler
1. `key.properties` içindeki parolaları kaldırıp CI secret veya environment variable kullanın. `key.properties` yerine `key.properties.template` kullanın.
2. CI pipeline: `flutter analyze`, `flutter test`, `flutter pub get` adımlarını ekleyin.
3. Unit test kapsamını artırın (SyncService, repository katmanları, notification service için entegrasyon testleri).
4. README temizliği: tekrar eden bölümleri sadeleştirin.

---

## 15) Next steps (kullanıcı tercihine göre)
- İsterseniz tüm `lib/` dosyaları için 1 satırlık açıklama tablosu oluştururum.
- Veya assets full listesi çıkartayım ve `pubspec.yaml` ile eşleştirip eksik asset kontrolü yapayım.
- Veya CI/test komutlarını sizin ortamda çalıştırıp çıkan hataları raporlayayım.

---

## 16) Değişiklik geçmişi (bu analiz sırasında yapılan değişiklikler)
- `lib/features/habits/presentation/providers/habits_provider.dart` import düzeltmesi (hide ifadesi kaldırıldı)

---

## 17) İlgili dosya alıntıları / kanıt noktaları
- `pubspec.yaml` bağımlılık listesi (dosyayı repo'dan okudum)
- `lib/main.dart` içindeki Firebase/Hive/timezone init satırları
- `lib/firebase_options.dart` içindeki platform-specific FirebaseOptions
- `android/app/google-services.json` ve `web/index.html` içindeki firebase konfigürasyonları
- `lib/core/services/sync_service.dart` içindeki queue/sync kodu
- `lib/core/services/notification_service.dart` ve `push_notification_service.dart`
- `lib/l10n/app_tr.arb` ve `lib/l10n/app_localizations.dart`

(Bu rapordaki tüm içerik workspace dosya okumaları ve hata tarama ile elde edilmiştir.)

---

### Ek: Hızlı referans — düzeltilen dosya
- `lib/features/habits/presentation/providers/habits_provider.dart` — `import '../../../achievements/presentation/providers/achievement_provider.dart' hide firestoreProvider;` satırı değiştirilip `hide firestoreProvider` kaldırıldı.

---

Raporu genişletmemi ister misiniz? Örneğin:
- Tüm `lib/` dosyalarının tek satırlık açıklamalı listesi (otomatik, 100+ dosya).
- Assets içeriğinin tam listesi.
- Bir `SECURITY.md` önerisi / `.gitignore` ve `key.properties.template` hazırlığı.

Hangisini yapmak istersiniz? Yapacağınız seçimi yazın, hemen uygulayayım.

---

## Ek - Dosya indeksi (lib/ içinde bulunan dosyalar ve kısa açıklamaları)

Not: Aşağıdaki liste repository içinde bulunan `lib/` altındaki dosyaların yolunu ve her dosya için 1 satırlık açıklamayı içerir. Açıklamalar dosya yoluna ve içeriklerine dayanılarak türetilmiştir.

1. `lib/shared/models/result.dart` — Genel `Result` sealed tipi (Success/Failure) uygulaması, fonksiyon dönüşleri için kullanılıyor.
2. `lib/shared/widgets/loading_indicator.dart` — Yükleme göstergesi ve tam ekran overlay widget'ları.
3. `lib/shared/widgets/error_widget.dart` — Hata/boş durum widget'ları ve retry butonları.
4. `lib/shared/widgets/custom_text_field.dart` — Tekrarlanan TextFormField konfigürasyonunu sağlayan bileşen.
5. `lib/shared/widgets/custom_button.dart` — Proje genelinde kullanılan özelleştirilmiş buton stilleri.
6. `lib/features/goals/domain/repositories/goal_repository.dart` — Goals feature için repository arayüzü.
7. `lib/features/goals/data/repositories/goal_repository_impl.dart` — Goals repository'nin Firestore/remote implementasyonu.
8. `lib/features/goals/presentation/widgets/goal_card.dart` — Goal kartı UI bileşeni.
9. `lib/features/goals/presentation/widgets/add_goal_dialog.dart` — Hedef ekleme dialogu UI.
10. `lib/features/habits/presentation/widgets/heatmap_calendar_card.dart` — Isı haritası (heatmap) takvim kartı widget'ı.
11. `lib/features/habits/presentation/widgets/progress_ring.dart` — Yüzde/ilerleme halkası görselleştirmesi.
12. `lib/features/habits/presentation/widgets/monthly_line_chart_card.dart` — Aylık çizgi grafik kartı.
13. `lib/features/habits/presentation/widgets/top_habits_card.dart` — En iyi/öncelikli alışkanlıkları gösteren kart.
14. `lib/features/habits/presentation/widgets/weekly_bar_chart_card.dart` — Haftalık bar grafik kartı.
15. `lib/features/social/domain/repositories/friend_repository.dart` — Arkadaşlık işlemleri için repository arayüzü.
16. `lib/features/social/domain/repositories/habit_activity_repository.dart` — Sosyal aktivite kayıtları için repository arayüzü.
17. `lib/features/social/domain/repositories/shared_habit_repository.dart` — Paylaşılan alışkanlıklar için repository arayüzü.
18. `lib/features/habits/presentation/widgets/streak_recovery_dialog.dart` — Seri kurtarma (streak recovery) için dialog UI.
19. `lib/features/habits/presentation/widgets/statistics_overview_card.dart` — İstatistik özeti kartı.
20. `lib/features/habits/presentation/widgets/skip_reason_sheet.dart` — Atlama nedeni seçimi için sheet.
21. `lib/features/habits/presentation/widgets/habit_card.dart` — Alışkanlık kartı bileşeni (liste öğesi).
22. `lib/features/habits/presentation/widgets/frequency_selector.dart` — Alışkanlık sıklığı seçim bileşeni.
23. `lib/features/profile/presentation/screens/profile_screen.dart` — Kullanıcı profil ekranı.
24. `lib/features/habits/presentation/widgets/edit_log_sheet.dart` — Log düzenleme sheet'i.
25. `lib/features/habits/presentation/widgets/detailed_checkin_sheet.dart` — Detaylı check-in sheet UI.
26. `lib/features/habits/presentation/widgets/daily_progress_card.dart` — Günlük ilerleme kartı.
27. `lib/features/habits/presentation/widgets/circle_progress_painter.dart` — Özel painter ile dairesel progress çizimi.
28. `lib/features/habits/presentation/widgets/category_pie_chart_card.dart` — Kategori bazlı pasta grafiği kartı.
29. `lib/features/habits/data/repositories/timer_session_repository_impl.dart` — Zamanlayıcı oturumları için repository implementasyonu.
30. `lib/features/social/data/models/shared_habit_model.dart` — Paylaşılan alışkanlık veri modeli (Firestore map dönüşümleri).
31. `lib/features/habits/data/repositories/offline_first_habit_repository.dart` — Offline-first dekoratör; local queue ile sync işlemleri ekler.
32. `lib/features/social/data/models/habit_activity_model.dart` — Sosyal aktivite veri modeli.
33. `lib/features/social/data/models/friend_model.dart` — Arkadaş veri modeli.
34. `lib/features/habits/data/repositories/habit_repository_impl.dart` — Firestore tabanlı habit repository uygulaması.
35. `lib/features/social/domain/entities/shared_habit.dart` — Paylaşılan alışkanlık domain entity'si.
36. `lib/features/social/domain/entities/habit_activity.dart` — Sosyal aktiviteler domain entity'si.
37. `lib/features/social/domain/entities/friend.dart` — Arkadaş entity'si.
38. `lib/features/statistics/presentation/screens/statistics_screen.dart` — İstatistik ekranı (charts ve özetler).
39. `lib/features/social/presentation/providers/social_providers.dart` — Social feature için Riverpod provider'ları.
40. `lib/features/social/presentation/screens/social_screen.dart` — Sosyal ekran (feed / activity).
41. `lib/features/social/presentation/widgets/friend_request_card.dart` — Arkadaş isteği kartı.
42. `lib/features/auth/data/datasources/auth_remote_datasource.dart` — Firebase Auth ve Google Sign-In işlemlerini yapan datasource.
43. `lib/features/auth/data/models/user_model.dart` — Kullanıcı veri modeli (Firestore <-> entity dönüşümleri).
44. `lib/features/auth/data/repositories/auth_repository_impl.dart` — Auth repository implementasyonu (remote datasource kullanır).
45. `lib/features/auth/data/datasources/auth_local_datasource.dart` — (Varsa) lokal auth cache veya guest-mode kaynakları.
46. `lib/features/social/presentation/widgets/shared_habit_card.dart` — Paylaşılan alışkanlık kartı UI.
47. `lib/features/social/presentation/widgets/friend_list_item.dart` — Arkadaş listesi öğesi.
48. `lib/features/social/presentation/widgets/add_friend_dialog.dart` — Arkadaş ekleme dialogu.
49. `lib/features/social/data/repositories/user_search_repository.dart` — Kullanıcı arama/repository implementasyonu.
50. `lib/features/social/data/repositories/shared_habit_repository_impl.dart` — Paylaşılan alışkanlık repository implementasyonu.
51. `lib/features/social/presentation/widgets/activity_card.dart` — Aktivite kartı (feed öğesi).
52. `lib/features/social/data/repositories/habit_activity_repository_impl.dart` — Habit activity repository impl.
53. `lib/features/social/data/repositories/friend_repository_impl.dart` — Friend repository impl.
54. `lib/features/habits/data/models/timer_session_model.dart` — Timer session veri modeli.
55. `lib/features/habits/data/models/streak_recovery_model.dart` — Streak recovery model.
56. `lib/features/habits/domain/repositories/timer_session_repository.dart` — Timer session repository interface.
57. `lib/features/habits/data/models/habit_model.dart` — Habit model (domain<->firestore dönüşümleri).
58. `lib/features/habits/domain/repositories/habit_repository.dart` — Habit repository arayüzü (domain contract).
59. `lib/features/habits/data/models/habit_log_model.dart` — Habit log veri modeli.
60. `lib/features/habits/domain/usecases/habit_usecases.dart` — Habit ile ilgili high-level usecase fonksiyonları (ör. tamamla, atla).
61. `lib/features/habits/data/datasources/timer_session_remote_datasource.dart` — Timer session remote data source (Firestore).
62. `lib/features/habits/data/datasources/habit_remote_datasource.dart` — Habit remote data source (Firestore collection erişimleri ve snapshot dinlemeleri).
63. `lib/features/habits/domain/entities/timer_session.dart` — Timer session domain entity.
64. `lib/features/habits/domain/entities/streak_recovery.dart` — Streak recovery domain entity.
65. `lib/features/habits/domain/entities/habit_log.dart` — Habit log domain entity.
66. `lib/features/habits/domain/entities/habit.dart` — Habit domain entity (alanlar, frequency, status vb.).
67. `lib/features/auth/domain/entities/user.dart` — User domain entity tanımı.
68. `lib/features/auth/domain/usecases/auth_usecases.dart` — Authentication ile ilgili usecase'ler (signIn/signUp/reset vb.).
69. `lib/main.dart` — Uygulamanın entrypoint'i; Firebase/Hive/timezone init ve MaterialApp konfigürasyonu.
70. `lib/features/auth/presentation/providers/username_check_provider.dart` — Kullanıcı adı kontrolü için provider (username uniqueness).
71. `lib/features/auth/presentation/providers/auth_provider.dart` — Auth ile ilgili provider'lar (firebaseAuthProvider, authRepositoryProvider, authStateProvider vb.).
72. `lib/features/auth/presentation/screens/welcome_screen.dart` — Welcome ekranı (giriş/kayıt yönlendirmesi).
73. `lib/features/auth/presentation/widgets/social_sign_in_button.dart` — Google sign-in buton widget'ı.
74. `lib/features/auth/presentation/widgets/password_input_field.dart` — Şifre alanı widget'ı (gizleme/visibility toggles).
75. `lib/features/auth/presentation/screens/splash_screen.dart` — Splash ekranı; onboarding ve auth durumuna göre yönlendirme.
76. `lib/features/auth/presentation/widgets/email_input_field.dart` — E-posta alanı widget'ı.
77. `lib/features/auth/presentation/screens/sign_up_screen.dart` — Kayıt ekranı.
78. `lib/features/auth/presentation/screens/sign_in_screen.dart` — Giriş ekranı.
79. `lib/features/auth/presentation/screens/onboarding_screen.dart` — Onboarding (ilk açılış rehberi).
80. `lib/features/auth/presentation/screens/username_selection_screen.dart` — Google kullanıcıları için username seçimi ekranı.
81. `lib/firebase_options.dart` — FlutterFire tarafından oluşturulmuş platform-specific Firebase config.
82. `lib/features/habits/presentation/providers/timer_session_providers.dart` — Timer session ile ilgili provider'lar.
83. `lib/features/habits/presentation/providers/habit_timer_notifier.dart` — Habit timer state notifier (başlat/durdur/bitir).
84. `lib/features/habits/presentation/providers/habits_provider.dart` — Habits ile ilişkili provider'lar (habits list, today logs, actions).
85. `lib/features/auth/domain/repositories/auth_repository.dart` — Auth repository arayüzü.
86. `lib/features/habits/presentation/screens/create_habit_screen.dart` — Yeni alışkanlık oluşturma ekranı.
87. `lib/features/goals/data/models/goal_model.dart` — Goal veri modeli.
88. `lib/features/habits/presentation/screens/today_screen.dart` — Bugünkü alışkanlıkların listelendiği ana ekran.
89. `lib/features/habits/presentation/screens/statistics_screen.dart` — Habite özel istatistik ekranı.
90. `lib/l10n/app_en.arb` — İngilizce çeviri ARB dosyası.
91. `lib/l10n/app_localizations_tr.dart` — Üretilmiş Türkçe localization dart dosyası.
92. `lib/l10n/app_localizations_en.dart` — Üretilmiş İngilizce localization dart dosyası.
93. `lib/l10n/app_localizations.dart` — Generated localization delegate ve lookup fonksiyonları.
94. `lib/features/habits/presentation/screens/home_screen.dart` — Ana ekran; habit listesi ve navigasyon hub.
95. `lib/l10n/app_tr.arb` — Türkçe çeviri ARB dosyası.
96. `lib/features/habits/presentation/screens/habit_timer_screen.dart` — Alışkanlık zamanlayıcı ekranı.
97. `lib/features/habits/presentation/screens/habit_detail_screen.dart` — Alışkanlık detay ekranı (istatistikler, loglar).
98. `lib/features/habits/presentation/screens/edit_habit_screen.dart` — Alışkanlık düzenleme ekranı.
99. `lib/features/goals/presentation/screens/goal_detail_screen.dart` — Hedef detay ekranı.
100. `lib/features/goals/presentation/providers/goal_providers.dart` — Goals feature provider'ları.
101. `lib/features/goals/presentation/screens/goals_screen.dart` — Goals listesi ekranı.
102. `lib/features/goals/domain/entities/goal.dart` — Goal domain entity.
103. `lib/generated/l10n.dart` — Generated localization helper (projeye özgü jenerik l10n giriş noktası).
104. `lib/features/achievements/presentation/widgets/badge_widget.dart` — Achievement badge UI.
105. `lib/features/achievements/presentation/widgets/achievement_unlocked_dialog.dart` — Achievement unlocked dialog.
106. `lib/generated/intl/messages_en.dart` — Generated intl messages for English.
107. `lib/core/constants/firebase_constants.dart` — Firebase koleksiyon isimleri/sabitleri.
108. `lib/generated/intl/messages_all.dart` — Generated intl messages bootstrap.
109. `lib/core/constants/app_constants.dart` — Uygulama genel sabitler (appName vb.).
110. `lib/core/widgets/sync_indicator.dart` — Senkronizasyon durum göstergesi bileşeni.
111. `lib/core/widgets/initial_sync_dialog.dart` — İlk senkronizasyon uyarı/dialog bileşeni.
112. `lib/features/achievements/presentation/providers/achievement_provider.dart` — Achievement provider ve servis entegrasyonu.
113. `lib/features/achievements/data/services/achievement_service.dart` — Achievement kontrol, kilit açma ve yönetim servisleri.
114. `lib/core/errors/failures.dart` — Uygulama genel hata/failure modelleri.
115. `lib/core/errors/exceptions.dart` — Domain/data katmanı exception tanımları.
116. `lib/features/achievements/data/models/achievement_model.dart` — Achievement veri modeli.
117. `lib/features/achievements/domain/entities/achievement.dart` — Achievement domain entity.
118. `lib/core/utils/validators.dart` — Form/alan doğrulama yardımcı fonksiyonları.
119. `lib/core/utils/extensions.dart` — Proje genelinde kullanılan extension methodlar.
120. `lib/core/utils/date_utils.dart` — Tarih işlemleri yardımcı fonksiyonları.
121. `lib/core/network/network_info.dart` — Ağ durumu / network helper wrapper.
122. `lib/core/theme/app_theme.dart` — Temalar (light/dark) — (daha önce listelendi).
123. `lib/core/theme/app_colors.dart` — Renk sabitleri ve palet tanımları.
124. `lib/core/network/connectivity_service.dart` — Connectivity servisi (online/offline izleme).
125. `lib/core/services/advanced_statistics_service.dart` — Gelişmiş istatistik hesaplama servisleri.
126. `lib/core/services/connectivity_service.dart` — Connectivity provider ve helper (kullanılan yerde referans).
127. `lib/core/routing/app_router.dart` — Uygulama rotalarını yöneten merkezi router.
128. `lib/core/services/push_notification_service.dart` — Push notification (FCM) entegrasyonu.
129. `lib/core/services/sync_queue_item.dart` — Hive model (sync queue item).
130. `lib/core/services/sync_service.dart` — SyncService (kuyruk + firestore sync).
131. `lib/core/services/notification_service.dart` — Lokal notification servis.
132. `lib/core/services/initial_sync_service.dart` — İlk açılışta tam senkronizasyon işlemleri (bootstrap).
133. `lib/core/services/export_import_service.dart` — Veri dışarı alma/içe alma servisleri (yedekleme/geri yükleme).

---

Rapor güncellendi: şimdi `ANALYSIS_REPORT.md` içinde proje, platformlar, assets ve tüm `lib/` dosyalarının kısa açıklamaları yer alıyor.

---

## Detaylı Açıklamalar — lib/core dosyaları

Aşağıda `lib/core` içindeki yardımcı (utility) ve tema dosyaları için tek satırlık özetlerin ötesine geçen daha detaylı, dosya bazlı açıklamalar yer alıyor. Her dosya için: amaç, ana fonksiyon/klass, önemli davranışlar ve nerede kullanıldığına dair notlar verildi.

### `lib/core/utils/validators.dart`
- Amaç: Form ve kullanıcı girdilerini doğrulamak için merkezi, tekrar kullanılabilir validator fonksiyonlarını sağlar. Uygulama çapında e-posta, şifre, kullanıcı adı, zorunlu alan, minimum/maximum uzunluk ve eşleşme kontrolleri için standart mesajlar içerir.
- Ana içerik ve kullanım:
  - `Validators.email(String?)` — Boş kontrolü ve regex ile e-posta format doğrulaması. Hatalıysa kullanıcıya Türkçe geri bildirim döner.
  - `Validators.password(String?, {minLength})` — Boş kontrolü ve minimum uzunluk kontrolü yapar; configurable `minLength` parametresi ile farklı kurallar desteklenir.
  - `Validators.username(String?, {minLength})` — Alfanumerik ve alt çizgi dışı karakterleri engelleyen regex ile kullanıcı adı doğrulaması yapar.
  - `Validators.required`, `minLength`, `maxLength`, `match` — Genel yardımcı validatorlar.
  - `Validators.combine` — Birden çok validator'ı zincirleme çalıştırarak ilk hata mesajını döndüren bir kombinasyon üretir. Bu, TextFormField `validator` parametreleri için kullanışlıdır.
- Nerede kullanılır: Tüm `presentation` katmanında (auth ekranları, habit oluşturma/düzenleme formları, profile forms vb.). Localization yapılmış hata mesajları yerine statik Türkçe mesajlar döndürüyor; eğer multi-locale hata mesajı istenirse bu dosya i18n ile entegre edilmeli.

### `lib/core/utils/extensions.dart`
- Amaç: Temel Dart tipleri (`String`, `DateTime`, `BuildContext`, `List`) için proje genelinde sık kullanılan yardımcı extension metodlarını sağlar. Bu sayede kod tekrarını azaltır ve okunabilirliği artırır.
- Ana içerik ve kullanım:
  - `StringExtensions` — `capitalize()`, `toTitleCase()`, `isValidEmail`, `truncate()` gibi metotlar; UI metinlerinin sunumunda sıkça kullanılır.
  - `DateTimeExtensions` — `toDateString()`, `toTimeString()`, `toFormattedDate()`, `toFullDateTime()` ve `toRelativeTime()` gibi formatlayıcılar; ayrıca `isToday/isYesterday/isTomorrow`, `startOfDay/endOfDay` gibi yardımcılar içerir. Bu uzantılar `presentation/widgets` içindeki tarih gösterimlerinde ve listelerde okunabilir çıktılar üretir.
  - `BuildContextExtensions` — `screenSize`, `screenWidth`, `screenHeight`, `theme`, `colorScheme`, kısa snackbar yardımcıları (`showSnackBar`, `showErrorSnackBar`, `showSuccessSnackBar`) sağlar. Bu, View katmanında sık kullanılan UI yardımcılarını tek bir yerden erişilebilir kılar.
  - `ListExtensions<T>` — `isNullOrEmpty`, `isNotNullOrEmpty`, `firstOrNull`, `lastOrNull` gibi nullable-safe yardımcılar.
- Nerede kullanılır: Neredeyse tüm UI bileşenleri, widget'lar ve bazı servislerde (log formatlama vb.) kullanılır. Örneğin `habit_card.dart` veya `statistics_overview_card.dart` gibi widget'larda tarih formatlama ve konteks snackbar'ları için referans verilir.

### `lib/core/utils/date_utils.dart`
- Amaç: Takvim ve tarih hesaplamalarını kapsayan, test edilebilir utility fonksiyonlarını barındırır. Bu dosya, uygulamadaki haftalık/aylık hesaplama, tarih aralıkları oluşturma ve locale-özgü formatlama sorumludur.
- Ana içerik ve kullanım:
  - `startOfDay`, `endOfDay`, `startOfWeek`, `endOfWeek`, `startOfMonth`, `endOfMonth` — Tarih aralığı hesaplamaları.
  - `isSameDay`, `isToday`, `isYesterday`, `isTomorrow` — Karşılaştırma yardımcıları.
  - `daysBetween`, `getDatesInWeek`, `getDatesInMonth` — Liste bazlı tarih üretimi; bunlar takvim görünümlerinde (heatmap, calendar widget) doğrudan kullanılır.
  - `formatDate`, `formatDateLong`, `formatDateFull`, `formatTime`, `formatDateTime` — `intl` paketini kullanarak locale-aware string çıktısı üretir (varsayılan `tr_TR`).
  - `getRelativeTime` — İnsan-centred relatif zaman metinleri üretir ("Az önce", "2 saat önce"), UI'da zaman damgası gösterimleri için uygundur.
  - `parseDate`, `isLeapYear`, `getDaysInMonth`, `getWeekNumber` — Ek yardımcı fonksiyonlar, takvim hesaplarına destek verir.
- Nerede kullanılır: `features/habits` içindeki takvimler, heatmap ve istatistik widget'larında, ayrıca zamanla ilgili business logic (streak hesapları, timer session zaman hesaplamaları) için kullanılır.

### `lib/core/theme/app_colors.dart`
- Amaç: Uygulama genelinde kullanılan renk paletlerini, kategori renklerini, gradient tanımlarını ve yardımcı renk dönüşüm fonksiyonlarını merkezi bir yerde toplar. Temalar ve widget'lar bu sabitleri kullanır.
- Ana içerik ve kullanım:
  - `primary`, `primaryLight`, `primaryDark`, `secondary`, `success`, `warning`, `error`, `background`, `surface`, `divider` gibi temel sabit renkler.
  - `habitColors` listesi — Alışkanlıklar için atanabilecek hızlı renk paleti; `getHabitColor(int)` döngüsel eşleme sağlar.
  - `categoryColors` map'i — Kategori isimlerine göre renk eşleştirmesi; `getCategoryColor(String)` ile güvenli erişim sağlanır.
  - `primaryGradient`, `successGradient`, `warningGradient` — UI'da kullanılan hazır linear gradient tanımları.
  - `hexToColor` / `colorToHex` yardımcıları — Dinamik renk verileri alırken/serileştirirken yardımcı olur (ör. kullanıcı özel renk seçimi kaydı).
- Nerede kullanılır: Tema, kart, progress ring, kategori etiketleri ve habit renkleri gibi UI bileşenlerinde geniş çapta kullanılır. `habit_card.dart`, `category_pie_chart_card.dart` ve custom painter'larda `AppColors` referansları görülür.

### `lib/core/theme/app_theme.dart`
- Amaç: Material 3 temalarını (light/dark) merkezi bir konfigürasyonda tutar. Buton stilleri, input dekorasyonları, appbar ve kart temaları burada tanımlanmıştır.
- Ana içerik ve kullanım:
  - `lightTheme` ve `darkTheme` getter'ları: `ThemeData` döndürür; `ColorScheme.fromSeed` ile tohum rengi (`primaryColor`) kullanılarak tutarlı bir palette oluşturulur.
  - `appBarTheme`, `cardTheme`, `inputDecorationTheme`, `elevatedButtonTheme`, `outlinedButtonTheme`, `textButtonTheme` gibi component-level ayarlar yer alır. Bu sayede tüm uygulama genelinde tutarlı bir görünüm elde edilir.
  - `useMaterial3: true` ile modern Material 3 component davranışları kullanılıyor.
- Nerede kullanılır: `main.dart` içinde `MaterialApp`/`MaterialApp.router` veya `CupertinoApp` yerine `ThemeData`'yı sağlamak için referans verilir. Ayrıca widget'larda `context.theme` vs. extension ile birlikte bu değerlerin okunması beklenir.

### `lib/core/services/advanced_statistics_service.dart`
- Durum: Dosya mevcut fakat içeriği boş (workspace'te dosya var, ancak henüz implementasyon yok). Bu genellikle ya ileride planlanan bir servis için placeholder ya da otomatik oluşturulmuş bir boş dosya olabilir.
- Öneri: Eğer gelişmiş istatistikler hesaplanacaksa (`streak` analizleri, aylık/haftalık karşılaştırmalar, regresyon trendleri, cohort analizleri), bu servis burada toplanmalı. Test edilebilir metotlar, input/output kontratları ve caching stratejisi eklenmeli.

### `lib/core/services/notification_service.dart`
- Amaç: Lokal bildirimleri yönetir; bildirimlerin planlanması, iptali ve anında gösterilmesi işlevlerini sağlar. `flutter_local_notifications` ve `timezone` paketleri ile tam zamanlı (zoned) hatırlatmalar kurar.
- Ana içerik ve kullanım:
  - `_notifications` içindeki `initialize()` metodu Android ve iOS için başlangıç ayarlarını yapar ve tıklama callback'ini (`_onNotificationTap`) bağlar.
  - `requestPermissions()` platforma özel izin isteklerini yönetir (Android/iOS ayrı implementasyonlar kullanılıyor).
  - `scheduleDailyReminder(...)` — Belirli bir saate günlük tekrar eden hatırlatma kurar. `tz` (timezone) kullanarak yerel saat dilimine göre programlama yapar ve `matchDateTimeComponents: DateTimeComponents.time` ile yalnızca saat/dakika eşleşmesine göre tekrar ayarlar.
  - `showNotification`, `cancelNotification`, `cancelAllNotifications` gibi yardımcılar; `showNotification` foreground veya event-driven anlık bildirimler için kullanılır.
  - `_nextInstanceOfTime` helper'ı bir sonraki uygun zoned datetime'i hesaplar ve eğer bugünkü zaman geçmişse bir gün ekler.
  - `_onNotificationTap` şu anda TODO içeriyor; uygulama içinde bildirim tıklamalarına göre navigasyon veya belirli ekrana yönlendirme eklenmeli.
- Nerede kullanılır: Alışkanlık hatırlatmaları, uygulama içi anlık uyarılar, zamanlayıcı bitiş bildirimleri vb. `PushNotificationService` foreground mesajlarda local gösterim için bu servisi kullanır.

### `lib/core/services/push_notification_service.dart`
- Amaç: Firebase Cloud Messaging (FCM) ile entegrasyonu sağlar; token yönetimi, konu abonelikleri, gelen mesajların işlenmesi ve kullanıcı dokümanına token kaydetme sorumlulukları vardır.
- Ana içerik ve kullanım:
  - `initialize()` — İzin isteği, token alma, token yenileme dinleme, foreground mesaj dinleme (`FirebaseMessaging.onMessage`), uygulama açma mesajını işleme (`onMessageOpenedApp`) ve başlangıç mesajı (`getInitialMessage`) kontrolü içerir.
  - `_saveFCMToken(token)` — Geçerli kullanıcı oturumu varsa `users/{userId}` dokümanına `fcmToken` ve güncelleme zamanını kaydeder.
  - `_handleForegroundMessage` — Foreground mesaj geldiğinde local notification gösterir (local `NotificationService` kullanılarak). Bu sayede hem push hem de lokal notifikasyon kanalları uyumlu çalışır.
  - `_handleMessageTap` — Mesaj tıklamalarında yapılacak navigasyon için placeholder; burada mesajın payload verisine göre deep-link veya route yönlendirmesi eklenmeli.
  - `subscribeToTopic` / `unsubscribeFromTopic` — Sunucu tabanlı topic abonelikleri yönetimi.
- Nerede kullanılır: `main.dart` uygulama başlatılırken initialize edilmesi gerekir; kullanıcı oturumu değiştiğinde (login/logout) token kaydı ve silinmesi yönetilmelidir. Ayrıca sosyal özellikler için topic abonelikleri (ör. arkadaş etkinlikleri) burada yönetilebilir.

### `lib/core/services/initial_sync_service.dart`
- Amaç: Yeni bir kullanıcının veya cihazın uygulamayı ilk çalıştırdığında gerekli verileri (habits, logs, achievements, profil) sunucudan indirip yerel cache'e getirmek için kullanılan bootstrap servisidir. Kullanıcıya progress bildirimi vermek için `InitialSyncProgress` callback'leri sağlar.
- Ana içerik ve kullanım:
  - `performInitialSync({required onProgress})` — Sıralı olarak habit, log, achievement ve profil verilerini indirir ve ilerleme callback'leri gönderir (ör. %10, %40, %70, %90, %100).
  - `_downloadHabits`, `_downloadLogs`, `_downloadAchievements`, `_downloadUserProfile` — Firestore sorguları çalıştırır. Kod yorumuna göre Firestore cache/SDK'nun kendi caching mekanizmasına güveniliyor (veriler client cache'inde tutuluyor), bu yüzden burada ek yerel persist işlemi yapılmıyor; eğer uygulama Hive vb. ile caching yapıyorsa burada ek yazma adımı gerekebilir.
  - `needsInitialSync(userId)` ve `markInitialSyncComplete(userId)` — Kullanıcının ilk senkronizasyon durumunu `users` dokümanındaki `lastInitialSync` alanı ile kontrol eder/günceller.
- Nerede kullanılır: Onboarding veya splash akışı sırasında; `initial_sync_dialog.dart` gibi UI bileşenleri bu servisin `onProgress` callback'lerine abone olur ve kullanıcıyı ilerleme ile bilgilendirir.

### `lib/core/services/export_import_service.dart`
- Durum: Dosya workspace'te mevcut ancak içeriği boş. Bu servis için beklenen sorumluluklar genelde şu şekilde olur:
  - Kullanıcı verilerini (habits, logs, achievements, profile) JSON/CSV/XML formatında dışa aktarma (export) ve dosya olarak paylaşma.
  - Dışa aktarılmış dosyadan içe aktarma (import) ve olası conflict/dupe deduplaması, field mapping logic.
  - Şifreli yedekleme veya bulut yedekleme (isteğe bağlı) için sağlayıcı adaptörleri (local file, Google Drive, iCloud, vs.).
- Öneri: Eğer export/import planlanıyorsa bu dosya implementasyon için uygun yerdir. Unit-testler ile round-trip (export → import) testi eklenmelidir.

### `lib/core/widgets/sync_indicator.dart`
- Amaç: Senkronizasyon durumunu kullanıcıya küçük, gömülebilir bir gösterge (badge / indicator) ile bildirmek. Hem global senkronizasyon durumu (`syncState`) hem de bekleyen işlem sayısı (`pendingCount`) akışlarına abone olur ve uygun UI durumunu render eder.
- Ana içerik ve kullanım:
  - `SyncIndicator` bir `ConsumerWidget` olup `syncStateProvider` ve `pendingCountProvider` streamlerine abone olur. Duruma göre beş farklı görsel durum gösterir: `idle` (gizli/boş), `pending` (çevrimdışı ve bekleyen öğeler), `syncing` (aktif senkronizasyon), `success` (başarılı senkronizasyon) ve `failed` (hata).
  - Her durum için özel builder metodları (`_buildPendingIndicator`, `_buildSyncingIndicator`, `_buildSuccessIndicator`, `_buildFailedIndicator`, `_buildConflictIndicator`) tanımlanmıştır. `AnimatedSwitcher` ile durum değişimlerinde yumuşak geçiş sağlanır.
  - `HabitCardSyncBadge` — Alışkanlık kartı içinde kullanılmak üzere küçük bir senkronizasyon rozeti sunar. `pendingCountProvider`'ı okuyup `SyncService.getPendingOperations()` ile bu alışkanlığa ait bekleyen işlemleri kontrol eder ve varsa rozet gösterir.
  - Hata durumunda göstergeye tıklanabilir; `_buildFailedIndicator` içindeki `onTap` `syncService.syncPendingOperations()` çağırarak elle retry sağlar.
- Nerede kullanılır: `AppBar` veya list item header'larında küçük bir gösterge olarak kullanılır; ayrıca `habit_card.dart` gibi bileşenlerde `HabitCardSyncBadge` ile işlem bazlı geri bildirim sağlar. Bu widget, kullanıcıya offline/online durumunu ve arka plan sync aktivitelerini hızlıca görme imkanı verir.

### `lib/core/widgets/initial_sync_dialog.dart`
- Amaç: Yeni cihaz veya yeni oturum açıldığında kullanıcıya ilk senkronizasyon sürecini gösteren, progress bar ve mesajlar ile ilerlemeyi kullanıcıya bildiren modal dialog. Hata durumlarında retry ve kapatma seçenekleri sunar.
- Ana içerik ve kullanım:
  - `InitialSyncDialog` bir `ConsumerStatefulWidget` olarak `InitialSyncService.performInitialSync` fonksiyonunu başlatır ve `onProgress` callback'i ile `InitialSyncProgress` nesnelerini state'e yazar.
  - Dialog `LinearProgressIndicator` ile yüzde bazında ilerlemeyi gösterir, mesaj alanı (örn. "Alışkanlıklar indiriliyor...") ve yüzdelik metin sunar. İlerleme %100 olduğunda dialog otomatik kapanır.
  - Hata yönetimi: Eğer `performInitialSync` sırasında hata fırlatılırsa `_isError` true olur, hata mesajı gösterilir ve kullanıcıya `Kapat` veya `Tekrar Dene` seçenekleri sunulur. `Tekrar Dene` tıklanması servis yeniden çalıştırır.
  - `showInitialSyncDialog(context)` yardımcı fonksiyonu dialog'u göstermeyi kolaylaştırır ve sonuç (`bool`) döndürür.
- Nerede kullanılır: Uygulama açılışında `splash_screen` veya onboarding akışında, ya da `settings` içinde manuel "Başlangıç Senkronizasyonu" tetiklendiğinde kullanılır. UI/UX açısından kullanıcıyı bekletirken nelerin indirildiğini ve ne kadar kaldığını açıkça gösterir.

### `lib/core/routing/app_router.dart`
- Amaç: Uygulamanın tüm route isimlerini ve route creation mantığını merkezi bir noktada tutar. Route'lar `RouteSettings` üzerinden alınan `name` ve `arguments` ile eşlenir.
- Ana içerik ve kullanım:
  - Sabit route isimleri (`splash`, `onboarding`, `welcome`, `sign-in`, `sign-up`, `home`, `habit/create`, `habit/detail`, `habit/edit`, vb.) burada tanımlıdır. Bu sayede uygulama içinde hard-coded string'ler yerine `AppRouter.home` gibi referanslar kullanılabilir.
  - `generateRoute(RouteSettings settings)` fonksiyonu `switch` ile gelen `settings.name`'e göre doğru widget'ı döndürür. Bazı route'lar `arguments` bekler (örn. `usernameSelection`, `habitDetail`, `habitEdit`) — eksik argümanlar için `_errorRoute` ile kullanıcı dostu bir hata ekranı gösterilir.
  - `_errorRoute` helper, eksik veya tanımsız route durumlarında debug/uygulama içi hata ekranı sağlar.
- Nerede kullanılır: `MaterialApp` veya `MaterialApp.router` içinde `onGenerateRoute: AppRouter.generateRoute` olarak bağlanır. Merkezi router, deep-link ve analytics için de tek noktadan kontrol olanağı verir.

### `lib/core/constants/firebase_constants.dart`
- Amaç: Firestore koleksiyon isimleri, doküman alan adları ve belli sabit değerleri (status, privacy, quality) tek bir yerde toplar. Bu, koleksiyon/alan adlarında yazım hatalarını azaltır ve refactor ile değişiklikleri kolaylaştırır.
- Ana içerik ve kullanım:
  - Collection isimleri (`users`, `habits`, `habit_logs`, `shared_habits`, `notifications`) ve sık kullanılan alan isimleri (`userId`, `ownerId`, `name`, `frequency`, `status`, `updatedAt` vb.) tanımlanmıştır.
  - Statik `activeStatus`, `pausedStatus`, `archivedStatus` gibi status değerleri merkezi olarak tutuluyor.
- Nerede kullanılır: Tüm `data` ve `domain` katmanlarında Firestore sorguları yazılırken doğrudan `FirebaseConstants.habitsCollection` gibi referanslar kullanılıyor. Bu aynı zamanda kuralları (`firestore.rules`) yazarken veya Cloud Function'larda kullanılan isimlerle eşleşme kontrolünde yararlı olur.

### `lib/core/constants/app_constants.dart`
- Amaç: Uygulama seviyesindeki sabitleri (appName, packageName, limitler, kategori listesi, ikon map'i, frekans tipleri, kalite düzeyleri, atlama nedenleri) merkezi şekilde sunar.
- Ana içerik ve kullanım:
  - `maxHabitsFreeTier`, `maxSharedHabits` gibi iş mantığı limitleri ve `maxHabitNameLength`, `maxDescriptionLength` gibi UI/validation limitleri.
  - `categories` ve `categoryIcons` Türkçe değerler içerir; UI'da kategori seçimleri ve ikon eşlemeleri bu sabitlerden çekilir.
  - Frekans türleri (`daily`, `weekly`, `monthly`, `flexible`) ile kalite seviyeleri ve skip nedenleri gibi sabit listeler yer alır.
- Nerede kullanılır: Hem UI (drop-down, selection lists) hem domain validation/limits (ör. `Validators` veya usecases içinde) için referans alınır. Değiştirilmesi gerektiğinde tek yerden güncelleme kolaylığı sağlar.

### `lib/core/errors/failures.dart`
- Amaç: Domain seviyesinde hata/failure modellerini tanımlar; `Failure` türleri fonksiyonel hata durumlarını temsil eder ve `Equatable` ile value-based karşılaştırma sağlar.
- Ana içerik ve kullanım:
  - Temel `Failure` sınıfı ve türetilmiş tipler: `NetworkFailure`, `ServerFailure`, `CacheFailure`, `DatabaseFailure`, `AuthFailure` ve türevleri (`InvalidCredentialsFailure`, `UserNotFoundFailure`, `EmailAlreadyInUseFailure`, `WeakPasswordFailure`, `NotAuthenticatedFailure`), `ValidationFailure` ve alt tipleri, `PermissionFailure`, `NotFoundFailure`, `SyncFailure`, `UnexpectedFailure`.
  - `FailureExtension` helper metodları ile bir `Failure` örneğinin network/auth/validation/permission ilişkili olup olmadığını kolayca kontrol edebilirsiniz (`isNetworkFailure`, `isAuthFailure`, `isValidationFailure`, `isPermissionFailure`).
- Nerede kullanılır: Usecase ve repository sınırlarında (domain/data boundary) hataların temsil edilmesi için kullanılır. UI katmanında `Result` veya `Either<Failure, T>` dönen metodların hata mesajlarını render etmek için bu tipler ele alınır.

### `lib/core/errors/exceptions.dart`
- Amaç: Data kaynaklarında (remote/local) fırlatılan istisnalar için typed exception sınıfları sunar. Bu istisnalar repository seviyesinde yakalanıp `Failure`'lara çevrilir.
- Ana içerik ve kullanım:
  - `AppException` temel sınıfı, ve network (`NetworkException`, `TimeoutException`, `ServerException`), cache (`CacheException`, `CacheNotFoundException`), database (`DatabaseException`, `QueryException`, `InsertException`, `UpdateException`, `DeleteException`), auth (`AuthException`, `UnauthenticatedException`, `InvalidCredentialsException`, `UserAlreadyExistsException`, `UserNotFoundException`), validation (`ValidationException`, `MissingFieldException`, `InvalidFormatException`), permission/file/sync ile ilgili exception tipleri.
  - `getExceptionMessage(Exception)` helper fonksiyonu, farklı exception türlerini kullanıcı-dostu mesajlara map'ler. Bu, repository -> domain dönüşümü sırasında kullanıcıya gösterilecek mesajın seçilmesinde yardımcı olur.
- Nerede kullanılır: Remote datasource'larda (Firestore, network requests) exception fırlatma, repository'de bunları `Failure`'a dönüştürme ve UI'ya uygun mesaj iletme akışında; ayrıca logging ve hata raporlama için uygun tip ayrımı sağlar.


### `lib/core/network/network_info.dart`
- Amaç: Ağ bağlantı durumunu soyut bir arayüz (interface) üzerinden sağlamaktır. Böylece servisler ve repository'ler doğrudan `connectivity_plus`'a bağımlı kalmadan ağ durumunu sorgulayabilir veya dinleyebilir.
- Ana içerik ve kullanım:
  - `abstract class NetworkInfo` — `Future<bool> get isConnected` ve `Stream<bool> get onConnectivityChanged` sözleşmesini tanımlar.
  - `NetworkInfoImpl` — `connectivity_plus` paketini kullanarak `checkConnectivity()` ve `onConnectivityChanged` fonksiyonlarından gelen sonuçları bool/stream'e çevirir. `_hasConnection` yardımcı metodu, `ConnectivityResult` içinde mobil/wifi/ethernet varsa çevrimiçi kabul eder.
- Nerede kullanılır: Bağımlılık olarak alınarak repository'lerde ve servislerde (ör. `SyncService`, `remote datasource` kontrollerinde) çevrimdışı/çevrimiçi davranışı değiştirmek için kullanılır. Test yazarken `NetworkInfo` interface'ine mock sağlayarak çevrimdışı senaryoları kolayca test edebilirsiniz.

### `lib/core/network/connectivity_service.dart`
- Amaç: Uygulama çapında bağlantı izleme ve Riverpod provider'ları ile kolay erişim sağlamak. `connectivity_plus`'ın ham sonuçlarını uygulama açısından daha kullanılabilir bir forma (bool stream) dönüştürür ve lifecycle yönetimi sağlar.
- Ana içerik ve kullanım:
  - `ConnectivityService` sınıfı `Connectivity` örneğini kapsar; `isConnected`, `connectivityType`, `onConnectivityChanged` metod/özellikleri sunar.
  - `startMonitoring(onChanged)` / `stopMonitoring()` yöntemleri ile manuel dinleme kontrolü mümkündür; ayrıca `dispose()` ile temizlenir.
  - Riverpod provider'ları:
    - `connectivityServiceProvider` — `ConnectivityService` örneğini üretir ve `ref.onDispose` ile yaşam döngüsünü bağlar.
    - `connectivityStatusProvider` — `StreamProvider<bool>` olarak uygulama genelinde gerçek zamanlı çevrimdışı/çevrimiçi statüsüne abone olmayı sağlar.
- Nerede kullanılır: UI'da senkronizasyon göstergeleri, offline uyarıları, network-dependent butonların enable/disable mantığında kullanılır. `SyncService` gibi altyapı servisleri bu provider üzerinden doğrudan dinleme yapabilir.

### `lib/core/services/sync_queue_item.dart`
- Amaç: Offline işlem kuyruğunun (SyncQueue) her öğesinin serileştirilebilir, Hive ile saklanabilir modelini tanımlar. Kuyruk öğesi, tip (create/update/delete), hedef entity tipi, JSON serileştirilmiş veri, retry sayısı, hata mesajı ve zaman bilgisi içerir.
- Ana içerik ve kullanım:
  - `@HiveType(typeId: 0) class SyncQueueItem extends HiveObject` — Hive için tip ID atanmış; alanlar `@HiveField` ile numaralandırılmış.
  - Alanlar: `id`, `operation`, `entityType`, `entityId`, `data` (JSON string), `createdAt`, `retryCount`, `isSyncing`, `error`.
  - `fromMap`, `toMap`, `copyWith` metodları ile kolay manipülasyon ve (de)serializasyon sağlar; `copyWith` retry/error/isSyncing gibi durum güncellemelerinde kullanılır.
- Nerede kullanılır: `SyncService` kuyruğa ekleme (`queueOperation`) ve kuyruktan alma/senkronize etme işlemlerinde, ayrıca debug ekranları veya yönetim araçlarında bekleyen/başarısız öğeleri göstermek için kullanılır.

### `lib/core/services/sync_service.dart`
- Amaç: Offline-first senkronizasyonu uygulayan merkezi servis. Local Hive kutusunda biriken operasyonları Firestore'a güvenli bir sırayla gönderir, retry politikası uygular, ve uygulama genelinde senkronizasyon durumu ile bekleyen işlem sayısını stream olarak sunar.
- Ana içerik ve davranış:
  - Yapılandırma ve bağımlılıklar: `Box<SyncQueueItem>`, `FirebaseFirestore`, `FirebaseAuth`, `ConnectivityService` referansları constructor ile alınır.
  - Durum akışları: `BehaviorSubject<SyncState>` ile `syncState`, `BehaviorSubject<int>` ile `pendingCount` sunulur. Bu sayede UI gerçek zamanlı geri bildirim alır.
  - Kuyruğa ekleme: `queueOperation` fonksiyonu yeni bir `SyncQueueItem` oluşturur ve `sync_queue` kutusuna yazar. Eğer online ise hemen `syncPendingOperations()` tetiklenir.
  - Senkronizasyon akışı: `_initializeSync` içinde connectivity değişiklikleri ve Hive box.watch() ile tetiklenen `syncPendingOperations()`. `syncPendingOperations` metodu aynı anda birden fazla senkronizasyon çalışmasını engellemek için `_isSyncing` bayrağı kullanır; sıralamayı korumak için `createdAt` göre sort edilir.
  - Operasyon tipi bazlı senkronizasyon: `_syncCreate`, `_syncUpdate`, `_syncDelete` Firestore koleksiyonlarına (`habits`, `habit_logs`, `users`, `achievements`, `streak_recoveries`) yazma/güncelleme/silme işlemlerini gerçekleştirir.
  - Hata yönetimi & retry: Başarısız bir işlem `retryCount` arttırılarak kutuda saklanır; 3 denemeden sonra `SyncState.failed` durumuna geçilebilir ve hata mesajı `error` alanına kaydedilir. `retryFailedOperations` ve `clearFailedOperations` yardımcı metodlar sağlanmıştır.
  - Sağladığı provider'lar: `syncQueueBoxProvider`, `syncServiceProvider`, `syncStateProvider`, `pendingCountProvider` ile entegrasyon sağlanır.
- Nerede kullanılır: `presentation` katmanında senkronizasyon göstergeleri (`sync_indicator.dart`), başlangıç sync diyalogları (`initial_sync_dialog.dart`), ayrıca repository implementasyonlarında offline-first dekoratörlerin kullanımında. SyncService, offline-first davranışın omurgasıdır ve veri bütünlüğü için merkezi rol oynar.

---

## Detaylı Açıklamalar — lib/features/habits

Aşağıda `lib/features/habits` içindeki önemli dosyalar için ayrıntılı açıklamalar bulunmaktadır: domain entity, data model, repository implementasyonu, offline-first dekoratörü ve presentation provider katmanı. Her öğe için amaç, ana metodlar, hata/yönetim stratejileri ve diğer modüllerle bağlantıları özetlenmiştir.

### `lib/features/habits/domain/entities/habit.dart`
- Amaç: Alışkanlık (Habit) domain entity'si uygulamanın iş mantığını temsil eden saf veri yapısını sunar. `Equatable` ile value-based karşılaştırma sağlar, bu da state management ve testlerde kullanışlıdır.
- Ana içerik ve kullanım:
  - Temel alanlar: `id`, `userId`, `name`, `description`, `category`, `icon`, `color`, `frequency`, `isShared`, `status`, `createdAt`, `updatedAt`.
  - Gelişmiş özellikler: "Part 4" olarak adlandırılmış alan seti içinde "habit stacking" (bir alışkanlığın başka bir alışkanlıkla zincirlenmesi), zamanlı alışkanlıklar (timed habits) için `isTimedHabit`, `targetDurationMinutes`, `timerSound`, `ambientSound`, `vibrateOnComplete` gibi ayarlar bulunur. Bu, uygulamanın daha zengin alışkanlık davranışları (ör. ardışık görev zincirleri, arka plan zamanlayıcıları) desteklediğini gösterir.
  - `HabitFrequency` sınıfı frekans türünü (`FrequencyType`) ve konfigürasyonunu (`config` map) kapsar. Factory metodları (`daily`, `dailySpecific`, `weekly`, `flexible`, `custom`) ile farklı frekans şablonları kolayca oluşturuluyor. `isScheduledForToday(DateTime)` gibi yardımcılar scheduling kararlarında kullanılır.
  - `copyWith` metodu immutable update için kullanılır; state notifiers ve repository'lerde güncellemeler bu metotla yapılır.
- Nerede kullanılır: Domain katmanında, usecase'lerde, repository arayüzlerinde ve presentation katmanında (widget/state) tip güvenli veri aktarımı için kullanılır. Özellikle `HabitFrequency` iş mantığı (bugün gösterilmeli mi) ve timed/stacked özellikleri UI ve servislerde davranışı etkiler.

### `lib/features/habits/data/models/habit_model.dart`
- Amaç: Firestore ile (de)serializasyonu yönetmek için domain entity'sine genişletilmiş data model sağlar. `toFirestore()` ve `fromFirestore()` metodları Firestore doküman yapısını eşler.
- Ana içerik ve kullanım:
  - `fromFirestore(Map<String, dynamic>)` Firestore dokümanını parse eder; `frequency` alanı nested map olarak alınır ve `HabitFrequency` objesine çevrilir. Timestamp alanları `Timestamp` -> `DateTime` dönüşümü ile ele alınır.
  - `toFirestore()` Firestore'a yazılacak map'i üretir; burada `FieldValue.serverTimestamp()` kullanılarak `createdAt/updatedAt` sunucu zaman damgası ile set ediliyor.
  - `fromEntity()` / `toEntity()` dönüşümleri domain-model <-> data-model dönüşümü sağlar, bu da repository'lerin domain API'si ile veri kaynağı arasındaki adaptasyon katmanıdır.
  - Part 4 (stacking/timed) alanları hem read hem write sırasında korunuyor; böylece yeni özellikler Firestore şemasına yansıtılmış.
- Nerede kullanılır: `HabitRemoteDataSource`, `HabitRepositoryImpl` gibi data-layer bileşenlerinde Firestore okuma/yazma akışında kullanılır. Modeldeki `toFirestore()` fonksiyonunun FieldValue kullanımı, timestamp tutarlılığı sağlar.

### `lib/features/habits/data/repositories/habit_repository_impl.dart`
- Amaç: `HabitRepository` arayüzünün Firestore tabanlı uygulanması; CRUD, log işlemleri, istatistik hesaplamaları ve streak recovery gibi yüksek seviyeli operasyonları gerçekleştirir.
- Ana içerik ve davranış:
  - CRUD: `createHabit`, `getHabits`, `getActiveHabits`, `getHabitById`, `updateHabit`, `deleteHabit`, `changeHabitStatus` implementasyonları `remoteDataSource` çağrıları ile gerçekleşir. Hatalar `Result` tipi (`Success`/`Failure`) ile sarılır ve kullanıcıya/upper-layer'a iletilir.
  - Log işlemleri: `completeHabit`, `skipHabit`, `undoCheckIn`, `getLogsForHabit`, `getLogForDate`, `getTodayLogs` gibi metodlar log yaratma, güncelleme ve silme akışlarını yönetir. `uuid` kullanılarak log/habit id'leri oluşturulur.
  - Detaylar (kaynak kodundan çıkarıldı):
    - `createHabit` → `HabitModel.fromEntity(habit)` ve `remoteDataSource.createHabit(habitModel)` çağrılır; Success ile geri dönülür veya Failure döndürülür.
    - `getHabits` / `getActiveHabits` → `remoteDataSource.getAllHabits(userId)` / `getActiveHabits(userId)` çağrıları ile Firestore sorguları yapılır, sonuç domain `Habit` listesine map edilir.
    - `getHabitById` → Eğer uzaktan doküman bulunamazsa `Failure('Alışkanlık bulunamadı')` döndürülür.
    - `changeHabitStatus` → mevcut habit snapshot'ı çekilir, `copyWith(status: status, updatedAt: DateTime.now())` ile güncellenir ve `updateHabit` çağrılır.
  - İstatistikler: `getHabitStatistics`, `getCompletionCount`, `getCurrentStreak` metodları lokal hesaplamalar gerçekleştirir (log'ları çekip tamamlanma sayısı, current/longest streak hesaplanıyor). `completionRate` hesaplaması TODO işaretli; frekans bazlı oran hesaplama eklenmeli.
  - Streak recovery: `useStreakRecovery`, `getRecentRecoveries`, `checkRecoveryEligibility` gibi metodlar recovery akışını denetler ve `StreakRecoveryModel`/datasource ile etkileşir.
  - Detaylar (useStreakRecovery):
    - `checkRecoveryEligibility` çağrısı ile önce uygunluk kontrolü yapılır; `Success` dönerse eligibility içeriğine bakılır. Eğer uygun ise `StreakRecoveryModel` yaratılarak `remoteDataSource.createStreakRecovery(recovery)` ile kaydedilir. Ardından `HabitLogModel` oluşturularak `createHabitLog` ile kaydedilir.
  - Error handling: Tüm önemli işlemler try/catch içine alınmış, hatalarda `Failure` ile kullanıcıya iletilecek mesaj oluşturuluyor. Bazı yerlerde hata mesajı doğrudan `e.toString()` içerir; production için daha anlamlı `Failure`/`Exception` dönüşümü (localized messages) önerilir.
  - Streaming: `watchHabits` ve `watchTodayLogs` Firestore snapshot stream'lerini domain listelerine map'ler; bu, UI tarafında gerçek zamanlı güncelleme sağlar.
- Nerede kullanılır: `habitRepositoryProvider` üzerinden Riverpod'a sunulur; presentation katmanındaki providers ve action notifiers bu repository üzerinden veri alır/günceller. Ayrıca offline decorator veya testlerde bu implementasyon mock/replace edilebilir.

### `lib/features/habits/data/repositories/offline_first_habit_repository.dart`
- Amaç: Varolan bir `HabitRepository` implementasyonunu sarmalayan (decorator) offline-first davranışı ekler. Local işlemleri önce gerçekleştirir, ardından `SyncService`'e queue item ekleyerek arka planda Firestore ile eşitleme sağlar.
- Ana içerik ve davranış:
  - Create/Update/Delete: İlk olarak `_baseRepository` (ör. local/hive-backed repo) üzerinde işlemi gerçekleştirir; başarılı olduğunda `_syncService.queueOperation(...)` ile ilgili create/update/delete operasyonunu kuyruğa ekler.
  - Log işlemleri (`completeHabit`, `skipHabit`, `undoCheckIn`, `useStreakRecovery`) da benzer şekilde önce lokal repo'ya uygulanır ve ardından sync kuyruğuna eklenir. `useStreakRecovery` gibi compound işlemler için hem log hem recovery record kuyruğa eklenir.
  - Read-only ve stream metodları (`getHabits`, `getTodayLogs`, `watchHabits`) base repository'ye passtrough yapar; bunlar genellikle local cache veya remote stream sağlayabilir.
  - `syncWithFirebase()` çağrısı direkt olarak `_syncService.syncPendingOperations()` tetikler; bu, manuel retry butonları veya ayarlar ekranından tetiklenebilir.
  - Helper dönüşümler `_habitToMap`, `_logToMap` gibi metodlar queue item'larının JSON payload'ını üretir.
- Nerede kullanılır: Uygulama offline-safely veri oluşturma/güncelleme yaparken kullanıcı deneyimini korur. `habits` feature'da repository provider konfigürasyonunda bu dekoratör tercih ediliyorsa, presentation katmanı değişiklik yapmadan offline-first davranış kazanır.

### `lib/features/habits/presentation/providers/habits_provider.dart`
- Amaç: Riverpod tabanlı provider katmanı; veri (FutureProvider/StreamProvider) ve action (StateNotifier) sağlayarak UI ile domain/data katmanları arasında köprü kurar.
- Ana içerik ve kullanım:
  - Providers:
    - `uuidProvider` — Uuid üreticisi.
    - `habitRemoteDataSourceProvider` — Firestore datasouce sağlayıcı.
    - `habitRepositoryProvider` — `HabitRepositoryImpl` örneği (veya DI ile offline decorator injekte edilir).
    - `habitsProvider` — `FutureProvider.family<List<Habit>, String>`; userId bazlı aktif alışkanlık listesini döner.
    - `habitProvider` — Belirli `habitId` için tekil `FutureProvider`.
    - `todayLogsProvider` — Günlük logları sağlayan provider.
    - `habitStatisticsProvider` — Bir alışkanlık için istatistikleri hesaplar ve döner.
    - `streakRecoveryEligibilityProvider` — Kullanıcının belirtilen tarihte kurtarma hakkı olup olmadığını kontrol eder.
  - Action StateNotifier (`HabitActionNotifier`): `createHabit`, `updateHabit`, `deleteHabit`, `completeHabit`, `skipHabit`, `useStreakRecovery`, `syncWithFirebase` gibi eylemler için yüklenme durumu, hata ve başarı mesajlarını yönetir. Ayrıca tamamlamalardan sonra `AchievementService`'i çağırarak kazanç rozetlerini kontrol eder ve unlocked achievements listesini state içinde tutar.
  - Result handling: `Result` tipi (`Success`/`Failure`) ile repository dönüşleri ele alınıyor; yardımcı extension `ResultExtension` okunabilir `dataOrNull` ve `errorOrNull` erişimleri sağlar.
- Nerede kullanılır: Tüm `habits` ekranları (home, today, create/edit screens, detail screen) bu provider'ları kullanır. `HabitActionNotifier` UI'da buton etkileşimleri sonucunda çağrılır ve UI mesajlarını (toast/snackbar/dialog) tetikler.

---

İlerleyecek adımlar: Eğer onay verirseniz, sıradaki hedefim `lib/features/habits/presentation/screens` içindeki ana ekranlar (home_screen, today_screen, habit_detail_screen, create/edit screens) ve `data/datasources` içindeki `habit_remote_datasource.dart` ile `habit_log_model.dart`, `streak_recovery_model.dart` gibi kalan model/datasource dosyalarını benzer düzeyde dokümante etmek olacak.

---

## Ek Detaylar — Habits Datasources & Modeller (eklenen)

Aşağıda `lib/features/habits/data/datasources` ve `lib/features/habits/data/models` içinden okunan beş dosya için ayrıntılı açıklamalar yer alır. Bu bölümü, okunan kodun API'leri, hata davranışları ve kullanım yerlerine dair somut notlarla genişlettim.

### `lib/features/habits/data/datasources/habit_remote_datasource.dart`
- Amaç: Firestore üzerinde `habits`, `habit_logs` ve `streak_recoveries` koleksiyonları ile etkileşimi soyutlar. Tüm remote CRUD ve batch/senkronizasyon yardımcı metodlarını içerir.
- Öne çıkan metotlar:
  - `getAllHabits(userId)`, `getActiveHabits(userId)`, `getHabitById(habitId)` — Basit sorgular ile dokümanları getirir. Tarihe göre sıralama `createdAt` alanı üzerinden `descending` olarak yapılır.
  - `createHabit(HabitModel)`, `updateHabit(HabitModel)`, `deleteHabit(habitId)` — Create/update/delete işlemlerini gerçekleştirir. `updateHabit` ayrıca `updatedAt: FieldValue.serverTimestamp()` set eder. `deleteHabit` çağrıldığında ilgili habit log'larını da batch ile siler.
  - `watchHabits(userId)` — Aktif (status == 'active') habit'ler için Firestore snapshot stream döner; UI tarafında gerçek zamanlı liste güncellemesi sağlar.
  - Log odaklı API'ler: `getLogsForHabit(habitId)`, `getLogForDate(habitId, date)`, `getTodayLogsForUser(userId)`, `upsertHabitLog(HabitLogModel)`, `deleteHabitLog(logId)`, `watchTodayLogs(userId)` — Log sorguları ve snapshot stream'leri; günlük sorgularda `date` alanı `Timestamp` aralığı sorgusu ile sınırlandırılıyor.
  - Batch senkronizasyon: `syncHabits(List<HabitModel>)` ve `syncLogs(List<HabitLogModel>)` metodları birden fazla dokümanı `batch` ile Firestore'a yazar (SetOptions(merge: true) kullanarak merge davranışı sağlar).
  - Streak recovery: `createStreakRecovery(StreakRecoveryModel)` ve `getRecentRecoveries(habitId, userId)` — Kurtarma kayıtlarını tutar ve son 7 gün içindeki kullanımları sorgular.
- Hata davranışı: Tüm metotlar try/catch bloğuna sarılmış ve hata durumunda `Exception('Failed ...: $e')` şeklinde genel istisna fırlatıyor. Repository katmanında daha özel `Exception`/`Failure`'a dönüştürülmesi bekleniyor.

### `lib/features/habits/data/models/habit_log_model.dart`
- Amaç: Domain `HabitLog` entity'sinden genişletilmiş ve Firestore serileştirme/deserileştirmesini yöneten model sınıfı. `domain.HabitLog`'u genişleterek ek helper ve `fromFirestore/toFirestore` metodlarını sağlıyor.
- Öne çıkan noktalar:
  - `fromFirestore(Map<String,dynamic>)` — Firestore dokümanını parse ederken `date` ve `createdAt` alanlarını `Timestamp` -> `DateTime`'a çevirir. `quality` alanı string olarak saklanıp domain'de enum benzeri `toLogQuality()` dönüşümü kullanılıyor.
  - `toFirestore()` — Firestore'a yazılacak map'i üretir; `date` için `Timestamp.fromDate(date)` ve `createdAt: FieldValue.serverTimestamp()` kullanır. `durationSeconds` gibi opsiyonel alanlar yalnızca mevcutsa eklenir.
  - `fromEntity()` / `toEntity()` dönüşümleri domain katmanı ile model arasında bir adaptör görevi görür.
  - `copyWith()` override'u immutable güncellemeler için sağlanmış.
- Hata/varsayımlar: Model `fromFirestore`'da beklenen alan isimlerini (`logId`, `habitId`, `userId`, `date`, `completed`) kullanıyor — Firestore şeması bu isimlerle uyumlu olmalı.

### `lib/features/habits/data/models/streak_recovery_model.dart`
- Amaç: Firestore içinde saklanan streak recovery kayıtlarının modellemesini sağlar. Bu kayıtlar kullanıcıların bir günlük kaybı telafi etmek için kullandığı hakları tutar.
- Öne çıkan noktalar:
  - `fromFirestore(DocumentSnapshot)` — Firestore doküman snapshot'ından model yaratır; `usedAt` ve `recoveredDate` timestamp alanları DateTime'a çevrilir.
  - `toFirestore()` — `habitId`, `userId`, `recoveredDate`, `usedAt` alanlarını `Timestamp` olarak döner.
  - `toEntity()` dönüşümü domain nesnesine çevirir.
- Kullanım: `HabitRepository`'nin `useStreakRecovery` ve `getRecentRecoveries` akışlarında kullanılır; `HabitRemoteDataSource.getRecentRecoveries` fonksiyonuyla eşleşir.

### `lib/features/habits/data/models/timer_session_model.dart`
- Amaç: Alışkanlık için başlatılan zamanlayıcı oturumlarını (`TimerSession`) Firestore'a yazmak/okumak için model sağlar. Domain `TimerSession`'ı genişletir.
- Öne çıkan noktalar:
  - `fromFirestore(Map<String,dynamic>)` — `startedAt` ve `completedAt` Timestamp dönüşümleri; `status` string -> `TimerSessionStatus` dönüşümü (`toTimerSessionStatus()`) yapılır. `pauseCount` ve `totalPausedSeconds` için default 0 kullanılıyor.
  - `toFirestore()` — `sessionId`, `habitId`, `userId`, `startedAt`, `completedAt` (opsiyonel), `targetSeconds`, `actualSeconds`, `status`, `pauseCount`, `totalPausedSeconds`, `createdAt: FieldValue.serverTimestamp()` şeklinde bir map döner.
  - `toEntity()` ve `copyWith()` metotları domain ile senkron çalışmayı kolaylaştırır.
- Not: `actualSeconds` ve `targetSeconds` integer saniye cinsinden tutuluyor; aggregasyon/sorgulama yaparken bu değerler toplanıp toplam süre hesaplanabiliyor.

### `lib/features/habits/data/datasources/timer_session_remote_datasource.dart`
- Amaç: `timer_sessions` koleksiyonu için CRUD, sorgu ve stream API'lerini sağlar. Zamanlayıcı oturumları için oturum oluşturma, güncelleme, silme ve zaman aralığı sorguları burada yer alıyor.
- Öne çıkan metotlar:
  - `createSession(session)`, `updateSession(session)`, `deleteSession(sessionId)` — Basit Firestore işlemleri.
  - `getSession(sessionId)`, `getSessionsForHabit(habitId)`, `getSessionsInRange(habitId, startDate, endDate)`, `getTodaySessions(habitId)` — Oturum sorgu metodları.
  - `getTotalTimeForHabit(habitId)` — Reusable helper; habit için toplam harcanan süreyi (`actualSeconds`) döndürür.
  - `watchSessionsForHabit(habitId)` — Firestore snapshot stream sağlar.
- Hata davranışı: Metotlar genel olarak doğrudan Firestore çağrısı yapıyor; hataları tüketmeyip yukarı fırlatıyor (consumer/repository bu hataları yakalayacak).

---

Eklendi: Yukarıdaki bölümler `ANALYSIS_REPORT.md` içinde "Habits Datasources & Modeller" başlığı altında kaydedildi. Bir sonraki adım olarak `lib/features/habits/data/datasources/habit_remote_datasource.dart` ile ilişkili domain modellerin (ör. `habit_log.dart`, `timer_session.dart`, `streak_recovery.dart`) domain tarafı incelemesini tamamlayıp `presentation/screens` dosyalarını belgelemeye başlayacağım.

### Habits — Domain modellerinin detayları (eklenen)

Bu alt-bölüm, `lib/features/habits/domain/entities` içindeki üç ana domain entity'sini (log, streak recovery, timer session) açıklar; modellerle (model sınıfları) nasıl eşleştiklerini ve domain seviyesinde hangi yardımcı metodların bulunduğunu özetler.

#### `lib/features/habits/domain/entities/habit_log.dart`
- Amaç: Kullanıcının bir alışkanlık için yaptığı her "check-in" veya atlama (skip) kaydını temsil eder. `Equatable` ile value-based karşılaştırma sağlar, böylece state yönetiminde değişiklik tespiti kolaydır.
- Alanlar:
  - `id`, `habitId`, `userId` — Kimlik alanları.
  - `date` — Checkin tarihi (tarih-bazlı; zaman kısmı da tutulabilir ama sorgular genelde gün başlangıcı bitiş aralığına göre yapılır).
  - `completed` (bool) — Yapıldı mı.
  - `skipped` (bool), `skipReason` (String?) — Atlama durumu ve nedeni.
  - `quality` (LogQuality?) — Kullanıcının checkin kalitesi (minimal/good/excellent) için enum.
  - `note`, `mood` — Opsiyonel not ve duygu etiketleri.
  - `durationSeconds` — Part 4 kapsamında zamanlı alışkanlıklar için geçen süre (saniye).
  - `createdAt` — Kayıt oluşturulma zamanı.
- Yardımcılar:
  - `copyWith()` — Immutable güncellemeler için.
  - `LogQuality` enum ve string <-> enum dönüşümleri (`toLogQuality()`, `value`). Bu, `HabitLogModel`'in `quality` alanı ile uyumlu string saklama biçimini destekler.
- Model eşleşmesi: `HabitLogModel.fromFirestore`/`toFirestore` ile alan isimleri (`logId`, `habitId`, `date`, `completed`) birebir eşlenir; Firestore tarafında `createdAt` için `FieldValue.serverTimestamp()` kullanılıyor.

#### `lib/features/habits/domain/entities/streak_recovery.dart`
- Amaç: Haftalık veya belirli periyotlarda kullanıcının seriyi (streak) kurtarmak için kullandığı kaydı temsil eder.
- Alanlar:
  - `id`, `habitId`, `userId`, `recoveredDate`, `usedAt`.
- Yardımcılar ve iş mantığı:
  - `isWithinWeek(now)` — Bir kurtarmanın hala haftalık pencere içinde olup olmadığını kontrol eder.
  - `StreakRecoveryChecker.checkEligibility(missedDate, recentRecoveries)` — Missed (kaçırılmış) tarih için kurtarma uygunluğunu doğrular. Kurallar kodda belirtilmiştir: 24 saatlik pencere ve haftada bir kullanım sınırı. Fonksiyon kullanıcıya `StreakRecoveryEligibility` (canRecover + reason) döner.
- Model eşleşmesi: `StreakRecoveryModel` ile `fromFirestore/toFirestore` eşleşir; Firestore tarafındaki `usedAt`/`recoveredDate` timestamp alanları domain tarafında DateTime'a çevrilir.

#### `lib/features/habits/domain/entities/timer_session.dart`
- Amaç: Zamanlanmış veya başlatılmış alışkanlık oturumlarını temsil eder. Timer UI, background worker veya session history için bu entity kullanılır.
- Alanlar ve davranış:
  - `id`, `habitId`, `userId`, `startedAt`, `completedAt` (opsiyonel), `targetSeconds`, `actualSeconds`, `status`, `pauseCount`, `totalPausedSeconds`.
  - `targetMet` getter — Hedefin tamamlanıp tamamlanmadığını boolean olarak verir.
  - `completionPercentage` getter — Tamamlama yüzdesini döner (0-100 arası double).
  - `duration` ve `target` — Duration tipinde yardımcı getter'lar.
  - `copyWith()` — Immutable güncellemeler.
  - `TimerSessionStatus` enum ve string dönüşümleri (`toTimerSessionStatus()`, `value`). `TimerSessionModel` ile string alan uyumu sağlanır.
- Model eşleşmesi: `TimerSessionModel`'in `fromFirestore/toFirestore` metodları `sessionId`, `startedAt`, `completedAt`, `targetSeconds`, `actualSeconds`, `status` alanlarını map'ler. `getTotalTimeForHabit` gibi repository/helper fonksiyonlar `actualSeconds` alanlarını toplayarak toplam süreyi hesaplar.

---

Eklendi: Domain entity açıklamaları rapora eklendi. Bir sonraki adım olarak `lib/features/habits/presentation/screens` içindeki ana ekranları (özellikle `home_screen.dart`, `today_screen.dart`, `habit_detail_screen.dart`, `habit_timer_screen.dart`) tek tek okuyup her birini benzer detaylarda rapora aktaracağım.

### Habits — Presentation Screens (eklenen)

Aşağıdaki açıklamalar `lib/features/habits/presentation/screens` altındaki dört ana ekranı kapsar. Her ekran için amaç, ana bileşenleri, kullandığı provider'lar, önemli kullanıcı yolları ve hata/edge-case notları verilmektedir.

#### `lib/features/habits/presentation/screens/home_screen.dart`
- Amaç: Uygulamanın ana çatı ekranı; alt kısımda bir NavigationBar ile dört ana bölüme (Today, Statistics, Social, Profile) erişim sağlar. `IndexedStack` kullanarak görünür ekranlar arasında geçiş yapar ve tab durumunu kendi state'inde tutar.
- Öne çıkan davranışlar:
  - `IndexedStack` ile sayfa geçişleri: böylece sayfaların state'i korunur (örn. Today ekranındaki kaydırma pozisyonu korunur).
  - Localization: `AppLocalizations` ile NavigationDestination etiketleri. `l10n` kullanımı ekran başlıklarında ve buton etiketlerinde yaygındır.
  - Bağımlılıklar: `TodayScreen`, `StatisticsScreen`, `SocialScreen`, `ProfileScreen` widget'larını içeren hafif bir yönlendirme kabuğudur.
- Edge-cases: `HomeScreen` minimal logic içerir; test etmesi kolaydır. UI state (`_currentIndex`) basit olduğu için deep-link veya harici navigasyon tetiklemeleri için merkezi router kullanılması önerilir.

#### `lib/features/habits/presentation/screens/today_screen.dart`
- Amaç: Kullanıcının günlük görevlerinin (bugünkü alışkanlıklar) listelendiği ana çalışma ekranı. Kullanıcı burada check-in yapar, atlar, düzenler, paylaşır ve zamanlayıcıyı başlatır.
- Ana bileşen ve akışlar:
  - `TabController` ile iki sekme: "Bugün" ve "Günü Değil". "Bugün" sekmesi bugün programlanmış alışkanlıkları, "Günü Değil" sekmesi ise bugün programda olmayan ama günlük/özel ayarlı alışkanlıkları gösteriyor.
  - Kullanılan provider'lar: `authStateProvider` (kullanıcı oturumu), `habitsProvider(userId)` (aktif alışkanlık listesi), `todayLogsProvider(userId)` (bugünkü loglar), `habitActionProvider` (action notifier). `SyncIndicator` widget'ı uygulama üstünde senkron durumunu gösterir.
  - Streak recovery flow: `initState` içinde `_checkForBrokenStreaks()` çağrısı ile bir önceki gün kaçırılmış günlük varsa `streakRecoveryEligibilityProvider` kontrol edilir; uygun ise `StreakRecoveryDialog` gösterilir ve kullanıcı onaylarsa `HabitActionNotifier.useStreakRecovery` çağrılır.
  - Listeleme: Alışkanlıklar zaman dilimlerine göre (Sabah, Öğleden Sonra, Akşam, Gün Boyu) gruplanır. `HabitCard` widget'ı her satır için kullanılır ve `onComplete`, `onSkip`, `onTimer`, `onEdit`, `onDelete`, `onShare` gibi callback'leri barındırır.
  - Check-in ve paylaşım: `completeHabit` çağrısı sonrası istenirse sosyal aktivite `habitActivityRepository.shareActivity` ile paylaşılabilir; başarı durumunda Achievement dialog'ları gösterilir.
  - Timer entegrasyonu (Part 4): Eğer bir habit `isTimedHabit` ise `HabitCard` üzerinden `HabitTimerScreen` başlatılır; timer ekranından dönen sonuç `completeHabit` ile işlendi.
- Hata yönetimi ve edge-cases:
  - Guest kullanıcılar için basit bir bilgilendirme ve sign-in yönlendirmesi var.
  - UI, ağ hatalarını `CustomErrorWidget` ve `LoadingIndicator` ile yönetir; repository katmanı `Result` tipleri üzerinden dönüş yapar; `Success`/`Failure` ayrımı UI tarafından ele alınıyor.
  - `_checkForBrokenStreaks` içinde birden fazla async bekleme bulunduğundan `mounted` kontrolleri yaygın olarak kullanılmış; bu iyi bir pratik (widget dispose edildiğinde setState veya navigation hatalarını önler).

#### `lib/features/habits/presentation/screens/habit_detail_screen.dart`
- Amaç: Tek bir alışkanlığın detay sayfası; esnek bir header, tab'lar ve statistic/graph/calendar gibi bölümler içerir.
- Ana bileşen ve akışlar:
  - `TabBar` içinde 4 bölüm: Genel (info), Takvim, Grafik, İstatistik. `NestedScrollView` ve `SliverAppBar` ile geniş başlık (icon, renk gradient) sunar.
  - Kullanılan provider'lar: `habitProvider(habitId)` tekil habit verisini alır; `habitStatisticsProvider` ile istatistik verileri; ayrıca `habitRepositoryProvider`'dan `getLogsForHabit` çağrıları yapılır.
  - Calendar ve Chart: `TableCalendar`, `fl_chart` kütüphanesi ve custom mini-heatmap/gösterimler kullanılarak log verileri görselleştirilir. `LineChart` 30-günlük trendleri, `BarChart` haftalık karşılaştırmaları gösterir.
  - Recent activity & notes: `getLogsForHabit` çekilerek son aktiviteler listelenir; notlar, kalite ve atlama nedenleri detay içinde gösterilir.
  - Edit/Delete: AppBar üzerindeki ikonlar ile düzenleme (edit) ve silme işlemleri yapılır; silme onayı modal ile sorulur ve `habitActionProvider.deleteHabit` çağrılır.
- Hata yönetimi & performans:
  - Heavy UI (chart, calendar, lists) olduğu için veriler FutureProvider ile lazy-load ediliyor; büyük veri setlerinde paginate veya caching gerekebilir.
  - `FutureProvider` ile dönülen loglar `FutureBuilder` / `then` ile render ediliyor; performans ve re-build optimizasyonu için zaman içinde `Stream` veya memoization (cached provider) düşünülmelidir.

#### `lib/features/habits/presentation/screens/habit_timer_screen.dart`
- Amaç: Zamanlı alışkanlıklar için interaktif bir zamanlayıcı ekranı. Başlat/duraklat/devam/durdur aksiyonları, hızlı ekleme butonları (+1dk, +5dk), seans geçmişi ve oturum tamamlama akışı içerir.
- Ana bileşen ve akışlar:
  - State ve notifier: `habitTimerWithHabitProvider(habit)` provider'ı state (target, elapsed, progress, status) ve notifier (start, pause, resume, stop, addTime) sağlar. `HabitTimerNotifier` timer logic'ini yönetir ve `timer_session` repository ile etkileşir (session create/update).
  - UI: Büyük bir `CustomPaint` tabanlı `CircleProgressPainter` ile dairesel görsel ilerleme; ortada geçen süre ve yüzde gösterimi. Kontroller `ElevatedButton` (play/pause) ve `OutlinedButton` (complete) şeklinde sunulur.
  - Tamamlama akışı: Kullanıcı `Tamamla` butonunu onayladığında, notifier `stop()` çağırılır, süre epoch'su hesaplanır, sonra `DetailedCheckInSheet` bottom sheet'i ile kullanıcıya not/kalite input'u gösterilir. Bu sheet'ten dönen map (örn. {quality, note, shareWithFriends, photo}) `Navigator.pop` ile `TodayScreen`'a geri iletilir.
  - Seans geçmişi: `todaySessionsProvider(habit.id)` provider'ı ile bugünkü timer oturumları listelenir (seans sayısı, toplam süre).
- Error/edge-cases:
  - `PopScope` kullanılarak geri tuşu, timer çalışırken kullanıcıyı onay isteyen bir dialog gösterir; bu kullanıcı deneyimi için önemli bir korunma.
  - Notifier `stop()` asenkron olduğu için `mounted` kontrolleri ve dikkatli UI state güncellemeleri mevcut.
  - Zaman formatlama helper'ları (`_formatDuration`, `_formatMinutes`) ve renk/palette seçimleri UI içinde tanımlı; test edilebilirlik için formatter metodlarını ayrı util dosyaya taşımak faydalı olabilir.

---

Eklendi: `home_screen.dart`, `today_screen.dart`, `habit_detail_screen.dart`, `habit_timer_screen.dart` için detaylı açıklamalar rapora eklendi. Sonraki adım: `lib/features/habits/presentation/widgets` altındaki widget'ları (ör. `habit_card.dart`, `detailed_checkin_sheet.dart`, `streak_recovery_dialog.dart`, `progress_ring.dart` vb.) ve provider/notifier dosyalarını okuyup belgelemeye başlayacağım.

### Habits — Providers & Notifiers (eklenen)

Bu bölüm `lib/features/habits/presentation/providers` altındaki önemli provider ve notifier dosyalarını özetler: `habit_timer_notifier.dart`, `timer_session_providers.dart` ve `habits_provider.dart`.

#### `lib/features/habits/presentation/providers/habit_timer_notifier.dart`
- Amaç: Zamanlı alışkanlıklar için timer state'ini ve davranışını yönetir. `StateNotifier<HabitTimerState>` kullanılarak UI'ya reaktif state sağlar.
- State shape (`HabitTimerState`):
  - `habitId`, `status` (idle/running/paused/completed), `elapsed` (Duration), `target` (Duration? — hedef süre), `sessionId` (String?).
  - `progress` getter: elapsed/target oranını 0.0-1.0 arasında verir.
- Notifier davranışı:
  - `start()` — yeni seans başlatır (veya pause'tan resume eder). `_timer` ile 1 saniye periyodik güncelleme yapar; `WakelockPlus.enable()` ile ekran açık tutulur.
  - `pause()` — timer'ı durdurur, `_pausedDuration`'ı günceller, `WakelockPlus.disable()` çağrılır.
  - `resume()` — pause'tan devam ettirir (`start()` çağrısı arka planda resume davranışı ile çalışır).
  - `stop()` — timer'ı durdurur, `TimerSession` nesnesi oluşturur ve `timerSessionRepositoryProvider.createSession(session)` ile kaydeder. Burada userId olarak `'current_user'` hard-coded ve TODO bırakılmış: gerçek kullanıcı ID'si auth provider'dan alınmalı.
  - `addTime(seconds)` — hızlı + / - zaman ekleme desteği; running durumunda `_startTime` compensasyonu ile uygulanır.
  - `_onTargetReached()` — hedefe ulaşıldığında titreşim/ses uyarısı tetiklenir; otomatik durdurma yapılmaz (kullanıcıya kontrol bırakır).
- Repository entegrasyonu: `stop()` içinde `timerSessionRepositoryProvider` kullanılarak `createSession` çağrılır.
- Notlar / TODOs:
  - `userId` halen sabit; notifier auth provider'dan gerçek userId'yi alacak şekilde güncellenmeli.
  - `_pausedDuration` ve `totalPausedSeconds` hesaplamaları eksikken TODO işaretleri var.

#### `lib/features/habits/presentation/providers/timer_session_providers.dart`
- Amaç: `TimerSession` ile ilgili datasouce/repository ve provider'ları sağlar.
- Sağlanan provider'lar:
  - `timerSessionRemoteDataSourceProvider` — Firestore tabanlı `TimerSessionRemoteDataSource` örneği.
  - `timerSessionRepositoryProvider` — `TimerSessionRepositoryImpl` örneği (remote datasource kullanır).
  - `timerSessionsProvider` — `StreamProvider.family<List<TimerSession>, String>` ile bir alışkanlığın oturumlarını realtime izler (`watchSessionsForHabit`).
  - `todaySessionsProvider` — `FutureProvider.family<List<TimerSession>, String>` ile bugünün seanslarını getirir.
  - `totalTimeProvider` — bir alışkanlık için toplam geçirilen süreyi saniye cinsinden döner.
- Notlar: Provider'lar basit DI/abstraction görevi görüyor; UI tarafı bu provider'ları `watch`/`read` ile kullanıyor (ör. `HabitTimerScreen` bugünkü seans özetini göstermek için `todaySessionsProvider`'ı okuyor).

#### `lib/features/habits/presentation/providers/habits_provider.dart`
- Amaç: Habits feature için en kapsamlı provider dosyası. Remote datasource, repository, liste/tekil/istatistik/todayLogs provider'ları ve `HabitActionNotifier` (stateful actions) bu dosyada tanımlanmış.
- Öne çıkan provider'lar:
  - `uuidProvider` — UUID üretimi için `Uuid` instance'ı.
  - `habitRemoteDataSourceProvider` — `HabitRemoteDataSource` örneği (firestoreProvider kullanır).
  - `habitRepositoryProvider` — `HabitRepositoryImpl` örneği (remote datasource + uuid).
  - `habitsProvider(userId)` — `FutureProvider` ile aktif alışkanlık listesini döner.
  - `habitProvider(habitId)` — tekil habit getirme.
  - `todayLogsProvider(userId)` — bugünkü logları getirir.
  - `habitStatisticsProvider(habitId)` — `getHabitStatistics` çağrısı ile `HabitStatistics` döner; hata durumunda sıfır/varsayılan istatistik seti döndürülür.
  - `streakRecoveryEligibilityProvider` — belirli bir `missedDate` için recovery uygunluğunu `HabitRepository.checkRecoveryEligibility` üzerinden sorgular.
- `HabitActionNotifier` (StateNotifier):
  - State: `HabitActionState` (isLoading, error, successMessage, lastUnlockedAchievements).
  - Eylemler: `createHabit`, `updateHabit`, `deleteHabit`, `completeHabit`, `skipHabit`, `useStreakRecovery`, `syncWithFirebase`, `clearMessages`.
  - `completeHabit` akışı: repository.completeHabit -> sonra getHabitStatistics -> achievement servisinin `checkAndUnlockAchievements` çağrısı yapılır. Yeni kazanılan achievement'ler state'e eklenir ve UI tarafından dialog'larla gösterilir.
  - `useStreakRecovery` ve `skipHabit` pipeline'ları repository result'larına göre state güncellemesi yapar.
- Hata ve sonuç ele alma: `Result` tipi (Success/Failure) extension'ı `isSuccess`, `isFailure`, `dataOrNull`, `errorOrNull` ile kolay okunur. Notifier metodları dönüş olarak `bool` veriyor (başarılı/başarısız) ve state içinde mesaj/hata saklıyor.
- Notlar / Sugestiyonlar:
  - `completeHabit` içinde achievement kontrolü sync/async olarak yapılmış; büyük bir achievement check listesi performans etkileyebilir — bu kontrolün background queue'ya alınması veya sınırlı tetiklenmesi düşünülebilir.
  - StateNotifier'ın state'ini temizlemek için `clearMessages()` mevcut; UI tarafı bu çağrıyı uygun bir yerde yapmalı.

---

Eklendi: Provider/notifier açıklamaları rapora eklendi. Şimdi `habits` özelliği için kalan küçük dosyalar (özellikle presentation widgets dışında kalan provider dosyaları tamamlandı). Bir sonraki hedefim: `lib/features/habits/data/datasources` içinde kalan remote/local kaynakları ve `data/repositories` içindeki eksik dosyaları (örn. `timer_session_repository_impl.dart`) belgelemek, sonra auth/social/achievements özelliklerine geçmek.

### Habits — Presentation Widgets (eklenen)

Bu bölüm `lib/features/habits/presentation/widgets` içindeki dört ana widget'ı inceler: `HabitCard`, `DetailedCheckInSheet`, `StreakRecoveryDialog` ve `ProgressRing`.

#### `lib/features/habits/presentation/widgets/habit_card.dart`
- Amaç: Alışkanlık listesindeki her bir öğeyi gösteren kart bileşeni. Kart; icon, isim, kategori, açıklama, durum rozeti (tamamlandı/atlandı), hızlı eylem butonları (Tamamla, Atla), ve zamanlayıcı başlatma gibi callback'leri içerir. Ayrıca slidable (swipe) eylemleriyle düzenle/sil/paylaş fonksiyonlarını sunar.
- Öne çıkan davranışlar:
  - `Slidable` ile sol (complete) ve sağ (share/edit/delete) swipe aksiyonları. Hızlı tamamlama swipe ile tetiklenebilir.
  - `onComplete` ve `onSkip` callback'leri `Map<String, dynamic>` şeklinde detay (quality, note, photo, shareWithFriends) alabilecek şekilde tasarlanmış. Bu map `DetailedCheckInSheet`'ten veya hızlı tamamlama davranışından geliyor.
  - `isTimedHabit` kontrolü ile `onTimer` (timer başlat) callback'i gösteriliyor. Böylece `HabitCard` hem check-in hem de zamanlayıcı başlatma yeteneğine sahip.
  - `showStreakWarning` prop'u ile seri kırılma uyarısı banner'ı gösterilebiliyor; `onRecoverStreak` callback'i ile kurtarma diyaloğu tetikleniyor.
- UI/UX notlar:
  - Kart, tamamlandıysa metni üzerinden çizgi (line-through) uygular; tamamlanma/atlama renkleri UI'da belirgin.
  - Swipe/Slidable ve HapticFeedback entegrasyonu hızlı ve dokunsal geri bildirim sunuyor.

#### `lib/features/habits/presentation/widgets/detailed_checkin_sheet.dart`
- Amaç: Kullanıcının bir alışkanlığı tamamladığında detaylı bilgi (kalite seçimi, not, fotoğraf, paylaşma tercihi) girmesini sağlayan modal bottom sheet.
- Öne çıkan davranışlar:
  - Kalite seçimi için üç buton: Kötü / İyi / Mükemmel. Seçim `LogQuality` enum'una karşılık gelir.
  - Not alanı, opsiyonel fotoğraf ekleme (kamera veya galeriden) ve "Arkadaşlarla Paylaş" toggle'ı içerir.
  - Fotoğraf seçimi için `image_picker` kullanılıyor; seçilen fotoğraf bir `File` objesi olarak `Navigator.pop` ile parent'a döndürülüyor.
  - Tamamlama onayında `_handleComplete()` seçilen kaliteyi doğrulayıp (zorunlu) parent'a bir map döndürüyor: `{quality, note, photo, shareWithFriends}`. Cancel ve değişiklikleri iptal etme yolunda uyarılar bulunuyor.
  - `_saveDraft()` TODO olarak bırakılmış; not taslağı ileride local draft/persist ile geliştirilebilir.
- Güvenlik ve hata notları:
  - Fotoğraf seçiminde hatalar `SnackBar` ile kullanıcıya bildiriliyor.
  - `maxLength` ve `imageQuality` sınırları kullanıcı deneyimini ve network kullanımını optimize etmek için ayarlanmış.

#### `lib/features/habits/presentation/widgets/streak_recovery_dialog.dart`
- Amaç: Bir alışkanlığın seri kırıldığında kullanıcıya kurtarma seçeneği sunan dialog. Hem kurtarma kullanılabiliyorsa hem de kullanılamıyorsa farklı UI dalları içerir.
- Öne çıkan davranışlar:
  - `canRecover` boolean'ına göre iki farklı görünüm: Kurtarma kullanılabiliyorsa yeşil bilgi kartı ve "Seriyi Kurtar" butonu; kullanılamıyorsa açıklama ve "Yeni Başlangıç Yap" aksiyonu.
  - Dialog içinde kalan süre göstergesi (`hoursRemaining`) ve haftalık kullanım sınırı hakkında bilgi var.
  - `onRecover` ve `onSkip` callback'leri ile calling screen (TodayScreen) recovery logic'i tetikliyor.
- UX notları:
  - Tasarım hem aciliyet hissi yaratıyor (ikonlar, renk vurguları) hem de neden kurtarma kullanılamadığına dair kullanıcı dostu açıklama veriyor.

#### `lib/features/habits/presentation/widgets/progress_ring.dart`
- Amaç: Yüzde bazlı ilerlemeyi gösteren reusable görsel bileşen. Hem statik `ProgressRing` hem de `AnimatedProgressRing` (pulse tamamlandığında) versiyonları bulunuyor.
- Öne çıkan davranışlar:
  - `_ProgressRingPainter` custom painter ile çiziliyor; arka plan çemberi ve ilerleme yayı (`arc`) çiziliyor. Başlangıç açısı üstten başlıyor (-pi/2).
  - `TweenAnimationBuilder` ile animasyonlu geçiş sağlanıyor; `AnimatedProgressRing` tamamlandığında (progress >= 1.0) pulse efektli `ScaleTransition` ile dikkat çekiyor.
  - Orta alan isteğe bağlı `child` widget'ı veya yüzde metni gösteriyor.
- Kullanım yerleri: `habit_detail_screen` grafik alt başlıkları, `daily_progress_card`, `habit_card` içinde küçük versiyonlar ve istatistik kartlarında kullanılmak üzere tasarlanmış.

---

Eklendi: Widgets dokümantasyonu rapora eklendi. Bir sonraki adımım `lib/features/habits/presentation/providers` altındaki provider/notifier dosyalarını (özellikle `habit_timer_notifier.dart`, `timer_session_providers.dart`, `habits_provider.dart`) incelemek ve rapora detaylı açıklamalar eklemek olacak.

---

## Detaylı Açıklamalar — lib/features/auth (domain)

Aşağıda `lib/features/auth/domain` içindeki dosyalar için ayrıntılı açıklamalar bulunmaktadır. Bu bölüm `User` domain entity'sini, `AuthRepository` arayüzünü ve auth ile ilgili usecase sınıflarını kapsar. Amaç: domain sözleşmelerini, beklenen dönüşleri ve üst katman (presentation) ile veri katmanı (data) arasındaki sorumlulukları açıkça belgelemektir.

### `lib/features/auth/domain/entities/user.dart`
- Amaç: Uygulamanın iş mantığında kullanılan kullanıcı (User) domain varlığını temsil eder. Framework bağımsız, küçük ve immutable benzeri bir yapı sağlar.
- Alanlar ve davranış:
  - Alanlar: `id`, `email`, `username`, `displayName`, `photoUrl?`.
  - `copyWith(...)` ile immutable tarzda güncelleme desteği sağlar; `Equatable` kullanımı sayesinde state yönetiminde ve testlerde value-based karşılaştırma yapabilir.
  - `toString()` override'u debug/log amaçlı okunabilir çıktı verir.
- Nerede kullanılır: Auth usecaseleri, repository dönüşleri ve presentation katmanındaki provider'lar / widget'lar `User` tipini taşıyarak tip güvenli veri paylaşımı sağlar. `User` domain entity'si, data modeli (ör. `user_model.dart`) ile eşleştirilerek veri kaynağına/Firestore'a adaptasyon yapılır.

### `lib/features/auth/domain/repositories/auth_repository.dart`
- Amaç: Authentication ile ilgili tüm operasyonlar için bir soyut arayüz (contract) sunar. Data katmanı bu arayüzü implement ederek gerçek kimlik doğrulama mekaniklerini (Firebase Auth, Google Sign-In vb.) kapsüller.
- Önemli metotlar ve semantikleri:
  - `Future<Result<User>> signInWithEmail(String email, String password)` — E-posta/şifre ile giriş; `Success<User>` veya `Failure` döner.
  - `Future<Result<User>> signUpWithEmail(String email, String password, String username)` — Kayıt akışı; tipik olarak hem auth servisinde hesap oluşturma hem de users koleksiyonunda profil/username kaydı yapılır.
  - `Future<Result<User>> signInWithGoogle()` ve `Future<Result<User>> completeGoogleSignIn({...})` — Google OAuth akışı iki aşamalı desteklenmiş: SDK ile kimlik doğrulama, ardından uygulama içinde eksik kullanıcı alanı (ör. username) tamamlanarak `completeGoogleSignIn` ile uygulama veri modelinin oluşturulması bekleniyor.
  - `Future<Result<void>> signOut()` — Oturumu kapatma, token/FCM cleanup ve local session temizliği gibi yan etkiler data katmanında ele alınmalı.
  - `Future<Result<void>> resetPassword(String email)` — Şifre sıfırlama e-postası gönderme.
  - `Future<Result<User?>> getCurrentUser()` ve `Stream<User?> get authStateChanges` — Sunucudaki auth durumu ile uygulama state'ini senkronize eden çağrılar/stream'ler; presentation katmanı (provider) bu stream'e abone olur.
- Notlar / öneriler:
  - Arayüz `Result` tipini döndürüyor; bu, üst katmanların hataları kullanıcı-dostu mesajlara dönüştürmesini ve UI'ı uygun şekilde göstermesini kolaylaştırır.
  - `completeGoogleSignIn` metodunun varlığı, Google ile login olup username gibi ek meta veriyi tamamlamaya izin veren bir UX akışının uygulandığını gösterir — tipik olarak yeni Google kullanıcıları için gerekli.
  - Security: token, refresh token veya sesson bilgileri repository uygulamasında (data katmanı) saklanmalı; domain arayüzü bu detayları sarmalar ve presentation katmanına yalnızca `User` veya operation sonucu sunar.

### `lib/features/auth/domain/usecases/auth_usecases.dart`
- Amaç: Her bir usecase sınıfı, tek bir iş mantığı eylemini temsil eder ve `AuthRepository`'ye delegasyon yapar. Bu yapı Clean Architecture prensiplerine uygun, test edilebilir küçük parçalara ayrılmış bir iş mantığı sağlar.
- İçerik ve örnek davranışlar:
  - `SignInWithEmail`, `SignUpWithEmail`, `SignInWithGoogle`, `SignOut`, `GetCurrentUser` sınıfları her biri `repository` bağımlılığını constructor ile alır ve `call(...)` metodu üzerinden çalıştırılır.
  - Usecase'lerin doğrudan repository'yi çağırması, presentation katmanının iş mantığını bilmeden sadece usecase'leri kullanarak akışları tetiklemesine olanak tanır. Bu, testlerde repository'nin mock'lanmasını kolaylaştırır.
- Öneriler:
  - Usecase seviyesinde giriş doğrulama/ön koşullar (ör. email format kontrolü, şifre uzunluğu) yapılabilir; mevcut kod doğrudan repository'ye delegasyon yapıyor, bu nedenle bazı validation'lar presentation katmanında veya ayrı validation usecase'lerinde daha açık olabilir.
  - `SignInWithGoogle` ve `completeGoogleSignIn` arasındaki ayrım, UI'nin Google-akışı sonrası ek bilgi toplama (username seçimi) gerektirdiğini gösterir; bu akışın hata/geri alma durumları (kullanıcı username'i iptal etti) usecase seviyesinde ele alınmalı.

---

Eklenecek sonraki adım: `lib/features/auth/data` içindeki modeller, remote/local datasources ve `auth_repository_impl.dart` dosyalarını okuyup aynı detay seviyesinde rapora ekleyeceğim (token yönetimi, credential saklama, Google Sign-In flow ve Firestore `users` dokümanlarıyla eşleme gibi güvenlik notları dahil).

---

## Detaylı Açıklamalar — lib/features/auth (data)

Bu bölüm `lib/features/auth/data` içindeki modeller, remote/local datasources ve repository implementasyonunu inceler. Hem davranışsal (flow) hem de güvenlik/pratik notlar içerir.

### `lib/features/auth/data/models/user_model.dart`
- Amaç: Domain `User` entity'sinin Firestore ile (de)serializasyonunu sağlayan veri modeli. `UserModel` `User`'ı genişleterek Firestore alan isimleri ve `toFirestore()` map'ini yönetir.
- Öne çıkan noktalar:
  - `fromFirestore(Map<String, dynamic>)` ve `fromDocument(DocumentSnapshot)` ile dokümandan model yaratma.
  - `toFirestore()` kullanıcı dokümanını oluşturur; içinde `createdAt: FieldValue.serverTimestamp()` kullanıldığı için server-side timestamp garantilenir.
  - `toFirestore()` ayrıca `stats` ve `privacy` alt-map'leri oluşturur (ör. `totalCompletions`, `currentStreak`, `profileVisibility`) — bu, kullanıcı profilinin başlangıç verisini standardize eder.
  - `UserModel.toEntity()` domain seviyesine dönüştürme sağlar.
- Kullanım: `AuthRemoteDataSource` Firestore okuma/yazma sırasında `UserModel` kullanır; `AuthRepositoryImpl` ise modeli `User` entity'ye çevirip presentation/ domain'a sunar.

### `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Amaç: Firebase Auth ve Firestore etkileşimlerini kapsayan remote datasource. Hem mobile hem web platformlarına özgü Google Sign-In akışını düzgün şekilde destekleyecek şekilde yazılmıştır.
- Öne çıkan metotlar ve davranışlar:
  - `signInWithEmail` / `signUpWithEmail`:
    - `signUpWithEmail` önce Firestore üzerinde username uniqueness sorgusu yapar; eğer kullanıcı adı zaten varsa `FirebaseAuthException(code: 'username-already-exists')` ile hata fırlatır.
    - Kayıt işlemi hem `FirebaseAuth.createUserWithEmailAndPassword` hem de `users/{uid}.set(user.toFirestore())` adımlarını içerir; bu nedenle iki kaydın tutarlılığı önemlidir (yarı-oluşmuş kullanıcı durumunu handle edebilecek retry/cleanup politikası önerilir).
  - `signInWithGoogle`:
    - Web: popup yöntemi denenir; popup blocked durumunda redirect fallback ile uyumluluk sağlanır.
    - Mobile: `google_sign_in` paketinin account picker'ı kullanılır; `signInSilently()` sonucu varsa önce `signOut()` ile account seçim zorlanır.
    - Eğer Firestore `users` dokümanı yoksa fonksiyon bir `UserModel` döndürür ancak `username` alanı boş bırakılır — bu sinyal presentation katmanına username seçimi ekranı gösterilmesi gerektiğini belirtir.
  - `authStateChanges` stream'i:
    - Firestore dokümanının oluşması için race condition ihtimaline karşı 3 denemeye kadar bekleyip tekrar okuma yapan bir retry mekanizması mevcut; Google girişinde username kaydı gecikirse presentation katmanı username selection flow'u tetiklenir.
  - `completeGoogleSignIn`:
    - Username seçimi tamamlandığında username ile Firestore `users/{uid}` dokümanı oluşturulur.
- Hata yönetimi:
  - Metotlar `firebase_auth.FirebaseAuthException` türünü fırlatıyor (repository tarafından kullanıcı-dostu mesajlara çevriliyor).
  - `rethrow` kullanımı görüldü — dolayısıyla repository katmanında try/catch ile mesaj mapleme yapılıyor.

### `lib/features/auth/data/datasources/auth_local_datasource.dart`
- Amaç: `SharedPreferences` kullanarak basit local caching — kullanıcı bilgisi, oturum işaretleri ve opsiyonel auth token saklanır.
- Öne çıkan metotlar:
  - `cacheUser(UserModel user)` — id, email, username, displayName, photoUrl, is_logged_in ve last_login_time değerlerini kaydeder.
  - `getCachedUser()` — cache'den kullanıcı okuyup `UserModel` oluşturur; eksik alanlar varsa `null` döner.
  - `saveAuthToken/getAuthToken/clearAuthToken` — opsiyonel token saklama için yardımcılar sağlar.
  - `clearCache()` — logout sırasında cache temizliği için kullanılır.
- Güvenlik notları:
  - `SharedPreferences` cihaz üzerinde şifrelenmemiş düz metin olarak veri saklar. Eğer uygulama hassas tokenlar (ör. refresh tokens veya özel API tokenleri) saklıyorsa, `flutter_secure_storage` veya platform keystore/Keychain kullanılması önerilir.
  - Bu kod `saveAuthToken` API'sini sunuyor; eğer kullanılacaksa token saklama yöntemi gözden geçirilmeli ve mümkünse refresh token'lar yerine short-lived tokens ile backend proxy tercih edilmeli.

### `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Amaç: `AuthRepository` domain arayüzünü Firestore/Firebase implementasyonuna bağlayan adaptör. Remote datasource çağrılarını sarar, `FirebaseAuthException` kodlarını kullanıcı-dostu Türkçe mesajlara haritalar ve `UserModel` -> `User` dönüşümlerini yapar.
- Öne çıkan davranışlar:
  - Tüm önemli metotlar (signInWithEmail, signUpWithEmail, signInWithGoogle, signOut, resetPassword, getCurrentUser, completeGoogleSignIn) `try/catch` bloklarıyla korunur ve hata durumları `_handleFirebaseAuthError` aracılığıyla lokalize edilmiş mesajlara çevrilir.
  - `_handleFirebaseAuthError` geniş bir hata kodu setini ele alır: `user-not-found`, `wrong-password`, `email-already-in-use`, `weak-password`, `network-request-failed`, ayrıca custom kodlar `username-already-exists`, `google-sign-in-cancelled` vb. için de mesaj döner.
  - `authStateChanges` stream'i remote datasource'un stream'ine bağlıdır ve `UserModel`'i domain `User`'a map eder.
- Güvenlik/pratik notlar:
  - `AuthRepositoryImpl` repository katmanı olarak `FirebaseAuthException`'ları yakalayıp `Failure`'a çeviriyor — presentation katmanı bu mesajları kullanıcıya gösteriyor. Daha güvenli hata mesajları için `Failure` sınıflarına özel tipler eklemek ve mesajları i18n ile bağlamak faydalı olur.
  - `signUpWithEmail` akışında Firestore ve Auth arasında atomicite yok; kayıt sonrası Firestore yazması başarısız olursa auth hesabı oluşmuş ama profil kaydı eksik kalabilir — bu yüzden cleanup veya background retry mekanizması (ör. SyncService veya cloud function) önerilir.

---

## Güvenlik Özet (auth data ile ilgili)
- `SharedPreferences` içinde saklanan auth token kullanımına dikkat edin; eğer `saveAuthToken` aktif kullanılıyorsa `flutter_secure_storage` önerilir.
- `android/key.properties` içinde görülen keystore parolası (kök raporda daha önce not edildi) acil olarak silinmeli; `key.properties.template` ve CI secrets kullanılmalı.
- Firestore `users` doküman yazma sırasında atomicite sorunları olabilir; üretimde cloud function ile on-create user document handler veya retry/cleanup görevleri planlayın.

Eklenecek sonraki adım: `lib/features/auth/presentation` içindeki provider'lar, ekranlar ve widget'ları okuyup kullanıcı akışlarını (signup, signin, google-flow, username selection) belgeleyeceğim. Ayrıca presentation tarafında nasıl `AuthRepository` ve `AuthLocalDataSource` kullanıldığını göstereceğim.

---

## Detaylı Açıklamalar — lib/features/auth (presentation)

Bu bölüm, sunum katmanındaki provider'lar, ekranlar ve widget'lar hakkında ayrıntılı notlar içerir. Özellikle Google Sign-In sonrası username seçimi, splash/onboarding yönlendirmeleri ve auth-related widget'ların davranışları ele alınmıştır.

### Provider'lar (`lib/features/auth/presentation/providers/auth_provider.dart`)
- Amaç: Firebase/Firestore/GoogleSignIn örneklerini sağlamak, `AuthRemoteDataSource` ve `AuthRepository`'yi Riverpod provider'ları aracılığıyla uygulamanın geri kalanına enjekte etmek.
- Öne çıkan provider'lar:
  - `firebaseAuthProvider`, `firestoreProvider`, `googleSignInProvider` — platform bazlı Google clientId web için konfigüre edilmiş.
  - `authRemoteDataSourceProvider` — `AuthRemoteDataSource` örneğini konstrükte eder.
  - `authRepositoryProvider` — `AuthRepositoryImpl` örneği sağlar; presentation katmanı bu provider'ı okuyarak auth işlemlerini tetikler.
  - `authStateProvider` (StreamProvider) — `AuthRepository.authStateChanges` stream'ini expose eder; splash/onboarding ve app router tarafından kullanılır.
  - `currentUserProvider` (FutureProvider) — oturum açmış kullanıcının detaylarını getirir; `Result` bazlı dönüşlerin `Success` durumuna bakar.
  - `authLoadingProvider` — basit bir loading boolean state'i sağlar; ekranlar local loading yönetimi için bu provider'ı kullanıyor.

### Username selection flow (`lib/features/auth/presentation/screens/username_selection_screen.dart`)
- Amaç: Google Sign-In sonrası eğer Firestore'da `users/{uid}` dokümanı yoksa (yeni kullanıcı), uygulama kullanıcıdan bir `username` seçmesini ister ve seçilen kullanıcı adını `completeGoogleSignIn` ile Firestore'a yazar.
- Akış:
  - `SignInWithGoogle` veya `SignUpWithGoogle` sonucu gelen `User` nesnesinin `username` boşsa `UsernameSelectionScreen`'e yönlendirme yapılır.
  - Ekran email tabanlı öneri oluşturur, kullanıcı adını doğrular (regex, uzunluk), `usernameCheckProvider` ile benzersizliği kontrol eder ve `authRepository.completeGoogleSignIn` çağrısıyla Firestore yazmasını tamamlar.
  - Başarılı ise uygulama `AppRouter.home` rotasına geçer.
- Güvenlik/yararlılık notları:
  - `usernameCheckProvider` Firestore sorgusu sırasında hata alırsa güvenlik açısından `false` döndürerek username'in kullanılamaz olduğunu varsayar; bu, duplicate username riskini azaltır ancak kullanıcı deneyimini etkileyebilir.

### Sign-in / Sign-up ekranları (`sign_in_screen.dart`, `sign_up_screen.dart`)
- Amaç: E-posta/şifre veya Google ile oturum açma/kayıt akışlarını yönetir; hataları snackbar ile gösterir.
- Öne çıkan davranışlar:
  - Hem `signIn` hem `signUp` flow'larında `authRepositoryProvider` kullanılarak repository çağrılır ve `Result`'un `Success`/`Failure` durumuna göre navigation veya hata gösterimi yapılır.
  - Google sign-in sonucu username boşsa `usernameSelection` rotasına yönlendirilir.
  - `SignUpScreen` parola güçlendirici bir göstergesi (`_passwordStrength`) ile kullanıcıyı bilgilendirir ve şartlı onay (terms checkbox) ister.
  - `SignInScreen` içinde `forgot password` dialogu ile `resetPassword` kullanılabiliyor.

### Splash / Onboarding / Welcome (`splash_screen.dart`, `onboarding_screen.dart`, `welcome_screen.dart`)
- Amaç: Uygulama açılışında başlangıç kontrollerini yapar: minimal splash bekleme, onboarding kontrolü (`SharedPreferences`'ta `onboarding_seen`), auth state kontrolü ve yönlendirme.
- Akış detayları:
  - `SplashScreen._initializeApp()` 2 saniye bekledikten sonra `authStateProvider`'a bakar. Auth stream'in `data` kolu üzerinden gelen `User` objesi `null` değilse doğrudan home'a veya username selection'a yönlendirir.
  - Onboarding görülmemişse onboarding ekranına, görülmüşse welcome ekranına gider.

### Widgets (`social_sign_in_button.dart`, `password_input_field.dart`, `email_input_field.dart`)
- Amaç: Tekrarlanan input bileşenleri ve sosyal sign-in butonlarını birleştirmek. `social_sign_in_button` Google logosunu ve erişim kontrollü buton mantığını kapsar.
- Notlar:
  - `Image.asset('assets/icons/google_logo.png')` kullanımı var; asset yoksa fallback ikon gösteriliyor.
  - Giriş formlarında alan doğrulamaları local olarak yapılıyor (email format, şifre uzunluğu, username regex).

---

Eklenecek sonraki adım: `auth` feature'ın presentation kısmı belgelendi; şimdi `auth` feature için kalan test edilebilir noktalar ve güvenlik önerilerini rapora ekleyip, ardından `social` feature dokümantasyonuna geçeceğim (todo list'te sıradaki öğe).

---

## Detaylı Açıklamalar — lib/features/social

Bu bölüm `lib/features/social` içindeki domain, data ve presentation parçalarını detaylandırır: paylaşılan alışkanlıklar (`shared_habit`), aktiviteler (`habit_activity`) ve arkadaşlık (`friendships`) akışları. Hem API/contract (repository arayüzleri) hem de implementasyon (Firestore + Storage) önemli davranışlar ve güvenlik önerileri ile belgeledi.

### Özet (hangi dosyalar okundu)
- Domain entities: `shared_habit.dart`, `habit_activity.dart`, `friend.dart`
- Repositories (arayüzler): `shared_habit_repository.dart`, `habit_activity_repository.dart`, `friend_repository.dart`
- Data models: `shared_habit_model.dart`, `habit_activity_model.dart`, `friend_model.dart`
- Repository implementasyonları: `shared_habit_repository_impl.dart`, `habit_activity_repository_impl.dart`, `friend_repository_impl.dart`
- Presentation: `social_screen.dart` ve widget'lar (`activity_card.dart`, `shared_habit_card.dart`, `friend_list_item.dart`, `friend_request_card.dart`, `add_friend_dialog.dart`)

### Domain — ana varlıklar
- `SharedHabit`:
  - Paylaşılan alışkanlık meta verisini içerir: `habitId`, `habitName`, `ownerId/ownerUsername`, `sharedWithId/sharedWithUsername`, `canEdit`, `createdAt` vb.
  - `canEdit` bayrağı, paylaşılan kullanıcının paylaşılan alışkanlığı düzenleyip düzenleyemeyeceğini kontrol eder; uygulama bu bayrağa göre edit butonlarını gösterir.
- `HabitActivity`:
  - Kullanıcının arkadaşları ile paylaştığı bir aktivite kaydını temsil eder: `userId/username`, `habitId/habitName`, `quality`, `note`, `photoUrl`, `timerDuration`, `completedAt/createdAt`.
  - `timerDuration` ve `photoUrl` opsiyoneldir; fotoğraf varsa Firebase Storage'a yüklenip URL kayıt edilir.
- `Friend` + `FriendStatus`:
  - Arkadaşlık ilişkisini ve statülerini (`pending`, `accepted`, `rejected`) tanımlar. `Friend` entity'si aynı zamanda hem gönderilen hem gelen isteklerde kullanılıyor.

### Data layer — modeller ve implementasyon (özet)
- `SharedHabitModel`:
  - Firestore dokümanından oluşturulur ve `habitColor` gibi farklı formatlarda (int veya hex string) gelme ihtimaline karşı toleranslı parsing yapar.
  - `toFirestore()` ile `createdAt` timestamp'ı `Timestamp.fromDate` kullanılarak set ediliyor.
- `HabitActivityModel`:
  - `fromFirestore`/`toFirestore` ile `completedAt`/`createdAt` timestamp'larını DateTime <-> Timestamp olarak eşliyor.
  - `toFirestore()` sadece mevcut opsiyonel alanları (`quality`, `note`, `photoUrl`, `timerDuration`) ekliyor.
- `FriendModel`:
  - `status` alanını string olarak saklayıp modelde enum'a çeviriyor; `toFirestore()`/`fromFirestore()` ile uyumlu dönüştürme sağlanmış.

### Repository implementations — önemli davranışlar
- `SharedHabitRepositoryImpl`:
  - `shareHabit` akışı: current user, habit ve friend kullanıcı dokümanlarını okuyup, duplicate paylaşımı engellemek için sorgu çalıştırıyor. `habit` dokümanından `color` verisi hex string ise int'e parse ederek `habitColor` hesaplıyor.
  - `getSharedByMe`, `getSharedWithMe` ve streaming (`watchSharedByMe`/`watchSharedWithMe`) Firestore sorguları ile çalışıyor; hata durumları `Failure` ile döndürülüyor.
  - Güvenlik önerisi: Firestore kuralları `shared_habits` koleksiyonunda sadece `ownerId` veya `sharedWithId`'nin uygun izinlere sahip olmasını zorunlu kılmalı.
- `HabitActivityRepositoryImpl`:
  - `shareActivity` akışı: kullanıcı bilgisini alır, eğer `photo` varsa Firebase Storage'a yükler (dosya adı `habit_activities/{userId}/{timestamp}_{filename}`), URL alınıp activity dokümanı `habit_activities` koleksiyonuna yazılır.
  - Photo upload başarısız olursa akış fotoğraf olmadan devam ediyor (degrade gracefully).
  - `getActivityFeed` toplayıcı mantık: arkadaşlık listesini alıp (iki yönde accepted friendships), Firestore `in` sorgusu limiti (10) nedeniyle friend id'leri 10'ar paket halinde sorgulanıyor. Son 30 gün içindeki aktiviteler çekilip birleşik ve sıralı listede döndürülüyor.
  - `deleteActivity` kontrolü: sadece sahip kullanıcı silebilir; fotoğraf varsa Storage'dan da silmeye çalışıyor (silme başarısız olsa bile doküman siliniyor).
  - Performans notu: feed sorguları 'in' sınırlamaları ve batching ile çalışıyor — büyük arkadaş ağlarında pagination, caching veya server-side aggregation (Cloud Function) düşünülmeli.
- `FriendRepositoryImpl`:
  - `sendFriendRequest` öncelikle ayni istek/ters yöndeki istek var mı kontrolü yapıyor ve kendine istekte bulunmayı engelliyor.
  - `acceptFriendRequest` update ile `status: 'accepted'` ve `updatedAt` server timestamp olarak ayarlanıyor; `rejectFriendRequest` ise dokümanı siliyor.
  - `getFriends` birleştirilmiş sonuç döndürüyor: hem gönderilen hem alınan accepted ilişkileri birleştiriliyor; bazı durumlarda sender info almak için ek Firestore çağrıları yapılıyor.
  - `watchFriends` stream'i hem 'sent' hem 'received' accepted snapshot'larını dinliyor ve her iki kaynaktan gelen verileri birleştirip tek bir stream olarak publish ediyor. Bu, client-side karmaşık logic gerektiriyor ama realtime güncellemeler sağlıyor.

### Presentation — ekranlar ve widget akışları
- `SocialScreen`:
  - 4 tab: Aktiviteler (feed), Arkadaşlar, İstekler (pending), Paylaşılan (shared). `activityFeedProvider`, `friendsProvider`, `pendingRequestsProvider`, `sharedWithMeProvider` / `sharedByMeProvider` gibi provider'lara bağlı AsyncValue kullanımı var.
  - Aktiviteler tab'ı pull-to-refresh ile `ref.invalidate(activityFeedProvider)` tetikleyebiliyor.
  - Arkadaş ekleme `AddFriendDialog` ile username araması (`userSearchProvider`) yapılıp `sendFriendRequestProvider` ile istek gönderiliyor.
- Widget'lar:
  - `ActivityCard`: feed öğesini gösterir; fotoğraf için `CachedNetworkImage` kullanıyor, kendi aktivitenizse silme butonu gösteriyor; zaman formatlama `time ago` ve kalite mapping içerir.
  - `SharedHabitCard`: paylaşımları listeler, `onUnshare` callback'i ile paylaşımı kaldırabiliyor.
  - `FriendListItem`, `FriendRequestCard`: arkadaş listesini ve gelen istekleri yönetmek için kullanılacak küçük bileşenler—onay/red/çıkarma aksiyonları UI'dan tetikleniyor.

### Güvenlik ve operasyonel notlar
- Firestore kuralları: `habit_activities`, `shared_habits`, `friendships` koleksiyonları için yazma/okuma izinleri dikkatle tanımlanmalı — örneğin bir kullanıcı yalnızca kendi `habit_activities` dokümanlarını silebilmeli; `shared_habits` yalnızca `ownerId` veya `sharedWithId` tarafından okunabilmeli.
- Storage erişimi: fotoğraf upload ve silme işlemleri Storage URL'e dayandığından, Storage güvenlik kuralları ve token/URL erişim politikaları gözden geçirilmeli.
- Privacy: `UserModel.toFirestore()` içinde `privacy` alt-map'i (`profileVisibility`, `allowFriendRequests`) bulunduğu için UI bu ayarlara göre arkadaş istekleri, profil görüntüleme ve paylaşılan içerik görünürlüğünü kısıtlamalı.
- Performance: `getActivityFeed`'in batching ve `in` sorgu limiti için Cloud Function ile friend aggregation (ör. feed index per user) veya server-side fan-out stratejileri değerlendirilmeli.

Eklenecek sonraki adım: `achievements` feature dokümantasyonuna geçeceğim (todo list'teki bir sonraki öğe). Rota: önce `lib/features/achievements/domain` dosyalarını, sonra `data` ve `presentation` okuyup rapora ekleyeceğim.

---

## Detaylı Açıklamalar — lib/features/achievements

Bu bölüm `lib/features/achievements` altındaki dosyaların koduna dayalı, çok-paragraflı açıklamaları içerir: domain entity, data model, servis, provider ve UI widget'ları. Amaç: kazanılan rozetlerin nasıl hesaplandığı, kilitlenip kilit açma (unlock) davranışı, realtime izleme ve presentation davranışlarını belgelemektir.

### 1) Domain — `lib/features/achievements/domain/entities/achievement.dart`
- Amaç: Kullanıcının kazandığı bir ödülü/rozet'i (Achievement) temsil eden saf domain entity'si. `Equatable` kullanılarak value-based karşılaştırma sağlar.
- Temel alanlar: `id`, `userId`, `badgeType` (enum `BadgeType`), `unlockedAt`, opsiyonel `habitId` (alişkanlığa bağlı rozetler için) ve `metadata` (streak sayısı, zaman bilgisi vb.).
- `BadgeType` enum'u uygulamada kullanılan rozetleri tanımlar (`firstStep`, `weekWarrior`, `monthMaster`, `perfectWeek`, `streakKing`, `centurion`, `earlyBird`, `nightOwl`, `consistent`, `dedicated`). Buna ek olarak `BadgeTypeExtension` display metin, açıklama ve emoji/icon karşılıkları sağlar. Bu sayede UI tarafı doğrudan `badgeType.title`, `badgeType.description`, `badgeType.icon` kullanarak gösterim yapabilir.
- Notlar: `BadgeType.value` enum'un name'ini döner; model <-> Firestore string eşleştirmesinde bu field kullanılıyor. `fromString` yardımcı metodu veritabanından alınan string'i güvenli biçimde enum'a çevirir (fallback olarak `firstStep`).

### 2) Data model — `lib/features/achievements/data/models/achievement_model.dart`
- Amaç: Firestore dokümanlarını domain `Achievement` entity'sine çevirmek ve tersi dönüşümleri sağlamak.
- Özellikler:
  - `fromFirestore(DocumentSnapshot)` Firestore dokümanını okuyup model oluşturur; `unlockedAt` Timestamp -> DateTime dönüşümü yapar. `habitId` ve `metadata` opsiyonel olarak parse edilir.
  - `fromEntity(Achievement)` domain nesnesinden model inşa eder; `toFirestore()` ise Firestore'a yazılacak map'i üretir (Timestamp.fromDate kullanılarak `unlockedAt` saklanır).
  - `toEntity()` ile domain entity'sine dönüşüm sağlayarak repository veya servislerin domain tip ile devam etmesini kolaylaştırır.
- Güvenlik/şema notu: Model `badgeType`'ı string olarak saklar (enum.name). Firestore kurallarında `badgeType`'ın beklenen set'e ait olduğunun doğrulanması (allow list) önerilir.

### 3) Servis — `lib/features/achievements/data/services/achievement_service.dart`
- Amaç: Ödül kontrolü, kilit açma (unlock) işlemleri, sorgulama ve realtime izleme gibi tüm achievement operasyonlarını sunan tek hizmet katmanıdır.
- Öne çıkan API'ler:
  - `getUserAchievements(String userId)` — Kullanıcının tüm kazanılmış rozetlerini sıralı olarak çekip domain listesi döndürür (unlockedAt descending).
  - `hasAchievement(String userId, BadgeType badgeType)` — Bir rozetin zaten alınmış olup olmadığını sorgular; yaratma işlemi öncesi duplicate kontrolü için kullanılır.
  - `unlockAchievement({userId, badgeType, habitId, metadata})` — Eğer kullanıcı o rozet zaten kazanmadıysa yeni bir `Achievement` yaratır, Firestore'da `achievements` koleksiyonuna bir doküman olarak ekler (uuid ile id üretir) ve domain nesnesini döner. Eğer zaten varsa `null` döner. Hata durumunda istisna fırlatılır.
  - `checkAndUnlockAchievements(...)` — En kapsamlı yardımcı: bir tamamlamadan sonra (veya periodik analizde) bir dizi kuralı kontrol eder (ilk tamamlamada `firstStep`, streak bazlı `weekWarrior`, `consistent`, `monthMaster`, `dedicated`, `streakKing`, toplam tamamlamalar için `centurion`, saat bazlı `earlyBird`/`nightOwl` vb.). Yeni açılan rozetleri toplayıp liste halinde döner.
  - `watchUserAchievements(String userId)` — Firestore snapshot stream'ini domain listesine map'leyerek realtime güncelleme sağlar; UI bu stream'e subscribe olarak rozetlerin anlık görünümünü elde eder.
- Davranış ve hata notları:
  - `unlockAchievement` öncelikle `hasAchievement` ile duplicate kontrolü yapar; bu, aynı rozetin birden fazla kez yazılmasını engeller.
  - `checkAndUnlockAchievements` içinde her bir rozet için `unlockAchievement` çağrısı yapılırken `try/catch` ile hatalar sessiz geçirilir (uygulamanın asıl tamamlanma akışını engellememek adına). Bu nedenle loglama ya da telemetri ile başarısız olan unlock'ların izlenmesi önerilir.
  - Performans: çok sayıda kullanıcı için sık çalıştırıldığında `hasAchievement` sorguları maliyetli olabilir (her rozet için sorgu). Öneri: unlock kontrolünü optimize etmek için ya tek bir `where` sorgusuyla ilgili badgeType'ları birlikte sorgulamak ya da rozetleri local cache/aggregate olarak tutmak (ör. kullanıcı dokümanında kısa bir `earnedBadges` map) düşünülebilir.

### 4) Presentation — Providers (`lib/features/achievements/presentation/providers/achievement_provider.dart`)
- Amaç: Riverpod provider'ları ile `AchievementService`'i DI'lamak, kullanıcıya ait rozetleri stream/future üzerinden sunmak ve action'lar (check/trigger) için bir StateNotifier sağlamak.
- Sağlanan provider'lar:
  - `achievementUuidProvider` — `Uuid` instance sağlanır (service'nin id üretmesi için).
  - `achievementServiceProvider` — `AchievementService` inşa edilip paylaşılır (Firestore ve Uuid enjekte edilir).
  - `userAchievementsProvider` — `StreamProvider.family<List<Achievement>, String>` şeklinde kullanıcı bazlı realtime rozet listesi sağlar (service.watchUserAchievements kullanır).
  - `achievementCountProvider` — `FutureProvider.family<int, String>`; kullanıcının toplam rozet sayısını döner.
  - `AchievementActionNotifier` — `StateNotifier<AchievementActionState>`; `checkAchievements(...)` metodu ile `AchievementService.checkAndUnlockAchievements`'ı çağırır, `isLoading`, `error` ve `lastUnlockedAchievements` state'lerini yönetir. UI, yeni rozetleri almak ve kullanıcının ekrana gösterilmesi için bu notifier'ın state'ini kullanır.
- Notlar:
  - `checkAchievements` çağrısı genellikle bir habit tamamlanma pipeline'ında (`HabitActionNotifier` içinde) tetiklenir. Bu notifier'ın `lastUnlockedAchievements` alanı UI tarafından kontrol edilip `AchievementUnlockedDialog` gösterilmesi için kullanılabilir.
  - Error handling: notifier hata durumunda `state.error` içine mesaj setler ve boş liste döndürür; bu sayede başarısızlıklar kullanıcı deneyimini bozmaz.

### 5) Presentation — Widgets
- `lib/features/achievements/presentation/widgets/badge_widget.dart`
  - Amaç: Tek bir rozetin görsel gösterimi. `BadgeWidget` rozetin ikonunu (emoji), başlığını ve açıklamasını gösterir; boyut değişkenleri (`BadgeSize.small/medium/large`) ve `showDate` opsiyonu ile UI esnekliği sunar.
  - Görsel detaylar: gradient li altın/portakal renkler (Gold/Orange), shadow, ve icon için emoji karakteri kullanımı. `showDate` true ise `unlockedAt` tarihinde göre 'Bugün', 'Dün', 'X gün önce' veya `DD/MM/YYYY` formatında tarih gösterir.
  - Erişilebilirlik: Text alternatifleri (semantikler) eklenebilir; emoji tek başına erişilebilirlik için yetersiz kalabilir.

- `lib/features/achievements/presentation/widgets/achievement_unlocked_dialog.dart`
  - Amaç: Yeni kazanılmış rozetleri kullanıcıya kutlama amaçlı gösteren modal dialog. Animasyonlu (scale + fade) bir açılma ve basit "Harika!" butonu içerir.
  - Davranış: Dialog açıldığında animasyon oynatılır, rozet `BadgeWidget` ile büyük boyutta gösterilir ve konfeti/ışıltı sembollerle görsel geri bildirim verilir. Kapat butonuna basıldığında dialog kapanır.
  - Kullanım önerisi: `AchievementActionNotifier`'ın `lastUnlockedAchievements` listesini alan UI bileşeni, yeni çözülmüş rozetler için `showAchievementUnlockedDialog(context, achievement)` çağrısı yapabilir. Eğer birden fazla rozet açıldıysa ardışık gösterim veya özelleştirilmiş birliktelik dialog'u (ör. grid) düşünülebilir.

### 6) Edge cases, test ve güvenlik notları
- Duplicate unlock: `unlockAchievement` içinde `hasAchievement` ile ön kontrol var; yine de race condition durumları için Firestore tarafında `onCreate` Cloud Function ile double-check veya `achievements` koleksiyonunda `id` olarak UUID kullanılması korunur. Alternatif olarak `users/{userId}/achievements/{badgeType}` şeklinde tekil id'li doküman yapısı, duplicate yazımları teknik olarak engeller.
- Hata toleransı: `checkAndUnlockAchievements` hataları `print` ile sessiz bırakıyor; üretimde bu hataları bir hata izleme servisine (Sentry vb.) veya bir monitoring queue'ya göndermek daha sağlıklıdır.
- Performans: Çok sık tetiklenen `checkAndUnlockAchievements` çağrıları kullanıcı başına çok sayıda küçük Firestore yazma/read sorgusuna sebep olabilir. Öneri: küçük bir buffer/aggregate mantığı ile (ör. tamamlamadan sonra belirli koşullar sağlandığında veya arka plan job'larında toplu kontrol) çalıştırmak maliyetleri düşürebilir.
- Offline senkronizasyon: Şu an `AchievementService.unlockAchievement` doğrudan Firestore'a yazıyor. Eğer uygulama offline-first davranışı destekliyorsa achievement unlock işlemleri `SyncService` kuyruğuna eklenerek arka planda senkronize edilebilir; bu kullanıcı deneyimini iyileştirir (ör. mobil bağlantı yokken rozetlerin client'ta gösterilip sonradan server'a gönderilmesi).
- Firestore güvenlik kuralları: `achievements` koleksiyonunda sadece ilgili `userId`'nin kendi rozetlerini yazmasına izin verilmesi, `badgeType`'ın beklenen set içinde olmasının zorunlu kılınması ve `unlockedAt` alanının server timestamp ile set edilmesi önerilir.

### 7) Özet ve tavsiyeler
- `achievements` feature'ı küçük, iyi ayrılmış parçalardan (entity, model, service, providers, widgets) oluşuyor ve UI ile backend arasındaki etkileşimi sade bir servis API'siyle soyutluyor. `AchievementService`'in `checkAndUnlockAchievements` metodu uygulamanın ödül kurallarını merkezileştiriyor; bu iyi bir tasarım çünkü kurallar tek bir noktadan değiştirilebilir.
- Kısa iyileştirme önerileri:
  - `unlockAchievement` için atomic duplicate koruması (document id'yi `userId_badgeType` benzeri tekil bir anahtara dönüştürme) veya Firestore transaction/Cloud Function kontrolü.
  - Hata izleme/logging entegrasyonu (silent catch yerine monitoring).
  - Offline-first entegrasyon: `SyncService` ile unlock isteklerini kuyruğa yazmak (ve client-side hızlı UI gösterimi) kullanıcı deneyimini iyileştirir.
  - UI: `AchievementUnlockedDialog` için çoklu rozet gösterimi (grid) ve erişilebilirlik iyileştirmeleri.

Eklendi: Bu Achievements bölümü, `lib/features/achievements` altındaki domain, data ve presentation dosyalarına dayalı olarak `ANALYSIS_REPORT.md` içine eklendi.

---

## Finalization & Project Playbook

Bu bölüm, raporu kapatmadan önce uygulanması gereken hızlı eylemleri, ilk sprint önerisini ve temel kontrol komutlarını özetler. Amaç: projeyi yönetmeye hazır hale getirmek için pratik adımlar sağlamaktır.

### Hızlı öncelikler (ilk 2 hafta)
- Güvenlik: `android/key.properties` içindeki parolaların repodan kaldırılması, `upload-keystore.jks` dosyasının repodan çıkarılması ve `key.properties.template` ile CI secrets kullanımına geçiş. (kritik)
- CI: `flutter analyze`, `flutter test` ve `flutter pub get` adımlarını içeren bir pipeline oluşturulması. (yüksek)
- Tests: SyncService, AchievementService ve HabitRepository için öncelikli 3-5 birim testi yazılması. (yüksek)
- Secrets rotation: Mevcut keystore ve credential'ların yenilenmesi/rotasyonu planlanması. (kritik)
- Release hazırlığı: Play Store keystore güvence altına alınması ve release pipeline taslağı. (orta)

### Sprint 0 (ilk 5 iş günü) önerisi
- Gün 1: Güvenlik adımları — `key.properties.template` eklenmesi, `.gitignore` güncellemesi ve hassas dosyaların repodan kaldırılması (commit ve plan). (benim tarafımdan önerilen commit adımları aşağıda)
- Gün 2: CI pipeline kurulumuna başlama (GitHub Actions önerisi). `flutter pub get`, `flutter analyze`, `flutter test` adımlarını ekleyin.
- Gün 3: 3 kritik birim testi yazma ve CI ile entegre etme.
- Gün 4: Kod temizliği, TODO'ların listelenmesi ve küçük refactor'lar.
- Gün 5: İlk release candidate ve sürüm notları taslağı.

### Hızlı kontrol komutları (Windows cmd.exe)
```cmd
rem Flutter ortamını doğrulama
flutter --version
flutter pub get

rem Statik analiz
flutter analyze

rem Testleri çalıştırma
flutter test
```

---

## Security & Secrets — Quick Guide

Bu bölüm kritik güvenlik adımlarını ve repodan hassas verilerin kaldırılması için kısa talimatları içerir.

### Önerilen eylemler
1. `android/key.properties` içindeki parolaları derhal repodan kaldırın.
2. `android/app/upload-keystore.jks` veya benzeri `.jks` dosyalarını repodan silin ve güvenli bir secret store'a taşıyın.
3. Git geçmişinde bulunan hassas dosyaları temizlemek için `git filter-repo` veya BFG kullanın (aşağıda örnek komutlar).
4. CI ortamında gerekli secret'ları (KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD, GOOGLE_SERVICES_JSON) ortam değişkenleri veya secret manager ile sağlayın.

### Örnek local adımlar (commit sonrası temizleme ve push koordinasyonu gerektirir)
```cmd
git rm --cached android/key.properties
git rm --cached android/app/upload-keystore.jks
git commit -m "chore: remove local keystore and key.properties from repo"
git push origin master
```

### Eğer geçmişten tamamen temizlemek isterseniz (uygulama sahibinin onayı gerekir)
```cmd
rem BFG ya da git filter-repo önerilir; BFG örneği:
java -jar bfg.jar --delete-files upload-keystore.jks
java -jar bfg.jar --delete-files key.properties
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

Not: Bu adımlar remote branch'leri etkiler ve force push gerektirebilir — ekip ile koordinasyon zorunludur.

### `key.properties.template`
Projeye `key.properties.template` eklendi; geliştiriciler bu dosyayı kopyalayıp yerel `android/key.properties` dosyasını oluşturmalı veya CI secrets kullanmalıdır.

---

## Sonuç ve ne kaldı
- `ANALYSIS_REPORT.md` şimdi proje kod tabanının kapsamlı bir belgesini içeriyor; `ANALYSIS_REPORT_APPENDIX.md` ve `SECURITY.md` ek dosyaları eylem planı ve güvenlik rehberi sağlar.
- Todo list'te "Security sweep & secrets" ve "Finalize report & run checks" kalan yüksek öncelikli maddelerdir. Bir sonraki adım olarak bu iki maddede ilerleyebilirim: (1) git geçmiş temizliği için komut önerileriyle tam bir plan hazırlamak ve (2) basit bir GitHub Actions workflow şablonu oluşturmak (CI için).



