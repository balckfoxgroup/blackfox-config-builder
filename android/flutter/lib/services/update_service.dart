import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../utils/build_number.dart';
import 'app_log_service.dart';
import 'panel_engine.dart';
import 'remote_feed_service.dart';

class UpdateInfo {
  const UpdateInfo({
    required this.latestVersion,
    required this.latestBuild,
    required this.downloadUrl,
    this.releaseNotes,
    this.forceUpdate = false,
  });

  final String latestVersion;
  final int latestBuild;
  final String downloadUrl;
  final String? releaseNotes;
  final bool forceUpdate;

  factory UpdateInfo.fromFeed(AppVersionFeed feed) {
    return UpdateInfo(
      latestVersion: feed.version,
      latestBuild: feed.build,
      downloadUrl: feed.downloadUrl,
      releaseNotes: feed.releaseNotes,
      forceUpdate: feed.forceUpdate,
    );
  }
}

class UpdateService {
  UpdateService._();

  static final UpdateService instance = UpdateService._();

  final _feed = RemoteFeedService.instance;

  static const _cacheLatestVersion = 'cb_update_latest_version';
  static const _cacheLatestBuild = 'cb_update_latest_build';
  static const _cacheDownloadUrl = 'cb_update_download_url';
  static const _cacheReleaseNotes = 'cb_update_release_notes';
  static const _cacheLastCheck = 'cb_update_last_check_ms';

  Future<UpdateInfo?> fetchLatest({bool silent = true}) async {
    try {
      AppLogService.instance.info('Fetching version.json (dual-server)…');
      await _feed.refreshAll(silent: silent);
      final remote = _feed.versionFeed;
      if (remote == null || !_feed.versionLive) {
        return null;
      }
      final info = UpdateInfo.fromFeed(remote);
      await _cache(info);
      AppLogService.instance.ok(
          'Update info: v${info.latestVersion} (build ${info.latestBuild})');
      return info;
    } catch (e) {
      if (!silent) {
        rethrow;
      }
      AppLogService.instance.warn('Update check skipped: $e');
      return null;
    }
  }

  Future<UpdateInfo?> checkForUpdate({bool silent = true}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final build = BuildNumber.parse(packageInfo.buildNumber);
    final latest = await fetchLatest(silent: silent);
    if (latest == null) {
      return null;
    }
    final remote = AppVersionFeed(
      version: latest.latestVersion,
      build: latest.latestBuild,
      downloadUrl: latest.downloadUrl,
      releaseNotes: latest.releaseNotes,
      forceUpdate: latest.forceUpdate,
    );
    if (RemoteFeedService.isUpdateAvailable(
      remote: remote,
      currentVersion: packageInfo.version,
      currentBuild: build,
    )) {
      return latest;
    }
    return null;
  }

  Future<void> checkOnStartup(BuildContext context) async {
    if (!context.mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final packageInfo = await PackageInfo.fromPlatform();
    final build = BuildNumber.parse(packageInfo.buildNumber);

    await _feed.refreshAll(silent: true);
    if (!context.mounted) {
      return;
    }

    final remote = _feed.versionFeed;
    if (remote != null && _feed.versionLive) {
      if (RemoteFeedService.mustForceUpdate(
        remote: remote,
        currentVersion: packageInfo.version,
        currentBuild: build,
      )) {
        await _showForceUpdateDialog(
            context, UpdateInfo.fromFeed(remote), packageInfo.version);
        return;
      }
      final update = await checkForUpdate(silent: true);
      if (update != null && context.mounted) {
        await _showUpdateDialog(context, update,
            currentVersion: packageInfo.version);
      }
    }

    if (await _feed.shouldShowNewsDialog() && context.mounted) {
      await _showNewsDialog(context, l10n);
    }
  }

  Future<void> checkManually(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final build = BuildNumber.parse(packageInfo.buildNumber);
      final update = await checkForUpdate(silent: false);
      if (!context.mounted) {
        return;
      }
      if (update == null) {
        AppLogService.instance.ok('App is up to date');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsUpToDate)),
        );
        return;
      }
      final remote = AppVersionFeed(
        version: update.latestVersion,
        build: update.latestBuild,
        downloadUrl: update.downloadUrl,
        forceUpdate: update.forceUpdate,
      );
      if (RemoteFeedService.mustForceUpdate(
        remote: remote,
        currentVersion: packageInfo.version,
        currentBuild: build,
      )) {
        await _showForceUpdateDialog(context, update, packageInfo.version);
        return;
      }
      AppLogService.instance.info(
        'Update available: ${packageInfo.version} → ${update.latestVersion}',
      );
      await _showUpdateDialog(context, update,
          currentVersion: packageInfo.version);
    } catch (e) {
      AppLogService.instance.error('Update check failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.updateCheckFailed)),
        );
      }
    }
  }

  Future<void> _showNewsDialog(
      BuildContext context, AppLocalizations l10n) async {
    final news = _feed.news;
    if (news == null) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(news.title.isNotEmpty ? news.title : l10n.remoteNewsTitle),
        content: SingleChildScrollView(child: Text(news.message)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
    await _feed.markNewsShown();
  }

  Future<void> _showForceUpdateDialog(
    BuildContext context,
    UpdateInfo update,
    String currentVersion,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updateForceTitle),
        content: Text(l10n.updateForceBody),
        actions: [
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (context.mounted) {
                await downloadAndInstall(context, update);
              }
            },
            child: Text(l10n.updateNow),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateDialog(
    BuildContext context,
    UpdateInfo update, {
    String? currentVersion,
  }) async {
    final l10n = AppLocalizations.of(context);
    currentVersion ??= (await PackageInfo.fromPlatform()).version;
    final latestLabel = update.latestBuild > 0
        ? '${update.latestVersion} (build ${update.latestBuild})'
        : update.latestVersion;

    if (!context.mounted) {
      return;
    }

    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: !update.forceUpdate,
      builder: (ctx) {
        var body = l10n.updateAvailableBody(currentVersion!, latestLabel);
        if (update.releaseNotes != null && update.releaseNotes!.isNotEmpty) {
          body += '\n\n${update.releaseNotes}';
        }
        return AlertDialog(
          title: Text(l10n.updateAvailableTitle),
          content: Text(body),
          actions: [
            if (!update.forceUpdate)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.updateLater),
              ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.updateNow),
            ),
          ],
        );
      },
    );

    if (proceed == true && context.mounted) {
      AppLogService.instance
          .info('Downloading update v${update.latestVersion}…');
      await downloadAndInstall(context, update);
    }
  }

  Future<void> downloadAndInstall(
      BuildContext context, UpdateInfo update) async {
    final l10n = AppLocalizations.of(context);
    var progress = 0.0;

    if (!context.mounted) {
      return;
    }

    void showProgressDialog() {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.updateDownloading),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: progress <= 0 ? null : progress),
              const SizedBox(height: 12),
              Text(l10n.updateDownloadProgress((progress * 100).round())),
            ],
          ),
        ),
      );
    }

    showProgressDialog();

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/config_builder_update.apk');
      if (await file.exists()) {
        await file.delete();
      }

      await _feed.downloadApk(
        destPath: file.path,
        downloadUrl: update.downloadUrl,
        onProgress: (value) {
          progress = value;
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            showProgressDialog();
          }
        },
      );

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await PanelEngine.instance.installApk(file.path);
      AppLogService.instance.ok('Update downloaded, install prompt opened');
    } catch (e) {
      AppLogService.instance.error('Update download failed: $e');
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.updateDownloadFailed)),
        );
      }
    }
  }

  Future<void> _cache(UpdateInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheLatestVersion, info.latestVersion);
    await prefs.setInt(_cacheLatestBuild, info.latestBuild);
    await prefs.setString(_cacheDownloadUrl, info.downloadUrl);
    if (info.releaseNotes != null) {
      await prefs.setString(_cacheReleaseNotes, info.releaseNotes!);
    }
    await prefs.setInt(_cacheLastCheck, DateTime.now().millisecondsSinceEpoch);
  }
}
