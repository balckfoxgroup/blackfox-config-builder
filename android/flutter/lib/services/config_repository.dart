import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/config_record.dart';

class ConfigRepository extends ChangeNotifier {
  ConfigRepository._();

  static final ConfigRepository instance = ConfigRepository._();
  static const _key = 'config_records';

  List<ConfigRecord> records = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      records = [];
      return;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    records = list
        .map((e) => ConfigRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> add(ConfigRecord record) async {
    records.insert(0, record);
    await _persist();
    notifyListeners();
  }

  Future<void> addAll(List<ConfigRecord> newRecords) async {
    if (newRecords.isEmpty) {
      return;
    }
    records.insertAll(0, newRecords.reversed);
    await _persist();
    notifyListeners();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= records.length) {
      return;
    }
    records.removeAt(index);
    await _persist();
    notifyListeners();
  }

  Future<void> removeIndices(Set<int> indices) async {
    if (indices.isEmpty) {
      return;
    }
    final sorted = indices.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sorted) {
      if (index >= 0 && index < records.length) {
        records.removeAt(index);
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
