import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/seed_data/red_flag_rules.dart';

enum SymptomTopicId {
  irregularPeriods,
  severeCramps,
  pcosIndicators,
  breastAwareness,
  reproductiveWellness,
}

class SymptomFollowUpQuestion {
  const SymptomFollowUpQuestion({
    required this.id,
    required this.questionBn,
    required this.questionEn,
    required this.optionsBn,
    required this.optionsEn,
    this.redFlagOptionIndex,
    this.redFlagTriggerText,
  });

  final String id;
  final String questionBn;
  final String questionEn;
  final List<String> optionsBn;
  final List<String> optionsEn;
  final int? redFlagOptionIndex;
  final String? redFlagTriggerText;
}

class SymptomTopic {
  const SymptomTopic({
    required this.id,
    required this.emoji,
    required this.titleBn,
    required this.titleEn,
    required this.subtitleBn,
    required this.subtitleEn,
    required this.questions,
    required this.guidanceTitleBn,
    required this.guidanceTitleEn,
    required this.possiblePatternsBn,
    required this.possiblePatternsEn,
    required this.whyThisGuidanceBn,
    required this.whyThisGuidanceEn,
    required this.selfCareStepsBn,
    required this.selfCareStepsEn,
  });

  final SymptomTopicId id;
  final String emoji;
  final String titleBn;
  final String titleEn;
  final String subtitleBn;
  final String subtitleEn;
  final List<SymptomFollowUpQuestion> questions;
  final String guidanceTitleBn;
  final String guidanceTitleEn;
  final String possiblePatternsBn;
  final String possiblePatternsEn;
  final String whyThisGuidanceBn;
  final String whyThisGuidanceEn;
  final List<String> selfCareStepsBn;
  final List<String> selfCareStepsEn;
}

abstract final class WomensSymptomTopics {
  static const List<SymptomTopic> all = [
    SymptomTopic(
      id: SymptomTopicId.irregularPeriods,
      emoji: '🗓️',
      titleBn: 'অনিয়মিত মাসিক',
      titleEn: 'Irregular Periods',
      subtitleBn: 'দেরি হওয়া, ঘন ঘন হওয়া বা বন্ধ থাকা',
      subtitleEn: 'Delayed, skipped, or frequent cycles',
      questions: [
        SymptomFollowUpQuestion(
          id: 'q1',
          questionBn: 'আপনার মাসিক কত দিন ধরে অনিয়মিত?',
          questionEn: 'How long have your periods been irregular?',
          optionsBn: ['এই প্রথমবার (১ মাস)', '২–৩ মাস ধরে', '৩ মাসের বেশি সময় ধরে'],
          optionsEn: ['First time (1 month)', '2–3 months', 'More than 3 months'],
        ),
        SymptomFollowUpQuestion(
          id: 'q2',
          questionBn: 'অতিরিক্ত রক্তপাত (প্রতি ঘণ্টায় প্যাড ভরে যাওয়া) বা মাথা ঘুরে পড়ে যাওয়া কি হচ্ছে?',
          questionEn: 'Are you experiencing severe heavy bleeding (soaking pads hourly) or fainting?',
          optionsBn: ['না, রক্তপাত স্বাভাবিক বা কম', 'হ্যাঁ, অতিরিক্ত রক্তপাত / মাথা ঘুরে যাচ্ছে'],
          optionsEn: ['No, normal or light flow', 'Yes, severe heavy bleeding / fainting'],
          redFlagOptionIndex: 1,
          redFlagTriggerText: 'অতিরিক্ত রক্তপাত heavy bleeding fainting',
        ),
        SymptomFollowUpQuestion(
          id: 'q3',
          questionBn: 'আপনার কি গর্ভধারণের সম্ভাবনা রয়েছে?',
          questionEn: 'Could there be any chance of pregnancy?',
          optionsBn: ['না', 'নিশ্চিত নই / হতে পারে'],
          optionsEn: ['No', 'Unsure / Possibly'],
        ),
      ],
      guidanceTitleBn: 'অনিয়মিত মাসিক — প্রাথমিক স্বাস্থ্য নির্দেশনা',
      guidanceTitleEn: 'Irregular Periods — Grounded Health Guidance',
      possiblePatternsBn:
          'আপনার উত্তরের ধরন অনুযায়ী এটি হরমোনের অস্থায়ী পরিবর্তন, পিসিওএস (PCOS), রক্তশূন্যতা, থাইরয়েডের সমস্যা অথবা মানসিক চাপের সাথে সম্পর্কিত হতে পারে।',
      possiblePatternsEn:
          'Based on your answers, this pattern commonly relates to hormonal shifts (such as PCOS), thyroid imbalance, iron-deficiency anemia, or sustained stress.',
      whyThisGuidanceBn:
          'WHO ও DGHS প্রজনন স্বাস্থ্য নির্দেশিকা অনুযায়ী ৩৫ দিনের বেশি চক্র ব্যবধান বা একাধিক মাস মাসিক মিস হলে হরমোন ও হিমোগ্লোবিন পরীক্ষা করানো নিরাপদ এবং কার্যকর।',
      whyThisGuidanceEn:
          'Per WHO & DGHS reproductive health guidelines, cycles exceeding 35 days or repeated missed periods benefit from simple hemoglobin and hormonal checks rather than waiting silently.',
      selfCareStepsBn: [
        'প্রতি মাসে মাসিক শুরু ও শেষ হওয়ার তারিখ সূচনায় লিখে রাখুন।',
        'প্রতিদিন ২০ মিনিট হাঁটা, পর্যাপ্ত ঘুম ও সুষম খাবার (শাকসবজি, ডাল, ডিম) খান।',
        'নিকটস্থ উপজেলা স্বাস্থ্য কমপ্লেক্স বা নারী স্বাস্থ্য কেন্দ্রে গাইনি ডাক্তারের পরামর্শ নিন।',
      ],
      selfCareStepsEn: [
        'Log cycle start and end dates every month to share with your doctor.',
        'Walk 20 minutes daily, prioritize sleep before 11 PM, and eat iron-rich foods.',
        'Book a checkup with a female physician at your Upazila Health Complex.',
      ],
    ),
    SymptomTopic(
      id: SymptomTopicId.severeCramps,
      emoji: '🩹',
      titleBn: 'মাসিকের তীব্র পেটব্যথা',
      titleEn: 'Severe Menstrual Cramps',
      subtitleBn: 'তলপেটে বা কোমরে ব্যথা ও অস্বস্তি',
      subtitleEn: 'Lower abdominal or back pain during periods',
      questions: [
        SymptomFollowUpQuestion(
          id: 'q1',
          questionBn: 'ব্যথার তীব্রতা কেমন এবং কত দিন থাকে?',
          questionEn: 'How intense is the pain and how long does it last?',
          optionsBn: ['হালকা ব্যথা (১–২ দিন)', 'মাঝারি ব্যথা, কাজে কষ্ট হয়', 'তীব্র ব্যথা, বিছানা ছাড়া যায় না'],
          optionsEn: ['Mild cramps (1–2 days)', 'Moderate, disrupts work', 'Severe, bedridden'],
        ),
        SymptomFollowUpQuestion(
          id: 'q2',
          questionBn: 'ব্যথার সাথে কি অতিরিক্ত রক্তপাত, জ্বর বা অজ্ঞান হওয়ার ভাব আছে?',
          questionEn: 'Is pain paired with heavy bleeding, high fever, or fainting?',
          optionsBn: ['না, শুধু ব্যথা আছে', 'হ্যাঁ, প্রচুর রক্তপাত বা অজ্ঞান ভাব আছে'],
          optionsEn: ['No, cramps only', 'Yes, heavy bleeding or fainting'],
          redFlagOptionIndex: 1,
          redFlagTriggerText: 'প্রচুর রক্ত অজ্ঞান heavy bleeding fainting',
        ),
      ],
      guidanceTitleBn: 'মাসিকের ব্যথা (ডিসমেনোরিয়া) — প্রাথমিক তথ্য',
      guidanceTitleEn: 'Menstrual Cramps (Dysmenorrhea) — Guidance',
      possiblePatternsBn:
          'মাসিকের প্রথম ১–২ দিনের ব্যথা সাধারণত প্রাইমারি ডিসমেনোরিয়া বা পিএমএস (PMS)-এর কারণে হয়। তবে ব্যথা ক্রমাগত বাড়লে এন্ডোমেট্রিওসিস বা সংক্রমণ পরীক্ষা করা জরুরি।',
      possiblePatternsEn:
          'Pain in the first 1–2 days commonly matches primary dysmenorrhea or PMS. Progressively worsening cramps should be checked by a doctor to rule out endometriosis or pelvic infection.',
      whyThisGuidanceBn:
          'উষ্ণ সেঁক ও হালকা ব্যায়াম জরায়ুর পেশী শিথিল করে (WHO প্রাথমিক যত্ন নির্দেশিকা), তবে প্রতি মাসে কাজ বন্ধ হয়ে যাওয়া ব্যথার চিকিৎসক মূল্যায়ন প্রয়োজন।',
      whyThisGuidanceEn:
          'Heat therapy and hydration relax uterine smooth muscle (WHO primary care), while debilitating monthly pain warrants a clinical exam to rule out treatable secondary causes.',
      selfCareStepsBn: [
        'তলপেটে কুসুম গরম পানির সেঁক (১৫–২০ মিনিট) দিন।',
        'কুসুম গরম পানি ও আদা চা পান করুন; অতিরিক্ত ক্যাফেইন ও ঝাল খাবার এড়িয়ে চলুন।',
        'ডাক্তারের পরামর্শ ছাড়া বারবার ব্যথার ওষুধ (NSAID) খাবেন না।',
      ],
      selfCareStepsEn: [
        'Apply a warm water compress to the lower abdomen for 15–20 minutes.',
        'Sip warm water or ginger tea and avoid excessive salty or caffeinated drinks.',
        'Avoid repeated self-medicated painkillers without a doctor’s guidance.',
      ],
    ),
    SymptomTopic(
      id: SymptomTopicId.pcosIndicators,
      emoji: '⚖️',
      titleBn: 'হরমোন ও পিসিওএস (PCOS)',
      titleEn: 'Hormonal & PCOS Indicators',
      subtitleBn: 'অতিরিক্ত ব্রণ, মুখের লোম, ওজন বাড়া ও ক্লান্তি',
      subtitleEn: 'Acne, facial hair, weight gain, fatigue',
      questions: [
        SymptomFollowUpQuestion(
          id: 'q1',
          questionBn: 'আপনার কি অনিয়মিত মাসিকের সাথে হঠাৎ ওজন বাড়া বা অতিরিক্ত ব্রণ/মুখের লোম দেখা দিয়েছে?',
          questionEn: 'Do you notice irregular periods along with sudden weight gain, acne, or facial hair?',
          optionsBn: ['শুধু ১টি লক্ষণ আছে', '২টি বা তার বেশি লক্ষণ আছে'],
          optionsEn: ['Only 1 of these signs', '2 or more of these signs'],
        ),
        SymptomFollowUpQuestion(
          id: 'q2',
          questionBn: 'আপনার কি প্রায়ই তীব্র ক্লান্তি, ঘাড়ে কালচে দাগ বা অতিরিক্ত মিষ্টি খাওয়ার ইচ্ছা হয়?',
          questionEn: 'Do you feel frequent fatigue, dark velvety neck skin, or strong sugar cravings?',
          optionsBn: ['হ্যাঁ, প্রায়ই হয়', 'না, তেমন নয়'],
          optionsEn: ['Yes, frequently', 'No, rarely'],
        ),
      ],
      guidanceTitleBn: 'হরমোন ও পিসিওএস সচেতনতা নির্দেশনা',
      guidanceTitleEn: 'Hormonal & PCOS Awareness Guidance',
      possiblePatternsBn:
          'একাধিক লক্ষণ একসাথে থাকা পলিসিস্টিক ওভারি সিনড্রোম (PCOS) বা ইনসুলিন রেজিস্ট্যান্সের সাধারণ ইঙ্গিত হতে পারে — এটি খুব পরিচিত এবং জীবনযাত্রার পরিবর্তন ও চিকিৎসায় পুরোপুরি নিয়ন্ত্রণযোগ্য।',
      possiblePatternsEn:
          'Having several of these patterns together can align with Polycystic Ovary Syndrome (PCOS) or insulin resistance — a very common, manageable condition with lifestyle care and medical guidance.',
      whyThisGuidanceBn:
          'রটারড্যাম/WHO নির্দেশিকা অনুযায়ী অনিয়মিত চক্র ও হরমোনের বাহ্যিক লক্ষণ থাকলে একজন গাইনি চিকিৎসকের আল্ট্রাসনোগ্রাম ও রক্ত পরীক্ষার মাধ্যমে নিশ্চিত হওয়া উচিত।',
      whyThisGuidanceEn:
          'Clinical guidelines note that pairing cycle irregularity with androgen or insulin signs merits a simple ultrasound and blood test with an OB/GYN rather than guesswork.',
      selfCareStepsBn: [
        'সূচনা অভ্যাস ট্র্যাকারে "প্রতিদিন ২০ মিনিট হাঁটা" ও "অতিরিক্ত চিনি কমানো" চালু করুন।',
        'সাদা ভাত ও চিনির বদলে শাকসবজি, ডাল, ডিম ও আঁশযুক্ত খাবার বাড়ান।',
        'নিকটস্থ নারী স্বাস্থ্য কেন্দ্রে গিয়ে পিসিওএস ও থাইরয়েড পরীক্ষা করান।',
      ],
      selfCareStepsEn: [
        'Activate "20-Min Walk" and "Avoid Excess Sugar" inside SHUCHONA’s Habit Tracker.',
        'Balance meals with lentils, eggs, vegetables, and whole grains to steady blood sugar.',
        'Consult a female doctor at a local clinic for proper PCOS and thyroid evaluation.',
      ],
    ),
    SymptomTopic(
      id: SymptomTopicId.breastAwareness,
      emoji: '🎗️',
      titleBn: 'স্তনে চাকা বা ব্যথা সচেতনতা',
      titleEn: 'Breast Lump or Pain Awareness',
      subtitleBn: 'নিরাপদ ও গোপনীয় প্রাথমিক যাচাই',
      subtitleEn: 'Private, non-stigmatizing early screening guide',
      questions: [
        SymptomFollowUpQuestion(
          id: 'q1',
          questionBn: 'আপনি কী ধরনের পরিবর্তন লক্ষ্য করেছেন?',
          questionEn: 'What change have you noticed?',
          optionsBn: [
            'মাসিকের আগে হালকা ব্যথা বা ভারী ভাব',
            'নরম ও নড়াচড়া করে এমন ছোট গুটি',
            'শক্ত ও স্থির চাকা, চামড়া কুঁচকে যাওয়া বা বোঁটা থেকে রক্ত/তরল',
          ],
          optionsEn: [
            'Mild pain or heaviness before period',
            'Soft, movable small lump',
            'Hard fixed lump, skin dimpling, or bloody nipple discharge',
          ],
          redFlagOptionIndex: 2,
          redFlagTriggerText: 'শক্ত চাকা চামড়া কুঁচকে স্তন থেকে রক্ত hard lump skin dimpling nipple discharge',
        ),
        SymptomFollowUpQuestion(
          id: 'q2',
          questionBn: 'এই ব্যথা বা পরিবর্তন কত দিন ধরে আছে?',
          questionEn: 'How long has this been present?',
          optionsBn: ['কয়েক দিন (মাসিকের সময়)', '২ সপ্তাহের বেশি সময় ধরে'],
          optionsEn: ['A few days around period', 'More than 2 weeks'],
        ),
      ],
      guidanceTitleBn: 'স্তন স্বাস্থ্য সচেতনতা ও প্রাথমিক নির্দেশনা',
      guidanceTitleEn: 'Breast Health Awareness & Guidance',
      possiblePatternsBn:
          'মাসিকের আগে স্তনে ব্যথা বা নরম ফোলাভাব প্রায়ই সাধারণ হরমোনজনিত পরিবর্তন (ফাইব্রোসিস্টিক পরিবর্তন) এবং এতে আতঙ্কিত হওয়ার কিছু নেই। তবে যেকোনো নতুন চাকা ২ সপ্তাহের বেশি থাকলে নারী ডাক্তারকে দেখানো নিরাপদ।',
      possiblePatternsEn:
          'Cyclic tenderness or benign fibrocystic fullness before periods is very common and non-cancerous. Still, any new lump lasting beyond one cycle should be examined by a female physician.',
      whyThisGuidanceBn:
          'স্তনের বেশিরভাগ ব্যথা ও নরম পরিবর্তনই নির্দোষ (benign), কিন্তু প্রাথমিক পর্যায়ে সচেতন পরীক্ষা নারীর জীবন ও মানসিক প্রশান্তি নিশ্চিত করে (WHO স্তন স্বাস্থ্য নির্দেশিকা)।',
      whyThisGuidanceEn:
          'Most cyclic breast pain is benign, yet early clinical evaluation of persistent changes guarantees peace of mind and timely treatment (WHO Breast Health Initiative).',
      selfCareStepsBn: [
        'লজ্জা বা ভয় পাবেন না — প্রতি মাসে মাসিক শেষ হওয়ার ৫–৭ দিন পর নিজেই পরীক্ষা করুন।',
        'আরামদায়ক সুতির পোশাক পরুন এবং ক্যাফেইন কমান।',
        '২ সপ্তাহের বেশি কোনো চাকা থাকলে উপজেলা স্বাস্থ্য কমপ্লেক্সের নারী ডাক্তারকে দেখান।',
      ],
      selfCareStepsEn: [
        'No stigma or fear — do a gentle self-check 5–7 days after your period ends.',
        'Wear comfortable cotton support and reduce caffeine if experiencing cyclic ache.',
        'Visit a female physician if any change persists past 2 weeks.',
      ],
    ),
    SymptomTopic(
      id: SymptomTopicId.reproductiveWellness,
      emoji: '🌺',
      titleBn: 'সাধারণ নারী ও প্রজনন স্বাস্থ্য',
      titleEn: 'General Reproductive Wellness',
      subtitleBn: 'রক্তশূন্যতা, সাদা স্রাব, প্রস্রাবে জ্বালাপোড়া ও পুষ্টি',
      subtitleEn: 'Anemia, hygiene, UTI comfort & nutrition',
      questions: [
        SymptomFollowUpQuestion(
          id: 'q1',
          questionBn: 'আপনার প্রধান অসুবিধা কোনটি?',
          questionEn: 'What is your main concern today?',
          optionsBn: [
            'অতিরিক্ত ক্লান্তি, দুর্বলতা ও মাথা ঘোরা',
            'প্রস্রাবে জ্বালাপোড়া বা দুর্গন্ধযুক্ত স্রাব',
            'গর্ভাবস্থায় রক্তপাত বা তীব্র মাথাব্যথা',
          ],
          optionsEn: [
            'Frequent fatigue, weakness, or dizziness',
            'Burning urination or unusual discharge',
            'Bleeding or severe headache during pregnancy',
          ],
          redFlagOptionIndex: 2,
          redFlagTriggerText: 'গর্ভাবস্থায় রক্ত pregnancy bleeding',
        ),
        SymptomFollowUpQuestion(
          id: 'q2',
          questionBn: 'আপনি কি প্রতিদিন পর্যাপ্ত পানি (৮ গ্লাস) ও আয়রনসমৃদ্ধ খাবার খান?',
          questionEn: 'Do you drink 8 glasses of clean water and eat iron-rich foods daily?',
          optionsBn: ['হ্যাঁ, চেষ্টা করি', 'না, অনেক কম খাওয়া হয়'],
          optionsEn: ['Yes, mostly', 'No, very little'],
        ),
      ],
      guidanceTitleBn: 'নারী ও প্রজনন সুস্থতা — প্রাথমিক পরামর্শ',
      guidanceTitleEn: 'Women’s Reproductive Wellness — Guidance',
      possiblePatternsBn:
          'ক্লান্তি ও দুর্বলতা প্রায়ই আয়রনের ঘাটতি (রক্তশূন্যতা) থেকে হয়, আর প্রস্রাবে জ্বালাপোড়া কম পানি পান ও মূত্রনালির সংক্রমণ (UTI)-এর লক্ষণ হতে পারে।',
      possiblePatternsEn:
          'Fatigue commonly signals iron-deficiency anemia, while urinary burning or unusual discharge may point to dehydration or a treatable urinary/reproductive tract infection.',
      whyThisGuidanceBn:
          'DGHS বাংলাদেশ কমিউনিটি ক্লিনিকে বিনামূল্যে আয়রন-ফলিক এসিড ট্যাবলেট এবং প্রাথমিক স্বাস্থ্যসেবা পাওয়া যায়।',
      whyThisGuidanceEn:
          'DGHS Bangladesh Community Clinics provide free iron-folic acid supplementation and confidential female primary care evaluation.',
      selfCareStepsBn: [
        'প্রতিদিন কমপক্ষে ৮ গ্লাস নিরাপদ পানি পান করুন এবং পরিষ্কার সুতির কাপড়/প্যাড ব্যবহার করুন।',
        'প্রতিদিনের খাবারে কচু শাক, পালং শাক, ডাল, ডিম ও লেবু রাখুন।',
        'প্রস্রাবে জ্বালাপোড়া বা দুর্গন্ধযুক্ত স্রাব ২ দিনের বেশি থাকলে চিকিৎসকের পরামর্শ নিন।',
      ],
      selfCareStepsEn: [
        'Drink at least 8 glasses of safe water daily and maintain gentle cotton hygiene.',
        'Include iron-rich leafy greens, lentils, eggs, and vitamin C (lemon) in meals.',
        'See a doctor if urinary burning or abnormal discharge lasts more than 2 days.',
      ],
    ),
  ];
}

class SymptomGuideState {
  const SymptomGuideState({
    this.selectedTopic,
    this.answers = const {},
    this.redFlagMatch,
    this.showResult = false,
    this.freeTextInput = '',
  });

  final SymptomTopic? selectedTopic;
  final Map<String, int> answers;
  final RedFlagMatch? redFlagMatch;
  final bool showResult;
  final String freeTextInput;

  SymptomGuideState copyWith({
    SymptomTopic? selectedTopic,
    bool clearTopic = false,
    Map<String, int>? answers,
    RedFlagMatch? redFlagMatch,
    bool clearRedFlag = false,
    bool? showResult,
    String? freeTextInput,
  }) {
    return SymptomGuideState(
      selectedTopic: clearTopic ? null : (selectedTopic ?? this.selectedTopic),
      answers: answers ?? this.answers,
      redFlagMatch: clearRedFlag ? null : (redFlagMatch ?? this.redFlagMatch),
      showResult: showResult ?? this.showResult,
      freeTextInput: freeTextInput ?? this.freeTextInput,
    );
  }
}

class SymptomGuideNotifier extends StateNotifier<SymptomGuideState> {
  SymptomGuideNotifier(this._ref) : super(const SymptomGuideState());

  final Ref _ref;

  void selectTopic(SymptomTopic topic) {
    state = SymptomGuideState(
      selectedTopic: topic,
      answers: const {},
      redFlagMatch: null,
      showResult: false,
    );
  }

  void answerQuestion(SymptomFollowUpQuestion q, int optionIndex) {
    final nextAnswers = {...state.answers, q.id: optionIndex};

    // Tier 1 Deterministic Red-Flag interception!
    if (q.redFlagOptionIndex != null &&
        optionIndex == q.redFlagOptionIndex &&
        q.redFlagTriggerText != null) {
      final flag = RedFlagEngine.evaluate(q.redFlagTriggerText!);
      state = state.copyWith(
        answers: nextAnswers,
        redFlagMatch: flag,
        showResult: true,
      );
      return;
    }

    state = state.copyWith(
      answers: nextAnswers,
      clearRedFlag: true,
    );
  }

  /// Evaluates free-text / voice symptom description through Tier 1 Red-Flag Engine FIRST!
  RedFlagMatch? evaluateFreeText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final flag = RedFlagEngine.evaluate(trimmed);
    if (flag != null) {
      state = state.copyWith(
        freeTextInput: trimmed,
        redFlagMatch: flag,
        showResult: true,
      );
      return flag;
    }

    // Match best topic based on keywords if none selected
    final lower = trimmed.toLowerCase();
    SymptomTopic matched = WomensSymptomTopics.all.first;
    if (lower.contains('স্তন') || lower.contains('চাকা') || lower.contains('breast')) {
      matched = WomensSymptomTopics.all[3];
    } else if (lower.contains('ব্যথা') || lower.contains('cramp') || lower.contains('pain')) {
      matched = WomensSymptomTopics.all[1];
    } else if (lower.contains('pcos') || lower.contains('পিসিওএস') || lower.contains('ব্রণ')) {
      matched = WomensSymptomTopics.all[2];
    } else if (lower.contains('দুর্বল') || lower.contains('প্রস্রাব') || lower.contains('weak')) {
      matched = WomensSymptomTopics.all[4];
    }

    state = SymptomGuideState(
      selectedTopic: matched,
      freeTextInput: trimmed,
      showResult: true,
    );
    _recordAnonymizedSymptomCluster(matched.id.name);
    return null;
  }

  void completeGuidedFlow() {
    final topic = state.selectedTopic;
    if (topic == null) return;
    state = state.copyWith(showResult: true);
    _recordAnonymizedSymptomCluster(topic.id.name);
  }

  void _recordAnonymizedSymptomCluster(String cluster) {
    if (_ref.read(shgGuestModeProvider)) return;
    _ref.read(offlineSyncProvider.notifier).recordSyncableAction(
      actionType: 'anonymized_symptom_cluster',
      anonymizedPayload: {
        'cluster': cluster,
        'upazila': _ref.read(userSessionProvider).upazila,
      },
    );
  }

  void reset() {
    state = const SymptomGuideState();
  }
}

final symptomGuideProvider =
    StateNotifierProvider<SymptomGuideNotifier, SymptomGuideState>((ref) {
  return SymptomGuideNotifier(ref);
});

