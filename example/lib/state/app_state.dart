import 'package:flutter/foundation.dart';

/// 日志级别。
enum LogLevel { info, action, success, error }

/// 一条运行日志。
class LogEntry {
  LogEntry({required this.time, required this.message, required this.level});

  final DateTime time;
  final String message;
  final LogLevel level;

  /// HH:mm:ss 格式的时间。
  String get timeLabel {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }
}

/// 示例应用的全局状态：运行日志和注册状态。
class AppState extends ChangeNotifier {
  AppState._();

  static final AppState instance = AppState._();

  final List<LogEntry> logs = [];

  bool registered = false;

  void log(String message, {LogLevel level = LogLevel.info}) {
    logs.add(LogEntry(time: DateTime.now(), message: message, level: level));
    if (logs.length > 300) {
      logs.removeRange(0, logs.length - 300);
    }
    notifyListeners();
  }

  void setRegistered(bool value) {
    registered = value;
    notifyListeners();
  }

  void clear() {
    logs.clear();
    notifyListeners();
  }
}
