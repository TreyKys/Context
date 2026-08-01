import '../theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/subscription_service.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  /// Identifier of the product currently being purchased, or null.
  /// Tracked per-product rather than as a single bool so the spinner appears on
  /// the card the user actually tapped — previously tapping Monthly spun the
  /// Annual card.
  String? _purchasingId;
  bool _restoring = false;

  bool get _busy => _purchasingId != null || _restoring;

  void _toast(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? context.colors.accent : Colors.redAccent,
      ),
    );
  }

  Future<void> _purchase(StoreProduct? product) async {
    if (_busy) return;
    if (product == null) {
      // Previously a silent `return` — the button simply did nothing and the
      // user had no idea why.
      _toast('That plan isn\'t available right now. Please try again.');
      return;
    }
    setState(() => _purchasingId = product.identifier);
    try {
      final success =
          await ref.read(subscriptionServiceProvider).purchase(product);
      if (!mounted) return;
      if (success) {
        // Make the entitlement change visible immediately rather than waiting
        // for the next stream tick, then confirm it to the user.
        ref.invalidate(isPremiumProvider);
        _toast('You\'re Premium ⚡ Enjoy unlimited searches.', success: true);
      } else {
        _toast('Purchase failed or cancelled.');
      }
    } catch (_) {
      _toast('Purchase failed. Please try again.');
    } finally {
      if (mounted) setState(() => _purchasingId = null);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _restoring = true);
    try {
      final restored =
          await ref.read(subscriptionServiceProvider).restorePurchases();
      if (!mounted) return;
      if (restored) {
        ref.invalidate(isPremiumProvider);
        _toast('Purchases restored — Premium is active.', success: true);
      } else {
        // Previously this gave no feedback at all, so a user with nothing to
        // restore just saw the spinner stop and assumed it was broken.
        _toast('No previous purchase found for this Google account.');
      }
    } catch (_) {
      _toast('Couldn\'t reach the store. Please try again.');
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(subscriptionProductsProvider);
    final products = productsAsync.asData?.value ?? const <StoreProduct>[];
    // Play Billing subscriptions v2 (base plans) can return the identifier as
    // either the bare product ID or `productId:basePlanId` — match either form.
    final monthly = products
        .where((p) => p.identifier.startsWith(kMonthlySubId))
        .firstOrNull;
    final yearly = products
        .where((p) => p.identifier.startsWith(kYearlySubId))
        .firstOrNull;

    final isPremium = ref.watch(isPremiumProvider).asData?.value ?? false;

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colors.ink.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CupertinoIcons.xmark, color: context.colors.inkSoft, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Hero
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [context.colors.accent, context.colors.accent2],
                ).createShader(bounds),
                child: Icon(
                  CupertinoIcons.bolt_fill,
                  size: 56,
                  color: context.colors.ink,
                ),
              ).animate().fadeIn(duration: 500.ms).scale(),
              const SizedBox(height: 16),

              if (isPremium) ...[
                Text(
                  'You\'re Premium ⚡',
                  style: TextStyle(
                    color: context.colors.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enjoy unlimited access to everything.',
                  style: TextStyle(color: context.colors.inkSoft, fontSize: 15),
                ),
              ] else ...[
                Text(
                  'Unlock Neural Link\nPremium',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.colors.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Words have context. Now you do too — everywhere.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.colors.inkSoft, fontSize: 14),
                ),
              ],

              const SizedBox(height: 32),

              // Value props
              ..._features.map(
                (f) => _FeatureRow(icon: f.$1, text: f.$2)
                    .animate(delay: (50 * _features.indexOf(f)).ms)
                    .fadeIn()
                    .slideX(begin: -0.05),
              ),

              const SizedBox(height: 32),

              if (!isPremium) ...[
                // Only render plan buttons once the store actually returned
                // products — otherwise show why, with a retry.
                if (productsAsync.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: CircularProgressIndicator(
                      color: context.colors.accent2,
                      strokeWidth: 2,
                    ),
                  )
                else if (productsAsync.hasError)
                  _StoreUnavailable(
                    message: _storeErrorMessage(productsAsync.error),
                    onRetry: () => ref.invalidate(subscriptionProductsProvider),
                  )
                else ...[
                  // Annual — highlighted
                  _PlanCard(
                    label: 'Annual',
                    badge: 'Best Value · Save 37%',
                    price: yearly?.priceString ?? '\$29.99',
                    detail: 'billed yearly · cancel anytime',
                    isHighlighted: true,
                    onTap: _busy ? null : () => _purchase(yearly),
                    isLoading: _purchasingId != null &&
                        _purchasingId == yearly?.identifier,
                  ),
                  const SizedBox(height: 12),
                  _PlanCard(
                    label: 'Monthly',
                    price: monthly?.priceString ?? '\$3.99',
                    detail: 'per month · cancel anytime',
                    isHighlighted: false,
                    onTap: _busy ? null : () => _purchase(monthly),
                    isLoading: _purchasingId != null &&
                        _purchasingId == monthly?.identifier,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cancel anytime · Billed via Google Play',
                    style:
                        TextStyle(color: context.colors.inkSoft, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _busy ? null : _restore,
                  child: Text(
                    'Restore Purchases',
                    style: TextStyle(
                      color: context.colors.inkSoft,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: context.colors.inkSoft,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // NeuroDev Labs footer
              Text(
                'NeuroDev Labs',
                style: TextStyle(
                  color: context.colors.inkSoft,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _storeErrorMessage(Object? error) {
  if (error is StateError) return error.message;
  return 'Couldn\'t reach the store. Check your connection and try again.';
}

class _StoreUnavailable extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _StoreUnavailable({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.exclamationmark_circle,
              color: context.colors.inkSoft, size: 28),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: context.colors.accent.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Try again',
                style: TextStyle(
                  color: context.colors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _features = [
  (CupertinoIcons.bolt_fill, 'Unlimited searches, every day'),
  (CupertinoIcons.book_fill, 'Unlimited word library'),
  (CupertinoIcons.square_stack_fill, 'Unlimited floating-bubble search, any app'),
  (CupertinoIcons.xmark_circle_fill, 'No ads, ever'),
  (CupertinoIcons.heart_fill, 'Support an independent studio'),
];

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              colors: [context.colors.accent, context.colors.accent2],
            ).createShader(b),
            child: Icon(icon, size: 18, color: context.colors.ink),
          ),
          const SizedBox(width: 14),
          Flexible(child: Text(text, style: TextStyle(color: context.colors.ink, fontSize: 14))),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String label;
  final String? badge;
  final String price;
  final String detail;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final bool isLoading;

  const _PlanCard({
    required this.label,
    this.badge,
    required this.price,
    required this.detail,
    required this.isHighlighted,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isHighlighted
              ? LinearGradient(
                  colors: [context.colors.surfaceAlt, context.colors.surfaceAlt],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isHighlighted ? null : context.colors.surface,
          border: Border.all(
            color: isHighlighted
                ? context.colors.accent.withValues(alpha: 0.6)
                : context.colors.border,
            width: isHighlighted ? 1.5 : 1,
          ),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: context.colors.accent2,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: context.colors.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.accent2.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: context.colors.accent2.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  badge!,
                                  style: TextStyle(
                                    color: context.colors.accent2,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detail,
                          style: TextStyle(color: context.colors.inkSoft, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      color: context.colors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
