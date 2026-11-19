import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/severity_badge.dart';
import 'package:shuchona/core/widgets/shuchona_app_bar.dart';
import 'package:shuchona/features/leaderboard/leaderboard_provider.dart';

/// Module 9: Privacy-Preserving Habit Improvement Leaderboard.
/// - Selectable floral/nature avatars & pseudonyms (never real names!)
/// - Toggle between Individual Pseudonyms & Village Self-Help Group (SHG) Cohorts
/// - Ranked by Weekly Improvement XP (% streak growth) so newcomers can win
/// - Never reveals which specific sensitive habit a member is tracking!
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  bool _showVillageCohorts = false;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final session = ref.watch(userSessionProvider);
    final members = ref.watch(individualLeaderboardProvider);
    final cohorts = ref.watch(shgCohortLeaderboardProvider);
    final s = AppStrings(locale);
    final primary = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;

    final userRank = members.indexWhere((m) => m.isCurrentUser) + 1;
    final me = members.firstWhere((m) => m.isCurrentUser);

    final voiceIntro = s.tr(
      'গোপনীয়তা-সুরক্ষিত অভ্যাস উন্নতি লিডারবোর্ড। আপনার ছদ্মনাম ${session.pseudonymBn} এবং বর্তমান অবস্থান ${s.formatDigits(userRank.toString())} নম্বর, সাপ্তাহিক উন্নতি +${s.formatDigits(me.streakGrowthPercent.toString())} শতাংশ। এখানে কারো আসল নাম বা নির্দিষ্ট অভ্যাস দেখানো হয় না।',
      'Privacy-safe Habit Improvement Leaderboard. Your pseudonym ${session.pseudonymEn} is currently ranked number $userRank with +${me.streakGrowthPercent}% weekly streak growth. Real names and specific tracked habits are never disclosed.',
    );

    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalGutter =
        screenWidth > 760 ? (screenWidth - 760) / 2 + 16 : 16.0;

    return Scaffold(
      appBar: ShuchonaAppBar(
        title: s.tr('উন্নতি লিডারবোর্ড', 'Leaderboard'),
        showBackButton: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            horizontalGutter, 14, horizontalGutter, 100),
        children: [
          // Privacy Shield + Current Pseudonym Banner
          AccessibleCard(
            backgroundColor:
                isDark ? AppColors.darkTealBg : AppColors.primaryTealLight,
            borderColor: primary.withValues(alpha: 0.45),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showAvatarPicker(context, s),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: primary, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            session.avatarEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SeverityBadge(
                            label: s.tr('ছদ্মনাম সুরক্ষিত • ০% ব্যক্তিগত তথ্য',
                                'Pseudonymous • Private Habits Hidden'),
                            tone: BadgeTone.emeraldSafe,
                            icon: Icons.privacy_tip_rounded,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.tr(session.pseudonymBn, session.pseudonymEn),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            s.tr(
                              'অবস্থান #${s.formatDigits(userRank.toString())} • ${s.formatDigits(me.weeklyImprovementXp.toString())} XP (+${s.formatDigits(me.streakGrowthPercent.toString())}%)',
                              'Rank #$userRank • ${me.weeklyImprovementXp} XP (+${me.streakGrowthPercent}% growth)',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAvatarPicker(context, s),
                        icon: const Icon(Icons.auto_fix_high_rounded, size: 20),
                        label: Text(
                          s.tr('ফুল/প্রকৃতি অবতার বদলান', 'Change Nature Avatar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TtsListenButton(
                      textToSpeak: voiceIntro,
                      compact: true,
                      tag: 'leaderboard_intro',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Fair Ranking Explanation Pill
          AccessibleCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.trending_up_rounded,
                    color: AppColors.secondaryEmerald, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.tr(
                      'নতুন সদস্যরাও জিততে পারেন! মোট দিনের বদলে সাপ্তাহিক স্ট্রিক উন্নতি (%) অনুযায়ী র‍্যাংকিং হয়।',
                      'Newcomers can win! Ranked by Weekly Improvement XP (% streak growth) rather than raw all-time totals.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Mode Switch: Individual Pseudonyms vs Village SHG Cohort Circles
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  selected: !_showVillageCohorts,
                  showCheckmark: false,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  label: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        s.tr('🌸 ব্যক্তিগত', '🌸 Individuals'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  onSelected: (_) =>
                      setState(() => _showVillageCohorts = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  selected: _showVillageCohorts,
                  showCheckmark: false,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  label: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        s.tr('🏘️ স্বনির্ভর দল', '🏘️ Village SHGs'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  onSelected: (_) => setState(() => _showVillageCohorts = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (!_showVillageCohorts)
            ...members.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final m = entry.value;
              final medal = switch (rank) {
                1 => '🥇',
                2 => '🥈',
                3 => '🥉',
                _ => '#${s.formatDigits(rank.toString())}',
              };

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AccessibleCard(
                  backgroundColor: m.isCurrentUser
                      ? (isDark
                          ? AppColors.darkEmeraldBg
                          : AppColors.secondaryEmeraldLight)
                      : null,
                  borderColor:
                      m.isCurrentUser ? AppColors.secondaryEmerald : null,
                  borderWidth: m.isCurrentUser ? 2 : 1,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          medal,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: rank <= 3 ? 24 : 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(m.avatarEmoji,
                              style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.tr(m.pseudonymBn, m.pseudonymEn),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              s.tr(m.shgCircleBn, m.shgCircleEn),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${s.formatDigits(m.weeklyImprovementXp.toString())} XP',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          SeverityBadge(
                            label:
                                '+${s.formatDigits(m.streakGrowthPercent.toString())}%',
                            tone: BadgeTone.emeraldSafe,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            })
          else
            ...cohorts.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final c = entry.value;
              final medal = switch (rank) {
                1 => '🥇',
                2 => '🥈',
                3 => '🥉',
                _ => '#${s.formatDigits(rank.toString())}',
              };

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AccessibleCard(
                  backgroundColor: c.isUserCohort
                      ? (isDark
                          ? AppColors.darkEmeraldBg
                          : AppColors.secondaryEmeraldLight)
                      : null,
                  borderColor:
                      c.isUserCohort ? AppColors.secondaryEmerald : null,
                  borderWidth: c.isUserCohort ? 2 : 1,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          medal,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: rank <= 3 ? 24 : 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(c.badgeEmoji, style: const TextStyle(fontSize: 30)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.tr(c.nameBn, c.nameEn),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              s.tr(
                                '${s.formatDigits(c.memberCount.toString())} জন সদস্য • ${AppConstants.upazilaBanglaNames[c.upazila] ?? c.upazila}',
                                '${c.memberCount} members • ${c.upazila}',
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${s.formatDigits(c.weeklyImprovementXp.toString())} XP',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          SeverityBadge(
                            label:
                                '+${s.formatDigits(c.avgGrowthPercent.toString())}%',
                            tone: BadgeTone.emeraldSafe,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _showAvatarPicker(BuildContext context, AppStrings s) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.tr('আপনার গোপনীয় ফুল/প্রকৃতি অবতার বেছে নিন',
                  'Choose Your Privacy-Safe Nature Avatar'),
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: AppConstants.natureAvatars.map((a) {
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    ref
                        .read(userSessionProvider.notifier)
                        .updateAvatarAndPseudonym(
                          avatarEmoji: a['emoji']!,
                          pseudonymBn: a['bn']!,
                          pseudonymEn: a['en']!,
                        );
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(ctx).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(a['emoji']!, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          s.isBn ? a['bn']! : a['en']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(ctx).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

