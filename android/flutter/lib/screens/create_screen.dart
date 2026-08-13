import 'package:flutter/material.dart';

import '../core/theme/fox_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/config_record.dart';
import '../services/app_log_service.dart';
import '../services/config_repository.dart';
import '../services/inbound_service.dart';
import '../services/locale_service.dart';
import '../services/panel_engine.dart';
import '../services/panel_session.dart';
import '../services/panel_store.dart';
import '../utils/config_form_utils.dart';
import '../utils/random_config_name.dart';
import '../widgets/inbound_multi_select.dart';
import '../widgets/name_input_field.dart';
import '../widgets/tap_to_copy_qr.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _name = TextEditingController();
  final _traffic = TextEditingController(text: '10');
  final _days = TextEditingController(text: '30');
  final Set<int> _selectedInboundIds = {};
  bool _busy = false;
  ConfigRecord? _lastCreated;
  String? _error;
  bool _wasConnected = false;
  int _inboundCollapseToken = 0;

  TextAlign get _textAlign =>
      LocaleService.instance.isRtl ? TextAlign.right : TextAlign.left;

  @override
  void initState() {
    super.initState();
    _wasConnected = PanelSession.instance.connected;
    PanelSession.instance.addListener(_handleSessionChange);
    if (PanelSession.instance.connected) {
      InboundService.instance.refresh();
    }
  }

  @override
  void dispose() {
    PanelSession.instance.removeListener(_handleSessionChange);
    _name.dispose();
    _traffic.dispose();
    _days.dispose();
    super.dispose();
  }

  void _handleSessionChange() {
    final connected = PanelSession.instance.connected;
    if (connected && !_wasConnected) {
      InboundService.instance.refresh();
    }
    if (_wasConnected && !connected) {
      _resetPage(silent: true);
    }
    _wasConnected = connected;
  }

  void _resetPage({bool silent = false}) {
    setState(() {
      _name.clear();
      _traffic.text = '10';
      _days.text = '30';
      _selectedInboundIds.clear();
      _lastCreated = null;
      _error = null;
      _busy = false;
    });

    if (!silent && mounted) {
      _showMessage(AppLocalizations.of(context).pageCleared);
    }
  }

  Future<void> _confirmClearPage() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearPageTitle),
        content: Text(l10n.clearPageFormConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _resetPage();
    }
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _inboundCollapseToken++);

    if (!PanelSession.instance.connected) {
      setState(() => _error = l10n.connectFirst);
      return;
    }

    final settings = PanelStore.instance.settings;
    if (settings == null) {
      setState(() => _error = l10n.savePanelFirst);
      return;
    }

    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.configNameRequired);
      return;
    }
    if (!RandomConfigName.isAllowed(name)) {
      setState(() => _error = l10n.configNameInvalid);
      return;
    }
    if (RandomConfigName.isTaken(name)) {
      setState(() => _error = l10n.configNameDuplicate);
      return;
    }

    if (_selectedInboundIds.isEmpty) {
      setState(() => _error = l10n.inboundSelectionRequired);
      return;
    }

    final traffic = parseTrafficGb(_traffic.text);
    final days = parseDurationDays(_days.text);
    final inboundIds = _selectedInboundIds.toList()..sort();

    setState(() {
      _busy = true;
      _error = null;
    });

    AppLogService.instance.info(
      'Creating config "$name" (traffic=$traffic, days=$days, inbounds=$inboundIds)',
    );

    try {
      final record = await PanelEngine.instance.createClient(
        settings: settings,
        name: name,
        trafficGb: traffic,
        days: days,
        inboundIds: inboundIds,
      );
      await ConfigRepository.instance.add(record);
      RandomConfigName.markUsed(record.name);
      AppLogService.instance.ok('Config created: $name');
      setState(() => _lastCreated = record);
    } catch (e) {
      AppLogService.instance.error('Create config failed: $e');
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  String get _configLink {
    final record = _lastCreated;
    if (record == null) {
      return '';
    }
    return record.configLink.trim().isNotEmpty
        ? record.configLink
        : record.link;
  }

  void _showMessage(String message) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message, textAlign: _textAlign),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NameInputField(
                controller: _name,
                label: l10n.configName,
                onGenerated: () => setState(() {}),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _limitInput(
                      _traffic,
                      l10n.trafficGb,
                      l10n.unlimitedHint,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _limitInput(
                      _days,
                      l10n.durationDays,
                      l10n.unlimitedHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InboundMultiSelect(
                selectedIds: _selectedInboundIds,
                collapseToken: _inboundCollapseToken,
                onChanged: (value) => setState(() {
                  _selectedInboundIds
                    ..clear()
                    ..addAll(value);
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: FoxColors.amber),
                  textAlign: _textAlign,
                ),
              ],
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _busy ? null : _create,
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.createConfig),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 20),
        ),
        Expanded(
          child: _lastCreated == null
              ? Center(
                  child: Text(
                    l10n.singleResultPlaceholder,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: FoxColors.muted),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    Text(
                      l10n.v2rayHint,
                      textAlign: _textAlign,
                      style:
                          const TextStyle(color: FoxColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.configLink, textAlign: _textAlign),
                    SelectableText(
                      _configLink,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.subLink, textAlign: _textAlign),
                    SelectableText(
                      _lastCreated!.link,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TapToCopyQr(
                            label: l10n.qrConfig,
                            data: _configLink,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TapToCopyQr(
                            label: l10n.qrSub,
                            data: _lastCreated!.link,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: OutlinedButton(
              onPressed: _busy ? null : _confirmClearPage,
              child: Text(l10n.clearPage),
            ),
          ),
        ),
      ],
    );
  }

  Widget _limitInput(
    TextEditingController controller,
    String label,
    String helper,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: _textAlign,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        helperText: controller.text.trim() == '0' ? helper : null,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
