import 'dart:async';
import 'dart:math';
import '../models/health_data.dart';

/// SIMULATED wearable health band integration.
///
/// This MVP does not connect to any real device. This service generates
/// plausible, slowly-varying vitals on a timer so the app can demonstrate
/// the health-monitoring concept end-to-end (UI, alerts, notifications)
/// without hardware. Swapping this out for a real Bluetooth/API-based
/// service later would not require changing HealthProvider or any screen —
/// only this file.
class HealthBandService {
  HealthBandService._internal();
  static final HealthBandService instance = HealthBandService._internal();

  final StreamController<HealthData> _controller =
  StreamController<HealthData>.broadcast();
  Stream<HealthData> get dataStream => _controller.stream;

  Timer? _timer;
  final Random _random = Random();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  int _heartRate = 76;
  int _steps = 0;
  int _tickCount = 0;

  /// Simulates pairing with a health band. In a real integration this
  /// would perform Bluetooth discovery/pairing instead.
  Future<void> connect() async {
    if (_isConnected) return;
    await Future.delayed(const Duration(seconds: 1)); // simulated handshake
    _isConnected = true;
    _emitReading();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _tickCount++;
      _emitReading();
    });
  }

  void disconnect() {
    _timer?.cancel();
    _timer = null;
    _isConnected = false;
  }

  void _emitReading() {
    // Heart rate drifts gently within a realistic resting range.
    _heartRate += _random.nextInt(5) - 2; // -2..+2
    _heartRate = _heartRate.clamp(58, 95);

    // Steps accumulate gradually through the simulated day.
    _steps += _random.nextInt(40);

    // Blood pressure stays in a plausible range with small variation.
    final systolic = 118 + _random.nextInt(15); // 118-132
    final diastolic = 74 + _random.nextInt(10); // 74-83

    // Rare simulated fall event, purely for demo purposes — roughly
    // 1 in 40 readings, so it's easy to trigger during a live pitch by
    // using triggerFallDemo() instead of waiting.
    final fallDetected = _random.nextInt(40) == 0;

    _controller.add(HealthData(
      heartRate: _heartRate,
      bloodPressureSystolic: systolic,
      bloodPressureDiastolic: diastolic,
      steps: _steps,
      fallDetected: fallDetected,
      timestamp: DateTime.now(),
    ));
  }

  /// Manually triggers a simulated fall event on demand — use this button
  /// during a live demo/pitch instead of waiting for the random chance.
  void triggerFallDemo() {
    _controller.add(HealthData(
      heartRate: _heartRate,
      bloodPressureSystolic: 118 + _random.nextInt(15),
      bloodPressureDiastolic: 74 + _random.nextInt(10),
      steps: _steps,
      fallDetected: true,
      timestamp: DateTime.now(),
    ));
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}