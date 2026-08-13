import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';

class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = LocaleService.instance.locale.languageCode;
    if (!LocaleService.cycle.contains(_selectedCode)) {
      _selectedCode = 'en';
    }
  }

  Future<void> _select(BuildContext context, String code) async {
    await LocaleService.instance.setLocale(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeService = LocaleService.instance;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.selectLanguagePrompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCode,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    setState(() {
                      _selectedCode = code;
                    });
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _select(context, _selectedCode),
                    child: Text(MaterialLocalizations.of(context).okButtonLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
