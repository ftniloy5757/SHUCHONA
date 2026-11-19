import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/offline_sync/hive_storage_service.dart';
import 'package:shuchona/core/seed_data/habits_seed.dart';
import 'package:shuchona/features/habit_tracker/habit_tracker_provider.dart';
import 'package:shuchona/features/prescribe_safe/prescribe_safe_provider.dart';

class MentalWellnessState {
  const MentalWellnessState({
    required this.sevenDayMoods,
    required this.todayMoodScore,
    required this.dailyTipIndex,
  });

  final List<MoodLogEntry> sevenDayMoods;
  final int todayMoodScore; // 1..5
  final int dailyTipIndex;

  MentalWellnessState copyWith({
    List<MoodLogEntry>? sevenDayMoods,
    int? todayMoodScore,
    int? dailyTipIndex,
  }) {
    return MentalWellnessState(
      sevenDayMoods: sevenDayMoods ?? this.sevenDayMoods,
      todayMoodScore: todayMoodScore ?? this.todayMoodScore,
      dailyTipIndex: dailyTipIndex ?? this.dailyTipIndex,
    );
  }
}

class MentalWellnessNotifier extends StateNotifier<MentalWellnessState> {
  MentalWellnessNotifier(this._ref) : super(_loadInitial());

  final Ref _ref;

  static MentalWellnessState _loadInitial() {
    final saved = HiveStorageService.instance
        .read<List<dynamic>>(AppConstants.boxMoods, 'seven_day_moods');
    List<MoodLogEntry> moods;
    if (saved != null && saved.length == 7) {
      moods = saved
          .whereType<Map<dynamic, dynamic>>()
          .map(MoodLogEntry.fromMap)
          .toList();
    } else {
      moods = HabitsSeed.defaultSevenDayMoods();
    }

    return MentalWellnessState(
      sevenDayMoods: moods,
      todayMoodScore: moods.last.score,
      dailyTipIndex: DateTime.now().day % 4,
    );
  }

  Future<void> setTodayMood(int score) async {
    final habits = _ref.read(habitTrackerProvider);
    final ratio = habits.isEmpty
        ? 0.5
        : habits.where((h) => h.completedToday).length / habits.length;

    final updatedList = [...state.sevenDayMoods];
    updatedList[updatedList.length - 1] = updatedList.last.copyWith(
      score: score,
      habitCompletionRate: ratio,
    );

    state = state.copyWith(
      sevenDayMoods: updatedList,
      todayMoodScore: score,
    );

    if (!_ref.read(shgGuestModeProvider)) {
      await HiveStorageService.instance.write(
        AppConstants.boxMoods,
        'seven_day_moods',
        updatedList.map((m) => m.toMap()).toList(),
      );
      _ref.read(offlineSyncProvider.notifier).recordSyncableAction(
        actionType: 'mood_checkin_anonymized',
        anonymizedPayload: {
          'moodBand': score <= 2 ? 'low' : (score == 3 ? 'neutral' : 'positive'),
          'upazila': _ref.read(userSessionProvider).upazila,
        },
      );
    }
  }

  void nextDailyTip() {
    state = state.copyWith(dailyTipIndex: (state.dailyTipIndex + 1) % 4);
  }
}

final mentalWellnessProvider =
    StateNotifierProvider<MentalWellnessNotifier, MentalWellnessState>((ref) {
  return MentalWellnessNotifier(ref);
});

/// Combines saved 7-day moods with today's live habit completion ratio so the
/// 7-day chart updates immediately whenever the user checks off a habit.
final liveSevenDayMoodsProvider = Provider<List<MoodLogEntry>>((ref) {
  final wellness = ref.watch(mentalWellnessProvider);
  final habits = ref.watch(habitTrackerProvider);
  if (wellness.sevenDayMoods.isEmpty) return const [];

  final liveRatio = habits.isEmpty
      ? 0.5
      : habits.where((h) => h.completedToday).length / habits.length;

  final list = [...wellness.sevenDayMoods];
  list[list.length - 1] = list.last.copyWith(habitCompletionRate: liveRatio);
  return list;
});

/// Context-Aware Personalized Guidance Engine (Module 13).
/// Dynamically combines recent mood dips, missed habit streaks, and active
/// PrescribeSafe BD medication schedules into tailored daily Bangla & English nudges.
class PersonalizedNudge {
  const PersonalizedNudge({
    required this.titleBn,
    required this.titleEn,
    required this.bodyBn,
    required this.bodyEn,
    required this.actionRoute,
    required this.actionLabelBn,
    required this.actionLabelEn,
    required this.emoji,
  });

  final String titleBn;
  final String titleEn;
  final String bodyBn;
  final String bodyEn;
  final String actionRoute;
  final String actionLabelBn;
  final String actionLabelEn;
  final String emoji;
}

String _toBnDigits(Object value) {
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  var out = value.toString();
  for (var i = 0; i < 10; i++) {
    out = out.replaceAll(en[i], bn[i]);
  }
  return out;
}

final personalizedGuidanceProvider = Provider<PersonalizedNudge>((ref) {
  final mood = ref.watch(mentalWellnessProvider);
  final habits = ref.watch(habitTrackerProvider);
  final rx = ref.watch(prescribeSafeProvider);

  // Priority 1: Recent low mood dip (score 1 or 2)
  if (mood.todayMoodScore <= 2) {
    return const PersonalizedNudge(
      titleBn: 'আজ মন কিছুটা ভারী — সূচনা আপনার পাশে আছে',
      titleEn: 'Noticed a Dip in Mood Today — Take a Gentle Pause',
      bodyBn:
          'আপনার আজকের মুড চেক-ইন অনুযায়ী মন কিছুটা খারাপ। ২ মিনিটের ৪-৪-৬ বাংলা শ্বাস-প্রশ্বাস অনুশীলন করলে মানসিক চাপ অনেকটা হালকা হবে।',
      bodyEn:
          'Your mood check-in shows today feels heavy. A 2-minute guided 4-4-6 breathing session can calm your nervous system right now.',
      actionRoute: '/craving-sos',
      actionLabelBn: 'শ্বাস-প্রশ্বাস শুরু করুন',
      actionLabelEn: 'Start Guided Breathing',
      emoji: '💙',
    );
  }

  // Priority 2: Active PrescribeSafe BD prescription has unscheduled alarms or DDI alert
  final activeRx = rx.currentResult;
  if (activeRx != null && activeRx.ddiAlerts.isNotEmpty) {
    return PersonalizedNudge(
      titleBn:
          'প্রেসক্রিপশন সতর্কতা: ${_toBnDigits(activeRx.ddiAlerts.length)}টি ওষুধ বিক্রিয়া যাচাই করুন',
      titleEn:
          'PrescribeSafe Notice: Review ${activeRx.ddiAlerts.length} Medication Safety Alert(s)',
      bodyBn:
          'আপনার সাম্প্রতিক স্ক্যান করা প্রেসক্রিপশনে গুরুত্বপূর্ণ ওষুধ সতর্কতা ও ৳${_toBnDigits(activeRx.totalSavingsBdt.round())} সাশ্রয়ের সুযোগ পাওয়া গেছে।',
      bodyEn:
          'Your recent prescription scan flagged critical safety warnings and ৳${activeRx.totalSavingsBdt.round()} in DGDA generic savings.',
      actionRoute: '/prescribe-safe',
      actionLabelBn: 'প্রেসক্রিপশন দেখুন',
      actionLabelEn: 'Review Prescription',
      emoji: '💊',
    );
  }

  // Priority 3: Missed critical habit today (e.g. Iron/Folic Acid or Sleep)
  final missedHabits = habits.where((h) => !h.completedToday).toList();
  if (missedHabits.isNotEmpty) {
    final firstMissed = missedHabits.first;
    return PersonalizedNudge(
      titleBn: 'আজকের বাকি অভ্যাস: ${firstMissed.titleBn}',
      titleEn: 'Keep Your Streak Alive: ${firstMissed.titleEn}',
      bodyBn:
          'আপনার ${_toBnDigits(firstMissed.streakDays)} দিনের ধারাবাহিকতা বজায় রাখতে এখনই "${firstMissed.titleBn}" সম্পন্ন করুন এবং স্বনির্ভর দলের লিডারবোর্ডে +১৫ XP অর্জন করুন!',
      bodyEn:
          'Protect your ${firstMissed.streakDays}-day streak by checking in "${firstMissed.titleEn}" now and earning +15 Weekly Improvement XP!',
      actionRoute: '/habits',
      actionLabelBn: 'অভ্যাস চেক-ইন করুন',
      actionLabelEn: 'Check In Habit',
      emoji: firstMissed.emoji,
    );
  }

  // Priority 4: Great momentum celebration
  return const PersonalizedNudge(
    titleBn: 'দারুণ ধারাবাহিকতা! আজ সব অভ্যাস সম্পন্ন',
    titleEn: 'Amazing Consistency! All Habits Completed Today',
    bodyBn:
        'আপনার মুড ও অভ্যাস দুটিই চমৎকার অবস্থায় আছে। আপনার স্বনির্ভর দলের (SHG) লিডারবোর্ডে আপনার উন্নতির অবস্থান দেখুন।',
    bodyEn:
        'Your mood and daily streaks are both thriving today. Check your Weekly Improvement XP rank in your SHG circle!',
    actionRoute: '/leaderboard',
    actionLabelBn: 'লিডারবোর্ড দেখুন',
    actionLabelEn: 'View Leaderboard',
    emoji: '🏆',
  );
});

