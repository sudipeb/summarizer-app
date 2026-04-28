import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class HistoryRecord {
  HistoryRecord({required this.title, required this.query, required this.answer, required this.createdAt});

  final String title;
  final String query;
  final String answer;
  final DateTime createdAt;

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      title: (json['title'] as String?) ?? '',
      query: (json['query'] as String?) ?? '',
      answer: (json['answer'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory HistoryRecord.fromStoredValue(String storedValue) {
    try {
      final decoded = jsonDecode(storedValue);
      if (decoded is Map<String, dynamic>) {
        return HistoryRecord.fromJson(decoded);
      }
    } catch (_) {
      // Backward compatibility for old title-only entries.
    }

    return HistoryRecord(
      title: storedValue,
      query: storedValue,
      answer: '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'query': query,
      'answer': answer,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class HistoryService {
  static const _boxName = 'history';

  /// Initialize Hive and open the history box.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
  }

  static Future<Box<String>> _ensureBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }

    return Hive.openBox<String>(_boxName);
  }

  /// Add a full query/answer entry to history.
  static Future<void> addEntry({required String title, required String query, required String answer}) async {
    if (title.trim().isEmpty && query.trim().isEmpty && answer.trim().isEmpty) return;
    final box = await _ensureBox();
    final record = HistoryRecord(
      title: title.trim(),
      query: query.trim(),
      answer: answer.trim(),
      createdAt: DateTime.now(),
    );
    await box.add(jsonEncode(record.toJson()));
  }

  /// Get all history records in insertion order.
  static List<HistoryRecord> getAllEntries() {
    if (!Hive.isBoxOpen(_boxName)) return <HistoryRecord>[];
    final box = Hive.box<String>(_boxName);
    return box.values.map(HistoryRecord.fromStoredValue).toList();
  }

  /// Clear all history entries.
  static Future<void> clear() async {
    if (!Hive.isBoxOpen(_boxName)) return;
    final box = Hive.box<String>(_boxName);
    await box.clear();
  }
}
