// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Black Fox Config Builder';

  @override
  String get selectLanguagePrompt => 'Bitte wählen Sie Ihre Sprache';

  @override
  String get languageFa => 'فارسی';

  @override
  String get languageEn => 'English';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageZh => '中文';

  @override
  String get languageButton => 'Language';

  @override
  String get navConnection => 'Verbindung';

  @override
  String get navSingle => 'Einzeln';

  @override
  String get navBulk => 'Stapel';

  @override
  String get navList => 'Liste';

  @override
  String get connected => 'Verbunden';

  @override
  String get disconnected => 'Getrennt';

  @override
  String get connectToPanel => 'Mit 3X-UI-Panel verbinden';

  @override
  String get panelUrl => 'Panel-URL';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get apiKeyOptional => 'API-Schlüssel (optional)';

  @override
  String get subUriOptional => 'Sub-URI (optional)';

  @override
  String get connect => 'Verbinden';

  @override
  String get disconnect => 'Trennen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get requiredField => 'Required';

  @override
  String get connecting => 'Connecting to panel…';

  @override
  String get connectionEstablished =>
      'Connected. Session remains active until disconnected.';

  @override
  String get disconnecting => 'Disconnecting…';

  @override
  String get connectionClosed => 'Connection closed.';

  @override
  String get panelSaved => 'Panel settings saved.';

  @override
  String get panelCleared => 'Saved settings cleared.';

  @override
  String get configName => 'Config name';

  @override
  String get baseName => 'Base name';

  @override
  String get count => 'Count';

  @override
  String get trafficGb => 'Traffic (GB)';

  @override
  String get durationDays => 'Duration (days)';

  @override
  String get inboundPort => 'Inbound port';

  @override
  String get createConfig => 'Create config';

  @override
  String get createBulkConfig => 'Create bulk configs';

  @override
  String get clearPage => 'Clear page';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get clear => 'Clear';

  @override
  String get pageCleared => 'Page cleared.';

  @override
  String get clearPageTitle => 'Clear page';

  @override
  String get clearPageFormConfirm =>
      'Are you sure you want to clear the form?\n\nThis action cannot be undone.';

  @override
  String get clearBulkConfirm =>
      'Are you sure you want to clear the generated config list?\n\nThis action cannot be undone.';

  @override
  String get connectFirst =>
      'Connect to the panel from the Connection tab first.';

  @override
  String get savePanelFirst => 'Save panel settings first.';

  @override
  String get configNameRequired => 'Config name is required.';

  @override
  String get baseNameAndCountRequired => 'Base name and count are required.';

  @override
  String get v2rayHint =>
      'Use the Sub link in v2rayNG to show name, traffic and expiry.';

  @override
  String get configLink => 'Config link:';

  @override
  String get subLink => 'Sub link:';

  @override
  String get qrConfig => 'Config QR';

  @override
  String get qrSub => 'Sub QR';

  @override
  String get tapToCopy => 'Tap to copy';

  @override
  String copied(String label) {
    return '$label copied';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String selectedCount(int count) {
    return 'Selected: $count';
  }

  @override
  String get copyLink => 'Copy link';

  @override
  String get deleteFromPanel => 'Delete from panel';

  @override
  String get deleteFromList => 'Delete from list';

  @override
  String get noConfigsYet => 'No configs created yet.';

  @override
  String get deleteFromListTitle => 'Delete from list';

  @override
  String get deleteFromListSingle =>
      'Remove this config from the local list?\n\nThis does not delete the user from the server.';

  @override
  String get deleteFromListMultiple =>
      'Remove selected items from the local list?\n\nThis does not delete users from the server.';

  @override
  String get deleteFromPanelTitle => 'Delete from panel';

  @override
  String get deleteFromPanelSingle =>
      'Delete this user from the 3X-UI panel?\n\nThis action cannot be undone.';

  @override
  String get deleteFromPanelMultiple =>
      'Delete selected users from the panel?\n\nThis action cannot be undone.';

  @override
  String get deletePanelResultTitle => 'Delete from panel result';

  @override
  String successCount(int count) {
    return 'Success: $count';
  }

  @override
  String failureCount(int count) {
    return 'Failed: $count';
  }

  @override
  String get errors => 'Errors:';

  @override
  String get configDeletedFromPanel => 'Config deleted from panel';

  @override
  String get configDeletedFromList => 'Config removed from list';

  @override
  String get configsDeletedFromList => 'Selected items removed from list';

  @override
  String get noLinksToCopy => 'No links to copy.';

  @override
  String get linkCopied => 'Link copied';

  @override
  String linksCopied(int count) {
    return '$count links copied';
  }

  @override
  String get connectPanelFirst => 'Connect to the panel first.';

  @override
  String get stop => 'Stop';

  @override
  String get linkNumber => 'Link number';

  @override
  String get copy => 'Copy';

  @override
  String get configLinkColumn => 'Config link';

  @override
  String get subLinkColumn => 'Sub link';

  @override
  String get bulkLinksPlaceholder => 'Generated links will appear here.';

  @override
  String get singleResultPlaceholder =>
      'Created config result will appear here.';

  @override
  String linksCopiedByIndex(int index) {
    return 'Links #$index copied';
  }

  @override
  String indexCopied(int index) {
    return '#$index copied';
  }

  @override
  String get invalidIndex => 'Enter a valid number.';

  @override
  String get linkNotFoundByIndex => 'No link found with this number.';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get navContact => 'Contact';

  @override
  String get contactTitle => '🌐 Black Fox Contact 🌐';

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
  String get contactChannel => '📢 Official Channel:';

  @override
  String get contactChannelLink => '@BlackFoxVpnn';

  @override
  String get contactSupport => '🛠 Support:';

  @override
  String get contactSupportLink => '@HiBlackFoxVpn';

  @override
  String get contactBot => '🤖 Purchase & Service Bot:';

  @override
  String get contactBotLink => '@BlackFoxVpn_bot';

  @override
  String get contactGroup => '💬 Black Fox Group:';

  @override
  String get contactGroupLink => '@Black_Fox_Group';

  @override
  String get contactTelegramNote =>
      'All contact accounts are Telegram. Tap to open.';

  @override
  String get contactVersion => 'App version:';

  @override
  String get contactThanks =>
      '❤️ Thank you for being part of the Black Fox family!';

  @override
  String get toastConnecting => 'Connecting...';

  @override
  String get toastConnectSuccess => 'Connected successfully.';

  @override
  String get toastConnectFailed => 'Connection failed.';

  @override
  String get toastDisconnecting => 'Disconnecting...';

  @override
  String get toastDisconnectSuccess => 'Connection closed.';

  @override
  String get toastDisconnectFailed => 'Failed to disconnect.';

  @override
  String get toastSaving => 'Saving...';

  @override
  String get toastSaveSuccess => 'Saved successfully.';

  @override
  String get toastSaveFailed => 'Save failed.';

  @override
  String get toastDeleting => 'Deleting...';

  @override
  String get toastDeleteSuccess => 'Deleted successfully.';

  @override
  String get toastDeleteFailed => 'Delete failed.';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsProgramUpdate => 'Program update';

  @override
  String get settingsCurrentVersion => 'Current version';

  @override
  String get settingsCheckUpdates => 'Check for updates';

  @override
  String get settingsUpToDate => 'You are using the latest version.';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String current, String latest) {
    return 'A new version is available.\n\nCurrent: $current\nLatest: $latest';
  }

  @override
  String get updateNow => 'Update';

  @override
  String get updateLater => 'Later';

  @override
  String get updateDownloading => 'Downloading update…';

  @override
  String updateDownloadProgress(int percent) {
    return 'Progress: $percent%';
  }

  @override
  String get updateCheckFailed => 'Could not check for updates.';

  @override
  String get updateDownloadFailed => 'Update download failed.';

  @override
  String get panelVersionIncompatible =>
      'Panel version is not supported. Please update 3X-UI to 3.3.0 or newer.';

  @override
  String get apiKey => 'API Key';

  @override
  String get settingsActivityLog => 'Activity log';

  @override
  String get settingsCopyLog => 'Copy log';

  @override
  String get settingsClearLog => 'Clear log';

  @override
  String get settingsLogCopied => 'Log copied to clipboard.';

  @override
  String get settingsLogEmpty =>
      'No activity yet. Connect to the panel or create a config to see logs here.';

  @override
  String get settingsLogCleared => 'Activity log cleared.';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get unlimitedHint => '0 = unlimited';

  @override
  String get generateRandomName => 'Generate random name';

  @override
  String get selectInbounds => 'Select inbounds';

  @override
  String get refreshInbounds => 'Refresh inbounds';

  @override
  String get inboundEnabled => 'Enabled';

  @override
  String get inboundDisabled => 'Disabled';

  @override
  String get inboundNoRemark => 'No remark';

  @override
  String inboundOptionLabel(
      String protocol, String remark, int port, String status) {
    return '$protocol · $remark · port $port · $status';
  }

  @override
  String get noInboundFound => 'No inbounds found on the panel.';

  @override
  String get inboundListLoadFailed => 'Could not load inbound list.';

  @override
  String get inboundSelectionRequired => 'Select at least one inbound.';

  @override
  String get configNameInvalid =>
      'Use English letters, numbers, spaces, and hyphens only.';

  @override
  String get configNameDuplicate =>
      'This config name is already used. Choose another name or tap refresh.';

  @override
  String get remoteSectionTitle => 'Updates & Remote Config';

  @override
  String get remoteRefreshBtn => 'Refresh from server';

  @override
  String get remoteRefreshDone => 'Remote config refreshed.';

  @override
  String get remoteWalletTitle => 'Payment wallet (live)';

  @override
  String get remoteWalletUnavailable =>
      'Wallet address unavailable — connect to the internet and refresh.';

  @override
  String get copyAddressWallet => 'Copy wallet address';

  @override
  String remoteServerVersion(String version) {
    return 'Server version: $version';
  }

  @override
  String get remoteServerUnknown => 'unknown (offline)';

  @override
  String remoteCurrentVersion(String version, int build) {
    return 'Current version: $version (build $build)';
  }

  @override
  String get remoteNewsTitle => 'Announcement';

  @override
  String get updateForceTitle => 'Mandatory update required';

  @override
  String get updateForceBody =>
      'This version is no longer supported. Download and install the latest release to continue.';

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
