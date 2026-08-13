import 'package:flutter/foundation.dart';

import '../l10n/app_localizations.dart';
import '../models/inbound_info.dart';
import '../models/panel_settings.dart';
import 'app_log_service.dart';
import 'panel_engine.dart';
import 'panel_session.dart';
import 'panel_store.dart';

class InboundService extends ChangeNotifier {
  InboundService._();

  static final InboundService instance = InboundService._();

  List<InboundInfo> _inbounds = [];
  bool _loading = false;
  String? _errorKey;

  List<InboundInfo> get inbounds => List.unmodifiable(_inbounds);
  bool get loading => _loading;
  String? get errorKey => _errorKey;

  List<InboundInfo> get enabledInbounds =>
      _inbounds.where((item) => item.enable).toList(growable: false);

  void bindSession() {
    PanelSession.instance.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    if (!PanelSession.instance.connected) {
      _inbounds = [];
      _errorKey = null;
      notifyListeners();
      return;
    }
    refresh();
  }

  Future<void> refresh({bool silent = false}) async {
    if (!PanelSession.instance.connected) {
      _inbounds = [];
      _errorKey = null;
      notifyListeners();
      return;
    }

    final settings = PanelStore.instance.settings;
    if (settings == null) {
      return;
    }

    _loading = true;
    _errorKey = null;
    notifyListeners();

    try {
      final list = await PanelEngine.instance.fetchInbounds(settings);
      _inbounds = list;
      if (list.isEmpty) {
        _errorKey = 'noInboundFound';
      } else {
        AppLogService.instance.ok('Loaded ${list.length} inbound(s)');
      }
    } catch (e) {
      _inbounds = [];
      _errorKey = 'inboundListLoadFailed';
      AppLogService.instance.error('Inbound list failed: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String labelFor(AppLocalizations l10n, InboundInfo inbound) {
    final status =
        inbound.enable ? l10n.inboundEnabled : l10n.inboundDisabled;
    final remark = inbound.remark.isEmpty ? l10n.inboundNoRemark : inbound.remark;
    return l10n.inboundOptionLabel(
      inbound.protocol.toUpperCase(),
      remark,
      inbound.port,
      status,
    );
  }
}
