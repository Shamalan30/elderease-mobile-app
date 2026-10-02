import 'package:flutter/material.dart';

class Appointment {
  final String id;
  String title;
  DateTime date;
  TimeOfDay time;
  String location;
  String notes;
  bool reminderEnabled;
  int reminderMinutesBefore; // e.g. 1440 = 1 day before

  Appointment({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    this.location = '',
    this.notes = '',
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 1440,
  });

  DateTime get dateTime => DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );

  Appointment copyWith({
    String? title,
    DateTime? date,
    TimeOfDay? time,
    String? location,
    String? notes,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
  }) {
    return Appointment(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
      reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'timeHour': time.hour,
    'timeMinute': time.minute,
    'location': location,
    'notes': notes,
    'reminderEnabled': reminderEnabled,
    'reminderMinutesBefore': reminderMinutesBefore,
  };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      time: TimeOfDay(
        hour: json['timeHour'] as int,
        minute: json['timeMinute'] as int,
      ),
      location: json['location'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] as int? ?? 1440,
    );
  }
}