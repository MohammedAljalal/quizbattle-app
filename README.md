# QuizBattle 🎯

تطبيق موبايل تعليمي تنافسي مبني بـ Flutter و Firebase.

---

## 📁 هيكل المشروع

```
lib/
├── main.dart                          # نقطة الدخول + التوجيه
├── firebase_options.dart              # إعدادات Firebase (استبدلها)
├── theme/
│   └── app_theme.dart                 # الثيم والألوان
├── models/
│   ├── user_model.dart
│   ├── quiz_model.dart
│   ├── question_model.dart
│   └── submission_model.dart
├── services/
│   ├── auth_service.dart
│   ├── quiz_service.dart
│   └── submission_service.dart
├── providers/
│   ├── auth_provider.dart
│   └── quiz_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── host/
│   │   ├── host_dashboard_screen.dart
│   │   ├── create_quiz_screen.dart
│   │   └── quiz_details_screen.dart
│   └── participant/
│       ├── participant_home_screen.dart
│       ├── quiz_screen.dart
│       ├── result_screen.dart
│       └── leaderboard_screen.dart
└── widgets/
    └── custom_button.dart
```

---

##  خطوات الإعداد

### 1. إنشاء مشروع Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. اضغط **Add Project** وأنشئ مشروعاً جديداً
3. فعّل **Authentication** → Sign-in methods:
   - Email/Password ✅
   - Anonymous ✅
4. فعّل **Cloud Firestore** → Start in production mode

### 2. ربط Flutter بـ Firebase

```bash
# تثبيت FlutterFire CLI
dart pub global activate flutterfire_cli

# في مجلد المشروع
flutterfire configure
```

سيُولّد هذا الأمر ملف `lib/firebase_options.dart` تلقائياً.
**احذف** ملف `firebase_options.dart` الحالي واستبدله بالمُولَّد.

### 3. تثبيت المتطلبات

```bash
flutter pub get
```

### 4. رفع قواعد Firestore

في Firebase Console → Firestore → Rules، انسخ محتوى `firestore.rules`.

أو عبر CLI:
```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 5. تشغيل التطبيق

```bash
flutter run
```

---

##  Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /quizzes/{quizId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'host';
      allow update: if request.auth != null
        && resource.data.hostId == request.auth.uid;
      allow delete: if request.auth != null
        && resource.data.hostId == request.auth.uid;
    }
    match /submissions/{submissionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

---

##  Firestore Indexes المطلوبة

أضفها من Firebase Console → Firestore → Indexes:

| Collection   | Fields                              |
|--------------|-------------------------------------|
| quizzes      | hostId ASC, startTime DESC          |
| quizzes      | roomCode ASC                        |
| submissions  | quizId ASC, score DESC              |
| submissions  | quizId ASC, userId ASC              |
| submissions  | quizId ASC, submittedAt DESC        |

---

## تدفق التطبيق

```
Splash (2s)
  └─ Onboarding (أول مرة)
       └─ Login / Register
            ├─ Host  → Host Dashboard → Create Quiz → Quiz Details
            └─ Student/Guest → Participant Home → Quiz → Result → Leaderboard
```

---

## 🏗️ الميزات

| الميزة | الوصف |
|--------|-------|
| **Authentication** | تسجيل بالإيميل أو دخول كضيف |
| **إنشاء اختبار** | أسئلة MCQ مع 4 خيارات وتحديد الإجابة الصحيحة |
| **رمز الغرفة** | رمز فريد بصيغة QB-XXXX |
| **Real-time** | تحديث فوري للنتائج والمشاركين |
| **Leaderboard** | ترتيب تنافسي مع ميداليات للأوائل |
| **نجوم النتيجة** | 1-3 نجوم بحسب النسبة المئوية |
| **حماية البيانات** | Firestore Rules + Role-based access |
| **RTL كامل** | دعم كامل للعربية |
| **Offline** | Firestore offline persistence |

---

##  المكتبات المستخدمة

```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
provider: ^6.1.0
google_fonts: ^6.2.0
flutter_animate: ^4.5.0
shared_preferences: ^2.2.0
intl: ^0.19.0
uuid: ^4.3.0
lottie: ^3.1.0
```
