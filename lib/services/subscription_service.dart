import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/quota_service.dart';

const String kMonthlySubId = 'context_monthly_sub';
const String kYearlySubId = 'context_yearly_sub';

/// RevenueCat public SDK key (Android, starts with `goog_`). It is a
/// publishable key, but we still supply it at build time rather than commit it:
///   flutter build appbundle --dart-define=REVENUECAT_API_KEY=goog_XXXXXXXX
const String kRevenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  QuotaService? _quotaService;

  final StreamController<bool> _premiumStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  List<StoreProduct> _products = [];
  List<StoreProduct> get products => _products;

  /// False when no RevenueCat key was supplied at build time — the paywall
  /// can't function at all in that case, and should say so rather than
  /// rendering dead buttons.
  bool get isConfigured => kRevenueCatApiKey.isNotEmpty;

  bool _configured = false;

  Future<void> init(QuotaService quotaService) async {
    _quotaService = quotaService;

    try {
      const apiKey = kRevenueCatApiKey;
      if (apiKey.isNotEmpty) {
        if (kDebugMode) {
          await Purchases.setLogLevel(LogLevel.debug);
        }

        if (!_configured) {
          PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
          await Purchases.configure(configuration);
          _configured = true;
        }

        await _checkEntitlements();

        Purchases.addCustomerInfoUpdateListener((customerInfo) async {
          await _updatePremiumStatus(customerInfo);
        });

        await loadProducts();
      }
    } catch (e) {
      debugPrint('SubscriptionService init failed: $e');
    }
  }

  /// Fetches the current offering's products. Throws on failure so the paywall
  /// can show a real error with a retry, instead of silently rendering buttons
  /// that do nothing when tapped.
  Future<List<StoreProduct>> loadProducts() async {
    if (!isConfigured) {
      throw StateError(
        'Store unavailable — the app was built without a RevenueCat key.',
      );
    }
    // init() may not have run yet (or may have failed) when the paywall is
    // opened; make sure the SDK is configured before asking for offerings.
    if (!_configured) {
      await Purchases.configure(PurchasesConfiguration(kRevenueCatApiKey));
      _configured = true;
    }

    final Offerings offerings = await Purchases.getOfferings();
    final packages = offerings.current?.availablePackages ?? const [];
    if (packages.isEmpty) {
      throw StateError(
        'No subscriptions are available right now. This usually means the '
        'RevenueCat offering has no packages, or the Play products are not '
        'active yet.',
      );
    }
    _products = packages.map((p) => p.storeProduct).toList();
    return _products;
  }

  Future<void> _checkEntitlements() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      await _updatePremiumStatus(customerInfo);
    } catch (e) {
       // Log error
    }
  }

  Future<void> _updatePremiumStatus(CustomerInfo customerInfo) async {
     final isPremium = customerInfo.entitlements.active.containsKey("pro_fluency");
     await _quotaService?.setPremium(isPremium);
     _premiumStatusController.add(isPremium);
  }

  Future<bool> purchase(StoreProduct product) async {
    try {
      PurchaseResult result = await Purchases.purchaseStoreProduct(product);
      CustomerInfo customerInfo = result.customerInfo;
      final success = customerInfo.entitlements.active.containsKey("pro_fluency");
      if (success) {
        await _updatePremiumStatus(customerInfo);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      final success = customerInfo.entitlements.active.containsKey("pro_fluency");
      if (success) {
        await _updatePremiumStatus(customerInfo);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _premiumStatusController.close();
  }
}
