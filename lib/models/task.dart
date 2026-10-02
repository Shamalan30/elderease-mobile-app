import 'package:flutter/material.dart';

/// The categories a task can belong to.
/// These map directly to Survey Question 3 (most-forgotten task types).
enum TaskCategory {
  medication,
  appointment,
  meal,
  water,
  exercise,
  household,
  shopping,
  other,
}

extension TaskCategoryX on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.medication:
        return 'Medication';
      case TaskCategory.appointment:
        return 'Appointment';
      case TaskCategory.meal:
        return 'Meal';
      case TaskCategory.water:
        return 'Water';
      case TaskCategory.exercise:
        return 'Exercise';
      case TaskCategory.household:
        return 'Household';
      case TaskCategory.shopping:
        return 'Shopping / Errands';
      case TaskCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.medication:
        return Icons.medication;
      case TaskCategory.appointment:
        return Icons.event;
      case TaskCategory.meal:
        return Icons.restaurant;
      case TaskCategory.water:
        return Icons.local_drink;
      case TaskCategory.exercise:
        return Icons.directions_walk;
      case TaskCategory.household:
        return Icons.home;
      case TaskCategory.shopping:
        return Icons.shopping_cart;
      case TaskCategory.other:
        return Icons.checklist;
    }
  }
}

class Task {
  final String id;
  String title;
  TaskCategory category;
  DateTime date; // stores only the date part (time is separate below)
  TimeOfDay time;
  String notes;
  bool isCompleted;
  bool reminderEnabled;
  int reminderMinutesBefore;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    this.notes = '',
    this.isCompleted = false,
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 10,
  });

  /// Combines the date and time fields into a single DateTime,
  /// useful for scheduling notifications and sorting.
  DateTime get dateTime => DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );

  Task copyWith({
    String? title,
    TaskCategory? category,
    DateTime? date,
    TimeOfDay? time,
    String? notes,
    bool? isCompleted,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
      reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    'date': date.toIso8601String(),
    'timeHour': time.hour,
    'timeMinute': time.minute,
    'notes': notes,
    'isCompleted': isCompleted,
    'reminderEnabled': reminderEnabled,
    'reminderMinutesBefore': reminderMinutesBefore,
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      category: TaskCategory.values.firstWhere(
            (c) => c.name == json['category'],
        orElse: () => TaskCategory.other,
      ),
      date: DateTime.parse(json['date'] as String),
      time: TimeOfDay(
        hour: json['timeHour'] as int,
        minute: json['timeMinute'] as int,
      ),
      notes: json['notes'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] as int? ?? 10,
    );
  }
}