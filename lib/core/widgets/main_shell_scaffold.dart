import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/features/prescribe_safe/prescribe_safe_provider.dart';
import 'package:shuchona/features/voice_chatbot/chatbot_provider.dart';
import 'package:shuchona/features/womens_symptom_guide/symptom_guide_provider.dart';

/// Main App Shell with bottom navigation bar and persistent centered floating
/// Voice Microphone CTA (`সূচনা কে বলুন` / `Speak to SHUCHONA`).
class MainShellScaffold extends ConsumerWidget {
  const MainShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final isGuest = ref.watch(shgGuestModeProvider);
    final s = AppStrings(locale);

    final navBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final navBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final currentIdx = navigationShell.currentIndex;

    return BackButtonListener(
      onBackButtonPressed: () async {
        // When sitting directly on a secondary shell tab (no pushed page above),
        // consume hardware Back and return to Home instead of exiting the app.
        // (_TabBackToHomeGuard's PopScope ensures Android 16+ routes Back here.)
        if (!GoRouter.of(context).canPop() && currentIdx != 0) {
          navigationShell.goBranch(0);
          return true;
        }
        return false;
      },
      child: Scaffold(
      body: Column(
        children: [
          if (isGuest)
            Material(
              color: isDark
                  ? AppColors.darkCautionBg
                  : AppColors.cautionAmberDark,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: isDark ? const Color(0xFFFCD34D) : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.guestModeBanner,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? const Color(0xFFFDE68A)
                                    : Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(shgGuestModeProvider.notifier).state = false;
                          // Zero-trace cleanup when exiting SHG Guest Mode
                          ref
                              .read(chatbotProvider.notifier)
                              .restorePersonalSession();
                          ref.read(symptomGuideProvider.notifier).reset();
                          ref
                              .read(prescribeSafeProvider.notifier)
                              .clearResult();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? const Color(0xFFFCD34D)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          s.tr('বন্ধ', 'Exit'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: Material(
        color: navBg,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: navBorder)),
          ),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: s.navHome,
                      selected: currentIdx == 0,
                      onTap: () => navigationShell.goBranch(
                        0,
                        initialLocation: currentIdx == 0,
                      ),
                    ),
                    _NavItem(
                      icon: Icons.document_scanner_rounded,
                      label: s.navRx,
                      selected: currentIdx == 1,
                      onTap: () => navigationShell.goBranch(
                        1,
                        initialLocation: currentIdx == 1,
                      ),
                    ),
                    _NavItem(
                      icon: Icons.mic_rounded,
                      label: s.tr('বলুন', 'Speak'),
                      emphasized: true,
                      onTap: () => context.push('/chatbot'),
                    ),
                    _NavItem(
                      icon: Icons.favorite_rounded,
                      label: s.navSymptoms,
                      selected: currentIdx == 2,
                      onTap: () => navigationShell.goBranch(
                        2,
                        initialLocation: currentIdx == 2,
                      ),
                    ),
                    _NavItem(
                      icon: Icons.bloodtype_rounded,
                      label: s.navBlood,
                      selected: currentIdx == 3,
                      onTap: () => navigationShell.goBranch(
                        3,
                        initialLocation: currentIdx == 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Expanded(
      child: Semantics(
        button: true,
        selected: emphasized ? null : selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: emphasized
                          ? colors.primary
                          : selected
                          ? colors.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      child: Icon(
                        icon,
                        size: 23,
                        color: emphasized
                            ? colors.onPrimary
                            : selected
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: selected || emphasized
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      fontWeight: selected || emphasized
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
