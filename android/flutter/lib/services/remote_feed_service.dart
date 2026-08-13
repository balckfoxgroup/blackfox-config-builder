import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remote feeds from blackfoxupdate.ir (primary) and foxnext.net (secondary).
/// Mirrors [internal/remotehub] policy in the Windows installer.
class RemoteFeedService {
  RemoteFeedService._();

  static final RemoteFeedService instance = RemoteFeedService._();

  static const primaryBase = 'http://blackfoxupdate.ir';
  static const secondaryBase = 'https://foxnext.net';
  static const primaryDownloads = 'http://blackfoxupdate.ir/downloads';
  static const secondaryDownloads = 'https://foxnext.net/downloads';
  static const versionJsonPath = '/version.json';
  static const walletJsonPath = '/wallet.json';
  static const newsJsonPath = '/news.json';
  static const versionBlockKey = 'config_builder';
  static const apkFileName = 'Black-Fox-Config-Builder.apk';

  static const _cacheNewsTitle = 'cb_remote_news_title';
  static const _cacheNewsMessage = 'cb_remote_news_message';
  static const _cacheNewsEnabled = 'cb_remote_news_enabled';
  static const _cacheNewsShownKey = 'cb_remote_news_shown_key';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Accept': 'application/json'},
    ),
  );

  WalletFeed? _walletLive;
  NewsFeed? _news;
  bool _newsLive = false;
  AppVersionFeed? _version;
  bool _versionLive = false;
  List<String> _errors = [];

  WalletFeed? get walletLive => _walletLive;
  NewsFeed? get news => _news;
  bool get newsLive => _newsLive;
  AppVersionFeed? get versionFeed => _version;
  bool get versionLive => _versionLive;
  List<String> get fetchErrors => List.unmodifiable(_errors);

  Future<RemoteFeedSnapshot> refreshAll({bool silent = true}) async {
    _errors = [];
    await _fetchWallet(silent: silent);
    await _fetchNews(silent: silent);
    await _fetchVersion(silent: silent);
    return snapshot();
  }

  RemoteFeedSnapshot snapshot() => RemoteFeedSnapshot(
        wallet: _walletLive,
        news: _news,
        newsLive: _newsLive,
        version: _version,
        versionLive: _versionLive,
        errors: _errors,
      );

  Future<WalletFeed?> _fetchWallet({required bool silent}) async {
    for (final base in [primaryBase, secondaryBase]) {
      final body = await _fetchUrl('$base$walletJsonPath', silent: silent, tag: 'wallet $base');
      if (body == null) {
        continue;
      }
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final feed = WalletFeed.fromJson(json);
        if (!feed.isValid) {
          _errors.add('wallet $base: invalid address');
          continue;
        }
        _walletLive = feed;
        return feed;
      } catch (e) {
        if (!silent) {
          _errors.add('wallet $base: $e');
        }
      }
    }
    _walletLive = null;
    return null;
  }

  Future<NewsFeed?> _fetchNews({required bool silent}) async {
    final body = await _fetchPathSmart(newsJsonPath, silent: silent);
    if (body == null) {
      if (_news == null) {
        _news = await _loadCachedNews();
        _newsLive = false;
      }
      return _news;
    }
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final feed = NewsFeed.fromJson(json);
      _news = feed;
      _newsLive = true;
      await _cacheNews(feed);
      return feed;
    } catch (e) {
      if (!silent) {
        _errors.add('news: $e');
      }
      if (_news == null) {
        _news = await _loadCachedNews();
      }
      _newsLive = false;
      return _news;
    }
  }

  Future<AppVersionFeed?> _fetchVersion({required bool silent}) async {
    AppVersionFeed? primary;
    AppVersionFeed? secondary;

    final primaryBody = await _fetchUrl('$primaryBase$versionJsonPath', silent: silent, tag: 'version');
    if (primaryBody != null) {
      primary = _parseVersionBlock(primaryBody);
    }

    final secondaryBody = await _fetchUrl('$secondaryBase$versionJsonPath', silent: silent, tag: 'version');
    if (secondaryBody != null) {
      secondary = _parseVersionBlock(secondaryBody);
    }

    final picked = _pickNewestVersion(primary, secondary);
    if (picked != null) {
      _version = picked;
      _versionLive = true;
      return picked;
    }
    _versionLive = false;
    return null;
  }

  AppVersionFeed? _parseVersionBlock(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final block = json[versionBlockKey] as Map<String, dynamic>?;
      if (block == null) {
        _errors.add('version: missing $versionBlockKey block');
        return null;
      }
      final feed = AppVersionFeed.fromJson(block);
      if (!feed.isValid) {
        _errors.add('version: invalid $versionBlockKey payload');
        return null;
      }
      return feed;
    } catch (e) {
      _errors.add('version: $e');
      return null;
    }
  }

  AppVersionFeed? _pickNewestVersion(AppVersionFeed? a, AppVersionFeed? b) {
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }
    final cmp = compareSemver(b.version, a.version);
    if (cmp > 0) {
      return b;
    }
    if (cmp < 0) {
      return a;
    }
    return b.build > a.build ? b : a;
  }

  Future<String?> _fetchPathSmart(String path, {required bool silent}) async {
    final primary = await _fetchUrl('$primaryBase$path', silent: silent, tag: 'primary$path');
    if (primary != null) {
      return primary;
    }
    return _fetchUrl('$secondaryBase$path', silent: silent, tag: 'secondary$path');
  }

  Future<String?> _fetchUrl(String url, {required bool silent, required String tag}) async {
    try {
      final response = await _dio.get<String>(url);
      final data = response.data;
      if (data != null && data.isNotEmpty) {
        return data;
      }
    } catch (e) {
      if (!silent) {
        _errors.add('$tag: $e');
      }
    }
    return null;
  }

  static bool isUpdateAvailable({
    required AppVersionFeed remote,
    required String currentVersion,
    required int currentBuild,
  }) {
    final cmp = compareSemver(remote.version, currentVersion);
    if (cmp > 0) {
      return true;
    }
    if (cmp == 0 && remote.build > currentBuild) {
      return true;
    }
    return false;
  }

  static bool mustForceUpdate({
    required AppVersionFeed remote,
    required String currentVersion,
    required int currentBuild,
  }) {
    if (!remote.forceUpdate) {
      return false;
    }
    return isUpdateAvailable(
      remote: remote,
      currentVersion: currentVersion,
      currentBuild: currentBuild,
    );
  }

  static int compareSemver(String a, String b) {
    List<int> parse(String value) {
      var v = value.trim().toLowerCase();
      if (v.startsWith('v')) {
        v = v.substring(1);
      }
      final dash = v.indexOf('-');
      if (dash >= 0) {
        v = v.substring(0, dash);
      }
      final parts = v.split('.');
      return List<int>.generate(3, (i) {
        if (i >= parts.length) {
          return 0;
        }
        return int.tryParse(parts[i].trim()) ?? 0;
      });
    }

    final av = parse(a);
    final bv = parse(b);
    for (var i = 0; i < 3; i++) {
      if (av[i] < bv[i]) {
        return -1;
      }
      if (av[i] > bv[i]) {
        return 1;
      }
    }
    return 0;
  }

  String resolveApkFileName(String? downloadUrl) {
    if (downloadUrl == null || downloadUrl.trim().isEmpty) {
      return apkFileName;
    }
    final uri = Uri.tryParse(downloadUrl.trim());
    if (uri == null) {
      return apkFileName;
    }
    final segment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    if (segment.toLowerCase().endsWith('.apk')) {
      return Uri.decodeComponent(segment);
    }
    return apkFileName;
  }

  Future<void> downloadApk({
    required String destPath,
    String? downloadUrl,
    void Function(double progress)? onProgress,
  }) async {
    final fileName = resolveApkFileName(downloadUrl);
    final primaryUrl = '$primaryDownloads/${Uri.encodeComponent(fileName)}';
    try {
      await _downloadToFile(primaryUrl, destPath, onProgress: onProgress);
      return;
    } catch (_) {}

    final secondaryUrl = '$secondaryDownloads/${Uri.encodeComponent(fileName)}';
    await _downloadToFile(secondaryUrl, destPath, onProgress: onProgress);
  }

  Future<void> _downloadToFile(
    String url,
    String destPath, {
    void Function(double progress)? onProgress,
  }) async {
    await _dio.download(
      url,
      destPath,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );
  }

  Future<bool> shouldShowNewsDialog() async {
    final feed = _news;
    if (feed == null || !feed.enabled) {
      return false;
    }
    final message = feed.message.trim();
    if (message.isEmpty) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = '${feed.title}|${feed.message}';
    return prefs.getString(_cacheNewsShownKey) != key;
  }

  Future<void> markNewsShown() async {
    final feed = _news;
    if (feed == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheNewsShownKey, '${feed.title}|${feed.message}');
  }

  Future<void> _cacheNews(NewsFeed feed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheNewsTitle, feed.title);
    await prefs.setString(_cacheNewsMessage, feed.message);
    await prefs.setBool(_cacheNewsEnabled, feed.enabled);
  }

  Future<NewsFeed?> _loadCachedNews() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString(_cacheNewsTitle);
    final message = prefs.getString(_cacheNewsMessage);
    if (title == null && message == null) {
      return null;
    }
    return NewsFeed(
      enabled: prefs.getBool(_cacheNewsEnabled) ?? false,
      title: title ?? '',
      message: message ?? '',
    );
  }
}

class WalletFeed {
  const WalletFeed({
    required this.network,
    required this.wallet,
    this.updatedAt,
  });

  final String network;
  final String wallet;
  final String? updatedAt;

  bool get isValid {
    final addr = wallet.trim();
    if (addr.length != 42 || !addr.startsWith('0x')) {
      return false;
    }
    for (var i = 2; i < addr.length; i++) {
      final c = addr.codeUnitAt(i);
      final isHex = (c >= 0x30 && c <= 0x39) ||
          (c >= 0x61 && c <= 0x66) ||
          (c >= 0x41 && c <= 0x46);
      if (!isHex) {
        return false;
      }
    }
    return true;
  }

  factory WalletFeed.fromJson(Map<String, dynamic> json) {
    return WalletFeed(
      network: (json['network'] as String?)?.trim() ?? '',
      wallet: (json['wallet'] as String?)?.trim() ?? '',
      updatedAt: (json['updated_at'] as String?)?.trim(),
    );
  }
}

class NewsFeed {
  const NewsFeed({
    required this.enabled,
    required this.title,
    required this.message,
  });

  final bool enabled;
  final String title;
  final String message;

  factory NewsFeed.fromJson(Map<String, dynamic> json) {
    return NewsFeed(
      enabled: json['enabled'] == true,
      title: (json['title'] as String?)?.trim() ?? '',
      message: (json['message'] as String?)?.trim() ?? '',
    );
  }
}

class AppVersionFeed {
  const AppVersionFeed({
    required this.version,
    required this.build,
    required this.downloadUrl,
    this.releaseNotes,
    this.forceUpdate = false,
  });

  final String version;
  final int build;
  final String downloadUrl;
  final String? releaseNotes;
  final bool forceUpdate;

  bool get isValid => version.isNotEmpty && downloadUrl.isNotEmpty;

  factory AppVersionFeed.fromJson(Map<String, dynamic> json) {
    return AppVersionFeed(
      version: (json['version'] as String?)?.trim() ?? '',
      build: (json['build'] as num?)?.toInt() ?? 0,
      downloadUrl: (json['download_url'] as String?)?.trim() ?? '',
      releaseNotes: (json['release_notes'] as String?)?.trim(),
      forceUpdate: json['force_update'] == true,
    );
  }
}

class RemoteFeedSnapshot {
  const RemoteFeedSnapshot({
    this.wallet,
    this.news,
    this.newsLive = false,
    this.version,
    this.versionLive = false,
    this.errors = const [],
  });

  final WalletFeed? wallet;
  final NewsFeed? news;
  final bool newsLive;
  final AppVersionFeed? version;
  final bool versionLive;
  final List<String> errors;
}
