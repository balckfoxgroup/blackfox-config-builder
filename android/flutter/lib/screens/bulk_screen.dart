import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/fox_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/bulk_result_line.dart';
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

class BulkScreen extends StatefulWidget {
  const BulkScreen({super.key});

  @override
  State<BulkScreen> createState() => _BulkScreenState();
}

class _BulkScreenState extends State<BulkScreen> {
  final _baseName = TextEditingController();
  final _count = TextEditingController(text: '10');
  final _traffic = TextEditingController(text: '10');
  final _days = TextEditingController(text: '30');
  final _copyIndex = TextEditingController();
  final Set<int> _selectedInboundIds = {};
  bool _busy = false;
  bool _stopRequested = false;
  int _progress = 0;
  int _total = 0;
  String? _error;
  List<BulkResultLine> _lines = [];
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
    _baseName.dispose();
    _count.dispose();
    _traffic.dispose();
    _days.dispose();
    _copyIndex.dispose();
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
      _lines = [];
      _progress = 0;
      _total = 0;
      _error = null;
      _busy = false;
      _stopRequested = false;
      _selectedInboundIds.clear();
      _copyIndex.clear();
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
        content: Text(l10n.clearBulkConfirm),
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

  Future<void> _startBulk() async {
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

    final baseName = _baseName.text.trim();
    final count = int.tryParse(_count.text.trim()) ?? 0;
    if (baseName.isEmpty || count <= 0) {
      setState(() => _error = l10n.baseNameAndCountRequired);
      return;
    }
    if (!RandomConfigName.isAllowed(baseName)) {
      setState(() => _error = l10n.configNameInvalid);
      return;
    }
    if (RandomConfigName.isBulkBaseTaken(baseName)) {
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
    final expectedTotal = count * inboundIds.length;

    setState(() {
      _busy = true;
      _stopRequested = false;
      _error = null;
      _lines = [];
      _progress = 0;
      _total = expectedTotal;
    });

    AppLogService.instance.info(
      'Bulk create started: base="$baseName", count=$count, inbounds=$inboundIds',
    );

    try {
      final lines = await PanelEngine.instance.createBulk(
        settings: settings,
        baseName: baseName,
        count: count,
        trafficGb: traffic,
        days: days,
        inboundIds: inboundIds,
      );

      if (_stopRequested) {
        return;
      }

      RandomConfigName.markUsed(baseName);
      for (final line in lines) {
        RandomConfigName.markUsed(line.name);
      }
      final newRecords = lines
          .map(
            (line) => ConfigRecord(
              id: line.name,
              name: line.name,
              link: line.subLink,
              configLink: line.configLink,
              trafficLimitGb: traffic > 0 ? traffic : null,
              expirationDays: days > 0 ? days : null,
            ),
          )
          .toList(growable: false);
      await ConfigRepository.instance.addAll(newRecords);

      if (!mounted) {
        return;
      }
      setState(() {
        _lines = lines;
        _progress = lines.length;
      });
      AppLogService.instance
          .ok('Bulk create finished: ${lines.length} configs');
    } catch (e) {
      AppLogService.instance.error('Bulk create failed: $e');
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  void _stopBulk() {
    setState(() => _stopRequested = true);
  }

  Future<void> _copyPairByIndex() async {
    final l10n = AppLocalizations.of(context);
    final index = int.tryParse(_copyIndex.text.trim());
    if (index == null || index < 1) {
      setState(() => _error = l10n.invalidIndex);
      return;
    }

    BulkResultLine? line;
    for (final item in _lines) {
      if (item.index == index) {
        line = item;
        break;
      }
    }

    if (line == null) {
      setState(() => _error = l10n.linkNotFoundByIndex);
      return;
    }

    final payload = '${line.configLink}\n${line.subLink}';
    await Clipboard.setData(ClipboardData(text: payload));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.linksCopiedByIndex(index))),
      );
    }
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
                controller: _baseName,
                label: l10n.baseName,
                bulkBase: true,
                onGenerated: () => setState(() {}),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _input(_count, l10n.count)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _limitInput(
                      _traffic,
                      l10n.trafficGb,
                      l10n.unlimitedHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _limitInput(_days, l10n.durationDays, l10n.unlimitedHint),
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
              if (_total > 0) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _total == 0 ? null : _progress / _total,
                ),
                Text('$_progress / $_total', textAlign: _textAlign),
              ],
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
                onPressed: _busy ? null : _startBulk,
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.createBulkConfig),
              ),
              if (_busy) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _stopBulk,
                  child: Text(l10n.stop),
                ),
              ],
              if (_lines.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _copyIndex,
                        keyboardType: TextInputType.number,
                        textAlign: _textAlign,
                        decoration: InputDecoration(
                          labelText: l10n.linkNumber,
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: _copyPairByIndex,
                      child: Text(l10n.copy),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 20),
        ),
        Expanded(
          child: _lines.isEmpty
              ? Center(
                  child: Text(
                    l10n.bulkLinksPlaceholder,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: FoxColors.muted),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    _alignedLinkGrid(l10n, _lines),
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

  Widget _alignedLinkGrid(AppLocalizations l10n, List<BulkResultLine> lines) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.configLinkColumn,
                textAlign: _textAlign,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.subLinkColumn,
                textAlign: _textAlign,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _linkCell(line.index, line.configLink)),
                  const SizedBox(width: 8),
                  Expanded(child: _linkCell(line.index, line.subLink)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _linkCell(int index, String link) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: link));
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.indexCopied(index))),
          );
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: FoxColors.card,
          border: Border.all(color: FoxColors.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '$index.',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: FoxColors.blue,
                ),
              ),
            ),
            Expanded(
              child: Text(
                link,
                textDirection: TextDirection.ltr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      textAlign: _textAlign,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
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
