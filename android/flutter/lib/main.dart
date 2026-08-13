import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/fox_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_shell.dart';
import 'screens/language_picker_screen.dart';
import 'services/app_log_service.dart';
import 'services/config_repository.dart';
import 'services/inbound_service.dart';
import 'services/locale_service.dart';
import 'services/panel_engine.dart';
import 'services/panel_session.dart';
import 'services/panel_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final log = AppLogService.instance;
  log.info('App starting…');
  await LocaleService.instance.load();
  log.info('Locale loaded: ${LocaleService.instance.locale.languageCode}');
  await PanelStore.instance.load();
  await ConfigRepository.instance.load();
  InboundService.instance.bindSession();
  try {
    await PanelEngine.instance.ensureInitialized();
    log.ok('Panel engine initialized');
    final connected = await PanelEngine.instance.fetchConnectionStatus();
    PanelSession.instance.setConnected(connected);
    log.info('Panel session: ${connected ? "connected" : "disconnected"}');
  } catch (e) {
    PanelSession.instance.setConnected(false);
    log.warn('Startup panel check failed: $e');
  }
  runApp(const ConfigBuilderApp());
}

class ConfigBuilderApp extends StatelessWidget {
  const ConfigBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (context, _) {
        final localeService = LocaleService.instance;
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: FoxTheme.dark(),
          locale: localeService.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return Directionality(
              textDirection:
                  localeService.isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: localeService.languageSelected
              ? const HomeShell()
              : const LanguagePickerScreen(),
        );
      },
    );
  }
}
