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
  bool _isPurchasing = false;

  Future<void> _purchase(StoreProduct? product) async {
    if (product == null || _isPurchasing) return;
    setState(() => _isPurchasing = true);
    try {
      final success = await ref.read(subscriptionServiceProvider).purchase(product);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed or cancelled.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    await ref.read(subscriptionServiceProvider).restorePurchases();
    if (mounted) setState(() => _isPurchasing = false);
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(subscriptionServiceProvider);
    // Play Billing subscriptions v2 (base plans) can return the identifier as
    // either the bare product ID or `productId:basePlanId` — match either form.
    final monthly = service.products
        .where((p) => p.identifier.startsWith(kMonthlySubId))
        .firstOrNull;
    final yearly = service.products
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
                // Annual — highlighted
                _PlanCard(
                  label: 'Annual',
                  badge: 'Best Value · Save 37%',
                  price: yearly?.priceString ?? '\$29.99',
                  detail: 'billed yearly · cancel anytime',
                  isHighlighted: true,
                  onTap: _isPurchasing ? null : () => _purchase(yearly),
                  isLoading: _isPurchasing,
                ),
                const SizedBox(height: 12),
                _PlanCard(
                  label: 'Monthly',
                  price: monthly?.priceString ?? '\$3.99',
                  detail: 'per month · cancel anytime',
                  isHighlighted: false,
                  onTap: _isPurchasing ? null : () => _purchase(monthly),
                  isLoading: false,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cancel anytime · Billed via Google Play',
                  style: TextStyle(color: context.colors.inkSoft, fontSize: 11),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _isPurchasing ? null : _restore,
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

const _features = [
  (CupertinoIcons.bolt_fill, 'Unlimited searches, every day'),
  (CupertinoIcons.book_fill, 'Unlimited word library'),
  (CupertinoIcons.square_stack_fill, 'Floating overlay search — from any app'),
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
