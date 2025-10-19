/// Time override utility for testing
/// 
/// This utility allows overriding DateTime.now() for testing purposes.
/// Only works in debug mode.
class TimeOverride {
  static DateTime? _overrideDateTime;
  static bool _enabled = false;

  /// Get current DateTime, respecting override if set and enabled
  static DateTime now() {
    if (_enabled && _overrideDateTime != null) {
      return _overrideDateTime!;
    }
    return DateTime.now();
  }

  /// Enable or disable time override
  static void setEnabled(bool enabled) {
    assert(() {
      _enabled = enabled;
      return true;
    }());
  }

  /// Check if time override is enabled
  static bool get isEnabled => _enabled;

  /// Set override date (only in debug mode)
  static void setOverride(DateTime? dateTime) {
    assert(() {
      _overrideDateTime = dateTime;
      return true;
    }());
  }

  /// Clear override
  static void clearOverride() {
    assert(() {
      _overrideDateTime = null;
      return true;
    }());
  }

  /// Add days to current override (or now if not set)
  static void addDays(int days) {
    assert(() {
      final current = _overrideDateTime ?? DateTime.now();
      _overrideDateTime = current.add(Duration(days: days));
      return true;
    }());
  }

  /// Subtract days from current override (or now if not set)
  static void subtractDays(int days) {
    assert(() {
      final current = _overrideDateTime ?? DateTime.now();
      _overrideDateTime = current.subtract(Duration(days: days));
      return true;
    }());
  }

  /// Check if override is active
  static bool get isOverrideActive => _overrideDateTime != null;

  /// Get override date if set
  static DateTime? get overrideDate => _overrideDateTime;
}
