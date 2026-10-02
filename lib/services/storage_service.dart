import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/appointment.dart';

/// Handles saving and loading Tasks and Appointments to local device storage.
/// Uses SharedPreferences (simple key-value storage) since the MVP doesn't
/// need a full database yet. Each list is stored as one JSON string.
class StorageService {
  static const String _tasksKey = 'remindly_tasks';
  static const String _appointmentsKey = 'remindly_appointments';
  static const String _userTypeKey = 'remindly_user_type';
  static const String _onboardingDoneKey = 'remindly_onboarding_done';
  static const String _textScaleKey = 'remindly_text_scale';

  // ---------------- Tasks ----------------

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // If stored data is ever corrupted, fail safe with an empty list
      // instead of crashing the app.
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, raw);
  }

  // ---------------- Appointments ----------------

  Future<List<Appointment>> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_appointmentsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAppointments(List<Appointment> appointments) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(appointments.map((a) => a.toJson()).toList());
    await prefs.setString(_appointmentsKey, raw);
  }

  // ---------------- User type (Elderly / Family / Caregiver) ----------------

  Future<String?> loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, userType);
  }

  // ---------------- Onboarding flag ----------------

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingDoneKey) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingDoneKey, true);
  }

  // ---------------- Text size preference ----------------
  // Stored as a scale multiplier: 0.9 (Small), 1.0 (Medium), 1.15 (Large), 1.3 (Extra Large)

  Future<double> loadTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_textScaleKey) ?? 1.15; // default: Large
  }

  Future<void> saveTextScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, scale);
  }
}