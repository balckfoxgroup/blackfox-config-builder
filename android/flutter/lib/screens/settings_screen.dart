import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/app_localizations.dart';
import '../services/app_log_service.dart';
import '../services/locale_service.dart';
import '../services/remote_feed_service.dart';
import '../services/update_service.dart';
import '../utils/build_number.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '…';
  int _appBuild = 0;
  bool _checkingUpdate = false;
  bool _remoteBusy = false;
  final _logScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadVersion();
    AppLogService.instance.addListener(_onLogChanged);
  }

  @override
  void dispose() {
    AppLogService.instance.removeListener(_onLogChanged);
    _logScrollController.dispose();
    super.dispose();
  }

  void _onLogChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = info.version;
        _appBuild = BuildNumber.parse(info.buildNumber);
      });
    }
  }

  Future<void> _checkUpdates() async {
    if (_checkingUpdate) {
      return;
    }
    setState(() => _checkingUpdate = true);
    try {
      await UpdateService.instance.checkManually(context);
      setState(() {});
    } finally {
      if (mounted) {
        setState(() => _checkingUpdate = false);
      }
    }
  }

  Future<void> _refreshRemote() async {
    if (_remoteBusy) {
      return;
    }
    setState(() => _remoteBusy = true);
    final l10n = AppLocalizations.of(context);
    try {
      await RemoteFeedService.instance.refreshAll(silent: false);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.remoteRefreshDone)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.updateCheckFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _remoteBusy = false);
      }
    }
  }

  void _openRemoteDialog() {
    final l10n = AppLocalizations.of(context);
    final feed = RemoteFeedService.instance;
    final remoteVer = feed.versionFeed;
    final serverLabel = remoteVer != null
        ? '${remoteVer.version} (build ${remoteVer.build})'
        : l10n.remoteServerUnknown;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.remoteSectionTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.remoteCurrentVersion(_appVersion, _appBuild)),
              const SizedBox(height: 8),
              Text(l10n.remoteServerVersion(serverLabel)),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed:
                    _remoteBusy || _checkingUpdate ? null : _checkUpdates,
                child: Text(l10n.settingsCheckUpdates),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _remoteBusy
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        await _refreshRemote();
                      },
                child: Text(l10n.remoteRefreshBtn),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.close)),
        ],
      ),
    );
  }

  Future<void> _copyLog() async {
    final l10n = AppLocalizations.of(context);
    final text = AppLogService.instance.text;
    if (text.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsLogCopied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeService = LocaleService.instance;
    final textAlign = localeService.isRtl ? TextAlign.right : TextAlign.left;
    final logText = AppLogService.instance.text;

    return ListenableBuilder(
      listenable: localeService,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settingsTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: textAlign,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.settingsLanguage,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: textAlign,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: localeService.locale.languageCode,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: LocaleService.cycle
                    .map(
                      (code) => DropdownMenuItem<String>(
                        value: code,
                        child: Text(
                          '${localeService.languageFlag(code)}  ${_labelForCode(l10n, code)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (code) {
                  if (code == null) {
                    return;
                  }
                  localeService.setLocale(code);
                },
              ),
              const SizedBox(height: 24),
              Text(
                l10n.settingsProgramUpdate,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: textAlign,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.remoteCurrentVersion(_appVersion, _appBuild),
                textAlign: textAlign,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _checkingUpdate ? null : _checkUpdates,
                child: _checkingUpdate
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.settingsCheckUpdates),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _remoteBusy ? null : _openRemoteDialog,
                child: Text(l10n.remoteSectionTitle),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.settingsActivityLog,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: textAlign,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: logText.isEmpty ? null : _copyLog,
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text(l10n.settingsCopyLog),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: logText.isEmpty
                          ? null
                          : () {
                              AppLogService.instance.clear();
                              AppLogService.instance
                                  .info(l10n.settingsLogCleared);
                            },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(l10n.settingsClearLog),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.35),
                ),
                padding: const EdgeInsets.all(12),
                child: logText.isEmpty
                    ? Center(
                        child: Text(
                          l10n.settingsLogEmpty,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : Scrollbar(
                        controller: _logScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _logScrollController,
                          child: SelectableText(
                            logText,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _labelForCode(AppLocalizations l10n, String code) {
    switch (code) {
      case 'fa':
        return l10n.languageFa;
      case 'en':
        return l10n.languageEn;
      case 'ru':
        return l10n.languageRu;
      case 'zh':
        return l10n.languageZh;
      case 'de':
        return l10n.languageDe;
      case 'uz':
        return l10n.languageUz;
      case 'tr':
        return l10n.languageTr;
      case 'id':
        return l10n.languageId;
      case 'uk':
        return l10n.languageUk;
      case 'hi':
        return l10n.languageHi;
      default:
        return code;
    }
  }
}
