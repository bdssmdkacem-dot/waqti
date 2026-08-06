# ⏰ وقتي v3.0 — Flutter (Android)

## ✅ ما تم إصلاحه في هذه النسخة

| المشكلة | الحل |
|---------|------|
| `build_runner` / Freezed / code gen | حُذف تماماً — Dart خالص بدون توليد كود |
| `riverpod_generator` / `@Riverpod` | استُبدل بـ `Provider` / `AsyncNotifierProvider` يدوياً |
| `freezed_annotation` | استُبدل بـ classes عادية بـ `copyWith` يدوي |
| `fontFamily: 'Cairo'` بدون ملفات | استُبدل بـ `GoogleFonts.cairo().fontFamily` |
| `assets/fonts/` فارغ | خطوط Cairo تأتي من `google_fonts` تلقائياً |
| IDs مكررة في constants | حُذف المجلد المكرر `lib/features/core/` |
| ملفات `.g.dart` و `.freezed.dart` مفقودة | لا حاجة لها بعد الآن |

---

## 🚀 تشغيل المشروع

```bash
# 1. Install dependencies (NO build_runner needed)
flutter pub get

# 2. Run directly
flutter run

# 3. Build release APK
flutter build apk --release

# 4. Build AAB for Play Store
flutter build appbundle --release
```

---

## 💰 AdMob — إعداد وحدات الإعلان

App ID مُضبوط مسبقاً: `ca-app-pub-1377346158677931~9202705192`

**الخطوة الوحيدة المتبقية:**
1. اذهب إلى **admob.google.com**
2. افتح تطبيقك → **Ad units** → **Create ad unit**
3. أنشئ 4 وحدات: Banner (Home), Banner (Lesson), Interstitial, Rewarded
4. افتح `lib/core/constants/app_constants.dart`
5. استبدل `XXXXXXXXXX` بالـ IDs الحقيقية

```dart
// lib/core/constants/app_constants.dart
static const androidBannerHome    = 'ca-app-pub-1377346158677931/REAL_ID_HERE';
static const androidBannerLesson  = 'ca-app-pub-1377346158677931/REAL_ID_HERE';
static const androidInterstitial  = 'ca-app-pub-1377346158677931/REAL_ID_HERE';
static const androidRewarded      = 'ca-app-pub-1377346158677931/REAL_ID_HERE';
```

> **ملاحظة:** في Debug mode تُستخدم Google Test IDs تلقائياً — لا حاجة لتغيير أي شيء للاختبار.

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/      app_constants.dart + AdMobIds
│   ├── errors/         failures.dart (sealed class, بدون Freezed)
│   ├── router/         app_router.dart (GoRouter, بدون @Riverpod)
│   └── theme/          WaqtiTheme + WaqtiColors + WaqtiSize
│
├── features/
│   ├── curriculum/     13 وحدة، 50+ درس، 300+ سؤال
│   │   ├── data/       curriculum_datasource.dart (in-memory)
│   │   ├── domain/     curriculum_entities.dart (plain Dart classes)
│   │   └── presentation/ home_page, lesson_page, free_play_page
│   │
│   ├── progress/       تقدم المستخدم + streak + نجوم
│   │   ├── data/       SharedPreferences JSON (بدون Hive)
│   │   ├── domain/     progress_entity.dart (plain Dart)
│   │   └── presentation/ progress_provider.dart (AsyncNotifier)
│   │
│   ├── ads/            AdMob: Banner + Interstitial + Rewarded
│   │   └── data/       ad_service.dart (ChangeNotifier + Provider)
│   │
│   └── settings/
│       ├── data/       sound_service.dart (audioplayers pool)
│       └── presentation/ settings_page.dart
│
└── shared/widgets/
    ├── analog_clock.dart   (CustomPainter + FIXED drag)
    ├── digital_clock.dart  (LCD style + AM/PM badge)
    └── zaid_mascot.dart    (CustomPainter, 4 حالات, float animation)
```

---

## 🔑 GitHub Secrets للـ CI/CD

```
KEYSTORE_BASE64       # base64 of your .jks release keystore
KEYSTORE_PASSWORD     # keystore password
KEY_ALIAS             # alias (waqti)
KEY_PASSWORD          # key password
PLAY_STORE_JSON_KEY   # Google Play service account JSON (from Play Console)
```

---

## 🧪 Tests

```bash
flutter test test/unit/curriculum_test.dart
```
