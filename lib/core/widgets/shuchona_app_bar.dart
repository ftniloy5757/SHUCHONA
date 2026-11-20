import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/widgets/shuchona_logo.dart';

/// Shared Enterprise Top App Bar featuring:
/// - Instant Bangla <-> English runtime switcher
/// - One-tap High-Contrast Dark Mode toggle (#090D16 / #38BDF8)
/// - Role Switcher menu (Community User View <-> NGO / Admin Impact Dashboard)
class ShuchonaAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ShuchonaAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.extraActions = const [],
  });

  final String? title;
  final bool showBackButton;
  final List<Widget> extraActions;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final isAdmin = ref.watch(adminRoleProvider);
    final s = AppStrings(locale);

    return AppBar(
      toolbarHeight: preferredSize.height,
      leading: showBackButton
          ? IconButton(
              tooltip: s.tr('ফিরে যান', 'Go back'),
              icon: const Icon(Icons.arrow_back_rounded, size: 26),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      titleSpacing: showBackButton ? 4 : 16,
      title: Row(
        children: [
          if (!showBackButton) ...[
            const ShuchonaLogo(size: 38),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title ?? s.appName,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      actions: [
        ...extraActions,
        TextButton(
          onPressed: () => ref.read(localeProvider.notifier).toggle(),
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          child: Text(
            s.isBn ? 'English' : 'বাংলা',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        // High-Contrast / Dark Mode Toggle
        IconButton(
          tooltip: s.tr('পর্দার রং বদলান', 'Change screen contrast'),
          onPressed: () => ref.read(highContrastDarkProvider.notifier).toggle(),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.contrast_rounded,
            color: isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal,
          ),
        ),
        // Role Switcher (Community User <-> NGO / Admin Impact Dashboard)
        PopupMenuButton<String>(
          tooltip: s.tr('আরও সেবা', 'More services'),
          icon: Icon(
            isAdmin
                ? Icons.admin_panel_settings_rounded
                : Icons.more_vert_rounded,
            color: isAdmin
                ? AppColors.secondaryEmerald
                : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
          ),
          onSelected: (value) {
            final currentPath = GoRouterState.of(context).uri.path;
            if (value == 'toggle_admin') {
              if (currentPath == '/admin' || isAdmin) {
                ref.read(adminRoleProvider.notifier).state = false;
                if (context.canPop() && currentPath == '/admin') {
                  context.pop();
                } else {
                  context.go('/home');
                }
              } else {
                ref.read(adminRoleProvider.notifier).state = true;
                context.push('/admin');
              }
            } else if (value == 'find_care') {
              if (currentPath != '/care') {
                context.push('/care');
              }
            } else if (value == 'leaderboard') {
              if (currentPath != '/leaderboard') {
                context.push('/leaderboard');
              }
            } else if (value == 'wellness') {
              if (currentPath != '/wellness') {
                context.push('/wellness');
              }
            } else if (value == 'onboarding') {
              ref.read(adminRoleProvider.notifier).state = false;
              ref.read(userSessionProvider.notifier).signOutToOnboarding();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_admin',
              child: Row(
                children: [
                  Icon(
                    isAdmin
                        ? Icons.person_outline_rounded
                        : Icons.analytics_rounded,
                    color: isDark
                        ? AppColors.darkAccentBlue
                        : AppColors.primaryTeal,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      isAdmin ? s.communityUserView : s.adminDashboardView,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'leaderboard',
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.cautionAmber,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(s.tr('অভ্যাস লিডারবোর্ড', 'Habit Leaderboard')),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'wellness',
              child: Row(
                children: [
                  const Icon(
                    Icons.self_improvement_rounded,
                    color: AppColors.secondaryEmerald,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      s.tr('মানসিক স্বাস্থ্য ও মুড', 'Mental Wellness & Mood'),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'find_care',
              child: Row(
                children: [
                  const Icon(
                    Icons.local_hospital_rounded,
                    color: AppColors.alertCrimson,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      s.tr('হাসপাতাল ও রিমাইন্ডার', 'Find Care & Reminders'),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'onboarding',
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.indigoSoft,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      s.tr('লগইন ও গোপনীয়তা সম্মতি', 'Login & Privacy Consent'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
