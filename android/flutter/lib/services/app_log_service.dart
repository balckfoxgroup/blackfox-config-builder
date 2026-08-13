import 'package:flutter/foundation.dart';

enum AppLogLevel { info, ok, warn, error }

class AppLogService extends ChangeNotifier {
  AppLogService._();

  static final AppLogService instance = AppLogService._();

  static const _maxLines = 400;
  final List<String> _lines = [];

  List<String> get lines => List.unmodifiable(_lines);

  String get text => _lines.join('\n');

  bool get isEmpty => _lines.isEmpty;

  void info(String message) => _add(AppLogLevel.info, message);

  void ok(String message) => _add(AppLogLevel.ok, message);

  void warn(String message) => _add(AppLogLevel.warn, message);

  void error(String message) => _add(AppLogLevel.error, message);

  void _add(AppLogLevel level, String message) {
    final tag = switch (level) {
      AppLogLevel.info => 'INFO',
      AppLogLevel.ok => 'OK',
      AppLogLevel.warn => 'WARN',
      AppLogLevel.error => 'ERR',
    };
    final ts = DateTime.now().toIso8601String().substring(0, 19);
    _lines.add('[$ts] [$tag] $message');
    while (_lines.length > _maxLines) {
      _lines.removeAt(0);
    }
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
