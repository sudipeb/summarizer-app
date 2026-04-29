import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class HistoryRecord {
  HistoryRecord({
    required this.title,
    required this.query,
    required this.answer,
    required this.createdAt,
  });

  final String title;
  final String query;
  final String answer;
  final DateTime createdAt;

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      title: (json['title'] as String?) ?? '',
      query: (json['query'] as String?) ?? '',
      answer: (json['answer'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory HistoryRecord.fromStoredValue(String storedValue) {
    try {
      final decoded = jsonDecode(storedValue);
      if (decoded is Map<String, dynamic>) {
        return HistoryRecord.fromJson(decoded);
      }
    } catch (_) {}

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
  static const String _boxName = 'history';
  static Box<String>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _historyBox {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    throw StateError('HistoryService not initialized. Call init() first.');
  }

  static Future<void> addEntry({
    required String title,
    required String query,
    required String answer,
  }) async {
    if (title.trim().isEmpty && query.trim().isEmpty && answer.trim().isEmpty) {
      return;
    }

    final record = HistoryRecord(
      title: title.trim(),
      query: query.trim(),
      answer: answer.trim(),
      createdAt: DateTime.now(),
    );

    await _historyBox.add(jsonEncode(record.toJson()));
  }

  static List<HistoryRecord> getAllEntries() {
    try {
      return _historyBox.values.map(HistoryRecord.fromStoredValue).toList();
    } catch (_) {
      return <HistoryRecord>[];
    }
  }

  static Future<void> clear() async {
    try {
      await _historyBox.clear();
    } catch (_) {}
  }
}
