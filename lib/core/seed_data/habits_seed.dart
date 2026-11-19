enum HabitKind { buildHealthy, quitHarmful }

class HabitItem {
  const HabitItem({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.subtitleBn,
    required this.subtitleEn,
    required this.emoji,
    required this.kind,
    required this.streakDays,
    required this.completedToday,
    required this.reminderTime,
    required this.weeklyHistory, // 7 bools: Mon..Sun (index 6 = today)
  });

  final String id;
  final String titleBn;
  final String titleEn;
  final String subtitleBn;
  final String subtitleEn;
  final String emoji;
  final HabitKind kind;
  final int streakDays;
  final bool completedToday;
  final String reminderTime;
  final List<bool> weeklyHistory;

  HabitItem copyWith({
    int? streakDays,
    bool? completedToday,
    String? reminderTime,
    List<bool>? weeklyHistory,
  }) {
    return HabitItem(
      id: id,
      titleBn: titleBn,
      titleEn: titleEn,
      subtitleBn: subtitleBn,
      subtitleEn: subtitleEn,
      emoji: emoji,
      kind: kind,
      streakDays: streakDays ?? this.streakDays,
      completedToday: completedToday ?? this.completedToday,
      reminderTime: reminderTime ?? this.reminderTime,
      weeklyHistory: weeklyHistory ?? this.weeklyHistory,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'titleBn': titleBn,
        'titleEn': titleEn,
        'subtitleBn': subtitleBn,
        'subtitleEn': subtitleEn,
        'emoji': emoji,
        'kind': kind.name,
        'streakDays': streakDays,
        'completedToday': completedToday,
        'reminderTime': reminderTime,
        'weeklyHistory': weeklyHistory,
      };

  factory HabitItem.fromMap(Map<dynamic, dynamic> map) {
    return HabitItem(
      id: map['id'] as String,
      titleBn: map['titleBn'] as String,
      titleEn: map['titleEn'] as String,
      subtitleBn: map['subtitleBn'] as String? ?? '',
      subtitleEn: map['subtitleEn'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '✨',
      kind: (map['kind'] as String?) == HabitKind.quitHarmful.name
          ? HabitKind.quitHarmful
          : HabitKind.buildHealthy,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      completedToday: map['completedToday'] as bool? ?? false,
      reminderTime: map['reminderTime'] as String? ?? '08:00',
      weeklyHistory: (map['weeklyHistory'] as List<dynamic>?)
              ?.map((e) => e == true)
              .toList() ??
          [true, true, false, true, true, true, false],
    );
  }
}

class MoodLogEntry {
  const MoodLogEntry({
    required this.dayLabelBn,
    required this.dayLabelEn,
    required this.score, // 1 (খুব খারাপ) to 5 (খুব ভালো)
    required this.habitCompletionRate, // 0.0 to 1.0
    required this.note,
  });

  final String dayLabelBn;
  final String dayLabelEn;
  final int score;
  final double habitCompletionRate;
  final String note;

  MoodLogEntry copyWith({
    int? score,
    double? habitCompletionRate,
    String? note,
  }) {
    return MoodLogEntry(
      dayLabelBn: dayLabelBn,
      dayLabelEn: dayLabelEn,
      score: score ?? this.score,
      habitCompletionRate: habitCompletionRate ?? this.habitCompletionRate,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'dayLabelBn': dayLabelBn,
        'dayLabelEn': dayLabelEn,
        'score': score,
        'habitCompletionRate': habitCompletionRate,
        'note': note,
      };

  factory MoodLogEntry.fromMap(Map<dynamic, dynamic> map) => MoodLogEntry(
        dayLabelBn: map['dayLabelBn'] as String,
        dayLabelEn: map['dayLabelEn'] as String,
        score: (map['score'] as num).toInt(),
        habitCompletionRate: (map['habitCompletionRate'] as num).toDouble(),
        note: map['note'] as String? ?? '',
      );
}

abstract final class HabitsSeed {
  static List<HabitItem> defaultHabits() => const [
        HabitItem(
          id: 'h_water',
          titleBn: '৮ গ্লাস নিরাপদ পানি',
          titleEn: 'Drink 8 Glasses Water',
          subtitleBn: 'প্রতিদিন পর্যাপ্ত পানি পান করুন',
          subtitleEn: 'Stay hydrated throughout the day',
          emoji: '💧',
          kind: HabitKind.buildHealthy,
          streakDays: 9,
          completedToday: true,
          reminderTime: '10:00',
          weeklyHistory: [true, true, true, true, true, true, true],
        ),
        HabitItem(
          id: 'h_iron',
          titleBn: 'আয়রন ও ফলিক এসিড ট্যাবলেট',
          titleEn: 'Iron / Folic Acid Tablet',
          subtitleBn: 'রক্তশূন্যতা প্রতিরোধে প্রতিদিন ১টি',
          subtitleEn: 'Daily supplement to prevent anemia',
          emoji: '💊',
          kind: HabitKind.buildHealthy,
          streakDays: 6,
          completedToday: false,
          reminderTime: '20:30',
          weeklyHistory: [true, true, false, true, true, true, false],
        ),
        HabitItem(
          id: 'h_walk',
          titleBn: '২০ মিনিট হাঁটা',
          titleEn: '20-Min Brisk Walk',
          subtitleBn: 'হরমোন ও হৃদযন্ত্র সুস্থ রাখে',
          subtitleEn: 'Supports hormonal & heart health',
          emoji: '🚶‍♀️',
          kind: HabitKind.buildHealthy,
          streakDays: 5,
          completedToday: true,
          reminderTime: '17:00',
          weeklyHistory: [false, true, true, true, true, true, true],
        ),
        HabitItem(
          id: 'h_sleep',
          titleBn: 'রাত ১১টার আগে ঘুম',
          titleEn: 'Sleep Before 11 PM',
          subtitleBn: 'পর্যাপ্ত বিশ্রাম ও মানসিক প্রশান্তি',
          subtitleEn: 'Deep rest for mood and hormonal balance',
          emoji: '🌙',
          kind: HabitKind.buildHealthy,
          streakDays: 4,
          completedToday: false,
          reminderTime: '22:30',
          weeklyHistory: [true, false, true, true, true, false, false],
        ),
        HabitItem(
          id: 'h_quit_jarda',
          titleBn: 'পান-জর্দা / গুল বর্জন',
          titleEn: 'Zero Betel Nut / Jarda',
          subtitleBn: 'মুখের ক্যান্সার ও গ্যাস্ট্রিক থেকে সুরক্ষা',
          subtitleEn: 'Tobacco-free day for oral & gastric safety',
          emoji: '🍃',
          kind: HabitKind.quitHarmful,
          streakDays: 12,
          completedToday: true,
          reminderTime: '14:00',
          weeklyHistory: [true, true, true, true, true, true, true],
        ),
        HabitItem(
          id: 'h_quit_smoking',
          titleBn: 'ধূমপান / বিড়ি মুক্ত দিন',
          titleEn: 'Smoke-Free Day',
          subtitleBn: 'ফুসফুস ও পরিবারের সুস্থতার জন্য',
          subtitleEn: 'Clean lungs for you and your family',
          emoji: '🚭',
          kind: HabitKind.quitHarmful,
          streakDays: 8,
          completedToday: true,
          reminderTime: '16:00',
          weeklyHistory: [true, true, true, false, true, true, true],
        ),
        HabitItem(
          id: 'h_quit_sugar',
          titleBn: 'অতিরিক্ত চিনি কমানো',
          titleEn: 'Avoid Excess Sugar',
          subtitleBn: 'ডায়াবেটিস ও পিসিওএস নিয়ন্ত্রণে সহায়ক',
          subtitleEn: 'Helps control PCOS and blood glucose',
          emoji: '🍵',
          kind: HabitKind.quitHarmful,
          streakDays: 3,
          completedToday: false,
          reminderTime: '11:00',
          weeklyHistory: [false, false, true, true, true, false, false],
        ),
      ];

  static List<MoodLogEntry> defaultSevenDayMoods() => const [
        MoodLogEntry(
          dayLabelBn: 'শনি',
          dayLabelEn: 'Sat',
          score: 3,
          habitCompletionRate: 0.57,
          note: 'Mild fatigue',
        ),
        MoodLogEntry(
          dayLabelBn: 'রবি',
          dayLabelEn: 'Sun',
          score: 4,
          habitCompletionRate: 0.71,
          note: 'Good walk',
        ),
        MoodLogEntry(
          dayLabelBn: 'সোম',
          dayLabelEn: 'Mon',
          score: 2,
          habitCompletionRate: 0.43,
          note: 'Work stress',
        ),
        MoodLogEntry(
          dayLabelBn: 'মঙ্গল',
          dayLabelEn: 'Tue',
          score: 4,
          habitCompletionRate: 0.85,
          note: 'SHG meeting',
        ),
        MoodLogEntry(
          dayLabelBn: 'বুধ',
          dayLabelEn: 'Wed',
          score: 4,
          habitCompletionRate: 0.71,
          note: 'Calm evening',
        ),
        MoodLogEntry(
          dayLabelBn: 'বৃহঃ',
          dayLabelEn: 'Thu',
          score: 5,
          habitCompletionRate: 0.86,
          note: 'Feeling energetic',
        ),
        MoodLogEntry(
          dayLabelBn: 'আজ',
          dayLabelEn: 'Today',
          score: 4,
          habitCompletionRate: 0.57,
          note: 'Checked in',
        ),
      ];
}

