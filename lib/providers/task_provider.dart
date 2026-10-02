import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/appointment.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

/// Single source of truth for tasks and appointments.
/// Any screen wrapped under this provider will automatically rebuild
/// when tasks/appointments are added, edited, deleted, or completed.
class TaskProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService.instance;
  final Uuid _uuid = const Uuid();

  List<Task> _tasks = [];
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  bool get isLoading => _isLoading;

  /// Call once at app startup to load saved data.
  Future<void> loadData() async {
    _tasks = await _storage.loadTasks();
    _appointments = await _storage.loadAppointments();

    // First-ever launch: seed realistic sample data so the app is
    // immediately understandable during a demo. Safe to delete this
    // block later — it only runs when storage is completely empty.
    if (_tasks.isEmpty && _appointments.isEmpty) {
      _seedSampleData();
      await _storage.saveTasks(_tasks);
      await _storage.saveAppointments(_appointments);
    }

    _isLoading = false;
    notifyListeners();
  }

  void _seedSampleData() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    _tasks = [
      Task(
        id: _uuid.v4(),
        title: 'Take Medication',
        category: TaskCategory.medication,
        date: todayDate,
        time: const TimeOfDay(hour: 8, minute: 0),
        notes: 'Take after breakfast.',
      ),
      Task(
        id: _uuid.v4(),
        title: 'Drink Water',
        category: TaskCategory.water,
        date: todayDate,
        time: const TimeOfDay(hour: 10, minute: 0),
      ),
      Task(
        id: _uuid.v4(),
        title: 'Lunch',
        category: TaskCategory.meal,
        date: todayDate,
        time: const TimeOfDay(hour: 13, minute: 0),
      ),
      Task(
        id: _uuid.v4(),
        title: 'Evening Walk',
        category: TaskCategory.exercise,
        date: todayDate,
        time: const TimeOfDay(hour: 17, minute: 30),
      ),
      Task(
        id: _uuid.v4(),
        title: 'Check Garden',
        category: TaskCategory.household,
        date: todayDate,
        time: const TimeOfDay(hour: 19, minute: 0),
      ),
    ];

    _appointments = [
      Appointment(
        id: _uuid.v4(),
        title: 'Doctor Appointment',
        date: todayDate.add(const Duration(days: 4)),
        time: const TimeOfDay(hour: 10, minute: 30),
        location: 'Klinik Kesihatan',
        reminderMinutesBefore: 1440,
      ),
    ];
  }

  // ---------------- Derived / filtered views ----------------

  List<Task> tasksForDate(DateTime date) {
    final list = _tasks
        .where((t) =>
    t.date.year == date.year &&
        t.date.month == date.month &&
        t.date.day == date.day)
        .toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  List<Task> get todayTasks => tasksForDate(DateTime.now());

  /// The next upcoming, not-yet-completed task for today.
  Task? get nextTask {
    final now = DateTime.now();
    final upcoming = todayTasks
        .where((t) => !t.isCompleted && t.dateTime.isAfter(now))
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcoming.first;
  }

  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    final list = _appointments.where((a) => a.dateTime.isAfter(now)).toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  List<Appointment> appointmentsForDate(DateTime date) {
    return _appointments
        .where((a) =>
    a.date.year == date.year &&
        a.date.month == date.month &&
        a.date.day == date.day)
        .toList();
  }

  /// Today's progress as (completedCount, totalCount).
  (int, int) get todayProgress {
    final list = todayTasks;
    final completed = list.where((t) => t.isCompleted).length;
    return (completed, list.length);
  }

  /// Progress across the last 7 days (including today).
  (int, int) get weekProgress {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final list = _tasks.where((t) =>
    !t.date.isBefore(DateTime(weekAgo.year, weekAgo.month, weekAgo.day)) &&
        !t.date.isAfter(DateTime(now.year, now.month, now.day)));
    final completed = list.where((t) => t.isCompleted).length;
    return (completed, list.length);
  }

  // ---------------- Task CRUD ----------------

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    notifyListeners();
    await _storage.saveTasks(_tasks);
    await _scheduleTaskReminder(task);
  }

  Future<void> updateTask(Task updated) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    _tasks[index] = updated;
    notifyListeners();
    await _storage.saveTasks(_tasks);
    await _notifications.cancelReminder(updated.id.hashCode);
    await _scheduleTaskReminder(updated);
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _storage.saveTasks(_tasks);
    await _notifications.cancelReminder(id.hashCode);
  }

  Future<void> toggleTaskCompleted(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    notifyListeners();
    await _storage.saveTasks(_tasks);
  }

  String generateId() => _uuid.v4();

  Future<void> _scheduleTaskReminder(Task task) async {
    if (!task.reminderEnabled) return;
    final reminderTime =
    task.dateTime.subtract(Duration(minutes: task.reminderMinutesBefore));
    await _notifications.scheduleReminder(
      id: task.id.hashCode,
      title: 'Reminder',
      body: 'Time for: ${task.title}',
      scheduledDateTime: reminderTime,
    );
  }

  // ---------------- Appointment CRUD ----------------

  Future<void> addAppointment(Appointment appointment) async {
    _appointments.add(appointment);
    notifyListeners();
    await _storage.saveAppointments(_appointments);
    await _scheduleAppointmentReminder(appointment);
  }

  Future<void> updateAppointment(Appointment updated) async {
    final index = _appointments.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;
    _appointments[index] = updated;
    notifyListeners();
    await _storage.saveAppointments(_appointments);
    await _notifications.cancelReminder(updated.id.hashCode);
    await _scheduleAppointmentReminder(updated);
  }

  Future<void> deleteAppointment(String id) async {
    _appointments.removeWhere((a) => a.id == id);
    notifyListeners();
    await _storage.saveAppointments(_appointments);
    await _notifications.cancelReminder(id.hashCode);
  }

  Future<void> _scheduleAppointmentReminder(Appointment appointment) async {
    if (!appointment.reminderEnabled) return;
    final reminderTime = appointment.dateTime
        .subtract(Duration(minutes: appointment.reminderMinutesBefore));
    await _notifications.scheduleReminder(
      id: appointment.id.hashCode,
      title: 'Upcoming Appointment',
      body: appointment.title,
      scheduledDateTime: reminderTime,
    );
  }
}