import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _kHistoryKey = 'search_history';
const int _kMaxHistory = 20;

class HistoryEntry {
  final String word;
  final String mode;
  final String persona;
  final bool isDirectSearch;
  final DateTime timestamp;

  HistoryEntry({
    required this.word,
    required this.mode,
    required this.persona,
    required this.isDirectSearch,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'mode': mode,
    'persona': persona,
    'isDirect': isDirectSearch,
    'ts': timestamp.toIso8601String(),
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
    word: j['word'] as String,
    mode: j['mode'] as String? ?? 'Define',
    persona: j['persona'] as String? ?? '',
    isDirectSearch: j['isDirect'] as bool? ?? false,
    timestamp: DateTime.parse(j['ts'] as String),
  );
}

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<HistoryEntry> getHistory() {
    final raw = _prefs?.getStringList(_kHistoryKey) ?? [];
    return raw
        .map((s) {
          try {
            return HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<HistoryEntry>()
        .toList();
  }

  Future<void> addEntry(HistoryEntry entry) async {
    final prefs = _prefs;
    if (prefs == null) return;

    final existing = getHistory();
    // Remove duplicate word
    existing.removeWhere((e) => e.word.toLowerCase() == entry.word.toLowerCase());
    existing.insert(0, entry);

    // Keep only last N entries
    final trimmed = existing.take(_kMaxHistory).toList();
    await prefs.setStringList(
      _kHistoryKey,
      trimmed.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> clearHistory() async {
    await _prefs?.remove(_kHistoryKey);
  }
}
