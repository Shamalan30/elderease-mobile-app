import 'package:flutter/material.dart';
import '../models/health_data.dart';
import '../services/health_band_service.dart';
import '../services/notification_service.dart';

/// Exposes simulated health band data as app-wide state via Provider,
/// same pattern as TaskProvider. Also triggers a local notification
/// when a fall is detected, reusing the existing NotificationService.
class HealthProvider extends ChangeNotifier {
  final HealthBandService _service = HealthBandService.instance;
  final NotificationService _notifications = NotificationService.instance;

  HealthData? _latest;
  bool _isConnecting = false;

  HealthData? get latest => _latest;
  bool get isConnected => _service.isConnected;
  bool get isConnecting => _isConnecting;

  Future<void> connect() async {
    if (_service.isConnected || _isConnecting) return;
    _isConnecting = true;
    notifyListeners();

    _service.dataStream.listen(_onReading);
    await _service.connect();

    _isConnecting = false;
    notifyListeners();
  }

  void disconnect() {
    _service.disconnect();
    _latest = null;
    notifyListeners();
  }

  void _onReading(HealthData data) {
    _latest = data;
    notifyListeners();

    if (data.fallDetected) {
      _notifications.scheduleReminder(
        // Fixed ID so repeated falls simply replace the last alert
        // rather than stacking up duplicate notifications.
        id: 999001,
        title: 'Fall Detected',
        body: 'A possible fall was detected. Please check on the wearer.',
        scheduledDateTime: DateTime.now().add(const Duration(seconds: 1)),
      );
    }
  }

  /// For live demo purposes — instantly simulates a fall event.
  void triggerFallDemo() {
    _service.triggerFallDemo();
  }
}