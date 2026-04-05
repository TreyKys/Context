import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ad_service.dart';
import '../providers/vibe_provider.dart'; // To clear quota lock if needed

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
            const SnackBar(
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C10), // Obsidian
        borderRadius: BorderRadius.circular(32), // Heavily rounded
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 15.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.redAccent,
            blurRadius: 8.0,
            spreadRadius: 0.0,
          ),
          const BoxShadow(
            color: Colors.amber, // Subtle gold glow
            blurRadius: 16.0,
            spreadRadius: -4.0,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.lock_shield_fill,
            color: Colors.redAccent,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Neural Link Depleted\n(0 Searches Left)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The network requires more bandwidth. Recharge your connection.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          _buildChargeButton(
            title: 'Quick Charge',
            subtitle: '(Watch 1 Ad = +1 Search)',
            isLoading: _isLoadingQuick,
            onTap: _handleQuickCharge,
            colors: const [Colors.redAccent, Colors.red],
          ),
          const SizedBox(height: 16),
          _buildChargeButton(
            title: 'Super Charge',
            subtitle: '(Watch 2 Ads = +3 Searches)',
            isLoading: _isLoadingSuper,
            onTap: _handleSuperCharge,
            colors: const [Colors.redAccent, Colors.red],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildChargeButton({
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback onTap,
    required List<Color> colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.cyanAccent,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
