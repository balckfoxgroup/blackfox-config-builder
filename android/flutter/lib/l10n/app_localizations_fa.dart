// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'Black Fox Config Builder';

  @override
  String get selectLanguagePrompt => 'لطفاً زبان خود را انتخاب کنید';

  @override
  String get languageFa => 'فارسی';

  @override
  String get languageEn => 'English';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageZh => '中文';

  @override
  String get languageButton => 'زبان';

  @override
  String get navConnection => 'اتصال';

  @override
  String get navSingle => 'تکی';

  @override
  String get navBulk => 'گروهی';

  @override
  String get navList => 'لیست';

  @override
  String get connected => 'متصل';

  @override
  String get disconnected => 'قطع';

  @override
  String get connectToPanel => 'اتصال به پنل 3X-UI';

  @override
  String get panelUrl => 'آدرس پنل';

  @override
  String get username => 'نام کاربری';

  @override
  String get password => 'رمز عبور';

  @override
  String get apiKeyOptional => 'API Key (اختیاری)';

  @override
  String get subUriOptional => 'Sub URI (اختیاری)';

  @override
  String get connect => 'اتصال';

  @override
  String get disconnect => 'قطع اتصال';

  @override
  String get save => 'ذخیره';

  @override
  String get delete => 'حذف';

  @override
  String get requiredField => 'الزامی';

  @override
  String get connecting => 'در حال اتصال به پنل…';

  @override
  String get connectionEstablished =>
      'اتصال برقرار است. تا زمان قطع اتصال، session فعال می‌ماند.';

  @override
  String get disconnecting => 'در حال قطع اتصال…';

  @override
  String get connectionClosed => 'اتصال قطع شد.';

  @override
  String get panelSaved => 'اطلاعات پنل ذخیره شد.';

  @override
  String get panelCleared => 'اطلاعات ذخیره‌شده حذف شد.';

  @override
  String get configName => 'نام کانفیگ';

  @override
  String get baseName => 'نام پایه';

  @override
  String get count => 'تعداد';

  @override
  String get trafficGb => 'حجم (GB)';

  @override
  String get durationDays => 'مدت (روز)';

  @override
  String get inboundPort => 'پورت inbound';

  @override
  String get createConfig => 'ساخت کانفیگ';

  @override
  String get createBulkConfig => 'ساخت کانفیگ گروهی';

  @override
  String get clearPage => 'پاک کردن صفحه';

  @override
  String get cancel => 'انصراف';

  @override
  String get close => 'بستن';

  @override
  String get clear => 'پاک کردن';

  @override
  String get pageCleared => 'صفحه پاک شد.';

  @override
  String get clearPageTitle => 'پاک کردن صفحه';

  @override
  String get clearPageFormConfirm =>
      'آیا از پاک کردن اطلاعات فرم اطمینان دارید؟\n\nاین عملیات قابل بازگشت نیست.';

  @override
  String get clearBulkConfirm =>
      'آیا از پاک کردن لیست کانفیگ‌های ساخته‌شده اطمینان دارید؟\n\nاین عملیات قابل بازگشت نیست.';

  @override
  String get connectFirst => 'ابتدا از بخش اتصال، به پنل متصل شوید.';

  @override
  String get savePanelFirst => 'ابتدا اطلاعات پنل را ذخیره کنید.';

  @override
  String get configNameRequired => 'نام کانفیگ الزامی است.';

  @override
  String get baseNameAndCountRequired => 'نام پایه و تعداد الزامی است.';

  @override
  String get v2rayHint =>
      'برای نمایش نام، حجم و زمان در v2rayNG از لینک Sub استفاده کنید.';

  @override
  String get configLink => 'لینک کانفیگ:';

  @override
  String get subLink => 'لینک Sub:';

  @override
  String get qrConfig => 'QR کانفیگ';

  @override
  String get qrSub => 'QR ساب';

  @override
  String get tapToCopy => 'برای کپی ضربه بزنید';

  @override
  String copied(String label) {
    return '$label کپی شد';
  }

  @override
  String get selectAll => 'انتخاب همه';

  @override
  String selectedCount(int count) {
    return 'انتخاب شده: $count';
  }

  @override
  String get copyLink => 'کپی لینک';

  @override
  String get deleteFromPanel => 'حذف از پنل';

  @override
  String get deleteFromList => 'حذف از لیست';

  @override
  String get noConfigsYet => 'هنوز کانفیگی ساخته نشده است.';

  @override
  String get deleteFromListTitle => 'حذف از لیست';

  @override
  String get deleteFromListSingle =>
      'این کانفیگ از لیست محلی حذف شود؟\n\nاین عملیات کاربر را از سرور حذف نمی‌کند.';

  @override
  String get deleteFromListMultiple =>
      'موارد انتخاب‌شده از لیست محلی حذف شوند؟\n\nاین عملیات کاربران را از سرور حذف نمی‌کند.';

  @override
  String get deleteFromPanelTitle => 'حذف از پنل';

  @override
  String get deleteFromPanelSingle =>
      'این کاربر از پنل 3X-UI حذف شود؟\n\nاین عملیات غیرقابل بازگشت است.';

  @override
  String get deleteFromPanelMultiple =>
      'کاربران انتخاب‌شده از پنل حذف شوند؟\n\nاین عملیات غیرقابل بازگشت است.';

  @override
  String get deletePanelResultTitle => 'نتیجه حذف از پنل';

  @override
  String successCount(int count) {
    return 'موفق: $count';
  }

  @override
  String failureCount(int count) {
    return 'ناموفق: $count';
  }

  @override
  String get errors => 'خطاها:';

  @override
  String get configDeletedFromPanel => 'کانفیگ از پنل حذف شد';

  @override
  String get configDeletedFromList => 'کانفیگ از لیست حذف شد';

  @override
  String get configsDeletedFromList => 'موارد انتخاب‌شده از لیست حذف شدند';

  @override
  String get noLinksToCopy => 'لینکی برای کپی وجود ندارد.';

  @override
  String get linkCopied => 'لینک کپی شد';

  @override
  String linksCopied(int count) {
    return '$count لینک کپی شد';
  }

  @override
  String get connectPanelFirst => 'ابتدا به پنل متصل شوید.';

  @override
  String get stop => 'توقف';

  @override
  String get linkNumber => 'شماره لینک';

  @override
  String get copy => 'کپی';

  @override
  String get configLinkColumn => 'لینک کانفیگ';

  @override
  String get subLinkColumn => 'لینک Sub';

  @override
  String get bulkLinksPlaceholder =>
      'لینک‌های ساخته‌شده اینجا نمایش داده می‌شوند.';

  @override
  String get singleResultPlaceholder =>
      'نتیجه ساخت کانفیگ اینجا نمایش داده می‌شود.';

  @override
  String linksCopiedByIndex(int index) {
    return 'لینک‌های شماره $index کپی شد';
  }

  @override
  String indexCopied(int index) {
    return 'شماره $index کپی شد';
  }

  @override
  String get invalidIndex => 'شماره معتبر وارد کنید.';

  @override
  String get linkNotFoundByIndex => 'لینکی با این شماره پیدا نشد.';

  @override
  String daysCount(int count) {
    return '$count روز';
  }

  @override
  String get navContact => 'تماس';

  @override
  String get contactTitle => '🌐 راه‌های ارتباطی Black Fox 🌐';

  @override
  String get contactWebsiteDisplay => 'WWW.foxnext.net';

  @override
  String get contactWebsiteLink => 'http://foxnext.net/';

  @override
  String get contactEmailDisplay => 'support@foxnext.net';

  @override
  String get contactEmailLink => 'mailto:support@foxnext.net';

  @override
  String get contactGithubDisplay => 'github.com/balckfoxgroup';

  @override
  String get contactGithubLink => 'https://github.com/balckfoxgroup';

  @override
  String get contactChannel => '📢 کانال رسمی:';

  @override
  String get contactChannelLink => '@BlackFoxVpnn';

  @override
  String get contactSupport => '🛠 پشتیبانی:';

  @override
  String get contactSupportLink => '@HiBlackFoxVpn';

  @override
  String get contactBot => '🤖 ربات خرید و مدیریت:';

  @override
  String get contactBotLink => '@BlackFoxVpn_bot';

  @override
  String get contactGroup => '💬 گروه Black Fox:';

  @override
  String get contactGroupLink => '@Black_Fox_Group';

  @override
  String get contactTelegramNote =>
      'همه اکانت‌های ارتباطی تلگرام هستند. برای باز کردن لمس کنید.';

  @override
  String get contactVersion => 'نسخه برنامه:';

  @override
  String get contactThanks => '❤️ از همراهی شما سپاسگزاریم!';

  @override
  String get toastConnecting => 'در حال اتصال...';

  @override
  String get toastConnectSuccess => 'اتصال با موفقیت برقرار شد.';

  @override
  String get toastConnectFailed => 'اتصال برقرار نشد.';

  @override
  String get toastDisconnecting => 'در حال قطع اتصال...';

  @override
  String get toastDisconnectSuccess => 'اتصال قطع شد.';

  @override
  String get toastDisconnectFailed => 'قطع اتصال انجام نشد.';

  @override
  String get toastSaving => 'در حال ذخیره اطلاعات...';

  @override
  String get toastSaveSuccess => 'اطلاعات با موفقیت ذخیره شد.';

  @override
  String get toastSaveFailed => 'ذخیره اطلاعات انجام نشد.';

  @override
  String get toastDeleting => 'در حال حذف...';

  @override
  String get toastDeleteSuccess => 'حذف با موفقیت انجام شد.';

  @override
  String get toastDeleteFailed => 'حذف انجام نشد.';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsProgramUpdate => 'به‌روزرسانی برنامه';

  @override
  String get settingsCurrentVersion => 'نسخه فعلی';

  @override
  String get settingsCheckUpdates => 'بررسی به‌روزرسانی';

  @override
  String get settingsUpToDate => 'از آخرین نسخه استفاده می‌کنید.';

  @override
  String get updateAvailableTitle => 'به‌روزرسانی موجود است';

  @override
  String updateAvailableBody(String current, String latest) {
    return 'نسخه جدید در دسترس است.\n\nفعلی: $current\nجدید: $latest';
  }

  @override
  String get updateNow => 'به‌روزرسانی';

  @override
  String get updateLater => 'بعداً';

  @override
  String get updateDownloading => 'در حال دانلود به‌روزرسانی…';

  @override
  String updateDownloadProgress(int percent) {
    return 'پیشرفت: $percent٪';
  }

  @override
  String get updateCheckFailed => 'بررسی به‌روزرسانی انجام نشد.';

  @override
  String get updateDownloadFailed => 'دانلود به‌روزرسانی ناموفق بود.';

  @override
  String get panelVersionIncompatible =>
      'نسخه پنل پشتیبانی نمی‌شود. لطفاً 3X-UI را به 3.3.0 یا بالاتر به‌روز کنید.';

  @override
  String get apiKey => 'API Key';

  @override
  String get settingsActivityLog => 'لاگ فعالیت';

  @override
  String get settingsCopyLog => 'کپی لاگ';

  @override
  String get settingsClearLog => 'پاک کردن لاگ';

  @override
  String get settingsLogCopied => 'لاگ در کلیپ‌بورد کپی شد.';

  @override
  String get settingsLogEmpty =>
      'هنوز فعالیتی ثبت نشده. برای مشاهده لاگ، به پنل متصل شوید یا کانفیگ بسازید.';

  @override
  String get settingsLogCleared => 'لاگ فعالیت پاک شد.';

  @override
  String get unlimited => 'نامحدود';

  @override
  String get unlimitedHint => '۰ = نامحدود';

  @override
  String get generateRandomName => 'تولید نام تصادفی';

  @override
  String get selectInbounds => 'انتخاب inbound';

  @override
  String get refreshInbounds => 'بروزرسانی inboundها';

  @override
  String get inboundEnabled => 'فعال';

  @override
  String get inboundDisabled => 'غیرفعال';

  @override
  String get inboundNoRemark => 'بدون توضیح';

  @override
  String inboundOptionLabel(
      String protocol, String remark, int port, String status) {
    return '$protocol · $remark · پورت $port · $status';
  }

  @override
  String get noInboundFound => 'inboundی در پنل یافت نشد.';

  @override
  String get inboundListLoadFailed => 'بارگذاری لیست inbound ناموفق بود.';

  @override
  String get inboundSelectionRequired => 'حداقل یک inbound انتخاب کنید.';

  @override
  String get configNameInvalid =>
      'فقط حروف انگلیسی، عدد، فاصله و خط تیره مجاز است.';

  @override
  String get configNameDuplicate =>
      'این نام قبلاً استفاده شده. نام دیگری وارد کنید یا آیکون refresh را بزنید.';

  @override
  String get remoteSectionTitle => 'بروزرسانی و تنظیمات سرور';

  @override
  String get remoteRefreshBtn => 'بروزرسانی از سرور';

  @override
  String get remoteRefreshDone => 'تنظیمات سرور بروز شد.';

  @override
  String get remoteWalletTitle => 'ولت پرداخت (زنده)';

  @override
  String get remoteWalletUnavailable =>
      'آدرس ولت در دسترس نیست — اینترنت را بررسی و دوباره تازه‌سازی کنید.';

  @override
  String get copyAddressWallet => 'کپی آدرس ولت';

  @override
  String remoteServerVersion(String version) {
    return 'نسخه سرور: $version';
  }

  @override
  String get remoteServerUnknown => 'نامشخص (آفلاین)';

  @override
  String remoteCurrentVersion(String version, int build) {
    return 'نسخه فعلی: $version (build $build)';
  }

  @override
  String get remoteNewsTitle => 'اطلاعیه';

  @override
  String get updateForceTitle => 'بروزرسانی اجباری';

  @override
  String get updateForceBody =>
      'این نسخه دیگر پشتیبانی نمی‌شود. آخرین نسخه را دانلود و نصب کنید.';

  @override
  String get languageDe => 'Deutsch';

  @override
  String get languageUz => 'Oʻzbek';

  @override
  String get languageTr => 'Türkçe';

  @override
  String get languageId => 'Bahasa Indonesia';

  @override
  String get languageUk => 'Українська';

  @override
  String get languageHi => 'हिन्दी';
}
