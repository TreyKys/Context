import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/saved_word.dart';
import '../models/vibe_result.dart';

class LibraryService {
  static final LibraryService _instance = LibraryService._internal();
  factory LibraryService() => _instance;
  LibraryService._internal();

  static const int _freeTierLimit = 10;
  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'context_library.db');

    _db = await openDatabase(
      path,
      version: 1,
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
    );
  }

  Future<List<SavedWord>> getSavedWords() async {
    final db = _db;
    if (db == null) return [];
    final maps = await db.query('saved_words', orderBy: 'saved_at DESC');
    return maps.map(SavedWord.fromMap).toList();
  }

  Future<List<SavedWord>> searchLibrary(String query) async {
    final db = _db;
    if (db == null) return [];
    final q = query.trim();
    if (q.isEmpty) return getSavedWords();
    // Plain LIKE search across the saved fields. No FTS5 module required, so it
    // works on every device. The library is small, so performance is a non-issue.
    final like = '%${q.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_')}%';
    final maps = await db.rawQuery('''
      SELECT * FROM saved_words
      WHERE word LIKE ? ESCAPE '\\'
         OR literal_definition LIKE ? ESCAPE '\\'
         OR vibe_translation LIKE ? ESCAPE '\\'
         OR tags_json LIKE ? ESCAPE '\\'
      ORDER BY saved_at DESC
    ''', [like, like, like, like]);
    return maps.map(SavedWord.fromMap).toList();
  }

  Future<bool> isWordSaved(String word) async {
    final db = _db;
    if (db == null) return false;
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
    if (db == null) return 0;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM saved_words');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Returns null on success, or an error string if limit exceeded.
  Future<String?> saveWord(
    VibeResult result,
    String word, {
    required bool isPremium,
  }) async {
    final db = _db;
    if (db == null) return 'Library unavailable.';

    if (!isPremium) {
      final count = await getSavedCount();
      if (count >= _freeTierLimit) {
        return 'library_limit';
      }
    }

    // Don't save duplicates
    if (await isWordSaved(word)) return null;

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
    await _db?.delete('saved_words', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByWord(String word) async {
    await _db?.delete(
      'saved_words',
      where: 'LOWER(word) = LOWER(?)',
      whereArgs: [word.trim()],
    );
  }
}
