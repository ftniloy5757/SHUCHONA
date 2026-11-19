import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/seed_data/habits_seed.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/responsive_cards.dart';
import 'package:shuchona/core/widgets/progress_ring.dart';
import 'package:shuchona/core/widgets/severity_badge.dart';
import 'package:shuchona/core/widgets/shuchona_app_bar.dart';
import 'package:shuchona/features/habit_tracker/habit_tracker_provider.dart';

/// Module 8: Visual Icon-Driven Habit Tracker & Animated Streak Engine.
/// Supports building healthy habits & quitting harmful habits (Betel Nut/Jarda, Smoking, Excess Sugar).
class HabitTrackerScreen extends ConsumerWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final habits = ref.watch(habitTrackerProvider);
    final s = AppStrings(locale);
    final primary = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;

    final healthy = habits
        .where((h) => h.kind == HabitKind.buildHealthy)
        .toList();
    final quitHabits = habits
        .where((h) => h.kind == HabitKind.quitHarmful)
        .toList();

    final doneCount = habits.where((h) => h.completedToday).length;
    final ratio = habits.isEmpty ? 0.0 : doneCount / habits.length;
    final longestStreak = habits.fold<int>(
      0,
      (best, h) => h.streakDays > best ? h.streakDays : best,
    );

    final summarySpeech = s.tr(
      'আজ আপনি মোট ${s.formatDigits(habits.length.toString())}টি অভ্যাসের মধ্যে ${s.formatDigits(doneCount.toString())}টি সম্পন্ন করেছেন। আপনার সর্বোচ্চ ধারাবাহিকতা ${s.formatDigits(longestStreak.toString())} দিন। নিচের কার্ডে এক ট্যাপে আজকের চেক-ইন সম্পন্ন করুন।',
      'Today you completed $doneCount out of ${habits.length} habits. Your best streak is $longestStreak days. Tap any habit tile below to check in.',
    );

    return Scaffold(
      appBar: ShuchonaAppBar(
        title: s.tr('অভ্যাস ও স্ট্রিক ট্র্যাকার', 'Habit & Streak Tracker'),
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context, ref, s),
        backgroundColor: primary,
        foregroundColor: isDark ? AppColors.darkCanvas : Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(s.tr('নতুন অভ্যাস', 'Add Habit')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        children: [
          // Progress Summary Header
          AccessibleCard(
            backgroundColor: isDark
                ? AppColors.darkEmeraldBg
                : AppColors.secondaryEmeraldLight,
            borderColor: AppColors.secondaryEmerald.withValues(alpha: 0.45),
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    ProgressRing(
                      progress: ratio,
                      centerText:
                          '${s.formatDigits(doneCount.toString())}/${s.formatDigits(habits.length.toString())}',
                      subtitle: s.tr('আজ', 'Today'),
                      size: 80,
                      color: AppColors.secondaryEmerald,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SeverityBadge(
                            label: s.tr(
                              'অফলাইন সংরক্ষণ চালু',
                              'Offline Cached',
                            ),
                            tone: BadgeTone.emeraldSafe,
                            icon: Icons.offline_pin_rounded,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.tr(
                              'সর্বোচ্চ স্ট্রিক: ${s.formatDigits(longestStreak.toString())} দিন 🔥',
                              'Best Streak: $longestStreak Days 🔥',
                            ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.tr(
                              'প্রতিটি চেক-ইনে সাপ্তাহিক উন্নতি XP বাড়ে (সম্পূর্ণ গোপন)',
                              'Each check-in boosts private Weekly Improvement XP',
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
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
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cautionAmber,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => context.push('/leaderboard'),
                        icon: const Icon(Icons.emoji_events_rounded),
                        label: Text(
                          s.tr('SHG লিডারবোর্ড দেখুন', 'View SHG Leaderboard'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TtsListenButton(
                      textToSpeak: summarySpeech,
                      compact: true,
                      tag: 'habit_summary',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1: Build Healthy Habits
          Text(
            s.tr('🌱 সুস্থ অভ্যাস গড়ে তুলুন', '🌱 Build Healthy Habits'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          _HabitGrid(
            items: healthy,
            s: s,
            accent: AppColors.secondaryEmerald,
            onToggle: (id) =>
                ref.read(habitTrackerProvider.notifier).toggleHabitToday(id),
          ),
          const SizedBox(height: 20),

          // Section 2: Quit Harmful Habits (Jarda/Betel Nut, Smoking, Sugar)
          Row(
            children: [
              Expanded(
                child: Text(
                  s.tr(
                    '🛡️ ক্ষতিকর অভ্যাস ত্যাগ করুন',
                    '🛡️ Quit Harmful Habits',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push('/craving-sos'),
                icon: const Icon(
                  Icons.spa_rounded,
                  color: AppColors.alertCrimson,
                  size: 18,
                ),
                label: Text(
                  s.tr('তাড়না SOS', 'Craving SOS'),
                  style: const TextStyle(
                    color: AppColors.alertCrimson,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _HabitGrid(
            items: quitHabits,
            s: s,
            accent: primary,
            onToggle: (id) =>
                ref.read(habitTrackerProvider.notifier).toggleHabitToday(id),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddHabitDialog(
    BuildContext context,
    WidgetRef ref,
    AppStrings s,
  ) async {
    final titleCtrl = TextEditingController();
    var selectedKind = HabitKind.buildHealthy;
    var selectedEmoji = '🌿';
    final emojis = ['🌿', '🥗', '🧘‍♀️', '🥛', '🚶‍♀️', '🚭', '🍃', '😴'];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.tr('নতুন অভ্যাস যোগ করুন', 'Add a New Daily Habit'),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      selected: selectedKind == HabitKind.buildHealthy,
                      label: Center(
                        child: Text(s.tr('সুস্থ অভ্যাস', 'Build Healthy')),
                      ),
                      onSelected: (_) => setModalState(
                        () => selectedKind = HabitKind.buildHealthy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      selected: selectedKind == HabitKind.quitHarmful,
                      label: Center(
                        child: Text(s.tr('ক্ষতিকর ত্যাগ', 'Quit Harmful')),
                      ),
                      onSelected: (_) => setModalState(
                        () => selectedKind = HabitKind.quitHarmful,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: s.tr('অভ্যাসের নাম লিখুন', 'Habit Name'),
                  hintText: s.tr(
                    'যেমন: সকালে শাকসবজি খাওয়া',
                    'e.g. Morning stretching',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: emojis
                    .map(
                      (e) => ChoiceChip(
                        selected: selectedEmoji == e,
                        label: Text(e, style: const TextStyle(fontSize: 20)),
                        onSelected: (_) =>
                            setModalState(() => selectedEmoji = e),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final text = titleCtrl.text.trim();
                  if (text.isEmpty) return;
                  ref
                      .read(habitTrackerProvider.notifier)
                      .addCustomHabit(
                        titleBn: text,
                        titleEn: text,
                        emoji: selectedEmoji,
                        kind: selectedKind,
                      );
                  Navigator.of(ctx).pop();
                },
                child: Text(s.tr('অভ্যাস সংরক্ষণ করুন', 'Save Habit')),
              ),
            ],
          ),
        ),
      ),
    );
    titleCtrl.dispose();
  }
}

class _HabitGrid extends StatelessWidget {
  const _HabitGrid({
    required this.items,
    required this.s,
    required this.accent,
    required this.onToggle,
  });

  final List<HabitItem> items;
  final AppStrings s;
  final Color accent;
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveCards(
      children: items.map((item) {
        final title = s.tr(item.titleBn, item.titleEn);
        final sub = s.tr(item.subtitleBn, item.subtitleEn);
        final done = item.completedToday;

        return AccessibleCard(
          onTap: () => onToggle(item.id),
          backgroundColor: done
              ? (isDark
                    ? AppColors.darkEmeraldBg
                    : AppColors.secondaryEmeraldLight)
              : null,
          borderColor: done ? AppColors.secondaryEmerald : null,
          borderWidth: done ? 2 : 1,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 32)),
                  AnimatedScale(
                    scale: done ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.secondaryEmerald
                            : accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🔥 ${s.formatDigits(item.streakDays.toString())}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: done ? AppColors.darkCanvas : accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(sub, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        done
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: done
                            ? AppColors.secondaryEmerald
                            : Theme.of(context).colorScheme.outline,
                        size: 24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        done
                            ? s.tr('সম্পন্ন', 'Done')
                            : s.tr('ট্যাপ করুন', 'Tap'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: done ? AppColors.secondaryEmerald : null,
                        ),
                      ),
                    ],
                  ),
                  TtsListenButton(
                    textToSpeak:
                        '$title। $sub। ${s.tr("বর্তমান স্ট্রিক ${s.formatDigits(item.streakDays.toString())} দিন।", "Current streak: ${item.streakDays} days.")}',
                    compact: true,
                    tag: 'habit_${item.id}',
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
