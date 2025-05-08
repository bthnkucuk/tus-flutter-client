import 'package:flutter/foundation.dart' show debugPrint;

bool _isEnabled = false;

/// Enables debug logging for the TUS client
void enableDebugLog() {
  _isEnabled = true;
}

/// Logs a message if debug logging is enabled
void log(String msg) {
  if (!_isEnabled) return;
  debugPrint(msg);
}
