import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quotaServiceProvider = Provider<QuotaService>((ref) => QuotaService());

class QuotaService {
  static const String _dateKey = 'last_search_date';
  static const String _searchesKey = 'available_searches';
  static const String _premiumKey = 'is_premium';
  static const String _totalSearchCountKey = 'total_search_count';
  static const String _ratingShownKey = 'rating_shown';
  static const int _dailyLimit = 3;
  static const int _ratingTriggerCount = 5;

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _checkDailyReset();
  }

  void _checkDailyReset() {
    if (_prefs == null) return;
    if (isPremium) return; // Premium users have unlimited searches

    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = _prefs!.getString(_dateKey);

    if (lastDate != today) {
      _prefs!.setString(_dateKey, today);
      _prefs!.setInt(_searchesKey, _dailyLimit);
    } else {
      if (!_prefs!.containsKey(_searchesKey)) {
        _prefs!.setInt(_searchesKey, _dailyLimit);
      }
    }
  }

  bool get isPremium => _prefs?.getBool(_premiumKey) ?? false;

  Future<void> setPremium(bool value) async {
    await _prefs?.setBool(_premiumKey, value);
  }

  int get availableSearches {
    if (isPremium) return 999;
    return _prefs?.getInt(_searchesKey) ?? 0;
  }

  Future<void> consumeSearch() async {
    if (_prefs == null || isPremium) return;
    int current = availableSearches;
    if (current > 0) {
      await _prefs!.setInt(_searchesKey, current - 1);
    }
  }

  Future<void> addBonusSearches(int amount) async {
    if (_prefs == null || isPremium) return;
    int current = _prefs!.getInt(_searchesKey) ?? 0;
    await _prefs!.setInt(_searchesKey, current + amount);
  }

  /// Increments lifetime search count. Returns true if this is the trigger
  /// search (5th) and the prompt hasn't been shown yet.
  Future<bool> incrementAndCheckRating() async {
    final prefs = _prefs;
    if (prefs == null) return false;

    final alreadyShown = prefs.getBool(_ratingShownKey) ?? false;
    if (alreadyShown) return false;

    final count = (prefs.getInt(_totalSearchCountKey) ?? 0) + 1;
    await prefs.setInt(_totalSearchCountKey, count);

    if (count == _ratingTriggerCount) {
      await prefs.setBool(_ratingShownKey, true);
      return true;
    }
    return false;
  }
}
