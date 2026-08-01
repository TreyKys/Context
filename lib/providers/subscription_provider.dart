import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/subscription_service.dart';
import '../services/quota_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>(
  (ref) => SubscriptionService(),
);

/// The purchasable products, as a real async value.
///
/// The paywall previously read `service.products` directly off a plain
/// Provider. That list is filled in asynchronously by init(), and watching a
/// Provider whose object identity never changes produces no rebuild — so if
/// the offering hadn't loaded by the time the screen built, the plan buttons
/// stayed permanently inert. Fetching through a FutureProvider gives the UI
/// genuine loading/error/data states and something to retry.
final subscriptionProductsProvider =
    FutureProvider<List<StoreProduct>>((ref) async {
  return ref.watch(subscriptionServiceProvider).loadProducts();
});

final isPremiumProvider = StreamProvider<bool>((ref) {
  final quotaService = ref.watch(quotaServiceProvider);
  final subscriptionService = ref.watch(subscriptionServiceProvider);

  // Emit current value immediately, then listen for changes
  return subscriptionService.premiumStatusStream
      .map((_) => quotaService.isPremium);
});
