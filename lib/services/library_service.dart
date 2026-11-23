import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/saved_word.dart';
import '../models/vibe_result.dart';

class LibraryService {
  static final LibraryService _instance = LibraryService._internal();
  factory LibraryService() => _instance;
  LibraryService._internal();

  static const int _freeTierLimit = 10;
  static const String _kPrefsFallbackKey = 'context_library_fallback_v1';
  Database? _db;

  Future<void> init() async {
    if (kIsWeb) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'context_library.db');
    try {
      _db = await _open(path);
    } catch (e) {
      // The on-device DB is a local cache. If it can't be opened (e.g. a
      // corrupt or incompatible file left over from an older schema), delete
      // it and start clean rather than blocking the Library screen.
      debugPrint('LibraryService: recreating DB after open error: $e');
      try {
        await deleteDatabase(path);
      } catch (_) {}
      _db = await _open(path);
    }
  }

  Future<Database> _open(String path) {
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE saved_words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            literal_definition TEXT NOT NULL,
            vibe_translation TEXT NOT NULL,
            example_sentence TEXT NOT NULL,
            tags_json TEXT NOT NULL,
            is_direct_search INTEGER NOT NULL DEFAULT 0,
            is_verified INTEGER NOT NULL DEFAULT 0,
            saved_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_saved_words_word ON saved_words(word);
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // v1 → v2: drop the legacy FTS5 virtual table and its triggers, which
        // crashed on devices without the fts5 module. Search now uses LIKE.
        await db.execute('DROP TRIGGER IF EXISTS saved_words_ai');
        await db.execute('DROP TRIGGER IF EXISTS saved_words_ad');
        await db.execute('DROP TRIGGER IF EXISTS saved_words_au');
        await db.execute('DROP TABLE IF EXISTS saved_words_fts');
      },
    );
  }

  Future<List<SavedWord>> _loadPrefsFallback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_kPrefsFallbackKey) ?? const <String>[];
      final items = raw
          .map(
            (s) => SavedWord.fromMap(
              Map<String, dynamic>.from(jsonDecode(s) as Map),
            ),
          )
          .toList();
      items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> _savePrefsFallback(List<SavedWord> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = items.map((w) => jsonEncode(w.toMap())).toList();
    await prefs.setStringList(_kPrefsFallbackKey, encoded);
  }

  Future<List<SavedWord>> getSavedWords() async {
    final db = _db;
    if (db == null) return _loadPrefsFallback();
    try {
      final maps = await db.query('saved_words', orderBy: 'saved_at DESC');
      return maps.map(SavedWord.fromMap).toList();
    } catch (e) {
      debugPrint('LibraryService.getSavedWords failed: $e');
      return [];
    }
  }

  Future<List<SavedWord>> searchLibrary(String query) async {
    final db = _db;
    final q = query.trim();
    if (q.isEmpty) return getSavedWords();
    if (db == null) {
      final lower = q.toLowerCase();
      final all = await _loadPrefsFallback();
      return all
          .where(
            (w) =>
                w.word.toLowerCase().contains(lower) ||
                w.literalDefinition.toLowerCase().contains(lower) ||
                w.vibeTranslation.toLowerCase().contains(lower) ||
                w.tags.any((t) => t.toLowerCase().contains(lower)),
          )
          .toList();
    }
    // Plain LIKE search across the saved fields. No FTS5 module required, so it
    // works on every device. The library is small, so performance is a non-issue.
    final like =
        '%${q.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_')}%';
    try {
      final maps = await db.rawQuery(
        '''
        SELECT * FROM saved_words
        WHERE word LIKE ? ESCAPE '\\'
           OR literal_definition LIKE ? ESCAPE '\\'
           OR vibe_translation LIKE ? ESCAPE '\\'
           OR tags_json LIKE ? ESCAPE '\\'
        ORDER BY saved_at DESC
      ''',
        [like, like, like, like],
      );
      return maps.map(SavedWord.fromMap).toList();
    } catch (e) {
      debugPrint('LibraryService.searchLibrary failed: $e');
      return [];
    }
  }

  Future<bool> isWordSaved(String word) async {
    final db = _db;
    if (db == null) {
      final lower = word.trim().toLowerCase();
      final all = await _loadPrefsFallback();
      return all.any((w) => w.word.toLowerCase() == lower);
    }
    final result = await db.query(
      'saved_words',
      where: 'LOWER(word) = LOWER(?)',
      whereArgs: [word.trim()],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> getSavedCount() async {
    final db = _db;
    if (db == null) {
      final all = await _loadPrefsFallback();
      return all.length;
    }
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM saved_words',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Returns null on success, or an error string if limit exceeded.
  Future<String?> saveWord(
    VibeResult result,
    String word, {
    required bool isPremium,
  }) async {
    final db = _db;

    if (!isPremium) {
      final count = await getSavedCount();
      if (count >= _freeTierLimit) {
        return 'library_limit';
      }
    }

    // Don't save duplicates
    if (await isWordSaved(word)) return null;

    if (db == null) {
      final all = await _loadPrefsFallback();
      final nextId =
          all.fold<int>(0, (m, w) => (w.id ?? 0) > m ? (w.id ?? 0) : m) + 1;
      all.insert(
        0,
        SavedWord(
          id: nextId,
          word: word.trim(),
          literalDefinition: result.literalDefinition,
          vibeTranslation: result.vibeTranslation,
          exampleSentence: result.exampleSentence,
          tags: result.tags,
          isDirectSearch: result.isDirectSearch,
          isVerified: result.isVerified,
          savedAt: DateTime.now(),
        ),
      );
      await _savePrefsFallback(all);
      return null;
    }

    final saved = SavedWord(
      word: word.trim(),
      literalDefinition: result.literalDefinition,
      vibeTranslation: result.vibeTranslation,
      exampleSentence: result.exampleSentence,
      tags: result.tags,
      isDirectSearch: result.isDirectSearch,
      isVerified: result.isVerified,
      savedAt: DateTime.now(),
    );

    await db.insert('saved_words', saved.toMap());
    return null;
  }

  Future<void> deleteWord(int id) async {
    final db = _db;
    if (db == null) {
      final all = await _loadPrefsFallback();
      all.removeWhere((w) => w.id == id);
      await _savePrefsFallback(all);
      return;
    }
    await db.delete('saved_words', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByWord(String word) async {
    final db = _db;
    if (db == null) {
      final lower = word.trim().toLowerCase();
      final all = await _loadPrefsFallback();
      all.removeWhere((w) => w.word.toLowerCase() == lower);
      await _savePrefsFallback(all);
      return;
    }
    await db.delete(
      'saved_words',
      where: 'LOWER(word) = LOWER(?)',
      whereArgs: [word.trim()],
    );
  }
}
