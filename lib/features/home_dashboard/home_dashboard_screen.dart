import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/progress_ring.dart';
import 'package:shuchona/core/widgets/responsive_cards.dart';
import 'package:shuchona/core/widgets/severity_badge.dart';
import 'package:shuchona/core/widgets/shuchona_app_bar.dart';
import 'package:shuchona/features/blood_alert/blood_alert_provider.dart';
import 'package:shuchona/features/habit_tracker/habit_tracker_provider.dart';
import 'package:shuchona/features/mental_wellness/mental_wellness_provider.dart';
import 'package:shuchona/features/prescribe_safe/prescribe_safe_provider.dart';
import 'package:shuchona/features/voice_chatbot/chatbot_provider.dart';
import 'package:shuchona/features/womens_symptom_guide/symptom_guide_provider.dart';

/// Home Dashboard Hub uniting all 18 SHUCHONA modules with:
/// - Offline Sync Status Pill (tappable for live offline queue demo)
/// - SHG Facilitator Zero-Trace Guest Mode Toggle
/// - One-Tap Crimson "আমি কষ্টে আছি / I'm Struggling" Craving SOS CTA
/// - Context-Aware Personalized Guidance Card with TTS
/// - Daily Health Rings (Habit Adherence + Mood + PrescribeSafe BDT Savings)
/// - Oversized Low-Literacy Accessible Module Grid
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final isGuest = ref.watch(shgGuestModeProvider);
    final sync = ref.watch(offlineSyncProvider);
    final session = ref.watch(userSessionProvider);
    final habits = ref.watch(habitTrackerProvider);
    final mood = ref.watch(mentalWellnessProvider);
    final nudge = ref.watch(personalizedGuidanceProvider);
    final blood = ref.watch(bloodNetworkProvider);
    final s = AppStrings(locale);

    final completedCount = habits.where((h) => h.completedToday).length;
    final habitProgress = habits.isEmpty ? 0.0 : completedCount / habits.length;
    final primary = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;

    final upazilaLabel = s.isBn
        ? (AppConstants.upazilaBanglaNames[session.upazila] ?? session.upazila)
        : session.upazila;

    final greetingSpeech = s.tr(
      'আসসালামু আলাইকুম ${session.pseudonymBn}। আজ আপনার $completedCount টি অভ্যাস সম্পন্ন হয়েছে। নিচের যেকোনো কার্ডে চাপ দিয়ে প্রেসক্রিপশন স্ক্যান, নারী স্বাস্থ্য গাইড, বা জরুরি রক্ত সহায়তা নিন।',
      'Hello ${session.pseudonymEn}. You have completed $completedCount habits today. Tap any card below for PrescribeSafe BD, Women’s Health Guide, or Blood SOS.',
    );

    final gutter = ((MediaQuery.sizeOf(context).width - 880) / 2).clamp(
      16.0,
      double.infinity,
    );

    return Scaffold(
      appBar: ShuchonaAppBar(title: s.tr('সূচনা', 'SHUCHONA')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 20),
        children: [
          AccessibleCard(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.tr('কথা বলে সাহায্য নিন', 'Ask for help by voice'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  s.tr(
                    'মাইকে চাপ দিন, তারপর আপনার প্রশ্ন বলুন।',
                    'Tap the microphone and say your question.',
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.push('/chatbot'),
                  icon: const Icon(Icons.mic_rounded),
                  label: Text(s.tr('কথা বলুন', 'Speak')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // MODULE 11 ENTRY: Prominent "আমি কষ্টে আছি / I'm Struggling" Craving & Crisis SOS Button
          Material(
            color: isDark ? AppColors.darkAlertBg : AppColors.alertCrimsonDark,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/craving-sos'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.alertCrimson.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.strugglingCta,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.strugglingSubtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Section Title
          Text(
            s.tr('কী সাহায্য চান?', 'What do you need help with?'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          // Oversized Accessible 2-Column Module Grid
          ResponsiveCards(
            children: [
              _ServiceCard(
                icon: Icons.document_scanner_rounded,
                accent: primary,
                title: s.tr('প্রেসক্রিপশন দেখুন', 'Check a prescription'),
                subtitle: s.tr(
                  'ছবি তুলে ওষুধের তথ্য দেখুন',
                  'Take a photo to see medicine details',
                ),
                onTap: () => context.go('/prescribe-safe'),
              ),
              _ServiceCard(
                icon: Icons.health_and_safety_rounded,
                accent: AppColors.roseAccent,
                title: s.tr('নারী স্বাস্থ্য গাইড', 'Women’s Health'),
                subtitle: s.tr(
                  'মাসিক ও স্তনের সমস্যা সম্পর্কে জানুন',
                  'Learn about periods and breast health',
                ),
                onTap: () => context.go('/symptoms'),
              ),
              _ServiceCard(
                icon: Icons.bloodtype_rounded,
                accent: AppColors.alertCrimson,
                title: s.tr('জরুরি রক্তের সহায়তা', 'Urgent blood help'),
                subtitle: s.tr(
                  'রক্তদাতা খুঁজুন বা রক্তের অনুরোধ করুন',
                  'Find a donor or request blood',
                ),
                onTap: () => context.go('/blood'),
              ),
              _ServiceCard(
                icon: Icons.check_circle_rounded,
                accent: AppColors.secondaryEmerald,
                title: s.tr('দৈনিক অভ্যাস', 'Habit Tracker'),
                subtitle: s.tr(
                  'আজ কী কী করেছেন, লিখে রাখুন',
                  'Keep track of your daily habits',
                ),
                onTap: () => context.push('/habits'),
              ),
              _ServiceCard(
                icon: Icons.emoji_events_rounded,
                accent: AppColors.cautionAmber,
                title: s.tr('দলের অগ্রগতি', 'Group progress'),
                subtitle: s.tr(
                  'দলের সাপ্তাহিক অগ্রগতি দেখুন',
                  'See your group’s weekly progress',
                ),
                onTap: () => context.push('/leaderboard'),
              ),
              _ServiceCard(
                icon: Icons.self_improvement_rounded,
                accent: AppColors.indigoSoft,
                title: s.tr('মানসিক স্বাস্থ্য', 'Mental Wellness'),
                subtitle: s.tr(
                  'মনের খবর লিখুন ও পরামর্শ পড়ুন',
                  'Record how you feel and read tips',
                ),
                onTap: () => context.push('/wellness'),
              ),
              _ServiceCard(
                icon: Icons.local_hospital_rounded,
                accent: AppColors.skyAccent,
                title: s.tr(
                  'হাসপাতাল ও ওষুধের সময়',
                  'Find care & set reminders',
                ),
                subtitle: s.tr(
                  'ক্লিনিক খুঁজুন, ওষুধের সময় ঠিক করুন',
                  'Find a clinic or set a medicine reminder',
                ),
                onTap: () => context.push('/care'),
              ),
              _ServiceCard(
                icon: Icons.analytics_rounded,
                accent: AppColors.primaryTealDark,
                title: s.tr('এনজিও প্রতিবেদন', 'NGO reports'),
                subtitle: s.tr(
                  'এলাকার স্বাস্থ্যসেবার পরিসংখ্যান',
                  'View anonymized community health statistics',
                ),
                onTap: () {
                  ref.read(adminRoleProvider.notifier).state = true;
                  context.push('/admin');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Top Status Row: Offline Sync Pill + SHG Facilitator Guest Mode Toggle
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Offline Sync Status Pill (tappable to demo offline queueing!)
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => ref
                    .read(offlineSyncProvider.notifier)
                    .toggleSimulatedOffline(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: sync.effectivelyOnline
                        ? (isDark
                              ? AppColors.darkEmeraldBg
                              : AppColors.secondaryEmeraldLight)
                        : (isDark
                              ? AppColors.darkCautionBg
                              : AppColors.cautionAmberLight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sync.effectivelyOnline
                          ? AppColors.secondaryEmerald.withValues(alpha: 0.5)
                          : AppColors.cautionAmber.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sync.isSyncing
                            ? Icons.sync_rounded
                            : (sync.effectivelyOnline
                                  ? Icons.cloud_done_rounded
                                  : Icons.offline_pin_rounded),
                        size: 16,
                        color: sync.effectivelyOnline
                            ? AppColors.secondaryEmerald
                            : AppColors.cautionAmber,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          sync.isSyncing
                              ? s.syncingNow
                              : (sync.effectivelyOnline
                                    ? s.onlineSynced
                                    : '${s.offlineSaved}${sync.pendingQueueCount > 0 ? " (${s.formatDigits(sync.pendingQueueCount.toString())})" : ""}'),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: sync.effectivelyOnline
                                    ? (isDark
                                          ? const Color(0xFF6EE7B7)
                                          : AppColors.secondaryEmeraldDark)
                                    : (isDark
                                          ? const Color(0xFFFCD34D)
                                          : AppColors.cautionAmberDark),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // SHG Facilitator Guest Mode Toggle Pill
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final next = !isGuest;
                  ref.read(shgGuestModeProvider.notifier).state = next;
                  if (next) {
                    ref
                        .read(chatbotProvider.notifier)
                        .resetForGuestMode(locale);
                    ref.read(symptomGuideProvider.notifier).reset();
                    ref.read(prescribeSafeProvider.notifier).clearResult();
                  } else {
                    // Full zero-trace cleanup on exit
                    ref.read(chatbotProvider.notifier).restorePersonalSession();
                    ref.read(symptomGuideProvider.notifier).reset();
                    ref.read(prescribeSafeProvider.notifier).clearResult();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isGuest
                        ? AppColors.cautionAmberDark
                        : (isDark
                              ? AppColors.darkCardElevated
                              : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isGuest
                          ? AppColors.cautionAmber
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGuest
                            ? Icons.visibility_off_rounded
                            : Icons.groups_rounded,
                        size: 16,
                        color: isGuest ? Colors.white : primary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isGuest
                              ? s.tr('অতিথি মোড চালু', 'Guest mode on')
                              : s.tr('অতিথি মোড', 'Guest mode'),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isGuest
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Greeting & Personal Snapshot Card
          AccessibleCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          session.avatarEmoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.tr(
                              'স্বাগতম, ${session.pseudonymBn}',
                              'Welcome, ${session.pseudonymEn}',
                            ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  upazilaLabel,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TtsListenButton(
                      textToSpeak: greetingSpeech,
                      compact: true,
                      tag: 'home_greeting',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ProgressRing(
                      progress: habitProgress,
                      centerText:
                          '${s.formatDigits((habitProgress * 100).round().toString())}%',
                      subtitle: s.tr('অভ্যাস', 'Habits'),
                      size: 74,
                      color: AppColors.secondaryEmerald,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MiniMetricRow(
                            icon: Icons.savings_rounded,
                            color: AppColors.secondaryEmerald,
                            label: s.tr('ওষুধে সাশ্রয়', 'Medicine savings'),
                            value: s.formatTaka(session.cumulativeBdtSaved),
                          ),
                          const SizedBox(height: 8),
                          _MiniMetricRow(
                            icon: Icons.mood_rounded,
                            color: primary,
                            label: s.tr('আজকের মন', 'Today Mood'),
                            value: _moodEmoji(mood.todayMoodScore),
                          ),
                          const SizedBox(height: 8),
                          _MiniMetricRow(
                            icon: Icons.bloodtype_rounded,
                            color: AppColors.alertCrimson,
                            label: s.tr('রক্তের অনুরোধ', 'Blood requests'),
                            value: s.formatDigits(
                              blood.activeRequests.length.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // MODULE 13: Context-Aware Personalized Guidance Card
          AccessibleCard(
            backgroundColor: isDark
                ? AppColors.darkTealBg
                : AppColors.primaryTealLight,
            borderColor: primary.withValues(alpha: 0.35),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(nudge.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SeverityBadge(
                            label: s.tr(
                              'আপনার জন্য পরামর্শ',
                              'Guidance for you',
                            ),
                            tone: BadgeTone.clinicalTeal,
                            icon: Icons.auto_awesome_rounded,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.tr(nudge.titleBn, nudge.titleEn),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
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
                          s.tr(nudge.actionLabelBn, nudge.actionLabelEn),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TtsListenButton(
                      textToSpeak:
                          '${s.tr(nudge.titleBn, nudge.titleEn)}। ${s.tr(nudge.bodyBn, nudge.bodyEn)}',
                      compact: true,
                      tag: 'home_nudge',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  String _moodEmoji(int score) {
    return switch (score) {
      1 => '😞',
      2 => '😟',
      3 => '😐',
      4 => '🙂',
      _ => '😊',
    };
  }
}

class _MiniMetricRow extends StatelessWidget {
  const _MiniMetricRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AccessibleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 68),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 26,
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.onSurface
                    : accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
