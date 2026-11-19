import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/seed_data/wellness_tips_seed.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/severity_badge.dart';
import 'package:shuchona/core/widgets/shuchona_app_bar.dart';
import 'package:shuchona/features/mental_wellness/mental_wellness_provider.dart';

/// Modules 12 & 13: Daily Mental Wellness Voice Tips, 5-Emoji Daily Mood Check-in,
/// `fl_chart` 7-Day Mood & Habit Consistency Analytics, and Context-Aware Guidance.
class MentalWellnessScreen extends ConsumerWidget {
  const MentalWellnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final wellness = ref.watch(mentalWellnessProvider);
    final liveMoods = ref.watch(liveSevenDayMoodsProvider);
    final nudge = ref.watch(personalizedGuidanceProvider);
    final s = AppStrings(locale);
    final primary = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;

    final tip = WellnessTipsSeed.dailyTips[wellness.dailyTipIndex];
    final tipTitle = s.tr(tip.titleBn, tip.titleEn);
    final tipBody = s.tr(tip.bodyBn, tip.bodyEn);

    final moodOptions = [
      (score: 1, emoji: '😞', bn: 'খুব খারাপ', en: 'Very Low'),
      (score: 2, emoji: '😟', bn: 'খারাপ', en: 'Low'),
      (score: 3, emoji: '😐', bn: 'মোটামুটি', en: 'Okay'),
      (score: 4, emoji: '🙂', bn: 'ভালো', en: 'Good'),
      (score: 5, emoji: '😊', bn: 'খুব ভালো', en: 'Great'),
    ];

    return Scaffold(
      appBar: ShuchonaAppBar(
        title: s.tr('মানসিক স্বাস্থ্য', 'Mental Wellness'),
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        children: [
          // 1. Daily Voice-Enabled Mental Wellness Micro-Tip Card
          AccessibleCard(
            backgroundColor:
                isDark ? AppColors.darkTealBg : AppColors.primaryTealLight,
            borderColor: primary.withValues(alpha: 0.4),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(tip.emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SeverityBadge(
                            label: s.tr(
                              'আজকের মানসিক প্রশান্তি টিপ • ${tip.categoryBn}',
                              'Daily Wellness Tip • ${tip.categoryEn}',
                            ),
                            tone: BadgeTone.clinicalTeal,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tipTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(tipBody, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TtsListenButton(
                      textToSpeak: '$tipTitle। $tipBody',
                      compact: true,
                      tag: 'wellness_tip_${tip.id}',
                      labelOverride: s.tr('🔊 টিপ শুনুন', '🔊 Listen to Tip'),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => ref
                          .read(mentalWellnessProvider.notifier)
                          .nextDailyTip(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(s.tr('পরবর্তী টিপ', 'Next Tip')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. 5-Emoji Daily Mood Check-In Card
          AccessibleCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr('আজ আপনার মন কেমন আছে?', 'How Are You Feeling Today?'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  s.tr(
                    'নিচের একটি ইমোজি বেছে নিন — সূচনা আপনার জন্য উপযোগী পরামর্শ তৈরি করবে',
                    'Tap an emoji below to log today’s mood and update your 7-day trend',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: moodOptions.map((m) {
                    final selected = wellness.todayMoodScore == m.score;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => ref
                              .read(mentalWellnessProvider.notifier)
                              .setTodayMood(m.score),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 2),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primary.withValues(alpha: 0.16)
                                  : (isDark
                                      ? AppColors.darkCardElevated
                                      : AppColors.lightCanvas),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? primary
                                    : Theme.of(context).colorScheme.outline,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(m.emoji,
                                    style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text(
                                  s.tr(m.bn, m.en),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        fontWeight: selected
                                            ? FontWeight.w900
                                            : FontWeight.w600,
                                        color: selected ? primary : null,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Context-Aware Personalized Guidance Card
          AccessibleCard(
            backgroundColor: wellness.todayMoodScore <= 2
                ? (isDark
                    ? AppColors.darkAlertBg
                    : AppColors.alertCrimsonLight)
                : (isDark
                    ? AppColors.darkEmeraldBg
                    : AppColors.secondaryEmeraldLight),
            borderColor: wellness.todayMoodScore <= 2
                ? AppColors.alertCrimson.withValues(alpha: 0.6)
                : AppColors.secondaryEmerald.withValues(alpha: 0.5),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(nudge.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.tr(nudge.titleBn, nudge.titleEn),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  s.tr(nudge.bodyBn, nudge.bodyEn),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (nudge.actionRoute == '/prescribe-safe') {
                            context.go('/prescribe-safe');
                          } else {
                            context.push(nudge.actionRoute);
                          }
                        },
                        child: Text(
                            s.tr(nudge.actionLabelBn, nudge.actionLabelEn)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TtsListenButton(
                      textToSpeak:
                          '${s.tr(nudge.titleBn, nudge.titleEn)}। ${s.tr(nudge.bodyBn, nudge.bodyEn)}',
                      compact: true,
                      tag: 'wellness_nudge',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. fl_chart 7-Day Mood & Habit Consistency Chart
          AccessibleCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr(
                    'সাপ্তাহিক মুড ও অভ্যাস ধারাবাহিকতা চার্ট',
                    '7-Day Mood & Habit Consistency Chart',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  children: [
                    _LegendDot(
                      color: primary,
                      label: s.tr('মুড স্কোর (১–৫)', 'Mood Score (1–5)'),
                    ),
                    _LegendDot(
                      color: AppColors.secondaryEmerald,
                      label: s.tr('অভ্যাস সম্পন্ন (স্কেল ১–৫)',
                          'Habit Consistency (1–5 scale)'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      minY: 1,
                      maxY: 5,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 1,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.5),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 28,
                            getTitlesWidget: (val, _) => Text(
                              s.formatDigits(val.toInt().toString()),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 28,
                            getTitlesWidget: (val, _) {
                              final idx = val.toInt();
                              if (idx < 0 || idx >= liveMoods.length) {
                                return const SizedBox.shrink();
                              }
                              final entry = liveMoods[idx];
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  s.tr(entry.dayLabelBn, entry.dayLabelEn),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        // Mood Line
                        LineChartBarData(
                          isCurved: true,
                          color: primary,
                          barWidth: 3.5,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: primary.withValues(alpha: 0.14),
                          ),
                          spots: liveMoods
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.score.toDouble(),
                                ),
                              )
                              .toList(),
                        ),
                        // Habit Consistency Line (mapped 0..1 -> 1..5)
                        LineChartBarData(
                          isCurved: true,
                          color: AppColors.secondaryEmerald,
                          barWidth: 3,
                          dashArray: [6, 4],
                          dotData: const FlDotData(show: true),
                          spots: liveMoods
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(
                                  e.key.toDouble(),
                                  (1 + e.value.habitCompletionRate * 4)
                                      .clamp(1.0, 5.0),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

