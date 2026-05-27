import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/subscription_service.dart';
import '../services/quota_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>(
  (ref) => SubscriptionService(),
);

final isPremiumProvider = StreamProvider<bool>((ref) {
  final quotaService = ref.watch(quotaServiceProvider);
  final subscriptionService = ref.watch(subscriptionServiceProvider);

  // Emit current value immediately, then listen for changes
  return subscriptionService.premiumStatusStream
      .map((_) => quotaService.isPremium);
});
