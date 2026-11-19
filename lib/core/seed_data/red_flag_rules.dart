/// Tier 1 Deterministic On-Device Red-Flag Gatekeeper.
/// Runs strictly BEFORE any LLM API call to guarantee zero latency and zero
/// hallucination on life-threatening Bangla, Banglish, and English symptoms.
class RedFlagMatch {
  const RedFlagMatch({
    required this.ruleId,
    required this.categoryBn,
    required this.categoryEn,
    required this.urgentTitleBn,
    required this.urgentTitleEn,
    required this.spokenAlertBn,
    required this.spokenAlertEn,
    required this.actionStepsBn,
    required this.actionStepsEn,
    required this.matchedKeyword,
    required this.recommendedHelpline,
  });

  final String ruleId;
  final String categoryBn;
  final String categoryEn;
  final String urgentTitleBn;
  final String urgentTitleEn;
  final String spokenAlertBn;
  final String spokenAlertEn;
  final List<String> actionStepsBn;
  final List<String> actionStepsEn;
  final String matchedKeyword;
  final String recommendedHelpline;
}

class _RedFlagRule {
  const _RedFlagRule({
    required this.id,
    required this.keywords,
    required this.categoryBn,
    required this.categoryEn,
    required this.urgentTitleBn,
    required this.urgentTitleEn,
    required this.actionStepsBn,
    required this.actionStepsEn,
    this.helpline = '16263',
  });

  final String id;
  final List<String> keywords;
  final String categoryBn;
  final String categoryEn;
  final String urgentTitleBn;
  final String urgentTitleEn;
  final List<String> actionStepsBn;
  final List<String> actionStepsEn;
  final String helpline;
}

abstract final class RedFlagEngine {
  static const String mandatoryBanglaVoiceAlert =
      'জরুরি সতর্কতা: অনুগ্রহ করে দেরি না করে দ্রুত নিকটস্থ হাসপাতাল বা ডাক্তারের পরামর্শ নিন।';
  static const String mandatoryEnglishVoiceAlert =
      'Urgent Warning: Please do not delay. Go to the nearest hospital or consult a doctor immediately.';

  static const List<_RedFlagRule> _rules = [
    _RedFlagRule(
      id: 'severe_hemorrhage',
      keywords: [
        'অতিরিক্ত রক্তপাত',
        'প্রচুর রক্ত',
        'রক্তক্ষরণ',
        'রক্ত যাচ্ছে বেশি',
        'রক্ত বন্ধ হচ্ছে না',
        'heavy bleeding',
        'hemorrhage',
        'soaking pads',
        'severe bleeding',
        'blood clots',
        'prochur rokto',
        'roktopat',
      ],
      categoryBn: 'অতিরিক্ত রক্তপাত / জরুরি অবস্থা',
      categoryEn: 'Severe Heavy Bleeding / Hemorrhage',
      urgentTitleBn: 'জরুরি সতর্কতা: অতিরিক্ত রক্তপাতের লক্ষণ পাওয়া গেছে!',
      urgentTitleEn: 'URGENT ALERT: Signs of Severe Bleeding Detected!',
      actionStepsBn: [
        'অবিলম্বে নিকটস্থ উপজেলা স্বাস্থ্য কমপ্লেক্স বা হাসপাতালে যান।',
        'একাকী থাকবেন না — পরিবারের কাউকে বা স্বনির্ভর দলের সদস্যকে সাথে নিন।',
        'জরুরি পরামর্শের জন্য এখনই ১৬২৬৩ (স্বাস্থ্য বাতায়ন) বা ৯৯৯ নম্বরে কল করুন।',
      ],
      actionStepsEn: [
        'Go immediately to the nearest Upazila Health Complex or emergency hospital.',
        'Do not stay alone — alert a family member or SHG leader right away.',
        'Call 16263 (Shastho Batayon) or 999 for emergency support.',
      ],
    ),
    _RedFlagRule(
      id: 'pregnancy_bleeding',
      keywords: [
        'গর্ভাবস্থায় রক্ত',
        'গর্ভবতী রক্ত',
        'পেটে বাচ্চা রক্ত',
        'গর্ভাবস্থায় তীব্র ব্যথা',
        'খিঁচুনি',
        'pregnancy bleeding',
        'bleeding while pregnant',
        'pregnant bleeding',
        'eclampsia',
        'seizure',
        'gorbhobosthay rokto',
      ],
      categoryBn: 'গর্ভকালীন বিপদ চিহ্ন',
      categoryEn: 'Maternal / Pregnancy Danger Sign',
      urgentTitleBn: 'জরুরি মাতৃস্বাস্থ্য সতর্কতা: দ্রুত হাসপাতালে যান!',
      urgentTitleEn: 'URGENT MATERNAL ALERT: Seek Hospital Care Now!',
      actionStepsBn: [
        'গর্ভাবস্থায় রক্তপাত, তীব্র মাথাব্যথা বা খিঁচুনি অত্যন্ত ঝুঁকিপূর্ণ।',
        'দেরি না করে জরুরি প্রসূতি সেবা আছে এমন হাসপাতালে যান।',
        'রক্তের প্রয়োজন হলে সূচনার "রক্ত SOS" বাটন ব্যবহার করুন।',
      ],
      actionStepsEn: [
        'Bleeding, severe headache, blurred vision, or seizures during pregnancy require immediate emergency obstetric care.',
        'Transport to the nearest Upazila Health Complex or district hospital immediately.',
        'Use SHUCHONA Blood SOS if emergency blood donors are needed.',
      ],
    ),
    _RedFlagRule(
      id: 'fainting_shock',
      keywords: [
        'অজ্ঞান',
        'জ্ঞান হারিয়ে',
        'মাথা ঘুরে পড়ে',
        'শ্বাস নিতে পারছি না',
        'বুকে তীব্র ব্যথা',
        'fainting',
        'fainted',
        'passed out',
        'unconscious',
        'chest pain',
        'cannot breathe',
        'oggan',
      ],
      categoryBn: 'অজ্ঞান হওয়া / বুকে ব্যথা / শ্বাসকষ্ট',
      categoryEn: 'Fainting / Chest Pain / Breathing Crisis',
      urgentTitleBn: 'জরুরি বিপদ সংকেত: দ্রুত জরুরি চিকিৎসা প্রয়োজন!',
      urgentTitleEn: 'URGENT MEDICAL RED FLAG: Immediate Care Needed!',
      actionStepsBn: [
        'রোগীকে নিরাপদ স্থানে শুইয়ে দিন এবং বাতাস চলাচলের ব্যবস্থা করুন।',
        'অবিলম্বে ৯৯৯ বা ১৬২৬৩ নম্বরে কল করে অ্যাম্বুলেন্স/চিকিৎসা নিন।',
        'নিকটস্থ হাসপাতালের জরুরি বিভাগে নিয়ে যান।',
      ],
      actionStepsEn: [
        'Help the person lie down safely with good airflow.',
        'Call 999 or 16263 immediately for emergency guidance/transport.',
        'Proceed directly to the nearest emergency department.',
      ],
    ),
    _RedFlagRule(
      id: 'breast_red_flag',
      keywords: [
        'শক্ত চাকা',
        'স্তনে শক্ত চাকা',
        'চামড়া কুঁচকে',
        'স্তন থেকে রক্ত',
        'বোটা থেকে রক্ত',
        'hard lump',
        'fixed breast lump',
        'skin dimpling',
        'nipple discharge',
        'bloody discharge',
        'stone shokto chaka',
      ],
      categoryBn: 'স্তনের জরুরি সতর্কতা লক্ষণ',
      categoryEn: 'Urgent Breast Evaluation Sign',
      urgentTitleBn: 'জরুরি চিকিৎসক পরামর্শ প্রয়োজন (স্তন পরীক্ষা)',
      urgentTitleEn: 'URGENT: Prompt Clinical Breast Examination Needed',
      actionStepsBn: [
        'স্তনে শক্ত ও নড়াচড়া না করা চাকা, চামড়া কুঁচকে যাওয়া বা বোঁটা থেকে রক্ত/তরল বের হওয়া অবহেলা করবেন না।',
        'এটি সবসময় ক্যান্সার নাও হতে পারে, তবে দ্রুত নারী ডাক্তার বা উপজেলা স্বাস্থ্য কমপ্লেক্সে পরীক্ষা করানো অত্যন্ত জরুরি।',
        '১৬২৬৩ নম্বরে কল করে নিকটস্থ নারী স্বাস্থ্য কেন্দ্রের তথ্য জানুন।',
      ],
      actionStepsEn: [
        'A hard, fixed breast lump, skin dimpling, or bloody nipple discharge must be examined promptly by a doctor.',
        'While many lumps are benign, early clinical evaluation is vital and can be life-saving.',
        'Call 16263 or tap Find Clinic to locate the nearest Women’s Health Center.',
      ],
    ),
    _RedFlagRule(
      id: 'self_harm_crisis',
      keywords: [
        'আত্মহত্যা',
        'মরে যেতে ইচ্ছা',
        'বেঁচে থাকতে চাই না',
        'নিজেকে শেষ',
        'নিজের ক্ষতি',
        'suicide',
        'self-harm',
        'self harm',
        'kill myself',
        'want to die',
        'end my life',
        'atmohatya',
      ],
      categoryBn: 'মানসিক সংকট / জরুরি সহায়তা',
      categoryEn: 'Emotional Crisis / Self-Harm Support',
      urgentTitleBn: 'আপনি একা নন — এখনই সাহায্য নিন',
      urgentTitleEn: 'You Are Not Alone — Immediate Human Support Available',
      actionStepsBn: [
        'আপনার জীবন অত্যন্ত মূল্যবান। অনুগ্রহ করে এখনই একজন প্রশিক্ষিত কাউন্সেলরের সাথে কথা বলুন।',
        'কান পেতে রই হেল্পলাইন (০১৭৭৯৫৫৪৩৯১) অথবা জাতীয় জরুরি সেবা ৯৯৯ / ১৬২৬৩-এ কল করুন।',
        'একজন বিশ্বস্ত বন্ধু বা পরিবারের সদস্যের পাশে বসুন।',
      ],
      actionStepsEn: [
        'Your life matters deeply. Please speak to a caring trained counselor right now.',
        'Call Kaan Pete Roi (01779554391), Shastho Batayon (16263), or 999 immediately.',
        'Stay near a trusted family member, friend, or SHG sister.',
      ],
      helpline: '01779554391',
    ),
  ];

  /// Deterministically scans text for any clinical red flag.
  /// Returns null if safe to proceed to Tier 2 symptom guidance / LLM.
  static RedFlagMatch? evaluate(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    for (final rule in _rules) {
      for (final kw in rule.keywords) {
        if (normalized.contains(kw.toLowerCase())) {
          return RedFlagMatch(
            ruleId: rule.id,
            categoryBn: rule.categoryBn,
            categoryEn: rule.categoryEn,
            urgentTitleBn: rule.urgentTitleBn,
            urgentTitleEn: rule.urgentTitleEn,
            spokenAlertBn: mandatoryBanglaVoiceAlert,
            spokenAlertEn: mandatoryEnglishVoiceAlert,
            actionStepsBn: rule.actionStepsBn,
            actionStepsEn: rule.actionStepsEn,
            matchedKeyword: kw,
            recommendedHelpline: rule.helpline,
          );
        }
      }
    }
    return null;
  }
}

