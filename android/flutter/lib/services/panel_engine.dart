import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/bulk_result_line.dart';
import '../models/config_record.dart';
import '../models/inbound_info.dart';
import '../models/panel_settings.dart';

class PanelEngine {
  PanelEngine._();

  static final PanelEngine instance = PanelEngine._();
  static const _channel = MethodChannel('com.blackfoxvpnn.configbuilder/engine');

  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    final err = await _channel.invokeMethod<String>('init');
    if (err != null && err.isNotEmpty) {
      throw StateError(err);
    }
    _initialized = true;
  }

  Future<bool> fetchConnectionStatus() async {
    await ensureInitialized();
    final raw = await _channel.invokeMethod<String>('connectionStatus');
    final map = _parseResponse(raw);
    return map['connected'] as bool? ?? false;
  }

  Future<void> connectPanel(PanelSettings settings) async {
    await ensureInitialized();
    final raw = await _channel.invokeMethod<String>(
      'connectPanel',
      {'settings': jsonEncode(settings.toJson())},
    );
    _throwIfFailed(raw);
  }

  Future<void> disconnectPanel() async {
    await ensureInitialized();
    final raw = await _channel.invokeMethod<String>('disconnectPanel');
    _throwIfFailed(raw);
  }

  Future<void> testConnection(PanelSettings settings) async {
    await ensureInitialized();
    final raw = await _channel.invokeMethod<String>(
      'testConnection',
      {'settings': jsonEncode(settings.toJson())},
    );
    _throwIfFailed(raw);
  }

  Future<List<InboundInfo>> fetchInbounds(PanelSettings settings) async {
    await ensureInitialized();
    final raw = await _channel.invokeMethod<String>(
      'listInbounds',
      {'settings': jsonEncode(settings.toJson())},
    );
    final map = _parseResponse(raw);
    final list = map['inbounds'] as List<dynamic>? ?? [];
    return list
        .map((e) => InboundInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ConfigRecord> createClient({
    required PanelSettings settings,
    required String name,
    required double trafficGb,
    required int days,
    required List<int> inboundIds,
    int inboundPort = 0,
  }) async {
    await ensureInitialized();
    final raw = await _channel.invokeMethod<String>('createClient', {
      'settings': jsonEncode(settings.toJson()),
      'request': jsonEncode({
        'name': name,
        'trafficLimitGb': trafficGb,
        'expirationDays': days,
        'inboundIds': inboundIds,
        'inboundPort': inboundPort,
      }),
    });
    final map = _parseResponse(raw);
    final recordJson = map['record'] as Map<String, dynamic>?;
    if (recordJson == null) {
      throw StateError('Panel did not return a config record.');
    }
    return ConfigRecord.fromJson(recordJson);
  }

  Future<void> deleteClientFromPanel({
    required PanelSettings settings,
    required String name,
    int inboundPort = 0,
  }) async {
    await ensureInitialized();
    final raw = await _channel.invokeMethod<String>('deleteClient', {
      'settings': jsonEncode(settings.toJson()),
      'request': jsonEncode({
        'name': name,
        'inboundPort': inboundPort,
      }),
    });
    _throwIfFailed(raw);
  }

  Future<List<BulkResultLine>> createBulk({
    required PanelSettings settings,
    required String baseName,
    required int count,
    required double trafficGb,
    required int days,
    required List<int> inboundIds,
    int inboundPort = 0,
    String remarkPattern = '',
  }) async {
    await ensureInitialized();
    final raw = await _channel.invokeMethod<String>('createBulk', {
      'settings': jsonEncode(settings.toJson()),
      'request': jsonEncode({
        'baseName': baseName,
        'count': count,
        'trafficLimitGb': trafficGb,
        'expirationDays': days,
        'inboundIds': inboundIds,
        'inboundPort': inboundPort,
        'remarkPattern': remarkPattern,
      }),
    });
    final map = _parseResponse(raw);
    final lines = map['lines'] as List<dynamic>? ?? [];
    return lines
        .map((e) => BulkResultLine.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> _parseResponse(String? raw) {
    if (raw == null || raw.isEmpty) {
      throw StateError('Empty response from panel engine.');
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    if (map['ok'] != true) {
      throw StateError(map['error'] as String? ?? 'Unknown panel error.');
    }
    return map;
  }

  void _throwIfFailed(String? raw) {
    _parseResponse(raw);
  }

  Future<void> installApk(String path) async {
    await _channel.invokeMethod<void>('installApk', {'path': path});
  }
}
