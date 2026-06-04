import 'dart:async';
import 'package:flutter/foundation.dart';

enum TimerState { idle, running, paused, finished }

class TimerProvider extends ChangeNotifier {
  static const List<int> presets = [30, 60, 90, 120, 180, 300];

  int _totalSeconds = 90;
  int _remaining = 90;
  TimerState _state = TimerState.idle;
  Timer? _timer;

  int get totalSeconds => _totalSeconds;
  int get remaining => _remaining;
  TimerState get state => _state;
  double get progress => _remaining / _totalSeconds;

  String get timeString {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void setPreset(int seconds) {
    _cancel();
    _totalSeconds = seconds;
    _remaining = seconds;
    _state = TimerState.idle;
    notifyListeners();
  }

  void start() {
    if (_state == TimerState.running) return;
    if (_state == TimerState.finished || _state == TimerState.idle) {
      _remaining = _totalSeconds;
    }
    _state = TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > 0) {
        _remaining--;
        notifyListeners();
      } else {
        _state = TimerState.finished;
        _timer?.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void pause() {
    if (_state != TimerState.running) return;
    _timer?.cancel();
    _state = TimerState.paused;
    notifyListeners();
  }

  void reset() {
    _cancel();
    _remaining = _totalSeconds;
    _state = TimerState.idle;
    notifyListeners();
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }
}
