import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';

class TapToCopyQr extends StatelessWidget {
  const TapToCopyQr({
    super.key,
    required this.label,
    required this.data,
    this.size = 160,
  });

  final String label;
  final String data;
  final double size;

  Future<void> _copy(BuildContext context) async {
    if (data.trim().isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: data.trim()));
    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.copied(label))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final textAlign =
        LocaleService.instance.isRtl ? TextAlign.right : TextAlign.left;

    return Column(
      children: [
        Text(label, textAlign: textAlign),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _copy(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: data.trim(),
              size: size,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.tapToCopy,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: textAlign,
        ),
      ],
    );
  }
}
