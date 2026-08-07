# 💰 دليل AdMob الكامل — وقتي

## نظرة عامة

وقتي يستخدم **4 أنواع إعلانات** لتحقيق الدخل:

| النوع | متى يظهر | مكانه في الكود |
|-------|----------|----------------|
| **Banner (الرئيسية)** | أسفل شاشة المسار | `home_page.dart` |
| **Banner (الدرس)** | أسفل شاشة نهاية الدرس | `lesson_page.dart` |
| **Interstitial** | كل 3 دروس مكتملة | `ad_service.dart` → `onLessonComplete()` |
| **Rewarded** | زر "مساعدة" (اختياري) | `ad_service.dart` → `showRewarded()` |

---

## الخطوة 1 — إنشاء حساب AdMob

1. اذهب إلى **https://admob.google.com**
2. سجّل دخول بحساب Google (نفس حساب Play Console إن أمكن)
3. أكمل معلومات الحساب (الاسم، البلد، العملة)
4. أضف معلومات الدفع (ضروري لاستلام الأرباح)

> **ملاحظة:** الدفع يبدأ بعد 60 يوماً من الإشتراك الأول وعند بلوغ 100$.

---

## الخطوة 2 — إضافة التطبيق

### Android
```
AdMob Console
→ Apps (التطبيقات)
→ Add App (إضافة تطبيق)
→ Platform: Android
→ Is the app listed on a supported app store? 
    ○ Yes → ابحث باسم وقتي (بعد رفعه)
    ○ No → Add manually (الآن قبل الرفع)
→ App name: وقتي
→ Add App
```

### iOS (منفصل)
```
→ Add App → iOS
→ App name: وقتي
→ Add App
```

> **مهم:** ستحصل على **App ID** مختلف لكل منصة.
> الشكل: `ca-app-pub-1234567890123456~1234567890`

---

## الخطوة 3 — إنشاء وحدات الإعلان (Ad Units)

### لكل تطبيق (Android و iOS) أنشئ 4 وحدات:

#### 3.1 Banner للشاشة الرئيسية
```
→ Ad units → Create ad unit
→ Type: Banner
→ Name: waqti_banner_home
→ Save → احفظ الـ Ad Unit ID
```

#### 3.2 Banner لنهاية الدرس
```
→ Create ad unit → Banner
→ Name: waqti_banner_lesson
→ Save → احفظ الـ Ad Unit ID
```

#### 3.3 Interstitial (يظهر كل 3 دروس)
```
→ Create ad unit → Interstitial
→ Name: waqti_interstitial
→ Save → احفظ الـ Ad Unit ID
```

#### 3.4 Rewarded (للمساعدة)
```
→ Create ad unit → Rewarded
→ Name: waqti_rewarded
→ Reward amount: 1 | Reward item: hint
→ Save → احفظ الـ Ad Unit ID
```

---

## الخطوة 4 — إدخال الـ IDs في الكود

### 4.1 في `lib/core/constants/app_constants.dart`

```dart
class AdMobIds {
  // ─── Android ───────────────────────────────────────────────
  static const androidAppId        = 'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX';
  static const androidBannerHome   = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const androidBannerLesson = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const androidInterstitial = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const androidRewarded     = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // ─── iOS ───────────────────────────────────────────────────
  static const iosAppId            = 'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX';
  static const iosBannerHome       = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const iosBannerLesson     = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const iosInterstitial     = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const iosRewarded         = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
}
```

### 4.2 في `android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
<!--                ↑ Android App ID من AdMob ↑            -->
```

### 4.3 في `ios/Runner/Info.plist`

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
<!--   ↑ iOS App ID من AdMob ↑                  -->
```

---

## الخطوة 5 — إعدادات تطبيقات الأطفال (إلزامي)

وقتي تطبيق أطفال — **يجب** الالتزام بـ Google Play Families Policy.
هذا مطبّق مسبقاً في `ad_service.dart`:

```dart
await MobileAds.instance.updateRequestConfiguration(
  RequestConfiguration(
    tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,  // ✅
    tagForUnderAgeOfConsent:      TagForUnderAgeOfConsent.yes,       // ✅
    maxAdContentRating:           MaxAdContentRating.g,              // ✅ G-rated only
  ),
);
```

**لا تغيّر هذه القيم** — إذا أزلتها وتطبيقك موجه للأطفال، قد يُحذف من المتجر.

---

## الخطوة 6 — اختبار الإعلانات

### استخدم Test IDs أثناء التطوير

الكود يستخدم Test IDs تلقائياً في Debug mode:

```dart
// في ad_service.dart — يتغير تلقائياً
static bool get _isDebug => !const bool.fromEnvironment('dart.vm.product');
```

في Debug → Test IDs  
في Release → IDs حقيقية

### أجهزة الاختبار

لتفادي تسجيل نقرات حقيقية أثناء التطوير:

```dart
// أضف في ad_service.dart داخل initialize()
await MobileAds.instance.updateRequestConfiguration(
  RequestConfiguration(
    testDeviceIds: ['YOUR_TEST_DEVICE_ID'],  // من logcat/console
    // ...
  ),
);
```

---

## الخطوة 7 — سياسة Play Store للأطفال

### في Google Play Console:
```
App content
→ Target audience and content
→ Target age group: Ages 5-8 (أو حسب جمهورك)
→ Does your app contain ads? → Yes
→ Ad type: Google AdMob (G-rated, child-directed)
```

### في App Store Connect:
```
App Information
→ Content Rights: No third-party content
→ Age Rating: 4+ (أو 9+)
→ Advertising Identifier (IDFA): Yes (AdMob uses it)
→ ✓ Serve advertisements within the app
```

---

## جدول الـ IDs — احتفظ بها في مكان آمن

| المنصة | النوع | الـ ID |
|--------|-------|--------|
| Android | App ID | `ca-app-pub-???~???` |
| Android | Banner Home | `ca-app-pub-???/???` |
| Android | Banner Lesson | `ca-app-pub-???/???` |
| Android | Interstitial | `ca-app-pub-???/???` |
| Android | Rewarded | `ca-app-pub-???/???` |
| iOS | App ID | `ca-app-pub-???~???` |
| iOS | Banner Home | `ca-app-pub-???/???` |
| iOS | Banner Lesson | `ca-app-pub-???/???` |
| iOS | Interstitial | `ca-app-pub-???/???` |
| iOS | Rewarded | `ca-app-pub-???/???` |

---

## توقعات الدخل

| معدل التحميل | CPM المتوقع (أطفال) | الدخل الشهري التقديري |
|-------------|-------------------|----------------------|
| 1,000 مستخدم نشط | $0.5 - $2 | $5 - $20 |
| 10,000 مستخدم نشط | $0.5 - $2 | $50 - $200 |
| 100,000 مستخدم نشط | $0.5 - $2 | $500 - $2,000 |

> إعلانات الأطفال لها CPM أقل بسبب قيود COPPA.
> الـ Rewarded ads لها CPM أعلى بكثير ($5-$15).

---

## المشاكل الشائعة

| المشكلة | الحل |
|---------|------|
| الإعلانات لا تظهر | تأكد من استبدال Test IDs بالحقيقية في Release |
| `MobileAds.instance.initialize()` يفشل | تأكد من وجود App ID صحيح في Manifest/Info.plist |
| حساب AdMob معلّق | تأكد من عدم النقر على إعلاناتك |
| الإعلانات مرفوضة | تأكد من `MaxAdContentRating.g` |
| لا تصلك مدفوعات | تحقق من معلومات الدفع وبلوغ حد $100 |
