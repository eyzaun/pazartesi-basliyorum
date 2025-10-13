import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'Pazartesi Başlıyorum'**
  String get appName;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @habits.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlıklar'**
  String get habits;

  /// No description provided for @statistics.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get statistics;

  /// No description provided for @social.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal'**
  String get social;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @createHabit.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Oluştur'**
  String get createHabit;

  /// No description provided for @editHabit.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlığı Düzenle'**
  String get editHabit;

  /// No description provided for @habitName.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlık Adı'**
  String get habitName;

  /// No description provided for @description.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get description;

  /// No description provided for @category.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @frequency.
  ///
  /// In tr, this message translates to:
  /// **'Sıklık'**
  String get frequency;

  /// No description provided for @icon.
  ///
  /// In tr, this message translates to:
  /// **'İkon'**
  String get icon;

  /// No description provided for @color.
  ///
  /// In tr, this message translates to:
  /// **'Renk'**
  String get color;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @complete.
  ///
  /// In tr, this message translates to:
  /// **'Tamamla'**
  String get complete;

  /// No description provided for @completed.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get completed;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get skip;

  /// No description provided for @skipped.
  ///
  /// In tr, this message translates to:
  /// **'Atlandı'**
  String get skipped;

  /// No description provided for @skipReason.
  ///
  /// In tr, this message translates to:
  /// **'Atlama Nedeni'**
  String get skipReason;

  /// No description provided for @addNote.
  ///
  /// In tr, this message translates to:
  /// **'Not Ekle'**
  String get addNote;

  /// No description provided for @quality.
  ///
  /// In tr, this message translates to:
  /// **'Kalite'**
  String get quality;

  /// No description provided for @minimal.
  ///
  /// In tr, this message translates to:
  /// **'Minimal'**
  String get minimal;

  /// No description provided for @good.
  ///
  /// In tr, this message translates to:
  /// **'İyi'**
  String get good;

  /// No description provided for @excellent.
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel'**
  String get excellent;

  /// No description provided for @signIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @username.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı'**
  String get username;

  /// No description provided for @confirmPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Onayla'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPassword;

  /// No description provided for @continueAsGuest.
  ///
  /// In tr, this message translates to:
  /// **'Misafir Olarak Devam Et'**
  String get continueAsGuest;

  /// No description provided for @signInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get signInWithGoogle;

  /// No description provided for @welcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Alışkanlıklarını takip et, hedeflerine ulaş'**
  String get welcomeTitle;

  /// No description provided for @noAccountYet.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get noAccountYet;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?'**
  String get alreadyHaveAccount;

  /// No description provided for @dailyProgress.
  ///
  /// In tr, this message translates to:
  /// **'Günlük İlerleme'**
  String get dailyProgress;

  /// No description provided for @streak.
  ///
  /// In tr, this message translates to:
  /// **'Seri'**
  String get streak;

  /// No description provided for @days.
  ///
  /// In tr, this message translates to:
  /// **'gün'**
  String get days;

  /// No description provided for @completionRate.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanma Oranı'**
  String get completionRate;

  /// No description provided for @totalCompletions.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Tamamlama'**
  String get totalCompletions;

  /// No description provided for @currentStreak.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Seri'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In tr, this message translates to:
  /// **'En Uzun Seri'**
  String get longestStreak;

  /// No description provided for @thisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ay'**
  String get thisMonth;

  /// No description provided for @noHabitsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz alışkanlık yok'**
  String get noHabitsYet;

  /// No description provided for @createYourFirstHabit.
  ///
  /// In tr, this message translates to:
  /// **'İlk alışkanlığını oluştur'**
  String get createYourFirstHabit;

  /// No description provided for @loadingError.
  ///
  /// In tr, this message translates to:
  /// **'Yükleme hatası'**
  String get loadingError;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @noInternetConnection.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok'**
  String get noInternetConnection;

  /// No description provided for @syncPending.
  ///
  /// In tr, this message translates to:
  /// **'Senkronizasyon bekleniyor'**
  String get syncPending;

  /// No description provided for @synced.
  ///
  /// In tr, this message translates to:
  /// **'Senkronize edildi'**
  String get synced;

  /// No description provided for @offlineMode.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı Mod'**
  String get offlineMode;

  /// No description provided for @emailRequired.
  ///
  /// In tr, this message translates to:
  /// **'E-posta gerekli'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta girin'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalı'**
  String get passwordTooShort;

  /// No description provided for @usernameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı gerekli'**
  String get usernameRequired;

  /// No description provided for @usernameTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı en az 3 karakter olmalı'**
  String get usernameTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get passwordsDoNotMatch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
