import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/medication.dart';

class MedicationProvider extends ChangeNotifier {
  static const _prefsKey = 'medications.v1';

  final List<Medication> _medications = <Medication>[];
  bool _loaded = false;

  bool get loaded => _loaded;
  List<Medication> get medications => List.unmodifiable(_medications);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      _loaded = true;
      notifyListeners();
      return;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    _medications
      ..clear()
      ..addAll(
        decoded.map((e) => Medication.fromJson(e as Map<String, dynamic>)),
      );
    _loaded = true;
    notifyListeners();
  }

  Future<void> addMedication({
    required String name,
    required String? purpose,
    required double dosageAmount,
    required String dosageUnit,
    required int reminderMinutes,
  }) async {
    final now = DateTime.now();
    final med = Medication(
      id: now.microsecondsSinceEpoch.toString(),
      name: name.trim(),
      purpose: (purpose == null || purpose.trim().isEmpty) ? null : purpose.trim(),
      dosageAmount: dosageAmount,
      dosageUnit: dosageUnit,
      reminderMinutes: reminderMinutes,
      createdAt: now,
    );
    _medications.add(med);
    _sortByReminder();
    await _persist();
    notifyListeners();
  }

  Future<void> toggleTakenForDate(String id, DateTime date) async {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _medications[index] = _medications[index].toggleTakenOn(date);
    await _persist();
    notifyListeners();
  }

  List<Medication> medicationsForDate(DateTime date) {
    // Current Stitch schedule is daily recurrence; date is used for completion/today filtering.
    return [..._medications]..sort((a, b) => a.reminderMinutes.compareTo(b.reminderMinutes));
  }

  int takenCountForDate(DateTime date) =>
      medicationsForDate(date).where((m) => m.isTakenOn(date)).length;

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_medications.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  void _sortByReminder() {
    _medications.sort((a, b) => a.reminderMinutes.compareTo(b.reminderMinutes));
  }
}
