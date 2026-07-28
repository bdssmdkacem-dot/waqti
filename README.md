# ⏰ وقتي v3.0 — Flutter Clean Architecture

تطبيق تعليمي للأطفال لتعلّم قراءة الساعة، مبني بـ **Flutter 3.24** مع معمارية نظيفة كاملة.

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/          # AppConstants + AdMobIds
│   ├── errors/             # Failure (sealed, Freezed)
│   ├── router/             # GoRouter + Routes + LessonRouteArgs
│   └── theme/              # WaqtiTheme + WaqtiColors + WaqtiSize (responsive)
│
├── features/
│   ├── curriculum/         # 13 وحدة، 50+ درس، 300+ سؤال
│   │   ├── data/datasources/   curriculum_datasource.dart (pure in-memory)
│   │   ├── domain/entities/    curriculum_entities.dart (Freezed)
│   │   └── presentation/
│   │       ├── pages/     home_page, lesson_page, free_play_page
│   │       └── providers/
│   │
│   ├── progress/           # تقدم المستخدم
│   │   ├── data/           SharedPreferences JSON storage
│   │   ├── domain/entities/    UserProgress + LessonProgress (Freezed)
│   │   └── presentation/providers/  ProgressNotifier (Riverpod AsyncNotifier)
│   │
│   ├── ads/                # AdMob
│   │   └── data/           AdService (Banner + Interstitial + Rewarded)
│   │                       — child-directed, G-rated
│   │
│   └── settings/
│       ├── data/           SoundService (audioplayers, pool system)
│       └── presentation/pages/  SettingsPage
│
└── shared/
    └── widgets/
        ├── analog_clock.dart    AnalogClock + InteractiveClock (fixed drag)
        ├── digital_clock.dart   DigitalClock + AmPmBadge
        └── zaid_mascot.dart     ZaidMascot (CustomPainter, 4 moods, floating)
```

## 🚀 البدء

### 1. Clone & Install
```bash
git clone https://github.com/daryne/waqti.git
cd waqti
flutter pub get
```

### 2. توليد الكود
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. تشغيل
```bash
flutter run
```

## 💰 AdMob — الإعدادات

اقرأ **`ADMOB_SETUP.md`** للدليل الكامل خطوة بخطوة.

**الخلاصة السريعة:**
1. أنشئ حساب AdMob على admob.google.com
2. أضف تطبيقاً لـ Android وآخر لـ iOS
3. أنشئ 4 وحدات إعلانية لكل منصة
4. ضع الـ IDs في `lib/core/constants/app_constants.dart`
5. استبدل App ID في `AndroidManifest.xml` و `ios/Runner/Info.plist`

## 📚 المنهج — 13 وحدة

| # | الوحدة | النوع | الدروس |
|---|--------|-------|--------|
| 1 | ⭐ أبطال الساعة | تناظري | 4 |
| 2 | 🌙 النصف الجميل | تناظري | 3 |
| 3 | 🌟 مغامرة الربع | تناظري | 4 |
| 4 | 🚀 عدّ بالخمسة | تناظري | 4 |
| 5 | 👑 أسياد الوقت | تناظري | 4 |
| 6 | 📱 الساعة الرقمية | رقمي | 4 |
| 7 | 🌅 صباح ومساء | رقمي | 4 |
| 8 | 🔄 رقمي↔تناظري | مختلط | 3 |
| 9 | 🌈 يومي مع الساعة | رقمي | 2 |
| 10 | ⚡ تحدي السرعة | مختلط | 3 |
| 11 | ⏳ كم مرّ من الوقت | تناظري | 2 |
| 12 | 🏆 أسطورة الوقت | مختلط | 2 |
| 13 | 🧮 حساب الوقت | حسابي | 5 |

## 🔊 الأصوات — 10 ملفات

| الملف | الحدث |
|-------|-------|
| `click.mp3` | أي زر |
| `correct.mp3` | إجابة صحيحة — C-E-G chime |
| `wrong.mp3` | إجابة خاطئة — gentle descend |
| `success.mp3` | إنجاز — Nintendo 6-note |
| `lesson_complete.mp3` | إكمال درس — fanfare |
| `level_up.mp3` | ترقية — pitch sweep |
| `streak.mp3` | سلسلة — whoosh + pings |
| `reward.mp3` | مكافأة — coin sparkles |
| `countdown.mp3` | عد تنازلي — 3 ticks + GO! |
| `notification.mp3` | إشعار — double bell |

## 🧪 الاختبارات

```bash
# Unit tests
flutter test test/unit/

# All tests
flutter test

# With coverage
flutter test --coverage
```

## 🏗️ البناء للنشر

### Android (Play Store)
```bash
# إنشاء Keystore (مرة واحدة)
keytool -genkey -v -keystore waqti-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias waqti

# نسخ إلى android/
cp waqti-release.jks android/app/

# إنشاء android/key.properties
echo "storeFile=waqti-release.jks" > android/key.properties
echo "storePassword=YOUR_PASSWORD" >> android/key.properties
echo "keyAlias=waqti" >> android/key.properties
echo "keyPassword=YOUR_PASSWORD" >> android/key.properties

# بناء AAB
flutter build appbundle --release
```

### iOS (App Store)
```bash
flutter build ios --release
# ثم Xcode → Product → Archive → Distribute
```

## 🔑 GitHub Secrets المطلوبة

```
KEYSTORE_BASE64        # base64 of .jks file
KEYSTORE_PASSWORD      # keystore password
KEY_ALIAS              # key alias (waqti)
KEY_PASSWORD           # key password
PLAY_STORE_JSON_KEY    # Google Play service account JSON
```

## 📄 الترخيص

MIT — استخدم بحرية.
