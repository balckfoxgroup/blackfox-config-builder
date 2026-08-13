import 'dart:math';

import 'package:flutter/material.dart';

import '../services/config_repository.dart';

/// Generates readable names such as `Black fox-482193`.
class RandomConfigName {
  RandomConfigName._();

  static final _random = Random();
  static final _sessionUsed = <String>{};
  static final _sessionSuggested = <String>{};
  static const _fixedPrefix = 'Black fox';
  static const _digitCount = 6;

  /// Letters, digits, spaces, and hyphen only.
  static final RegExp allowedPattern = RegExp(r'^[A-Za-z0-9 -]+$');
  static final RegExp allowedCharPattern = RegExp(r'[A-Za-z0-9 -]');

  static bool isAllowed(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty && allowedPattern.hasMatch(trimmed);
  }

  static Set<String> _committedKnown() {
    return {
      ..._sessionUsed,
      ...ConfigRepository.instance.records.map((r) => r.name.trim()),
    };
  }

  static Set<String> _allKnownForGeneration() {
    return {
      ..._committedKnown(),
      ..._sessionSuggested,
    };
  }

  static bool isTaken(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    return _committedKnown().contains(trimmed);
  }

  /// True when bulk suffix names like `{base}-001` would collide.
  static bool isBulkBaseTaken(String baseName) {
    final base = baseName.trim();
    if (base.isEmpty) {
      return false;
    }
    if (isTaken(base)) {
      return true;
    }
    final prefix = '$base-';
    return _committedKnown().any((name) => name.startsWith(prefix));
  }

  static void markUsed(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      _sessionUsed.add(trimmed);
      _sessionSuggested.remove(trimmed);
    }
  }

  static String generate({Set<String> extraUsed = const {}}) {
    final used = <String>{
      ..._allKnownForGeneration(),
      ...extraUsed.map((name) => name.trim()).where((name) => name.isNotEmpty),
    };

    for (var attempt = 0; attempt < 256; attempt++) {
      final suffix = _randomDigits(_digitCount);
      final name = '$_fixedPrefix-$suffix';
      if (isAllowed(name) && !used.contains(name)) {
        _sessionSuggested.add(name);
        return name;
      }
    }

    final fallback =
        '$_fixedPrefix-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    _sessionSuggested.add(fallback);
    return fallback;
  }

  /// Picks a random base name safe for bulk suffixes such as `{base}-001`.
  static String generateBulkBase({Set<String> extraUsed = const {}}) {
    final reserved = <String>{
      ...extraUsed.map((name) => name.trim()).where((name) => name.isNotEmpty),
    };

    for (var attempt = 0; attempt < 256; attempt++) {
      final name = generate(extraUsed: reserved);
      if (!isBulkBaseTaken(name)) {
        return name;
      }
      reserved.add(name);
    }

    final fallback =
        '$_fixedPrefix-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    _sessionSuggested.add(fallback);
    return fallback;
  }

  static void applyTo(
    TextEditingController controller, {
    bool bulkBase = false,
  }) {
    final name = bulkBase ? generateBulkBase() : generate();
    controller.value = TextEditingValue(
      text: name,
      selection: TextSelection.collapsed(offset: name.length),
    );
  }

  static String _randomDigits(int count) {
    final buffer = StringBuffer();
    for (var i = 0; i < count; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }
}
