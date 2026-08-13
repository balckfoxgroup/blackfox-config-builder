<div dir="rtl">

# Black Fox Config Builder — Android MVP

اپ جداگانه اندروید برای ساخت کانفیگ 3X-UI (نسخه ۱.۰ MVP).

## ساختار

```
android/
├── go/                 ← کلاینت 3X-UI (gomobile → mobile.aar)
├── flutter/            ← UI (Connection / Single / Bulk / List / Settings / Contact)
├── scripts/            ← build-gomobile.ps1, build-release.ps1
└── dist/               ← APK نهایی (بعد از build — در git نیست)
```

## پیش‌نیاز

- Go 1.22+
- Flutter SDK 3.3+
- Android SDK + NDK
- **JDK 17+** (`javac` در PATH — برای gomobile)
- `ANDROID_HOME` تنظیم شده

## Build

```powershell
# از ریشهٔ همین پوشه android/
# 1) کتابخانه Go
.\scripts\build-gomobile.ps1

# 2) APK release (arm64)
.\scripts\build-release.ps1
```

قبل از release signing، `flutter/android/key.properties.example` را به `key.properties` کپی کنید (این فایل در git نیست).

## MVP شامل

- اتصال و ذخیره امن پنل (`flutter_secure_storage`)
- ساخت کانفیگ تکی + QR + کپی لینک
- لیست محلی کانفیگ‌ها + حذف

## حجم تقریبی

~۲۵–۴۰ مگ (بدون embed بسته 3X-UI — فقط HTTP client)

## Package

`com.blackfoxvpnn.configbuilder`

</div>
