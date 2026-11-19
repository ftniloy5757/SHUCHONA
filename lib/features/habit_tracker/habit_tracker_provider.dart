import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/offline_sync/hive_storage_service.dart';
import 'package:shuchona/core/seed_data/habits_seed.dart';
import 'package:uuid/uuid.dart';

class HabitTrackerNotifier extends StateNotifier<List<HabitItem>> {
  HabitTrackerNotifier(this._ref) : super(_loadInitial());

  final Ref _ref;
  final _uuid = const Uuid();

  static List<HabitItem> _loadInitial() {
    final saved = HiveStorageService.instance
        .read<List<dynamic>>(AppConstants.boxHabits, 'habit_list');
    if (saved != null && saved.isNotEmpty) {
      return saved
          .whereType<Map<dynamic, dynamic>>()
          .map(HabitItem.fromMap)
          .toList();
    }
    return HabitsSeed.defaultHabits();
  }

  Future<void> _persist() async {
    // Respect SHG Facilitator Guest Mode: do not overwrite personal logs!
    if (_ref.read(shgGuestModeProvider)) return;
    await HiveStorageService.instance.write(
      AppConstants.boxHabits,
      'habit_list',
      state.map((h) => h.toMap()).toList(),
    );
  }

  Future<void> toggleHabitToday(String id) async {
    state = [
      for (final h in state)
        if (h.id == id)
          h.copyWith(
            completedToday: !h.completedToday,
            streakDays:
                !h.completedToday ? h.streakDays + 1 : (h.streakDays - 1).clamp(0, 999),
            weeklyHistory: [
              ...h.weeklyHistory.take(6),
              !h.completedToday,
            ],
          )
        else
          h,
    ];
    await _persist();

    if (!_ref.read(shgGuestModeProvider)) {
      _ref.read(offlineSyncProvider.notifier).recordSyncableAction(
        actionType: 'habit_checkin_anonymized',
        anonymizedPayload: {
          'completedRatio': todayCompletionRatio,
          'upazila': _ref.read(userSessionProvider).upazila,
        },
      );
    }
  }

  Future<void> addCustomHabit({
    required String titleBn,
    required String titleEn,
    required String emoji,
    required HabitKind kind,
  }) async {
    final newHabit = HabitItem(
      id: _uuid.v4(),
      titleBn: titleBn,
      titleEn: titleEn,
      subtitleBn: kind == HabitKind.buildHealthy
          ? 'নিজের গড়া সুস্থ অভ্যাস'
          : 'ক্ষতিকর অভ্যাস ত্যাগের লক্ষ্য',
      subtitleEn: kind == HabitKind.buildHealthy
          ? 'Personal healthy routine'
          : 'Harmful habit quit goal',
      emoji: emoji,
      kind: kind,
      streakDays: 1,
      completedToday: true,
      reminderTime: '09:00',
      weeklyHistory: const [false, false, false, false, false, false, true],
    );
    state = [...state, newHabit];
    await _persist();
  }

  double get todayCompletionRatio {
    if (state.isEmpty) return 0;
    final done = state.where((h) => h.completedToday).length;
    return done / state.length;
  }
}

final habitTrackerProvider =
    StateNotifierProvider<HabitTrackerNotifier, List<HabitItem>>((ref) {
  return HabitTrackerNotifier(ref);
});

