import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quotaServiceProvider = Provider<QuotaService>((ref) => QuotaService());

class QuotaService {
  static const String _dateKey = 'last_search_date';
  static const String _searchesKey = 'available_searches';
  static const int _dailyLimit = 3;

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _checkDailyReset();
  }

  void _checkDailyReset() {
    if (_prefs == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = _prefs!.getString(_dateKey);

    if (lastDate != today) {
      _prefs!.setString(_dateKey, today);
      _prefs!.setInt(_searchesKey, _dailyLimit);
    } else {
      // Ensure the key exists even if it's the same day but somehow missing
      if (!_prefs!.containsKey(_searchesKey)) {
        _prefs!.setInt(_searchesKey, _dailyLimit);
      }
    }
  }

  int get availableSearches {
    return _prefs?.getInt(_searchesKey) ?? 0;
  }

  Future<void> consumeSearch() async {
    if (_prefs == null) return;
    int current = availableSearches;
    if (current > 0) {
      await _prefs!.setInt(_searchesKey, current - 1);
    }
  }

  Future<void> addBonusSearches(int amount) async {
    if (_prefs == null) return;
    int current = availableSearches;
    await _prefs!.setInt(_searchesKey, current + amount);
  }
}
