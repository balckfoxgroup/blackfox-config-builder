// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Black Fox Config Builder';

  @override
  String get selectLanguagePrompt => '请选择您的语言';

  @override
  String get languageFa => 'فارسی';

  @override
  String get languageEn => 'English';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageZh => '中文';

  @override
  String get languageButton => '语言';

  @override
  String get navConnection => '连接';

  @override
  String get navSingle => '单个';

  @override
  String get navBulk => '批量';

  @override
  String get navList => '列表';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '未连接';

  @override
  String get connectToPanel => '连接 3X-UI 面板';

  @override
  String get panelUrl => '面板地址';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get apiKeyOptional => 'API Key（可选）';

  @override
  String get subUriOptional => 'Sub URI（可选）';

  @override
  String get connect => '连接';

  @override
  String get disconnect => '断开';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get requiredField => '必填';

  @override
  String get connecting => '正在连接面板…';

  @override
  String get connectionEstablished => '已连接。会话将保持活动直到断开。';

  @override
  String get disconnecting => '正在断开…';

  @override
  String get connectionClosed => '连接已关闭。';

  @override
  String get panelSaved => '面板设置已保存。';

  @override
  String get panelCleared => '已清除保存的设置。';

  @override
  String get configName => '配置名称';

  @override
  String get baseName => '基础名称';

  @override
  String get count => '数量';

  @override
  String get trafficGb => '流量 (GB)';

  @override
  String get durationDays => '时长（天）';

  @override
  String get inboundPort => 'Inbound 端口';

  @override
  String get createConfig => '创建配置';

  @override
  String get createBulkConfig => '批量创建配置';

  @override
  String get clearPage => '清空页面';

  @override
  String get cancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get clear => '清空';

  @override
  String get pageCleared => '页面已清空。';

  @override
  String get clearPageTitle => '清空页面';

  @override
  String get clearPageFormConfirm => '确定要清空表单吗？\n\n此操作无法撤销。';

  @override
  String get clearBulkConfirm => '确定要清空已生成的配置列表吗？\n\n此操作无法撤销。';

  @override
  String get connectFirst => '请先在「连接」选项卡中连接面板。';

  @override
  String get savePanelFirst => '请先保存面板设置。';

  @override
  String get configNameRequired => '配置名称为必填项。';

  @override
  String get baseNameAndCountRequired => '基础名称和数量为必填项。';

  @override
  String get v2rayHint => '在 v2rayNG 中使用 Sub 链接以显示名称、流量和到期时间。';

  @override
  String get configLink => '配置链接：';

  @override
  String get subLink => 'Sub 链接：';

  @override
  String get qrConfig => '配置 QR';

  @override
  String get qrSub => 'Sub QR';

  @override
  String get tapToCopy => '点击复制';

  @override
  String copied(String label) {
    return '$label 已复制';
  }

  @override
  String get selectAll => '全选';

  @override
  String selectedCount(int count) {
    return '已选：$count';
  }

  @override
  String get copyLink => '复制链接';

  @override
  String get deleteFromPanel => '从面板删除';

  @override
  String get deleteFromList => '从列表删除';

  @override
  String get noConfigsYet => '尚未创建任何配置。';

  @override
  String get deleteFromListTitle => '从列表删除';

  @override
  String get deleteFromListSingle => '从本地列表中移除此配置？\n\n不会从服务器删除用户。';

  @override
  String get deleteFromListMultiple => '从本地列表中移除所选项目？\n\n不会从服务器删除用户。';

  @override
  String get deleteFromPanelTitle => '从面板删除';

  @override
  String get deleteFromPanelSingle => '从 3X-UI 面板删除此用户？\n\n此操作无法撤销。';

  @override
  String get deleteFromPanelMultiple => '从面板删除所选用户？\n\n此操作无法撤销。';

  @override
  String get deletePanelResultTitle => '从面板删除结果';

  @override
  String successCount(int count) {
    return '成功：$count';
  }

  @override
  String failureCount(int count) {
    return '失败：$count';
  }

  @override
  String get errors => '错误：';

  @override
  String get configDeletedFromPanel => '配置已从面板删除';

  @override
  String get configDeletedFromList => '配置已从列表移除';

  @override
  String get configsDeletedFromList => '所选项目已从列表移除';

  @override
  String get noLinksToCopy => '没有可复制的链接。';

  @override
  String get linkCopied => '链接已复制';

  @override
  String linksCopied(int count) {
    return '已复制 $count 个链接';
  }

  @override
  String get connectPanelFirst => '请先连接面板。';

  @override
  String get stop => '停止';

  @override
  String get linkNumber => '链接编号';

  @override
  String get copy => '复制';

  @override
  String get configLinkColumn => '配置链接';

  @override
  String get subLinkColumn => 'Sub 链接';

  @override
  String get bulkLinksPlaceholder => '生成的链接将显示在此处。';

  @override
  String get singleResultPlaceholder => '创建的配置结果将显示在此处。';

  @override
  String linksCopiedByIndex(int index) {
    return '编号 $index 的链接已复制';
  }

  @override
  String indexCopied(int index) {
    return '编号 $index 已复制';
  }

  @override
  String get invalidIndex => '请输入有效编号。';

  @override
  String get linkNotFoundByIndex => '未找到该编号的链接。';

  @override
  String daysCount(int count) {
    return '$count 天';
  }

  @override
  String get navContact => '联系';

  @override
  String get contactTitle => '🌐 Black Fox 联系方式 🌐';

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
  String get contactChannel => '📢 官方频道：';

  @override
  String get contactChannelLink => '@BlackFoxVpnn';

  @override
  String get contactSupport => '🛠 技术支持：';

  @override
  String get contactSupportLink => '@HiBlackFoxVpn';

  @override
  String get contactBot => '🤖 购买与服务机器人：';

  @override
  String get contactBotLink => '@BlackFoxVpn_bot';

  @override
  String get contactGroup => '💬 Black Fox 群组：';

  @override
  String get contactGroupLink => '@Black_Fox_Group';

  @override
  String get contactTelegramNote => '所有联系方式均为 Telegram。点击即可打开。';

  @override
  String get contactVersion => '应用版本：';

  @override
  String get contactThanks => '❤️ 感谢您成为 Black Fox 大家庭的一员！';

  @override
  String get toastConnecting => '正在连接...';

  @override
  String get toastConnectSuccess => '连接成功。';

  @override
  String get toastConnectFailed => '连接失败。';

  @override
  String get toastDisconnecting => '正在断开...';

  @override
  String get toastDisconnectSuccess => '连接已关闭。';

  @override
  String get toastDisconnectFailed => '断开连接失败。';

  @override
  String get toastSaving => '正在保存...';

  @override
  String get toastSaveSuccess => '保存成功。';

  @override
  String get toastSaveFailed => '保存失败。';

  @override
  String get toastDeleting => '正在删除...';

  @override
  String get toastDeleteSuccess => '删除成功。';

  @override
  String get toastDeleteFailed => '删除失败。';

  @override
  String get navSettings => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsProgramUpdate => '程序更新';

  @override
  String get settingsCurrentVersion => '当前版本';

  @override
  String get settingsCheckUpdates => '检查更新';

  @override
  String get settingsUpToDate => '您已在使用最新版本。';

  @override
  String get updateAvailableTitle => '有可用更新';

  @override
  String updateAvailableBody(String current, String latest) {
    return '发现新版本。\n\n当前：$current\n最新：$latest';
  }

  @override
  String get updateNow => '更新';

  @override
  String get updateLater => '稍后';

  @override
  String get updateDownloading => '正在下载更新…';

  @override
  String updateDownloadProgress(int percent) {
    return '进度：$percent%';
  }

  @override
  String get updateCheckFailed => '无法检查更新。';

  @override
  String get updateDownloadFailed => '更新下载失败。';

  @override
  String get panelVersionIncompatible => '面板版本不受支持。请将 3X-UI 更新到 3.3.0 或更高版本。';

  @override
  String get apiKey => 'API Key';

  @override
  String get settingsActivityLog => '活动日志';

  @override
  String get settingsCopyLog => '复制日志';

  @override
  String get settingsClearLog => '清除日志';

  @override
  String get settingsLogCopied => '日志已复制到剪贴板。';

  @override
  String get settingsLogEmpty => '暂无活动记录。连接面板或创建配置后，日志会显示在这里。';

  @override
  String get settingsLogCleared => '活动日志已清除。';

  @override
  String get unlimited => '无限制';

  @override
  String get unlimitedHint => '0 = 无限制';

  @override
  String get generateRandomName => '生成随机名称';

  @override
  String get selectInbounds => '选择 inbound';

  @override
  String get refreshInbounds => '刷新 inbound';

  @override
  String get inboundEnabled => '已启用';

  @override
  String get inboundDisabled => '已禁用';

  @override
  String get inboundNoRemark => '无备注';

  @override
  String inboundOptionLabel(
      String protocol, String remark, int port, String status) {
    return '$protocol · $remark · 端口 $port · $status';
  }

  @override
  String get noInboundFound => '面板上未找到 inbound。';

  @override
  String get inboundListLoadFailed => '无法加载 inbound 列表。';

  @override
  String get inboundSelectionRequired => '请至少选择一个 inbound。';

  @override
  String get configNameInvalid => '仅允许英文字母、数字、空格和连字符。';

  @override
  String get configNameDuplicate => '此名称已被使用。请换一个名称或点击 refresh。';

  @override
  String get remoteSectionTitle => '更新与远程配置';

  @override
  String get remoteRefreshBtn => '从服务器刷新';

  @override
  String get remoteRefreshDone => '远程配置已刷新。';

  @override
  String get remoteWalletTitle => '付款钱包（实时）';

  @override
  String get remoteWalletUnavailable => '钱包地址不可用 — 请检查网络并刷新。';

  @override
  String get copyAddressWallet => '复制钱包地址';

  @override
  String remoteServerVersion(String version) {
    return '服务器版本：$version';
  }

  @override
  String get remoteServerUnknown => '未知（离线）';

  @override
  String remoteCurrentVersion(String version, int build) {
    return '当前版本：$version（build $build）';
  }

  @override
  String get remoteNewsTitle => '公告';

  @override
  String get updateForceTitle => '必须更新';

  @override
  String get updateForceBody => '此版本已不再支持。请下载并安装最新版本。';

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
