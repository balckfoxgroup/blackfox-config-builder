import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_uz.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fa'),
    Locale('hi'),
    Locale('id'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
    Locale('uz'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Black Fox Config Builder'**
  String get appTitle;

  /// No description provided for @selectLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select your language'**
  String get selectLanguagePrompt;

  /// No description provided for @languageFa.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get languageFa;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageRu.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRu;

  /// No description provided for @languageZh.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageZh;

  /// No description provided for @languageButton.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageButton;

  /// No description provided for @navConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get navConnection;

  /// No description provided for @navSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get navSingle;

  /// No description provided for @navBulk.
  ///
  /// In en, this message translates to:
  /// **'Bulk'**
  String get navBulk;

  /// No description provided for @navList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get navList;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @connectToPanel.
  ///
  /// In en, this message translates to:
  /// **'Connect to 3X-UI Panel'**
  String get connectToPanel;

  /// No description provided for @panelUrl.
  ///
  /// In en, this message translates to:
  /// **'Panel URL'**
  String get panelUrl;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @apiKeyOptional.
  ///
  /// In en, this message translates to:
  /// **'API Key (optional)'**
  String get apiKeyOptional;

  /// No description provided for @subUriOptional.
  ///
  /// In en, this message translates to:
  /// **'Sub URI (optional)'**
  String get subUriOptional;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to panel…'**
  String get connecting;

  /// No description provided for @connectionEstablished.
  ///
  /// In en, this message translates to:
  /// **'Connected. Session remains active until disconnected.'**
  String get connectionEstablished;

  /// No description provided for @disconnecting.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting…'**
  String get disconnecting;

  /// No description provided for @connectionClosed.
  ///
  /// In en, this message translates to:
  /// **'Connection closed.'**
  String get connectionClosed;

  /// No description provided for @panelSaved.
  ///
  /// In en, this message translates to:
  /// **'Panel settings saved.'**
  String get panelSaved;

  /// No description provided for @panelCleared.
  ///
  /// In en, this message translates to:
  /// **'Saved settings cleared.'**
  String get panelCleared;

  /// No description provided for @configName.
  ///
  /// In en, this message translates to:
  /// **'Config name'**
  String get configName;

  /// No description provided for @baseName.
  ///
  /// In en, this message translates to:
  /// **'Base name'**
  String get baseName;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @trafficGb.
  ///
  /// In en, this message translates to:
  /// **'Traffic (GB)'**
  String get trafficGb;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'Duration (days)'**
  String get durationDays;

  /// No description provided for @inboundPort.
  ///
  /// In en, this message translates to:
  /// **'Inbound port'**
  String get inboundPort;

  /// No description provided for @createConfig.
  ///
  /// In en, this message translates to:
  /// **'Create config'**
  String get createConfig;

  /// No description provided for @createBulkConfig.
  ///
  /// In en, this message translates to:
  /// **'Create bulk configs'**
  String get createBulkConfig;

  /// No description provided for @clearPage.
  ///
  /// In en, this message translates to:
  /// **'Clear page'**
  String get clearPage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @pageCleared.
  ///
  /// In en, this message translates to:
  /// **'Page cleared.'**
  String get pageCleared;

  /// No description provided for @clearPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear page'**
  String get clearPageTitle;

  /// No description provided for @clearPageFormConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the form?\n\nThis action cannot be undone.'**
  String get clearPageFormConfirm;

  /// No description provided for @clearBulkConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the generated config list?\n\nThis action cannot be undone.'**
  String get clearBulkConfirm;

  /// No description provided for @connectFirst.
  ///
  /// In en, this message translates to:
  /// **'Connect to the panel from the Connection tab first.'**
  String get connectFirst;

  /// No description provided for @savePanelFirst.
  ///
  /// In en, this message translates to:
  /// **'Save panel settings first.'**
  String get savePanelFirst;

  /// No description provided for @configNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Config name is required.'**
  String get configNameRequired;

  /// No description provided for @baseNameAndCountRequired.
  ///
  /// In en, this message translates to:
  /// **'Base name and count are required.'**
  String get baseNameAndCountRequired;

  /// No description provided for @v2rayHint.
  ///
  /// In en, this message translates to:
  /// **'Use the Sub link in v2rayNG to show name, traffic and expiry.'**
  String get v2rayHint;

  /// No description provided for @configLink.
  ///
  /// In en, this message translates to:
  /// **'Config link:'**
  String get configLink;

  /// No description provided for @subLink.
  ///
  /// In en, this message translates to:
  /// **'Sub link:'**
  String get subLink;

  /// No description provided for @qrConfig.
  ///
  /// In en, this message translates to:
  /// **'Config QR'**
  String get qrConfig;

  /// No description provided for @qrSub.
  ///
  /// In en, this message translates to:
  /// **'Sub QR'**
  String get qrSub;

  /// No description provided for @tapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get tapToCopy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String copied(String label);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count}'**
  String selectedCount(int count);

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @deleteFromPanel.
  ///
  /// In en, this message translates to:
  /// **'Delete from panel'**
  String get deleteFromPanel;

  /// No description provided for @deleteFromList.
  ///
  /// In en, this message translates to:
  /// **'Delete from list'**
  String get deleteFromList;

  /// No description provided for @noConfigsYet.
  ///
  /// In en, this message translates to:
  /// **'No configs created yet.'**
  String get noConfigsYet;

  /// No description provided for @deleteFromListTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete from list'**
  String get deleteFromListTitle;

  /// No description provided for @deleteFromListSingle.
  ///
  /// In en, this message translates to:
  /// **'Remove this config from the local list?\n\nThis does not delete the user from the server.'**
  String get deleteFromListSingle;

  /// No description provided for @deleteFromListMultiple.
  ///
  /// In en, this message translates to:
  /// **'Remove selected items from the local list?\n\nThis does not delete users from the server.'**
  String get deleteFromListMultiple;

  /// No description provided for @deleteFromPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete from panel'**
  String get deleteFromPanelTitle;

  /// No description provided for @deleteFromPanelSingle.
  ///
  /// In en, this message translates to:
  /// **'Delete this user from the 3X-UI panel?\n\nThis action cannot be undone.'**
  String get deleteFromPanelSingle;

  /// No description provided for @deleteFromPanelMultiple.
  ///
  /// In en, this message translates to:
  /// **'Delete selected users from the panel?\n\nThis action cannot be undone.'**
  String get deleteFromPanelMultiple;

  /// No description provided for @deletePanelResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete from panel result'**
  String get deletePanelResultTitle;

  /// No description provided for @successCount.
  ///
  /// In en, this message translates to:
  /// **'Success: {count}'**
  String successCount(int count);

  /// No description provided for @failureCount.
  ///
  /// In en, this message translates to:
  /// **'Failed: {count}'**
  String failureCount(int count);

  /// No description provided for @errors.
  ///
  /// In en, this message translates to:
  /// **'Errors:'**
  String get errors;

  /// No description provided for @configDeletedFromPanel.
  ///
  /// In en, this message translates to:
  /// **'Config deleted from panel'**
  String get configDeletedFromPanel;

  /// No description provided for @configDeletedFromList.
  ///
  /// In en, this message translates to:
  /// **'Config removed from list'**
  String get configDeletedFromList;

  /// No description provided for @configsDeletedFromList.
  ///
  /// In en, this message translates to:
  /// **'Selected items removed from list'**
  String get configsDeletedFromList;

  /// No description provided for @noLinksToCopy.
  ///
  /// In en, this message translates to:
  /// **'No links to copy.'**
  String get noLinksToCopy;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @linksCopied.
  ///
  /// In en, this message translates to:
  /// **'{count} links copied'**
  String linksCopied(int count);

  /// No description provided for @connectPanelFirst.
  ///
  /// In en, this message translates to:
  /// **'Connect to the panel first.'**
  String get connectPanelFirst;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @linkNumber.
  ///
  /// In en, this message translates to:
  /// **'Link number'**
  String get linkNumber;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @configLinkColumn.
  ///
  /// In en, this message translates to:
  /// **'Config link'**
  String get configLinkColumn;

  /// No description provided for @subLinkColumn.
  ///
  /// In en, this message translates to:
  /// **'Sub link'**
  String get subLinkColumn;

  /// No description provided for @bulkLinksPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Generated links will appear here.'**
  String get bulkLinksPlaceholder;

  /// No description provided for @singleResultPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Created config result will appear here.'**
  String get singleResultPlaceholder;

  /// No description provided for @linksCopiedByIndex.
  ///
  /// In en, this message translates to:
  /// **'Links #{index} copied'**
  String linksCopiedByIndex(int index);

  /// No description provided for @indexCopied.
  ///
  /// In en, this message translates to:
  /// **'#{index} copied'**
  String indexCopied(int index);

  /// No description provided for @invalidIndex.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number.'**
  String get invalidIndex;

  /// No description provided for @linkNotFoundByIndex.
  ///
  /// In en, this message translates to:
  /// **'No link found with this number.'**
  String get linkNotFoundByIndex;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @navContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get navContact;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'🌐 Black Fox Contact 🌐'**
  String get contactTitle;

  /// No description provided for @contactWebsiteDisplay.
  ///
  /// In en, this message translates to:
  /// **'WWW.foxnext.net'**
  String get contactWebsiteDisplay;

  /// No description provided for @contactWebsiteLink.
  ///
  /// In en, this message translates to:
  /// **'http://foxnext.net/'**
  String get contactWebsiteLink;

  /// No description provided for @contactEmailDisplay.
  ///
  /// In en, this message translates to:
  /// **'support@foxnext.net'**
  String get contactEmailDisplay;

  /// No description provided for @contactEmailLink.
  ///
  /// In en, this message translates to:
  /// **'mailto:support@foxnext.net'**
  String get contactEmailLink;

  /// No description provided for @contactGithubDisplay.
  ///
  /// In en, this message translates to:
  /// **'github.com/balckfoxgroup'**
  String get contactGithubDisplay;

  /// No description provided for @contactGithubLink.
  ///
  /// In en, this message translates to:
  /// **'https://github.com/balckfoxgroup'**
  String get contactGithubLink;

  /// No description provided for @contactChannel.
  ///
  /// In en, this message translates to:
  /// **'📢 Official Channel:'**
  String get contactChannel;

  /// No description provided for @contactChannelLink.
  ///
  /// In en, this message translates to:
  /// **'@BlackFoxVpnn'**
  String get contactChannelLink;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'🛠 Support:'**
  String get contactSupport;

  /// No description provided for @contactSupportLink.
  ///
  /// In en, this message translates to:
  /// **'@HiBlackFoxVpn'**
  String get contactSupportLink;

  /// No description provided for @contactBot.
  ///
  /// In en, this message translates to:
  /// **'🤖 Purchase & Service Bot:'**
  String get contactBot;

  /// No description provided for @contactBotLink.
  ///
  /// In en, this message translates to:
  /// **'@BlackFoxVpn_bot'**
  String get contactBotLink;

  /// No description provided for @contactGroup.
  ///
  /// In en, this message translates to:
  /// **'💬 Black Fox Group:'**
  String get contactGroup;

  /// No description provided for @contactGroupLink.
  ///
  /// In en, this message translates to:
  /// **'@Black_Fox_Group'**
  String get contactGroupLink;

  /// No description provided for @contactTelegramNote.
  ///
  /// In en, this message translates to:
  /// **'All contact accounts are Telegram. Tap to open.'**
  String get contactTelegramNote;

  /// No description provided for @contactVersion.
  ///
  /// In en, this message translates to:
  /// **'App version:'**
  String get contactVersion;

  /// No description provided for @contactThanks.
  ///
  /// In en, this message translates to:
  /// **'❤️ Thank you for being part of the Black Fox family!'**
  String get contactThanks;

  /// No description provided for @toastConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get toastConnecting;

  /// No description provided for @toastConnectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connected successfully.'**
  String get toastConnectSuccess;

  /// No description provided for @toastConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed.'**
  String get toastConnectFailed;

  /// No description provided for @toastDisconnecting.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting...'**
  String get toastDisconnecting;

  /// No description provided for @toastDisconnectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection closed.'**
  String get toastDisconnectSuccess;

  /// No description provided for @toastDisconnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to disconnect.'**
  String get toastDisconnectFailed;

  /// No description provided for @toastSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get toastSaving;

  /// No description provided for @toastSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully.'**
  String get toastSaveSuccess;

  /// No description provided for @toastSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed.'**
  String get toastSaveFailed;

  /// No description provided for @toastDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get toastDeleting;

  /// No description provided for @toastDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully.'**
  String get toastDeleteSuccess;

  /// No description provided for @toastDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed.'**
  String get toastDeleteFailed;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsProgramUpdate.
  ///
  /// In en, this message translates to:
  /// **'Program update'**
  String get settingsProgramUpdate;

  /// No description provided for @settingsCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get settingsCurrentVersion;

  /// No description provided for @settingsCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get settingsCheckUpdates;

  /// No description provided for @settingsUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You are using the latest version.'**
  String get settingsUpToDate;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A new version is available.\n\nCurrent: {current}\nLatest: {latest}'**
  String updateAvailableBody(String current, String latest);

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update…'**
  String get updateDownloading;

  /// No description provided for @updateDownloadProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent}%'**
  String updateDownloadProgress(int percent);

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates.'**
  String get updateCheckFailed;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Update download failed.'**
  String get updateDownloadFailed;

  /// No description provided for @panelVersionIncompatible.
  ///
  /// In en, this message translates to:
  /// **'Panel version is not supported. Please update 3X-UI to 3.3.0 or newer.'**
  String get panelVersionIncompatible;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @settingsActivityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity log'**
  String get settingsActivityLog;

  /// No description provided for @settingsCopyLog.
  ///
  /// In en, this message translates to:
  /// **'Copy log'**
  String get settingsCopyLog;

  /// No description provided for @settingsClearLog.
  ///
  /// In en, this message translates to:
  /// **'Clear log'**
  String get settingsClearLog;

  /// No description provided for @settingsLogCopied.
  ///
  /// In en, this message translates to:
  /// **'Log copied to clipboard.'**
  String get settingsLogCopied;

  /// No description provided for @settingsLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity yet. Connect to the panel or create a config to see logs here.'**
  String get settingsLogEmpty;

  /// No description provided for @settingsLogCleared.
  ///
  /// In en, this message translates to:
  /// **'Activity log cleared.'**
  String get settingsLogCleared;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @unlimitedHint.
  ///
  /// In en, this message translates to:
  /// **'0 = unlimited'**
  String get unlimitedHint;

  /// No description provided for @generateRandomName.
  ///
  /// In en, this message translates to:
  /// **'Generate random name'**
  String get generateRandomName;

  /// No description provided for @selectInbounds.
  ///
  /// In en, this message translates to:
  /// **'Select inbounds'**
  String get selectInbounds;

  /// No description provided for @refreshInbounds.
  ///
  /// In en, this message translates to:
  /// **'Refresh inbounds'**
  String get refreshInbounds;

  /// No description provided for @inboundEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get inboundEnabled;

  /// No description provided for @inboundDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get inboundDisabled;

  /// No description provided for @inboundNoRemark.
  ///
  /// In en, this message translates to:
  /// **'No remark'**
  String get inboundNoRemark;

  /// No description provided for @inboundOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'{protocol} · {remark} · port {port} · {status}'**
  String inboundOptionLabel(
      String protocol, String remark, int port, String status);

  /// No description provided for @noInboundFound.
  ///
  /// In en, this message translates to:
  /// **'No inbounds found on the panel.'**
  String get noInboundFound;

  /// No description provided for @inboundListLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load inbound list.'**
  String get inboundListLoadFailed;

  /// No description provided for @inboundSelectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one inbound.'**
  String get inboundSelectionRequired;

  /// No description provided for @configNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use English letters, numbers, spaces, and hyphens only.'**
  String get configNameInvalid;

  /// No description provided for @configNameDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This config name is already used. Choose another name or tap refresh.'**
  String get configNameDuplicate;

  /// No description provided for @remoteSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates & Remote Config'**
  String get remoteSectionTitle;

  /// No description provided for @remoteRefreshBtn.
  ///
  /// In en, this message translates to:
  /// **'Refresh from server'**
  String get remoteRefreshBtn;

  /// No description provided for @remoteRefreshDone.
  ///
  /// In en, this message translates to:
  /// **'Remote config refreshed.'**
  String get remoteRefreshDone;

  /// No description provided for @remoteWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment wallet (live)'**
  String get remoteWalletTitle;

  /// No description provided for @remoteWalletUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Wallet address unavailable — connect to the internet and refresh.'**
  String get remoteWalletUnavailable;

  /// No description provided for @copyAddressWallet.
  ///
  /// In en, this message translates to:
  /// **'Copy wallet address'**
  String get copyAddressWallet;

  /// No description provided for @remoteServerVersion.
  ///
  /// In en, this message translates to:
  /// **'Server version: {version}'**
  String remoteServerVersion(String version);

  /// No description provided for @remoteServerUnknown.
  ///
  /// In en, this message translates to:
  /// **'unknown (offline)'**
  String get remoteServerUnknown;

  /// No description provided for @remoteCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version} (build {build})'**
  String remoteCurrentVersion(String version, int build);

  /// No description provided for @remoteNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get remoteNewsTitle;

  /// No description provided for @updateForceTitle.
  ///
  /// In en, this message translates to:
  /// **'Mandatory update required'**
  String get updateForceTitle;

  /// No description provided for @updateForceBody.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Download and install the latest release to continue.'**
  String get updateForceBody;

  /// No description provided for @languageDe.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageDe;

  /// No description provided for @languageUz.
  ///
  /// In en, this message translates to:
  /// **'Oʻzbek'**
  String get languageUz;

  /// No description provided for @languageTr.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTr;

  /// No description provided for @languageId.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageId;

  /// No description provided for @languageUk.
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get languageUk;

  /// No description provided for @languageHi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHi;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'fa',
        'hi',
        'id',
        'ru',
        'tr',
        'uk',
        'uz',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'uz':
      return AppLocalizationsUz();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
