import 'dart:async';
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
final subscriptionProductsProvider = FutureProvider<List<StoreProduct>>((
  ref,
) async {
  return ref.watch(subscriptionServiceProvider).loadProducts();
});

final isPremiumProvider = StreamProvider<bool>((ref) {
  final quotaService = ref.watch(quotaServiceProvider);
  final subscriptionService = ref.watch(subscriptionServiceProvider);

  final controller = StreamController<bool>();
  // Emit current value immediately so consumers never stay stuck in loading
  // when SubscriptionService.init() already ran before runApp().
  controller.add(quotaService.isPremium);

  final sub1 = subscriptionService.premiumStatusStream.listen((_) {
    if (!controller.isClosed) controller.add(quotaService.isPremium);
  });
  final sub2 = quotaService.premiumStream.listen((value) {
    if (!controller.isClosed) controller.add(value);
  });

  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
    controller.close();
  });

  return controller.stream;
});
