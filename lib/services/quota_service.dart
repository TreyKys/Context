import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isPremium = false;
  int _availableSearches = 0;

  Future<void> init(String appUserId) async {
    _prefs = await SharedPreferences.getInstance();
    await _checkDailyReset(appUserId);
  }

  String? _appUserId;

  Future<void> _checkDailyReset(String appUserId) async {
    _appUserId = appUserId;
    if (isPremium) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final keySuffix = _appUserId ?? 'anonymous';
    final dateKey = '${_dateKey}_$keySuffix';
    final searchKey = '${_searchesKey}_$keySuffix';

    final lastDate = await _secureStorage.read(key: dateKey);
    final searchesStr = await _secureStorage.read(key: searchKey);

    if (lastDate != today) {
      await _secureStorage.write(key: dateKey, value: today);
      await _secureStorage.write(key: searchKey, value: _dailyLimit.toString());
      _availableSearches = _dailyLimit;
    } else {
      if (searchesStr == null) {
        await _secureStorage.write(key: searchKey, value: _dailyLimit.toString());
        _availableSearches = _dailyLimit;
      } else {
        _availableSearches = int.tryParse(searchesStr) ?? 0;
      }
    }
  }

  bool get isPremium => _isPremium;

  Future<void> setPremium(bool value) async {
    _isPremium = value;
  }

  int get availableSearches {
    if (isPremium) return 999;
    return _availableSearches;
  }

  Future<void> consumeSearch() async {
    if (isPremium) return;
    int current = availableSearches;
    final keySuffix = _appUserId ?? 'anonymous';
    final searchKey = '${_searchesKey}_$keySuffix';

    if (current > 0) {
      current -= 1;
      _availableSearches = current;
      await _secureStorage.write(key: searchKey, value: current.toString());
    }
  }

  Future<void> addBonusSearches(int amount) async {
    if (isPremium) return;
    int current = availableSearches;
    current += amount;
    _availableSearches = current;
    final keySuffix = _appUserId ?? 'anonymous';
    final searchKey = '${_searchesKey}_$keySuffix';

    await _secureStorage.write(key: searchKey, value: current.toString());
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
