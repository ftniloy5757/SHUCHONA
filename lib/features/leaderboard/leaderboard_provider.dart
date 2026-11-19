import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/seed_data/shg_leaderboard_seed.dart';
import 'package:shuchona/features/habit_tracker/habit_tracker_provider.dart';

/// Computes the Privacy-Safe Individual Habit Improvement Leaderboard dynamically
/// from live habit check-ins — ranked by Weekly Improvement XP (% streak growth)
/// with floral/nature avatars & pseudonyms and ZERO disclosure of tracked habits.
final individualLeaderboardProvider = Provider<List<LeaderboardMember>>((ref) {
  final session = ref.watch(userSessionProvider);
  final habits = ref.watch(habitTrackerProvider);

  final completedTodayCount = habits.where((h) => h.completedToday).length;
  final totalStreakBonus =
      habits.fold<int>(0, (sum, h) => sum + (h.completedToday ? 15 : 0));

  final dynamicList = ShgLeaderboardSeed.individuals.map((member) {
    if (member.isCurrentUser) {
      final xp = 330 + totalStreakBonus;
      final growth = 42 + (completedTodayCount * 4);
      return member.copyWith(
        pseudonymBn: '${session.pseudonymBn} (আপনি)',
        pseudonymEn: '${session.pseudonymEn} (You)',
        avatarEmoji: session.avatarEmoji,
        weeklyImprovementXp: xp,
        streakGrowthPercent: growth,
        activeDaysThisWeek: completedTodayCount > 0 ? 7 : 6,
      );
    }
    return member;
  }).toList();

  dynamicList
      .sort((a, b) => b.weeklyImprovementXp.compareTo(a.weeklyImprovementXp));
  return dynamicList;
});

final shgCohortLeaderboardProvider = Provider<List<ShgCohortEntry>>((ref) {
  final habits = ref.watch(habitTrackerProvider);
  final boost = habits.where((h) => h.completedToday).length * 25;

  final list = ShgLeaderboardSeed.villageCohorts.map((c) {
    if (c.isUserCohort) {
      return ShgCohortEntry(
        id: c.id,
        nameBn: c.nameBn,
        nameEn: c.nameEn,
        upazila: c.upazila,
        memberCount: c.memberCount,
        weeklyImprovementXp: c.weeklyImprovementXp + boost,
        avgGrowthPercent: c.avgGrowthPercent + (boost ~/ 40),
        badgeEmoji: c.badgeEmoji,
        isUserCohort: true,
      );
    }
    return c;
  }).toList();

  list.sort((a, b) => b.weeklyImprovementXp.compareTo(a.weeklyImprovementXp));
  return list;
});

