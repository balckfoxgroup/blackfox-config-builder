import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/fox_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/config_record.dart';
import '../services/app_log_service.dart';
import '../services/config_repository.dart';
import '../services/locale_service.dart';
import '../services/panel_engine.dart';
import '../services/panel_session.dart';
import '../services/panel_store.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final Set<int> _selected = {};

  TextAlign get _textAlign =>
      LocaleService.instance.isRtl ? TextAlign.right : TextAlign.left;

  List<ConfigRecord> get _records => ConfigRepository.instance.records;

  bool get _allSelected =>
      _records.isNotEmpty && _selected.length == _records.length;

  bool? get _selectAllValue {
    if (_selected.isEmpty) {
      return false;
    }
    return _allSelected ? true : null;
  }

  String _linkFor(ConfigRecord record) {
    final configLink = record.configLink.trim();
    return configLink.isNotEmpty ? configLink : record.link.trim();
  }

  Set<int> _targetIndices(int tappedIndex) {
    return _selected.isNotEmpty ? _selected : {tappedIndex};
  }

  void _clearSelection() {
    _selected.clear();
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selected
          ..clear()
          ..addAll(List.generate(_records.length, (index) => index));
      } else {
        _clearSelection();
      }
    });
  }

  void _toggleItem(int index, bool? value) {
    setState(() {
      if (value == true) {
        _selected.add(index);
      } else {
        _selected.remove(index);
      }
    });
  }

  Future<void> _copyLinks(Set<int> indices) async {
    final l10n = AppLocalizations.of(context);
    final sorted = indices.toList()..sort();
    final links = sorted
        .map((index) => _linkFor(_records[index]))
        .where((link) => link.isNotEmpty)
        .join('\n');

    if (links.isEmpty) {
      _showSnack(l10n.noLinksToCopy);
      return;
    }

    await Clipboard.setData(ClipboardData(text: links));
    _showSnack(
      sorted.length > 1
          ? l10n.linksCopied(sorted.length)
          : l10n.linkCopied,
    );
  }

  Future<void> _deleteFromList(Set<int> indices) async {
    if (indices.isEmpty) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final multiple = indices.length > 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteFromListTitle),
        content: Text(
          multiple ? l10n.deleteFromListMultiple : l10n.deleteFromListSingle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await ConfigRepository.instance.removeIndices(indices);
    setState(_clearSelection);
    _showSnack(
      multiple ? l10n.configsDeletedFromList : l10n.configDeletedFromList,
    );
  }

  Future<void> _deleteFromPanel(Set<int> indices) async {
    if (indices.isEmpty) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    if (!PanelSession.instance.connected) {
      _showSnack(l10n.connectPanelFirst);
      return;
    }

    final settings = PanelStore.instance.settings;
    if (settings == null) {
      return;
    }

    final multiple = indices.length > 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteFromPanelTitle),
        content: Text(
          multiple ? l10n.deleteFromPanelMultiple : l10n.deleteFromPanelSingle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final targets =
        indices.map((index) => (index: index, record: _records[index])).toList();

    final removedIndices = <int>[];
    final failures = <String>[];

    for (final item in targets) {
      try {
        AppLogService.instance.info('Deleting from panel: ${item.record.name}');
        await PanelEngine.instance.deleteClientFromPanel(
          settings: settings,
          name: item.record.name,
          inboundPort: item.record.inboundPort,
        );
        AppLogService.instance.ok('Deleted from panel: ${item.record.name}');
        removedIndices.add(item.index);
      } catch (e) {
        AppLogService.instance.error('Delete failed (${item.record.name}): $e');
        failures.add('${item.record.name}: $e');
      }
    }

    if (removedIndices.isNotEmpty) {
      await ConfigRepository.instance.removeIndices(removedIndices.toSet());
    }

    if (!mounted) {
      return;
    }

    setState(_clearSelection);

    if (!multiple && failures.isEmpty) {
      _showSnack(l10n.configDeletedFromPanel);
      return;
    }

    final successCount = removedIndices.length;
    final failureCount = failures.length;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePanelResultTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.successCount(successCount)),
              Text(l10n.failureCount(failureCount)),
              if (failures.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.errors,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ...failures.map(
                  (message) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: ConfigRepository.instance,
      builder: (context, _) {
        final records = ConfigRepository.instance.records;

        if (records.isEmpty) {
          return Center(
            child: Text(l10n.noConfigsYet),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _selectionHeader(l10n),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                itemCount: records.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _recordTile(context, l10n, index, records[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _selectionHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l10n.selectedCount(_selected.length),
                textAlign: _textAlign,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: FoxColors.blue,
                ),
              ),
            ),
          Row(
            children: [
              Checkbox(
                tristate: true,
                value: _selectAllValue,
                onChanged: _toggleSelectAll,
              ),
              Text(l10n.selectAll),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recordTile(
    BuildContext context,
    AppLocalizations l10n,
    int index,
    ConfigRecord record,
  ) {
    final meta = <String>[
      if (record.trafficLimitGb != null)
        '${record.trafficLimitGb!.toStringAsFixed(0)} GB',
      if (record.expirationDays != null)
        l10n.daysCount(record.expirationDays!),
    ].join(' · ');

    return ListTile(
      leading: Checkbox(
        value: _selected.contains(index),
        onChanged: (value) => _toggleItem(index, value),
      ),
      title: Text(record.name, textAlign: _textAlign),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (meta.isNotEmpty)
            Text(
              meta,
              textAlign: _textAlign,
              style: const TextStyle(color: FoxColors.muted),
            ),
          Text(
            record.link,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      isThreeLine: meta.isNotEmpty,
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          final targets = _targetIndices(index);
          if (value == 'copy') {
            await _copyLinks(targets);
          } else if (value == 'delete') {
            await _deleteFromList(targets);
          } else if (value == 'delete_panel') {
            await _deleteFromPanel(targets);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'copy', child: Text(l10n.copyLink)),
          PopupMenuItem(value: 'delete_panel', child: Text(l10n.deleteFromPanel)),
          PopupMenuItem(value: 'delete', child: Text(l10n.deleteFromList)),
        ],
      ),
    );
  }
}
