# 🔑 إنشاء Release Keystore — خطوة بخطوة

## ما هو الـ Keystore؟

الـ Keystore ملف يحتوي على مفتاح تشفير يُوقَّع به تطبيقك.
Google Play لا يقبل تحديثات التطبيق إلا إذا وُقِّعت بنفس المفتاح الأصلي.

⚠️ **فقدان الـ Keystore = عدم القدرة على تحديث التطبيق أبداً**
⚠️ **احتفظ بنسخة احتياطية في مكانين مختلفين**

---

## الخطوة 1 — إنشاء الـ Keystore

افتح Terminal في مجلد المشروع:

```bash
keytool -genkey -v \
  -keystore android/app/waqti-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias waqti
```

ستُسأل عن:
```
Enter keystore password:  [اختر كلمة سر قوية]
Re-enter password:        [أعد الكلمة]
What is your first and last name? Daryne
What is your organizational unit? Waqti
What is your organization? Daryne
What is the name of your City? Casablanca
What is the name of your State? Casablanca
What is the two-letter country code? MA
Is CN=Daryne, OU=Waqti, O=Daryne, L=Casablanca, ST=Casablanca, C=MA correct? yes

Enter key password for <waqti>: [نفس كلمة السر أو كلمة مختلفة]
```

---

## الخطوة 2 — إنشاء key.properties

```bash
cat > android/key.properties << PROPS
storeFile=waqti-release.jks
storePassword=YOUR_KEYSTORE_PASSWORD
keyAlias=waqti
keyPassword=YOUR_KEY_PASSWORD
PROPS
```

---

## الخطوة 3 — التحقق

```bash
keytool -list -v -keystore android/app/waqti-release.jks
# يجب أن يظهر: Alias name: waqti
```

---

## الخطوة 4 — بناء Release AAB

```bash
flutter build appbundle --release
```

الملف الناتج:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## الخطوة 5 — تفعيل Play App Signing (موصى به)

في Play Console:
```
Release → Setup → App signing
→ "Let Google manage and protect your app signing key"
→ Upload your key (رفع الـ .jks الخاص بك)
→ Google تحتفظ بنسخة احتياطية آمنة
```

هذا يحميك في حالة فقدان الـ Keystore.

---

## النسخ الاحتياطي ⭐ مهم جداً

```bash
# انسخ الملف لـ:
# 1. USB Drive خارجي
# 2. Google Drive (مُشفَّر)
# 3. Email لنفسك (مضغوط بكلمة سر)

zip -e waqti-keystore-backup.zip android/app/waqti-release.jks
```

---

## ملف .gitignore — تأكد أن الـ Keystore لا يُرفع لـ GitHub

```
# في .gitignore (موجود مسبقاً في المشروع)
*.jks
*.keystore
key.properties
android/key.properties
```

---

## إذا كنت تبني على CI/CD (GitHub Actions)

```bash
# حوِّل الـ keystore لـ base64
base64 -w 0 android/app/waqti-release.jks > keystore_base64.txt

# أضف في GitHub Secrets:
# KEYSTORE_BASE64  = محتوى keystore_base64.txt
# KEYSTORE_PASSWORD = كلمة سر الـ keystore
# KEY_ALIAS         = waqti
# KEY_PASSWORD      = كلمة سر المفتاح
```
