import 'package:shuchona/core/localization/app_locale.dart';

/// Centralized bilingual strings for SHUCHONA (সূচনা).
/// Provides instant runtime localization between Bangla (default) and English.
class AppStrings {
  const AppStrings(this.locale);

  final AppLocale locale;

  bool get isBn => locale.isBangla;

  String tr(String bn, String en) => isBn ? bn : en;

  // Brand & Core Disclaimers
  String get appName => tr('সূচনা', 'SHUCHONA');
  String get appFullTitle =>
      tr('সূচনা — আপনার স্বাস্থ্য সাথী', 'SHUCHONA — Health Companion');
  String get speakToShuchona => tr('সূচনাকে বলুন', 'Speak to SHUCHONA');
  String get listen => tr('শুনুন', 'Listen');
  String get stopListeningAudio => tr('থামুন', 'Stop');

  String get mandatoryDisclaimer => tr(
    'এটি শুধুমাত্র AI-ভিত্তিক প্রাথমিক তথ্য, কোনো চিকিৎসা নির্ণয় নয়। অনুগ্রহ করে একজন ডাক্তারের পরামর্শ নিন।',
    'This is AI guidance only, not a medical diagnosis. Please consult a doctor.',
  );

  String get urgentRedFlagSpeech => tr(
    'জরুরি সতর্কতা: অনুগ্রহ করে দেরি না করে দ্রুত নিকটস্থ হাসপাতাল বা ডাক্তারের পরামর্শ নিন।',
    'Urgent Alert: Please do not delay. Visit the nearest hospital or consult a doctor immediately.',
  );

  // Sync & Status
  String get onlineSynced => tr('অনলাইনে আছে', 'Online');
  String get offlineSaved =>
      tr('অফলাইন · তথ্য ফোনে আছে', 'Offline · Data saved on this device');
  String get syncingNow => tr('তথ্য মিলিয়ে নেওয়া হচ্ছে…', 'Syncing…');

  // SHG Facilitator Guest Mode
  String get guestModeTitle => tr('অতিথি মোড', 'SHG Guest');
  String get guestModeBanner => tr(
    'স্বনির্ভর দল (SHG) অতিথি মোড চালু — কোনো ব্যক্তিগত তথ্য সংরক্ষিত হবে না (জিরো-ট্রেস সেশন)',
    'SHG Facilitator Guest Mode Active — Zero-Trace Session (Personal logs protected)',
  );
  String get exitGuestMode => tr('অতিথি মোড বন্ধ করুন', 'Exit Guest Mode');

  // Bottom Navigation
  String get navHome => tr('শুরু', 'Home');
  String get navRx => tr('ওষুধ', 'Medicine');
  String get navSymptoms => tr('নারী স্বাস্থ্য', 'Women');
  String get navHabits => tr('অভ্যাস', 'Habits');
  String get navBlood => tr('রক্ত', 'Blood');
  String get navCare => tr('হাসপাতাল', 'Find Care');

  // Craving & Crisis SOS
  String get strugglingCta => tr('আমি কষ্টে আছি', 'I’m Struggling');
  String get strugglingSubtitle => tr(
    'তাৎক্ষণিক শ্বাস-প্রশ্বাস অনুশীলন ও সহায়তা',
    'Instant guided breathing & calm support',
  );
  String get call16263 => tr('১৬২৬৩ কল করুন', 'Call 16263');
  String get findClinic => tr('নিকটস্থ ক্লিনিক খুঁজুন', 'Find Clinic');

  // Role Switcher
  String get communityUserView =>
      tr('কমিউনিটি ব্যবহারকারী', 'Community User View');
  String get adminDashboardView =>
      tr('এনজিও / অ্যাডমিন ড্যাশবোর্ড', 'NGO / Admin Impact Dashboard');
  String get zeroPiiBadge => tr(
    'কোনো ব্যক্তিগত তথ্য (PII) সংরক্ষিত নয় — সব পরিচয় ডিভাইসেই মুছে ফেলা হয়।',
    'Zero PII Stored — All Identifiers Stripped On-Device Before Aggregation.',
  );

  // Bangla digit conversion helper
  String formatDigits(String input) {
    if (!isBn) return input;
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var out = input;
    for (var i = 0; i < en.length; i++) {
      out = out.replaceAll(en[i], bn[i]);
    }
    return out;
  }

  String formatTaka(num amount) {
    final fixed = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(1);
    return '৳${formatDigits(fixed)}';
  }
}
