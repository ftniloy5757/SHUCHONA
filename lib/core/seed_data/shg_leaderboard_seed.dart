/// Privacy-preserving Habit Improvement Leaderboard seed data.
/// Uses floral/nature avatars & pseudonyms (or village SHG circles) ranked by
/// Weekly Improvement XP (% streak growth) — zero exposure of private habits.
class LeaderboardMember {
  const LeaderboardMember({
    required this.id,
    required this.pseudonymBn,
    required this.pseudonymEn,
    required this.avatarEmoji,
    required this.shgCircleBn,
    required this.shgCircleEn,
    required this.upazila,
    required this.weeklyImprovementXp,
    required this.streakGrowthPercent,
    required this.activeDaysThisWeek,
    this.isCurrentUser = false,
  });

  final String id;
  final String pseudonymBn;
  final String pseudonymEn;
  final String avatarEmoji;
  final String shgCircleBn;
  final String shgCircleEn;
  final String upazila;
  final int weeklyImprovementXp;
  final int streakGrowthPercent;
  final int activeDaysThisWeek;
  final bool isCurrentUser;

  LeaderboardMember copyWith({
    String? pseudonymBn,
    String? pseudonymEn,
    String? avatarEmoji,
    int? weeklyImprovementXp,
    int? streakGrowthPercent,
    int? activeDaysThisWeek,
  }) {
    return LeaderboardMember(
      id: id,
      pseudonymBn: pseudonymBn ?? this.pseudonymBn,
      pseudonymEn: pseudonymEn ?? this.pseudonymEn,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      shgCircleBn: shgCircleBn,
      shgCircleEn: shgCircleEn,
      upazila: upazila,
      weeklyImprovementXp: weeklyImprovementXp ?? this.weeklyImprovementXp,
      streakGrowthPercent: streakGrowthPercent ?? this.streakGrowthPercent,
      activeDaysThisWeek: activeDaysThisWeek ?? this.activeDaysThisWeek,
      isCurrentUser: isCurrentUser,
    );
  }
}

class ShgCohortEntry {
  const ShgCohortEntry({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.upazila,
    required this.memberCount,
    required this.weeklyImprovementXp,
    required this.avgGrowthPercent,
    required this.badgeEmoji,
    this.isUserCohort = false,
  });

  final String id;
  final String nameBn;
  final String nameEn;
  final String upazila;
  final int memberCount;
  final int weeklyImprovementXp;
  final int avgGrowthPercent;
  final String badgeEmoji;
  final bool isUserCohort;
}

abstract final class ShgLeaderboardSeed {
  static const List<LeaderboardMember> individuals = [
    LeaderboardMember(
      id: 'lb_1',
      pseudonymBn: 'শিউলি ভোর',
      pseudonymEn: 'Shiuli Dawn',
      avatarEmoji: '🌸',
      shgCircleBn: 'বিরুলিয়া আশা স্বনির্ভর দল',
      shgCircleEn: 'Birulia Asha SHG Circle',
      upazila: 'Savar, Dhaka',
      weeklyImprovementXp: 460,
      streakGrowthPercent: 68,
      activeDaysThisWeek: 7,
    ),
    LeaderboardMember(
      id: 'lb_2',
      pseudonymBn: 'সবুজ প্রভা',
      pseudonymEn: 'Emerald Morning',
      avatarEmoji: '🌿',
      shgCircleBn: 'ধামরাই আলো স্বনির্ভর দল',
      shgCircleEn: 'Dhamrai Alo SHG Circle',
      upazila: 'Dhamrai, Dhaka',
      weeklyImprovementXp: 425,
      streakGrowthPercent: 62,
      activeDaysThisWeek: 7,
    ),
    LeaderboardMember(
      id: 'lb_me',
      pseudonymBn: 'শাপলা কলি (আপনি)',
      pseudonymEn: 'Water Lily Bud (You)',
      avatarEmoji: '🪷',
      shgCircleBn: 'বিরুলিয়া আশা স্বনির্ভর দল',
      shgCircleEn: 'Birulia Asha SHG Circle',
      upazila: 'Savar, Dhaka',
      weeklyImprovementXp: 390,
      streakGrowthPercent: 54,
      activeDaysThisWeek: 6,
      isCurrentUser: true,
    ),
    LeaderboardMember(
      id: 'lb_4',
      pseudonymBn: 'সূর্যমুখী তারা',
      pseudonymEn: 'Sunflower Star',
      avatarEmoji: '🌻',
      shgCircleBn: 'কুমিল্লা প্রগতি দল',
      shgCircleEn: 'Cumilla Progoti Circle',
      upazila: 'Cumilla Sadar, Cumilla',
      weeklyImprovementXp: 355,
      streakGrowthPercent: 48,
      activeDaysThisWeek: 6,
    ),
    LeaderboardMember(
      id: 'lb_5',
      pseudonymBn: 'কদম বৃষ্টি',
      pseudonymEn: 'Kodom Rain',
      avatarEmoji: '🌼',
      shgCircleBn: 'বগুড়া সোনালী দল',
      shgCircleEn: 'Bogura Sonali SHG',
      upazila: 'Bogura Sadar, Bogura',
      weeklyImprovementXp: 320,
      streakGrowthPercent: 42,
      activeDaysThisWeek: 5,
    ),
    LeaderboardMember(
      id: 'lb_6',
      pseudonymBn: 'শান্ত নদী',
      pseudonymEn: 'Calm River',
      avatarEmoji: '🌊',
      shgCircleBn: 'বিরুলিয়া আশা স্বনির্ভর দল',
      shgCircleEn: 'Birulia Asha SHG Circle',
      upazila: 'Savar, Dhaka',
      weeklyImprovementXp: 280,
      streakGrowthPercent: 39,
      activeDaysThisWeek: 5,
    ),
    LeaderboardMember(
      id: 'lb_7',
      pseudonymBn: 'নতুন প্রজাপতি',
      pseudonymEn: 'New Butterfly',
      avatarEmoji: '🦋',
      shgCircleBn: 'রংপুর জাগরণ যুব দল',
      shgCircleEn: 'Rangpur Jagoron Youth',
      upazila: 'Rangpur Sadar, Rangpur',
      weeklyImprovementXp: 245,
      streakGrowthPercent: 35,
      activeDaysThisWeek: 4,
    ),
  ];

  static const List<ShgCohortEntry> villageCohorts = [
    ShgCohortEntry(
      id: 'cohort_1',
      nameBn: 'বিরুলিয়া আশা স্বনির্ভর দল',
      nameEn: 'Birulia Asha SHG Circle',
      upazila: 'Savar, Dhaka',
      memberCount: 28,
      weeklyImprovementXp: 4820,
      avgGrowthPercent: 58,
      badgeEmoji: '🪷',
      isUserCohort: true,
    ),
    ShgCohortEntry(
      id: 'cohort_2',
      nameBn: 'ধামরাই আলো নারী সমবায়',
      nameEn: 'Dhamrai Alo Women’s Collective',
      upazila: 'Dhamrai, Dhaka',
      memberCount: 24,
      weeklyImprovementXp: 4510,
      avgGrowthPercent: 52,
      badgeEmoji: '🌿',
    ),
    ShgCohortEntry(
      id: 'cohort_3',
      nameBn: 'কুমিল্লা প্রগতি যুব ও নারী দল',
      nameEn: 'Cumilla Progoti Youth & Women',
      upazila: 'Cumilla Sadar, Cumilla',
      memberCount: 31,
      weeklyImprovementXp: 4290,
      avgGrowthPercent: 47,
      badgeEmoji: '🌻',
    ),
    ShgCohortEntry(
      id: 'cohort_4',
      nameBn: 'বগুড়া সোনালী স্বাস্থ্য চক্র',
      nameEn: 'Bogura Sonali Health Circle',
      upazila: 'Bogura Sadar, Bogura',
      memberCount: 19,
      weeklyImprovementXp: 3840,
      avgGrowthPercent: 44,
      badgeEmoji: '🌼',
    ),
    ShgCohortEntry(
      id: 'cohort_5',
      nameBn: 'সিলেট সুরমা স্বনির্ভর দল',
      nameEn: 'Sylhet Surma SHG Network',
      upazila: 'Sylhet Sadar, Sylhet',
      memberCount: 22,
      weeklyImprovementXp: 3590,
      avgGrowthPercent: 41,
      badgeEmoji: '🌸',
    ),
  ];
}

