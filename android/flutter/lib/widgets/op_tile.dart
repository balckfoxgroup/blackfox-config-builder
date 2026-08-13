import 'package:flutter/material.dart';

import '../core/theme/fox_colors.dart';

enum OpTileStyle { primary, secondary, danger }

class OpTile extends StatelessWidget {
  const OpTile({
    super.key,
    required this.label,
    required this.onTap,
    this.style = OpTileStyle.primary,
    this.trailing,
    this.subtitle,
    this.enabled = true,
  });

  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final OpTileStyle style;
  final Widget? trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = switch (style) {
      OpTileStyle.primary => (FoxColors.blue, Colors.black),
      OpTileStyle.secondary => (FoxColors.bg2, FoxColors.text),
      OpTileStyle.danger => (FoxColors.red.withValues(alpha: 0.15), FoxColors.red),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: colors.$1,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: style == OpTileStyle.danger
                      ? FoxColors.red
                      : FoxColors.line,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: colors.$2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty)
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: colors.$2.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else
                    Icon(
                      Icons.chevron_right,
                      color: colors.$2.withValues(alpha: 0.7),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
