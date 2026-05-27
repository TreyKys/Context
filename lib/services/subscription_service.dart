import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/quota_service.dart';

const String kMonthlySubId = 'context_monthly_sub';
const String kLifetimeSubId = 'context_lifetime_unlock';

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
      final apiKey = dotenv.env['REVENUECAT_API_KEY'];
      if (apiKey != null && apiKey.isNotEmpty) {
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
