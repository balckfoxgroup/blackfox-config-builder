import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/panel_settings.dart';

class PanelStore {
  PanelStore._();

  static final PanelStore instance = PanelStore._();
  static const _key = 'panel_settings';
  static const _storage = FlutterSecureStorage();

  PanelSettings? _cached;

  PanelSettings? get settings => _cached;

  Future<void> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) {
      _cached = null;
      return;
    }
    _cached = PanelSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(PanelSettings settings) async {
    _cached = settings;
    await _storage.write(key: _key, value: jsonEncode(settings.toJson()));
  }

  Future<void> clear() async {
    _cached = null;
    await _storage.delete(key: _key);
  }
}
