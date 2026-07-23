import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quota_provider.dart';

/// Shows "X searches left today" for free-tier users.
/// Hidden for premium users and when quota is unlimited.
class SearchCounter extends ConsumerWidget {
  final bool isPremium;
  const SearchCounter({super.key, required this.isPremium});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isPremium) return const SizedBox.shrink();

    final count = ref.watch(quotaCountProvider);
    if (count >= 999) return const SizedBox.shrink(); // Safety guard

    final color = count <= 1 ? Colors.redAccent : context.colors.inkSoft!;
    final icon = count <= 1
        ? Icons.battery_1_bar_rounded
        : count == 2
            ? Icons.battery_3_bar_rounded
            : Icons.battery_full_rounded;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            count == 0
                ? 'No searches left today'
                : '$count ${count == 1 ? 'search' : 'searches'} left today',
            style: TextStyle(
              color: color,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
