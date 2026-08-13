import 'package:flutter/material.dart';

import '../core/theme/fox_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/inbound_info.dart';
import '../services/inbound_service.dart';
import '../services/locale_service.dart';

class InboundMultiSelect extends StatefulWidget {
  const InboundMultiSelect({
    super.key,
    required this.selectedIds,
    required this.onChanged,
    this.collapseToken = 0,
  });

  final Set<int> selectedIds;
  final ValueChanged<Set<int>> onChanged;
  final int collapseToken;

  @override
  State<InboundMultiSelect> createState() => _InboundMultiSelectState();
}

class _InboundMultiSelectState extends State<InboundMultiSelect> {
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant InboundMultiSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collapseToken != widget.collapseToken && _expanded) {
      setState(() => _expanded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = InboundService.instance;
    final textAlign =
        LocaleService.instance.isRtl ? TextAlign.right : TextAlign.left;

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        if (service.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (service.errorKey != null) {
          final message = switch (service.errorKey) {
            'noInboundFound' => l10n.noInboundFound,
            _ => l10n.inboundListLoadFailed,
          };
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message,
                style: const TextStyle(color: FoxColors.amber),
                textAlign: textAlign,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => service.refresh(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.refreshInbounds),
                ),
              ),
            ],
          );
        }

        final items = service.inbounds;
        if (items.isEmpty) {
          return Text(
            l10n.noInboundFound,
            style: const TextStyle(color: FoxColors.amber),
            textAlign: textAlign,
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: FoxColors.card,
            border: Border.all(color: FoxColors.line),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.selectInbounds,
                          style: Theme.of(context).textTheme.titleSmall,
                          textAlign: textAlign,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.selectedCount(widget.selectedIds.length),
                          style: const TextStyle(
                            color: FoxColors.muted,
                            fontSize: 12,
                          ),
                          textAlign: textAlign,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.refreshInbounds,
                    onPressed: () => service.refresh(),
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    tooltip: _expanded ? l10n.close : l10n.selectInbounds,
                    onPressed: () => setState(() => _expanded = !_expanded),
                    icon: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                    ),
                  ),
                ],
              ),
              if (_expanded) ...[
                const Divider(height: 1),
                const SizedBox(height: 4),
                ...items.map((inbound) => _InboundTile(
                      inbound: inbound,
                      label: service.labelFor(l10n, inbound),
                      selected: widget.selectedIds.contains(inbound.id),
                      onChanged: (selected) {
                        final next = Set<int>.from(widget.selectedIds);
                        if (selected) {
                          next.add(inbound.id);
                        } else {
                          next.remove(inbound.id);
                        }
                        widget.onChanged(next);
                      },
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InboundTile extends StatelessWidget {
  const _InboundTile({
    required this.inbound,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final InboundInfo inbound;
  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = inbound.enable;
    return CheckboxListTile(
      value: selected,
      onChanged: enabled ? (value) => onChanged(value ?? false) : null,
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        label,
        style: TextStyle(
          color: enabled ? null : FoxColors.muted,
          fontSize: 13,
        ),
      ),
    );
  }
}
