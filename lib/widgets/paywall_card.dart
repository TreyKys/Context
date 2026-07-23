import '../theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ad_service.dart';
import '../providers/vibe_provider.dart';
import '../screens/subscription_screen.dart';

class PaywallCard extends ConsumerStatefulWidget {
  const PaywallCard({super.key});

  @override
  ConsumerState<PaywallCard> createState() => _PaywallCardState();
}

class _PaywallCardState extends ConsumerState<PaywallCard> {
  bool _isLoadingQuick = false;
  bool _isLoadingSuper = false;

  void _handleQuickCharge() async {
    if (_isLoadingQuick || _isLoadingSuper) return;
    setState(() => _isLoadingQuick = true);

    final adService = ref.read(adServiceProvider);
    await adService.watchOneAd(
      onCompleted: () {
        if (mounted) setState(() => _isLoadingQuick = false);
        _clearQuotaLock();
      },
      onFailed: () {
        if (mounted) {
          setState(() => _isLoadingQuick = false);
          _showError('Failed to load ad. Please try again.');
        }
      },
    );
  }

  void _handleSuperCharge() async {
    if (_isLoadingQuick || _isLoadingSuper) return;
    setState(() => _isLoadingSuper = true);

    final adService = ref.read(adServiceProvider);
    await adService.watchTwoAdsForThree(
      onCompleted: () {
        if (mounted) setState(() => _isLoadingSuper = false);
        _clearQuotaLock();
      },
      onFailed: () {
        if (mounted) {
          setState(() => _isLoadingSuper = false);
          _showError('Failed to load ad. Please try again.');
        }
      },
      onFallback: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Second ad failed. Awarded 1 search for the first ad.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      },
    );
  }

  void _clearQuotaLock() {
    ref.read(vibeProvider.notifier).checkQuotaLock();
    ref.read(directSearchProvider.notifier).checkQuotaLock();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _openSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: context.colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.colors.ink.withValues(alpha: 0.06),
            blurRadius: 18.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.lock_shield_fill, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            'Neural Link Depleted',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.ink,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ve used your 3 free searches today.\nRecharge with an ad, or go unlimited.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.inkSoft, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Go Premium — primary CTA
          _buildPremiumButton(),
          const SizedBox(height: 16),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: context.colors.inkSoft)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or watch an ad',
                  style: TextStyle(color: context.colors.inkSoft, fontSize: 11),
                ),
              ),
              Expanded(child: Divider(color: context.colors.inkSoft)),
            ],
          ),
          const SizedBox(height: 16),

          _buildChargeButton(
            title: 'Quick Charge',
            subtitle: 'Watch 1 Ad → +1 Search',
            isLoading: _isLoadingQuick,
            onTap: _handleQuickCharge,
            colors: [context.colors.surfaceAlt, context.colors.surfaceAlt],
            borderColor: Colors.redAccent.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          _buildChargeButton(
            title: 'Super Charge',
            subtitle: 'Watch 2 Ads → +3 Searches',
            isLoading: _isLoadingSuper,
            onTap: _handleSuperCharge,
            colors: [context.colors.surfaceAlt, context.colors.surfaceAlt],
            borderColor: Colors.redAccent.withValues(alpha: 0.4),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildPremiumButton() {
    return InkWell(
      onTap: _openSubscription,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [context.colors.accent, context.colors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.accent.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.bolt_fill, color: context.colors.ink, size: 16),
                SizedBox(width: 6),
                Text(
                  'Go Premium — Unlimited',
                  style: TextStyle(
                    color: context.colors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'From \$4.99/month · No ads · Full library',
              style: TextStyle(color: context.colors.ink.withValues(alpha: 0.75), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargeButton({
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback onTap,
    required List<Color> colors,
    required Color borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colors[0],
          border: Border.all(color: borderColor),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: context.colors.accent2,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    title.contains('Quick')
                        ? CupertinoIcons.play_circle
                        : CupertinoIcons.play_circle_fill,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.colors.inkSoft, fontSize: 11),
                      ),
                    ],
                  ),
                  ),
                ],
              ),
      ),
    );
  }
}
