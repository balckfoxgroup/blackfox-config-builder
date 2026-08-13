import 'package:flutter/material.dart';

import '../core/theme/fox_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/app_log_service.dart';
import '../services/panel_engine.dart';
import '../services/panel_session.dart';
import '../widgets/app_brand_title.dart';
import '../widgets/fox_toast.dart';
import 'bulk_screen.dart';
import 'connection_screen.dart';
import 'contact_screen.dart';
import 'create_screen.dart';
import 'list_screen.dart';
import 'settings_screen.dart';
import '../services/update_service.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    ConnectionScreen(),
    CreateScreen(),
    BulkScreen(),
    ListScreen(),
    SettingsScreen(),
    ContactScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _refreshConnectionStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppLogService.instance.info('Checking remote feeds (dual-server)…');
        UpdateService.instance.checkOnStartup(context);
      }
    });
  }

  Future<void> _refreshConnectionStatus() async {
    try {
      final connected = await PanelEngine.instance.fetchConnectionStatus();
      PanelSession.instance.setConnected(connected);
    } catch (_) {
      PanelSession.instance.setConnected(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: PanelSession.instance,
      builder: (context, _) {
        final connected = PanelSession.instance.connected;
        return Scaffold(
          appBar: AppBar(
            title: const AppBrandTitle(),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8, end: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: connected ? FoxColors.green : FoxColors.muted,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 108),
                          child: Text(
                            connected ? l10n.connected : l10n.disconnected,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              IndexedStack(
                index: _index,
                children: _pages,
              ),
              const Align(
                alignment: Alignment.topCenter,
                child: FoxToastBanner(),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.link),
                label: l10n.navConnection,
              ),
              NavigationDestination(
                icon: const Icon(Icons.add_circle_outline),
                label: l10n.navSingle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.copy_all),
                label: l10n.navBulk,
              ),
              NavigationDestination(
                icon: const Icon(Icons.list_alt),
                label: l10n.navList,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n.navSettings,
              ),
              NavigationDestination(
                icon: const Icon(Icons.mail_outline),
                selectedIcon: const Icon(Icons.mail),
                label: l10n.navContact,
              ),
            ],
          ),
        );
      },
    );
  }
}
