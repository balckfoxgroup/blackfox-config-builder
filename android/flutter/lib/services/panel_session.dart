import 'package:flutter/foundation.dart';

class PanelSession extends ChangeNotifier {
  PanelSession._();

  static final PanelSession instance = PanelSession._();

  bool _connected = false;

  bool get connected => _connected;

  void setConnected(bool value) {
    if (_connected == value) {
      return;
    }
    _connected = value;
    notifyListeners();
  }
}
