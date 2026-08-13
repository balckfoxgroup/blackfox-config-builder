import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/fox_colors.dart';

enum FoxToastType { progress, success, warning, error }

class FoxToastService extends ChangeNotifier {
  FoxToastService._();

  static final FoxToastService instance = FoxToastService._();

  String? _message;
  FoxToastType? _type;
  Timer? _dismissTimer;
  int _generation = 0;

  String? get message => _message;
  FoxToastType? get type => _type;
  bool get visible => _message != null && _type != null;

  void showProgress(String message) {
    _dismissTimer?.cancel();
    _generation++;
    _message = message;
    _type = FoxToastType.progress;
    notifyListeners();
  }

  void showResult(String message, FoxToastType type) {
    _dismissTimer?.cancel();
    _generation++;
    final generation = _generation;
    _message = message;
    _type = type;
    notifyListeners();

    if (type == FoxToastType.progress) {
      return;
    }

    final duration = type == FoxToastType.error
        ? const Duration(seconds: 4)
        : const Duration(seconds: 2);

    _dismissTimer = Timer(duration, () {
      if (generation == _generation) {
        _message = null;
        _type = null;
        notifyListeners();
      }
    });
  }

  void dismiss() {
    _dismissTimer?.cancel();
    _generation++;
    _message = null;
    _type = null;
    notifyListeners();
  }
}

class FoxToastBanner extends StatelessWidget {
  const FoxToastBanner({super.key});

  Color _accentColor(FoxToastType type) {
    return switch (type) {
      FoxToastType.progress => FoxColors.blue,
      FoxToastType.success => FoxColors.green,
      FoxToastType.warning => FoxColors.amber,
      FoxToastType.error => FoxColors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FoxToastService.instance,
      builder: (context, _) {
        final service = FoxToastService.instance;
        final message = service.message;
        final type = service.type;
        final visible = message != null && type != null;

        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            curve: visible ? Curves.easeOut : Curves.easeIn,
            child: AnimatedSlide(
              offset: visible ? Offset.zero : const Offset(0, -0.15),
              duration: const Duration(milliseconds: 220),
              curve: visible ? Curves.easeOut : Curves.easeIn,
              child: visible && message != null && type != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Material(
                        elevation: 6,
                        shadowColor: Colors.black54,
                        color: FoxColors.card,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _accentColor(type).withValues(alpha: 0.55),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _accentColor(type),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  message,
                                  style: const TextStyle(
                                    color: FoxColors.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
