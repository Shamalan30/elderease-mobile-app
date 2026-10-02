/// Represents a single snapshot of health data that would come from a
/// connected wearable health band. This MVP simulates the band since no
/// real hardware is integrated yet — the architecture is ready to swap
/// in a real Bluetooth/API data source later without changing the UI.
class HealthData {
  final int heartRate; // bpm
  final int bloodPressureSystolic; // mmHg
  final int bloodPressureDiastolic; // mmHg
  final int steps;
  final bool fallDetected;
  final DateTime timestamp;

  const HealthData({
    required this.heartRate,
    required this.bloodPressureSystolic,
    required this.bloodPressureDiastolic,
    required this.steps,
    this.fallDetected = false,
    required this.timestamp,
  });

  String get bloodPressureLabel =>
      '$bloodPressureSystolic/$bloodPressureDiastolic';

  /// Simple status flags so the UI can highlight concerning readings.
  bool get heartRateHigh => heartRate > 100;
  bool get heartRateLow => heartRate < 55;
  bool get bloodPressureHigh =>
      bloodPressureSystolic > 140 || bloodPressureDiastolic > 90;
}