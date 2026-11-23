import 'dart:async';
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
  static const String _prepaidWordKey = 'prepaid_lookup_word';
  static const String _prepaidTimestampKey = 'prepaid_lookup_ts';
  static const int _dailyLimit = 3;
  static const int _ratingTriggerCount = 5;

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final StreamController<bool> _premiumController =
      StreamController<bool>.broadcast();

  /// Emits whenever [setPremium] or [reload] updates the premium flag.
  Stream<bool> get premiumStream => _premiumController.stream;

  bool _isPremium = false;
  int _availableSearches = 0;
  String? _appUserId;

  Future<void> init(String appUserId) async {
    _prefs = await SharedPreferences.getInstance();
    // Premium was previously memory-only, so a cold start (and the overlay's
    // separate Flutter engine, which never runs SubscriptionService) always
    // saw isPremium == false. Seed from the cached value; RevenueCat still
    // overwrites it with the authoritative entitlement as soon as it responds.
    _isPremium = _prefs?.getBool(_premiumKey) ?? false;
    await _checkDailyReset(appUserId);
  }

  /// Re-reads persisted quota and premium status from storage (e.g., when
  /// returning to the main app after using the floating overlay or QuickDefine).
  Future<void> reload() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    try {
      await prefs.reload();
    } catch (_) {}
    final newPremium = prefs.getBool(_premiumKey) ?? false;
    if (newPremium != _isPremium) {
      _isPremium = newPremium;
      _premiumController.add(_isPremium);
    }
    await _checkDailyReset(_appUserId ?? 'anonymous');
  }

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
        await _secureStorage.write(
          key: searchKey,
          value: _dailyLimit.toString(),
        );
        _availableSearches = _dailyLimit;
      } else {
        _availableSearches = int.tryParse(searchesStr) ?? 0;
      }
    }
  }

  bool get isPremium => _isPremium;

  Future<void> setPremium(bool value) async {
    _isPremium = value;
    // Cache it so the overlay engine and the next cold start know, before
    // RevenueCat has had a chance to answer. The entitlement remains the
    // source of truth — this is only a cache.
    await _prefs?.setBool(_premiumKey, value);
    _premiumController.add(value);
  }

  int get availableSearches {
    if (isPremium) return 999;
    return _availableSearches;
  }

  /// Marks [word] as already paid for (e.g., when QuickDefineSheet consumed a
  /// search and the user immediately taps "More detail →" to open the full app)
  /// so the full app does not double-charge for the same lookup.
  Future<void> markPrepaidLookup(String word) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(_prepaidWordKey, word.trim().toLowerCase());
    await prefs.setInt(
      _prepaidTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Returns true if [word] was prepaid within the last 60 seconds, and clears
  /// the prepaid marker so it can only be redeemed once.
  Future<bool> consumePrepaidIfMatching(String? word) async {
    if (word == null || word.trim().isEmpty) return false;
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    try {
      await prefs.reload();
    } catch (_) {}
    final prepaidWord = prefs.getString(_prepaidWordKey);
    final prepaidTs = prefs.getInt(_prepaidTimestampKey) ?? 0;
    if (prepaidWord == null) return false;

    final ageMs = DateTime.now().millisecondsSinceEpoch - prepaidTs;
    if (prepaidWord == word.trim().toLowerCase() &&
        ageMs >= 0 &&
        ageMs <= 60000) {
      await prefs.remove(_prepaidWordKey);
      await prefs.remove(_prepaidTimestampKey);
      return true;
    }
    return false;
  }

  Future<void> consumeSearch({String? word}) async {
    if (isPremium) return;
    if (await consumePrepaidIfMatching(word)) return;

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
