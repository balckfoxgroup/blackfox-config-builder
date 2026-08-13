// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Black Fox Config Builder';

  @override
  String get selectLanguagePrompt => 'Пожалуйста, выберите язык';

  @override
  String get languageFa => 'فارسی';

  @override
  String get languageEn => 'English';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageZh => '中文';

  @override
  String get languageButton => 'Язык';

  @override
  String get navConnection => 'Подключение';

  @override
  String get navSingle => 'Один';

  @override
  String get navBulk => 'Массово';

  @override
  String get navList => 'Список';

  @override
  String get connected => 'Подключено';

  @override
  String get disconnected => 'Отключено';

  @override
  String get connectToPanel => 'Подключение к панели 3X-UI';

  @override
  String get panelUrl => 'URL панели';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get apiKeyOptional => 'API Key (необязательно)';

  @override
  String get subUriOptional => 'Sub URI (необязательно)';

  @override
  String get connect => 'Подключить';

  @override
  String get disconnect => 'Отключить';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get requiredField => 'Обязательно';

  @override
  String get connecting => 'Подключение к панели…';

  @override
  String get connectionEstablished =>
      'Подключено. Сессия активна до отключения.';

  @override
  String get disconnecting => 'Отключение…';

  @override
  String get connectionClosed => 'Соединение закрыто.';

  @override
  String get panelSaved => 'Настройки панели сохранены.';

  @override
  String get panelCleared => 'Сохранённые настройки удалены.';

  @override
  String get configName => 'Имя конфигурации';

  @override
  String get baseName => 'Базовое имя';

  @override
  String get count => 'Количество';

  @override
  String get trafficGb => 'Трафик (GB)';

  @override
  String get durationDays => 'Срок (дней)';

  @override
  String get inboundPort => 'Порт inbound';

  @override
  String get createConfig => 'Создать конфиг';

  @override
  String get createBulkConfig => 'Массовое создание';

  @override
  String get clearPage => 'Очистить страницу';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get clear => 'Очистить';

  @override
  String get pageCleared => 'Страница очищена.';

  @override
  String get clearPageTitle => 'Очистить страницу';

  @override
  String get clearPageFormConfirm =>
      'Вы уверены, что хотите очистить форму?\n\nЭто действие нельзя отменить.';

  @override
  String get clearBulkConfirm =>
      'Вы уверены, что хотите очистить список созданных конфигов?\n\nЭто действие нельзя отменить.';

  @override
  String get connectFirst =>
      'Сначала подключитесь к панели на вкладке «Подключение».';

  @override
  String get savePanelFirst => 'Сначала сохраните настройки панели.';

  @override
  String get configNameRequired => 'Имя конфигурации обязательно.';

  @override
  String get baseNameAndCountRequired =>
      'Базовое имя и количество обязательны.';

  @override
  String get v2rayHint =>
      'Используйте Sub-ссылку в v2rayNG для отображения имени, трафика и срока.';

  @override
  String get configLink => 'Ссылка конфига:';

  @override
  String get subLink => 'Sub-ссылка:';

  @override
  String get qrConfig => 'QR конфига';

  @override
  String get qrSub => 'QR Sub';

  @override
  String get tapToCopy => 'Нажмите для копирования';

  @override
  String copied(String label) {
    return '$label скопировано';
  }

  @override
  String get selectAll => 'Выбрать все';

  @override
  String selectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get copyLink => 'Копировать ссылку';

  @override
  String get deleteFromPanel => 'Удалить с панели';

  @override
  String get deleteFromList => 'Удалить из списка';

  @override
  String get noConfigsYet => 'Конфиги ещё не созданы.';

  @override
  String get deleteFromListTitle => 'Удалить из списка';

  @override
  String get deleteFromListSingle =>
      'Удалить этот конфиг из локального списка?\n\nПользователь на сервере не будет удалён.';

  @override
  String get deleteFromListMultiple =>
      'Удалить выбранные элементы из локального списка?\n\nПользователи на сервере не будут удалены.';

  @override
  String get deleteFromPanelTitle => 'Удалить с панели';

  @override
  String get deleteFromPanelSingle =>
      'Удалить этого пользователя с панели 3X-UI?\n\nЭто действие нельзя отменить.';

  @override
  String get deleteFromPanelMultiple =>
      'Удалить выбранных пользователей с панели?\n\nЭто действие нельзя отменить.';

  @override
  String get deletePanelResultTitle => 'Результат удаления с панели';

  @override
  String successCount(int count) {
    return 'Успешно: $count';
  }

  @override
  String failureCount(int count) {
    return 'Ошибок: $count';
  }

  @override
  String get errors => 'Ошибки:';

  @override
  String get configDeletedFromPanel => 'Конфиг удалён с панели';

  @override
  String get configDeletedFromList => 'Конфиг удалён из списка';

  @override
  String get configsDeletedFromList => 'Выбранные элементы удалены из списка';

  @override
  String get noLinksToCopy => 'Нет ссылок для копирования.';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String linksCopied(int count) {
    return 'Скопировано ссылок: $count';
  }

  @override
  String get connectPanelFirst => 'Сначала подключитесь к панели.';

  @override
  String get stop => 'Стоп';

  @override
  String get linkNumber => 'Номер ссылки';

  @override
  String get copy => 'Копировать';

  @override
  String get configLinkColumn => 'Ссылка конфига';

  @override
  String get subLinkColumn => 'Sub-ссылка';

  @override
  String get bulkLinksPlaceholder => 'Созданные ссылки появятся здесь.';

  @override
  String get singleResultPlaceholder =>
      'Результат создания конфига появится здесь.';

  @override
  String linksCopiedByIndex(int index) {
    return 'Ссылки #$index скопированы';
  }

  @override
  String indexCopied(int index) {
    return '#$index скопировано';
  }

  @override
  String get invalidIndex => 'Введите корректный номер.';

  @override
  String get linkNotFoundByIndex => 'Ссылка с таким номером не найдена.';

  @override
  String daysCount(int count) {
    return '$count дн.';
  }

  @override
  String get navContact => 'Контакты';

  @override
  String get contactTitle => '🌐 Контакты Black Fox 🌐';

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
  String get contactChannel => '📢 Официальный канал:';

  @override
  String get contactChannelLink => '@BlackFoxVpnn';

  @override
  String get contactSupport => '🛠 Поддержка:';

  @override
  String get contactSupportLink => '@HiBlackFoxVpn';

  @override
  String get contactBot => '🤖 Бот покупки и сервиса:';

  @override
  String get contactBotLink => '@BlackFoxVpn_bot';

  @override
  String get contactGroup => '💬 Группа Black Fox:';

  @override
  String get contactGroupLink => '@Black_Fox_Group';

  @override
  String get contactTelegramNote =>
      'Все контакты — в Telegram. Нажмите, чтобы открыть.';

  @override
  String get contactVersion => 'Версия приложения:';

  @override
  String get contactThanks => '❤️ Спасибо, что вы часть семьи Black Fox!';

  @override
  String get toastConnecting => 'Подключение...';

  @override
  String get toastConnectSuccess => 'Подключение успешно установлено.';

  @override
  String get toastConnectFailed => 'Не удалось подключиться.';

  @override
  String get toastDisconnecting => 'Отключение...';

  @override
  String get toastDisconnectSuccess => 'Соединение закрыто.';

  @override
  String get toastDisconnectFailed => 'Не удалось отключиться.';

  @override
  String get toastSaving => 'Сохранение...';

  @override
  String get toastSaveSuccess => 'Данные успешно сохранены.';

  @override
  String get toastSaveFailed => 'Не удалось сохранить.';

  @override
  String get toastDeleting => 'Удаление...';

  @override
  String get toastDeleteSuccess => 'Удаление выполнено успешно.';

  @override
  String get toastDeleteFailed => 'Не удалось удалить.';

  @override
  String get navSettings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsProgramUpdate => 'Обновление программы';

  @override
  String get settingsCurrentVersion => 'Текущая версия';

  @override
  String get settingsCheckUpdates => 'Проверить обновления';

  @override
  String get settingsUpToDate => 'У вас установлена последняя версия.';

  @override
  String get updateAvailableTitle => 'Доступно обновление';

  @override
  String updateAvailableBody(String current, String latest) {
    return 'Доступна новая версия.\n\nТекущая: $current\nНовая: $latest';
  }

  @override
  String get updateNow => 'Обновить';

  @override
  String get updateLater => 'Позже';

  @override
  String get updateDownloading => 'Загрузка обновления…';

  @override
  String updateDownloadProgress(int percent) {
    return 'Прогресс: $percent%';
  }

  @override
  String get updateCheckFailed => 'Не удалось проверить обновления.';

  @override
  String get updateDownloadFailed => 'Не удалось загрузить обновление.';

  @override
  String get panelVersionIncompatible =>
      'Версия панели не поддерживается. Обновите 3X-UI до 3.3.0 или новее.';

  @override
  String get apiKey => 'API Key';

  @override
  String get settingsActivityLog => 'Журнал активности';

  @override
  String get settingsCopyLog => 'Копировать журнал';

  @override
  String get settingsClearLog => 'Очистить журнал';

  @override
  String get settingsLogCopied => 'Журнал скопирован в буфер обмена.';

  @override
  String get settingsLogEmpty =>
      'Пока нет записей. Подключитесь к панели или создайте конфиг.';

  @override
  String get settingsLogCleared => 'Журнал активности очищен.';

  @override
  String get unlimited => 'Безлимит';

  @override
  String get unlimitedHint => '0 = безлимит';

  @override
  String get generateRandomName => 'Случайное имя';

  @override
  String get selectInbounds => 'Выберите inbound';

  @override
  String get refreshInbounds => 'Обновить inbound';

  @override
  String get inboundEnabled => 'Включён';

  @override
  String get inboundDisabled => 'Выключен';

  @override
  String get inboundNoRemark => 'Без заметки';

  @override
  String inboundOptionLabel(
      String protocol, String remark, int port, String status) {
    return '$protocol · $remark · порт $port · $status';
  }

  @override
  String get noInboundFound => 'Inbound не найдены на панели.';

  @override
  String get inboundListLoadFailed => 'Не удалось загрузить список inbound.';

  @override
  String get inboundSelectionRequired => 'Выберите хотя бы один inbound.';

  @override
  String get configNameInvalid =>
      'Допустимы только латиница, цифры, пробелы и дефис.';

  @override
  String get configNameDuplicate =>
      'Это имя уже используется. Введите другое или нажмите refresh.';

  @override
  String get remoteSectionTitle => 'Обновления и удалённая конфигурация';

  @override
  String get remoteRefreshBtn => 'Обновить с сервера';

  @override
  String get remoteRefreshDone => 'Удалённая конфигурация обновлена.';

  @override
  String get remoteWalletTitle => 'Кошелёк для оплаты (live)';

  @override
  String get remoteWalletUnavailable =>
      'Адрес кошелька недоступен — проверьте интернет и обновите.';

  @override
  String get copyAddressWallet => 'Копировать адрес кошелька';

  @override
  String remoteServerVersion(String version) {
    return 'Версия на сервере: $version';
  }

  @override
  String get remoteServerUnknown => 'неизвестно (офлайн)';

  @override
  String remoteCurrentVersion(String version, int build) {
    return 'Текущая версия: $version (build $build)';
  }

  @override
  String get remoteNewsTitle => 'Объявление';

  @override
  String get updateForceTitle => 'Требуется обязательное обновление';

  @override
  String get updateForceBody =>
      'Эта версия больше не поддерживается. Скачайте и установите последний релиз.';

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
