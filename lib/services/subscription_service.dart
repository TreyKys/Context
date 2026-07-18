import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/quota_service.dart';

const String kMonthlySubId = 'context_monthly_sub';
const String kLifetimeSubId = 'context_lifetime_unlock';

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

  Future<void> init(QuotaService quotaService) async {
    _quotaService = quotaService;

    try {
      const apiKey = kRevenueCatApiKey;
      if (apiKey.isNotEmpty) {
        if (kDebugMode) {
          await Purchases.setLogLevel(LogLevel.debug);
        }

        PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
        await Purchases.configure(configuration);

        await _checkEntitlements();

        Purchases.addCustomerInfoUpdateListener((customerInfo) async {
          await _updatePremiumStatus(customerInfo);
        });

        await _loadProducts();
      }
    } catch (e) {
      // Fail silently if setup fails
    }
  }

  Future<void> _loadProducts() async {
    try {
       Offerings offerings = await Purchases.getOfferings();
       if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
          _products = offerings.current!.availablePackages.map((p) => p.storeProduct).toList();
       }
    } catch (e) {
       // Log error
    }
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
