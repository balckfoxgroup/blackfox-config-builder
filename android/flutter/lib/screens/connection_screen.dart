import 'package:flutter/material.dart';

import '../core/theme/fox_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/panel_settings.dart';
import '../services/app_log_service.dart';
import '../services/inbound_service.dart';
import '../services/locale_service.dart';
import '../services/panel_engine.dart';
import '../services/panel_session.dart';
import '../services/panel_store.dart';
import '../widgets/fox_toast.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _url;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _apiKey;
  late final TextEditingController _subUri;
  bool _busy = false;

  FoxToastService get _toast => FoxToastService.instance;
  AppLogService get _log => AppLogService.instance;

  bool get _apiKeyMode => _apiKey.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final saved = PanelStore.instance.settings;
    _url = TextEditingController(text: saved?.panelUrl ?? '');
    _username = TextEditingController(text: saved?.username ?? '');
    _password = TextEditingController(text: saved?.password ?? '');
    _apiKey = TextEditingController(text: saved?.apiKey ?? '');
    _subUri = TextEditingController(text: saved?.subUri ?? '');
    _apiKey.addListener(_onApiKeyChanged);
  }

  void _onApiKeyChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _apiKey.removeListener(_onApiKeyChanged);
    _url.dispose();
    _username.dispose();
    _password.dispose();
    _apiKey.dispose();
    _subUri.dispose();
    super.dispose();
  }

  PanelSettings _readSettings() {
    return PanelSettings(
      panelUrl: _url.text.trim(),
      username: _username.text.trim(),
      password: _password.text,
      apiKey: _apiKey.text.trim(),
      subUri: _subUri.text.trim(),
    );
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    _toast.showProgress(l10n.toastConnecting);
    _log.info('Connecting to panel…');

    try {
      final settings = _readSettings();
      final authMode = _apiKeyMode ? 'API Key' : 'username/password';
      _log.info('Auth mode: $authMode');
      await PanelStore.instance.save(settings);
      await PanelEngine.instance.connectPanel(settings);
      PanelSession.instance.setConnected(true);
      await InboundService.instance.refresh();
      _log.ok('Panel connected');
      _toast.showResult(l10n.toastConnectSuccess, FoxToastType.success);
    } catch (e) {
      PanelSession.instance.setConnected(false);
      final message = e.toString();
      if (message.contains('not supported')) {
        _log.error('Panel version incompatible');
        _toast.showResult(l10n.panelVersionIncompatible, FoxToastType.error);
      } else {
        _log.error('Connect failed: $message');
        _toast.showResult(l10n.toastConnectFailed, FoxToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    _toast.showProgress(l10n.toastDisconnecting);
    _log.info('Disconnecting from panel…');

    try {
      await PanelEngine.instance.disconnectPanel();
      PanelSession.instance.setConnected(false);
      _log.ok('Panel disconnected');
      _toast.showResult(l10n.toastDisconnectSuccess, FoxToastType.success);
    } catch (e) {
      _log.error('Disconnect failed: $e');
      _toast.showResult(l10n.toastDisconnectFailed, FoxToastType.error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    _toast.showProgress(l10n.toastSaving);
    _log.info('Saving panel settings…');

    try {
      await PanelStore.instance.save(_readSettings());
      _log.ok('Panel settings saved');
      _toast.showResult(l10n.toastSaveSuccess, FoxToastType.success);
    } catch (e) {
      _log.error('Save failed: $e');
      _toast.showResult(l10n.toastSaveFailed, FoxToastType.error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    _toast.showProgress(l10n.toastDeleting);
    _log.info('Clearing saved panel settings…');

    try {
      if (PanelSession.instance.connected) {
        await PanelEngine.instance.disconnectPanel();
        PanelSession.instance.setConnected(false);
      }
      await PanelStore.instance.clear();
      _url.clear();
      _username.clear();
      _password.clear();
      _apiKey.clear();
      _subUri.clear();
      _log.ok('Panel settings cleared');
      _toast.showResult(l10n.toastDeleteSuccess, FoxToastType.success);
    } catch (e) {
      _log.error('Clear failed: $e');
      _toast.showResult(l10n.toastDeleteFailed, FoxToastType.error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connected = PanelSession.instance.connected;
    final textAlign =
        LocaleService.instance.isRtl ? TextAlign.right : TextAlign.left;
    final apiKeyMode = _apiKeyMode;

    return ListenableBuilder(
      listenable: PanelSession.instance,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.connectToPanel,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: textAlign,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      size: 14,
                      color: connected ? FoxColors.green : FoxColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Text(connected ? l10n.connected : l10n.disconnected),
                  ],
                ),
                const SizedBox(height: 16),
                _field(_url, l10n.panelUrl, required: true),
                _field(
                  _username,
                  l10n.username,
                  required: !apiKeyMode,
                  enabled: !apiKeyMode,
                ),
                _field(
                  _password,
                  l10n.password,
                  required: !apiKeyMode,
                  obscure: true,
                  enabled: !apiKeyMode,
                ),
                _field(
                  _apiKey,
                  apiKeyMode ? l10n.apiKey : l10n.apiKeyOptional,
                ),
                _field(_subUri, l10n.subUriOptional),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    FilledButton(
                      onPressed: _busy || connected ? null : _connect,
                      child: Text(l10n.connect),
                    ),
                    FilledButton.tonal(
                      onPressed: _busy || !connected ? null : _disconnect,
                      child: Text(l10n.disconnect),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : _save,
                      child: Text(l10n.save),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : _clear,
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool obscure = false,
    bool enabled = true,
  }) {
    final l10n = AppLocalizations.of(context);
    final textAlign =
        LocaleService.instance.isRtl ? TextAlign.right : TextAlign.left;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscure,
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) => (value == null || value.trim().isEmpty)
                ? l10n.requiredField
                : null
            : null,
      ),
    );
  }
}
