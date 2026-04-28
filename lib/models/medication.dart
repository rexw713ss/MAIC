import 'package:flutter/material.dart';

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.reminderMinutes,
    required this.createdAt,
    this.purpose,
    this.takenDateKeys = const <String>[],
  });

  final String id;
  final String name;
  final String? purpose;
  final double dosageAmount;
  final String dosageUnit;
  final int reminderMinutes;
  final DateTime createdAt;
  final List<String> takenDateKeys;

  TimeOfDay get reminderTime => TimeOfDay(
        hour: reminderMinutes ~/ 60,
        minute: reminderMinutes % 60,
      );

  bool isTakenOn(DateTime date) => takenDateKeys.contains(_dateKey(date));

  Medication copyWith({
    String? id,
    String? name,
    String? purpose,
    double? dosageAmount,
    String? dosageUnit,
    int? reminderMinutes,
    DateTime? createdAt,
    List<String>? takenDateKeys,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt ?? this.createdAt,
      takenDateKeys: takenDateKeys ?? this.takenDateKeys,
    );
  }

  Medication toggleTakenOn(DateTime date) {
    final key = _dateKey(date);
    final next = [...takenDateKeys];
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    return copyWith(takenDateKeys: next);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'purpose': purpose,
      'dosageAmount': dosageAmount,
      'dosageUnit': dosageUnit,
      'reminderMinutes': reminderMinutes,
      'createdAt': createdAt.toIso8601String(),
      'takenDateKeys': takenDateKeys,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      purpose: json['purpose'] as String?,
      dosageAmount: (json['dosageAmount'] as num).toDouble(),
      dosageUnit: json['dosageUnit'] as String,
      reminderMinutes: json['reminderMinutes'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      takenDateKeys: (json['takenDateKeys'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => e as String)
          .toList(),
    );
  }

  static int timeOfDayToMinutes(TimeOfDay time) => (time.hour * 60) + time.minute;

  static String _dateKey(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}
