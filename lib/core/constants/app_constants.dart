/// App-wide constants, helplines, Upazila list, and configuration keys.
abstract final class AppConstants {
  /// Passed via: flutter run --dart-define=GEMINI_API_KEY=your_key
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String geminiModel = 'gemini-2.0-flash';

  /// National Bangladesh Emergency & Health Helplines
  static const String shasthoBatayonHelpline = '16263';
  static const String nationalEmergencyHelpline = '999';
  static const String womenChildrenHelpline = '109';
  static const String kaanPeteRoiHelpline = '01779554391';
  static const String monerBondhuHelpline = '01776632344';

  /// PrescribeSafe BD confidence gate threshold (85%)
  static const double ocrConfidenceThreshold = 0.85;

  /// Blood donation mandatory medical cooldown (90 days)
  static const int bloodCooldownDays = 90;

  /// Supported Upazilas / Districts across rural & peri-urban Bangladesh
  static const List<String> bangladeshUpazilas = [
    'Savar, Dhaka',
    'Dhamrai, Dhaka',
    'Cumilla Sadar, Cumilla',
    'Bogura Sadar, Bogura',
    'Rangpur Sadar, Rangpur',
    'Sylhet Sadar, Sylhet',
    'Mymensingh Sadar, Mymensingh',
    'Jessore Sadar, Jashore',
  ];

  static const Map<String, String> upazilaBanglaNames = {
    'Savar, Dhaka': 'সাভার, ঢাকা',
    'Dhamrai, Dhaka': 'ধামরাই, ঢাকা',
    'Cumilla Sadar, Cumilla': 'কুমিল্লা সদর, কুমিল্লা',
    'Bogura Sadar, Bogura': 'বগুড়া সদর, বগুড়া',
    'Rangpur Sadar, Rangpur': 'রংপুর সদর, রংপুর',
    'Sylhet Sadar, Sylhet': 'সিলেট সদর, সিলেট',
    'Mymensingh Sadar, Mymensingh': 'ময়মনসিংহ সদর, ময়মনসিংহ',
    'Jessore Sadar, Jashore': 'যশোর সদর, যশোর',
  };

  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
    'Unknown',
  ];

  /// Privacy-safe floral & nature avatars for the Habit Improvement Leaderboard
  static const List<Map<String, String>> natureAvatars = [
    {'id': 'shapla', 'emoji': '🪷', 'bn': 'শাপলা ফুল', 'en': 'Water Lily'},
    {'id': 'kodom', 'emoji': '🌼', 'bn': 'কদম ফুল', 'en': 'Kodom Blossom'},
    {'id': 'shiuli', 'emoji': '🌸', 'bn': 'শিউলি ফুল', 'en': 'Shiuli Jasmine'},
    {'id': 'pata', 'emoji': '🌿', 'bn': 'সবুজ পাতা', 'en': 'Emerald Leaf'},
    {'id': 'surjo', 'emoji': '🌻', 'bn': 'সূর্যমুখী', 'en': 'Sunflower'},
    {'id': 'bhor', 'emoji': '🌅', 'bn': 'ভোরের আলো', 'en': 'Morning Dawn'},
    {'id': 'prajapati', 'emoji': '🦋', 'bn': 'প্রজাপতি', 'en': 'Butterfly'},
    {'id': 'nodi', 'emoji': '🌊', 'bn': 'শান্ত নদী', 'en': 'Calm River'},
  ];

  /// Hive Box Names
  static const String boxProfile = 'shuchona_profile';
  static const String boxHabits = 'shuchona_habits';
  static const String boxMoods = 'shuchona_moods';
  static const String boxSyncQueue = 'shuchona_sync_queue';
  static const String boxBlood = 'shuchona_blood';
  static const String boxPrescriptions = 'shuchona_prescriptions';
  static const String boxReminders = 'shuchona_reminders';
}

