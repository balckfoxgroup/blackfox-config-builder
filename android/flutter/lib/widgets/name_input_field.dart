import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';
import '../utils/random_config_name.dart';

class NameInputField extends StatelessWidget {
  const NameInputField({
    super.key,
    required this.controller,
    required this.label,
    this.bulkBase = false,
    this.onGenerated,
  });

  final TextEditingController controller;
  final String label;
  final bool bulkBase;
  final VoidCallback? onGenerated;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textAlign =
        LocaleService.instance.isRtl ? TextAlign.right : TextAlign.left;

    return TextField(
      controller: controller,
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RandomConfigName.allowedCharPattern),
      ],
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          tooltip: l10n.generateRandomName,
          icon: const Icon(Icons.refresh),
          onPressed: () {
            RandomConfigName.applyTo(controller, bulkBase: bulkBase);
            onGenerated?.call();
          },
        ),
      ),
    );
  }
}
