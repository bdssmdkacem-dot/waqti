# ✅ قائمة متطلبات Google Play Store — وقتي

## الحالة العامة

| المطلوب | الحالة | الإجراء |
|---------|--------|---------|
| App ID (applicationId) | ✅ `com.daryne.waqti` | جاهز |
| AdMob App ID | ✅ `ca-app-pub-1377346158677931~9202705192` | جاهز في Manifest |
| AdMob Ad Unit IDs | ⚠️ تحتاج تعيين | استبدل XXXXXXXXXX في app_constants.dart |
| أيقونة التطبيق (ic_launcher) | ✅ جميع الأحجام | جاهزة في mipmap-* |
| أيقونة المتجر 512×512 | ✅ | `assets/images/store_icon_512.png` |
| Feature Graphic 1024×500 | ✅ | `assets/images/feature_graphic_1024x500.png` |
| سياسة الخصوصية | ✅ | `PRIVACY_POLICY.html` — ارفعها على GitHub Pages |
| Release Keystore | ⚠️ تحتاج إنشاء | اتبع خطوات KEYSTORE_SETUP.md |
| Google Play Console ($25) | ⚠️ إذا لم يكن لديك | play.google.com/console |

---

## الخطوات بالترتيب

### 1. أنشئ Ad Units في AdMob ← الأهم

```
admob.google.com
→ Apps → وقتي (com.daryne.waqti)
→ Ad units → Create ad unit

أنشئ 4 وحدات:
  1. Banner    → اسم: waqti_banner_home
  2. Banner    → اسم: waqti_banner_lesson  
  3. Interstitial → اسم: waqti_interstitial
  4. Rewarded  → اسم: waqti_rewarded
                 reward: 1 hint

بعد الإنشاء، ضع الـ IDs في:
lib/core/constants/app_constants.dart
```

### 2. أنشئ Release Keystore (مرة واحدة للأبد)

```bash
keytool -genkey -v \
  -keystore waqti-release.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias waqti \
  -dname "CN=Daryne, O=Waqti, C=MA"

# احفظ كلمة السر في مكان آمن جداً
# فقدانها = عدم القدرة على تحديث التطبيق أبداً

# انقل الملف
mv waqti-release.jks android/app/

# أنشئ android/key.properties
echo "storeFile=waqti-release.jks"     > android/key.properties
echo "storePassword=YOUR_PASSWORD"    >> android/key.properties
echo "keyAlias=waqti"                 >> android/key.properties
echo "keyPassword=YOUR_PASSWORD"      >> android/key.properties
```

### 3. ابنِ الـ AAB

```bash
flutter pub get
flutter build appbundle --release
# الناتج: build/app/outputs/bundle/release/app-release.aab
```

### 4. ارفع سياسة الخصوصية

```bash
# على GitHub Pages (مجاناً):
# 1. أنشئ repo جديد: github.com/new
# 2. ارفع PRIVACY_POLICY.html بالاسم index.html
# 3. Settings → Pages → Deploy from branch (main)
# الرابط يصبح: https://YOUR_USERNAME.github.io/waqti-privacy/
```

### 5. أنشئ التطبيق في Play Console

```
play.google.com/console
→ Create app
→ App name: وقتي
→ Default language: Arabic (ar)
→ App or game: App
→ Free or paid: Free
→ Create
```

### 6. أكمل App Content

```
Policy → App content (يجب إكمال الكل قبل النشر)

✅ Privacy policy → الصق رابط GitHub Pages
✅ Ads → "Yes, my app contains ads"
✅ App access → All functionality is available without special access
✅ Content ratings → أكمل الاستبيان
   - Violence: No
   - Sexual content: No
   - Language: No  
   - Controlled substances: No
   - → Rating: Everyone (E)
✅ Target audience → Ages 5-8
   - Does your app target children? → Yes
   → Families Policy applies automatically
✅ News apps → No
✅ COVID-19 → No
✅ Data safety
   - Data collected: No (we collect nothing)
   - Data shared: No
   - Security practices: Data encrypted in transit ✓
```

### 7. Store Listing

```
Main store listing

App name (30 chars max):
وقتي - تعلّم قراءة الساعة

Short description (80 chars max):
تطبيق ممتع لتعلّم قراءة الساعة بالعربية للأطفال من 4 إلى 10 سنوات

Full description (4000 chars max):
[انسخ من STORE_LISTING.md]

Graphics:
- App icon (512×512):   assets/images/store_icon_512.png
- Feature graphic:      assets/images/feature_graphic_1024x500.png
- Screenshots (≥2):     التقط من جهازك أثناء التشغيل
```

### 8. Release

```
Production → Create new release
→ Upload: build/app/outputs/bundle/release/app-release.aab
→ Release name: 3.0.0
→ Release notes (ar): 
   "الإصدار الأول من وقتي على Google Play!
    13 وحدة تعليمية، 50+ درس لتعلّم قراءة الساعة."
→ Review → Start rollout to production
```

---

## مدة المراجعة

| النشر | الوقت المتوقع |
|-------|--------------|
| أول إصدار | 3 - 7 أيام عمل |
| تحديثات لاحقة | 1 - 3 أيام |

---

## نصائح مهمة

⚠️ **لا تنقر على إعلاناتك** — يؤدي لتعليق حساب AdMob

⚠️ **لا تفقد keystore** — لا يمكن استعادته، ولا يمكن تحديث التطبيق بدونه

⚠️ **Test IDs في Debug** — تأكد من بناء Release فقط مع IDs حقيقية

✅ **Play App Signing** — فعّله في Play Console لحماية keystore
   (Google تحتفظ بنسخة احتياطية)
