import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/subscription_provider.dart';
import '../services/quota_service.dart';
import '../services/overlay_service.dart';
import '../services/notification_service.dart';
import '../services/consent_service.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'subscription_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  bool _overlayEnabled = false;
  bool _privacyOptionsRequired = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadOverlayState();
    _loadConsentState();
  }

  Future<void> _loadConsentState() async {
    final required = await ConsentService.instance.isPrivacyOptionsRequired();
    if (mounted) setState(() => _privacyOptionsRequired = required);
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = '${info.version} (${info.buildNumber})');
    }
  }

  Future<void> _loadOverlayState() async {
    final granted = await OverlayService().isPermissionGranted();
    if (mounted) setState(() => _overlayEnabled = granted);
  }

  Future<void> _toggleOverlay(bool value, bool isPremium) async {
    if (!isPremium) {
      _openSubscription();
      return;
    }
    if (value) {
      await OverlayService().requestPermission(context);
      final granted = await OverlayService().isPermissionGranted();
      setState(() => _overlayEnabled = granted);
      if (granted) OverlayService().showOverlay();
    } else {
      OverlayService().hideOverlay();
      setState(() => _overlayEnabled = false);
    }
  }

  void _openSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider).asData?.value ??
        ref.read(quotaServiceProvider).isPremium;

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.back, color: context.colors.ink),
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Subscription Status
          _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: isPremium ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt,
            iconColor: isPremium ? context.colors.accent2 : context.colors.inkSoft,
            title: isPremium ? 'Premium Active' : 'Free Plan',
            subtitle: isPremium
                ? 'Unlimited searches & library'
                : '3 searches/day · Upgrade for unlimited',
            trailing: isPremium
                ? null
                : _PillButton(
                    label: 'Upgrade',
                    onTap: _openSubscription,
                  ),
            onTap: isPremium ? null : _openSubscription,
          ),

          const SizedBox(height: 8),
          _SectionHeader(title: 'Appearance'),
          _ThemeSelector(
            current: ref.watch(themeModeProvider),
            onSelect: (m) => ref.read(themeModeProvider.notifier).set(m),
          ),

          const SizedBox(height: 8),
          _SectionHeader(title: 'Features'),

          // Overlay toggle
          _SettingsTile(
            icon: CupertinoIcons.square_stack_fill,
            iconColor: _overlayEnabled ? context.colors.accent : context.colors.inkSoft,
            title: 'Floating Search Bubble',
            subtitle: isPremium
                ? 'Search from any app without opening Context'
                : 'Premium feature — search from any app',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isPremium)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Premium',
                      style: TextStyle(
                        color: context.colors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Switch(
                  value: _overlayEnabled && isPremium,
                  onChanged: (v) => _toggleOverlay(v, isPremium),
                  activeColor: context.colors.accent,
                  inactiveThumbColor: context.colors.inkSoft,
                  inactiveTrackColor: context.colors.border,
                ),
              ],
            ),
          ),

          // Notifications
          _SettingsTile(
            icon: CupertinoIcons.bell_fill,
            iconColor: context.colors.accent2,
            title: 'Daily Word of the Day',
            subtitle: 'Sent at 10:00 AM · 14 days pre-scheduled',
            trailing: _PillButton(
              label: 'Refresh',
              onTap: () async {
                await NotificationService().scheduleDailyNotifications(force: true);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notifications rescheduled for 14 days'),
                      backgroundColor: context.colors.surfaceAlt,
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 8),
          _SectionHeader(title: 'Support'),

          _SettingsTile(
            icon: CupertinoIcons.star_fill,
            iconColor: Colors.amber,
            title: 'Rate The Context Dictionary',
            subtitle: 'Your review helps others find us',
            onTap: () => _openUrl(
              'https://play.google.com/store/apps/details?id=com.context.dictv1',
            ),
          ),
          _SettingsTile(
            icon: CupertinoIcons.mail_solid,
            iconColor: context.colors.inkSoft,
            title: 'Contact Support',
            subtitle: 'hello@neurodevlabs.cloud',
            onTap: () => _openUrl(
              'mailto:hello@neurodevlabs.cloud?subject=The%20Context%20Dictionary%20Support',
            ),
          ),

          const SizedBox(height: 8),
          _SectionHeader(title: 'Legal'),

          _SettingsTile(
            icon: CupertinoIcons.shield_fill,
            iconColor: context.colors.inkSoft,
            title: 'Privacy Policy',
            onTap: () => _openUrl('https://neurodevlabs.cloud/context/privacy'),
          ),
          _SettingsTile(
            icon: CupertinoIcons.doc_text_fill,
            iconColor: context.colors.inkSoft,
            title: 'Terms of Service',
            onTap: () => _openUrl('https://neurodevlabs.cloud/context/terms'),
          ),
          if (_privacyOptionsRequired)
            _SettingsTile(
              icon: CupertinoIcons.slider_horizontal_3,
              iconColor: context.colors.inkSoft,
              title: 'Ad Privacy Options',
              subtitle: 'Manage your ad consent choices',
              onTap: () => ConsentService.instance.showPrivacyOptionsForm(),
            ),

          const SizedBox(height: 8),
          _SectionHeader(title: 'About'),

          _SettingsTile(
            icon: CupertinoIcons.info_circle_fill,
            iconColor: context.colors.inkSoft,
            title: 'The Context Dictionary',
            subtitle: _appVersion.isNotEmpty ? 'Version $_appVersion' : '',
          ),

          // Debug-only: exercise premium features (overlay, unlimited) without a
          // real purchase. kDebugMode is false in release, so this never ships.
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            _SectionHeader(title: 'Developer (debug only)'),
            _SettingsTile(
              icon: CupertinoIcons.hammer_fill,
              iconColor: Colors.orange,
              title: 'Premium override',
              subtitle: 'Test premium features without a purchase',
              trailing: Switch(
                value: isPremium,
                activeColor: Colors.orange,
                onChanged: (v) async {
                  await ref.read(quotaServiceProvider).setPremium(v);
                  ref.invalidate(isPremiumProvider);
                  if (mounted) setState(() {});
                },
              ),
            ),
          ],

          const SizedBox(height: 32),

          // NeuroDev Labs footer
          Column(
            children: [
              Divider(color: context.colors.surfaceAlt),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [context.colors.accent, context.colors.accent2],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'NeuroDev Labs',
                    style: TextStyle(
                      color: context.colors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Building tools for curious minds.',
                style: TextStyle(
                  color: context.colors.inkSoft,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: context.colors.inkSoft,
          fontSize: 10,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.colors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(color: context.colors.inkSoft, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(CupertinoIcons.chevron_right, color: context.colors.inkSoft, size: 14),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: context.colors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: context.colors.accent.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: context.colors.accent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onSelect;
  const _ThemeSelector({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const options = [
      (ThemeMode.system, CupertinoIcons.circle_lefthalf_fill, 'System'),
      (ThemeMode.light, CupertinoIcons.sun_max_fill, 'Light'),
      (ThemeMode.dark, CupertinoIcons.moon_fill, 'Dark'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: options.map((o) {
          final selected = current == o.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? context.colors.accent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? context.colors.accent.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      o.$2,
                      size: 18,
                      color: selected ? context.colors.accent : context.colors.inkSoft,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      o.$3,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? context.colors.accent : context.colors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
