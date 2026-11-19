class WellnessMicroTip {
  const WellnessMicroTip({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.bodyBn,
    required this.bodyEn,
    required this.categoryBn,
    required this.categoryEn,
    required this.emoji,
  });

  final String id;
  final String titleBn;
  final String titleEn;
  final String bodyBn;
  final String bodyEn;
  final String categoryBn;
  final String categoryEn;
  final String emoji;
}

class CopingStep {
  const CopingStep({
    required this.stepNumber,
    required this.titleBn,
    required this.titleEn,
    required this.instructionBn,
    required this.instructionEn,
    required this.emoji,
  });

  final int stepNumber;
  final String titleBn;
  final String titleEn;
  final String instructionBn;
  final String instructionEn;
  final String emoji;
}

abstract final class WellnessTipsSeed {
  static const List<WellnessMicroTip> dailyTips = [
    WellnessMicroTip(
      id: 'tip_1',
      titleBn: 'নিজের জন্য ৫ মিনিটের শান্ত বিরতি',
      titleEn: 'Take a 5-Minute Calm Pause for Yourself',
      bodyBn:
          'সারা দিনের সংসার ও কাজের চাপে মন অস্থির হলে চুপচাপ বসে ৩ বার গভীর শ্বাস নিন। নিজের যত্ন নেওয়া স্বার্থপরতা নয় — আপনি সুস্থ থাকলেই পরিবার ভালো থাকবে।',
      bodyEn:
          'When daily family and work pressure feels heavy, sit quietly and take 3 slow deep breaths. Caring for your mind is strength, not selfishness.',
      categoryBn: 'মানসিক প্রশান্তি',
      categoryEn: 'Mindfulness',
      emoji: '🌿',
    ),
    WellnessMicroTip(
      id: 'tip_2',
      titleBn: 'পানিশূন্যতা ও মন খারাপের সম্পর্ক',
      titleEn: 'Hydration Directly Lifts Energy & Mood',
      bodyBn:
          'শরীরে পানি কম থাকলে মাথা ভারী লাগে, ক্লান্তি আসে এবং মেজাজ খিটখিটে হয়। এখনই এক গ্লাস নিরাপদ পানি পান করুন।',
      bodyEn:
          'Even mild dehydration increases fatigue and irritability. Drink a full glass of clean water right now and notice your energy settle.',
      categoryBn: 'দৈনন্দিন অভ্যাস',
      categoryEn: 'Daily Care',
      emoji: '💧',
    ),
    WellnessMicroTip(
      id: 'tip_3',
      titleBn: 'মনের কথা বিশ্বস্ত কারো সাথে ভাগ করুন',
      titleEn: 'Share Your Feelings With a Trusted Sister',
      bodyBn:
          'কষ্ট বা দুশ্চিন্তা একা চেপে রাখলে চাপ আরও বাড়ে। স্বনির্ভর দলের কোনো আপা বা বিশ্বস্ত বন্ধুর সাথে মন খুলে কথা বললে মন অনেক হালকা হয়।',
      bodyEn:
          'Carrying worry alone magnifies stress. Talking openly with a trusted SHG sister or family member lightens the emotional weight.',
      categoryBn: 'কমিউনিটি শক্তি',
      categoryEn: 'Community Support',
      emoji: '🤝',
    ),
    WellnessMicroTip(
      id: 'tip_4',
      titleBn: 'ঘুমের আগে স্ক্রিন ও দুশ্চিন্তা দূরে রাখুন',
      titleEn: 'Gentle Evening Wind-Down Before Sleep',
      bodyBn:
          'রাত ১১টার আগে ঘুমোতে গেলে হরমোনের ভারসাম্য ঠিক থাকে এবং পরদিন সকালে মানসিক চাপ কমে। ঘুমের আগে হালকা গরম পানি পান করতে পারেন।',
      bodyEn:
          'Sleeping before 11 PM supports hormonal balance and lowers next-day anxiety. Try sipping warm water and resting your eyes 20 minutes before bed.',
      categoryBn: 'সুস্থ ঘুম',
      categoryEn: 'Restful Sleep',
      emoji: '🌙',
    ),
  ];

  /// 3 Step-by-Step Grounding & Coping Cards for Craving / Crisis SOS Mode
  static const List<CopingStep> crisisCopingSteps = [
    CopingStep(
      stepNumber: 1,
      titleBn: 'ধাপ ১: ঠান্ডা পানি ও ৫-৪-৩-২-১ গ্রাউন্ডিং',
      titleEn: 'Step 1: Cold Water & 5-4-3-2-1 Grounding',
      instructionBn:
          'হাতে বা মুখে একটু ঠান্ডা পানি দিন। আপনার চারপাশে ৩টি জিনিস দেখুন, ২টি জিনিস ছুঁয়ে অনুভব করুন এবং ১টি শান্ত শব্দ শুনুন। আপনি এখন নিরাপদ।',
      instructionEn:
          'Splash cool water on your hands or face. Notice 3 things you can see, 2 things you can touch, and 1 calm sound around you. You are safe right now.',
      emoji: '💧',
    ),
    CopingStep(
      stepNumber: 2,
      titleBn: 'ধাপ ২: তীব্র তাড়না ১০ মিনিট পর কমে যায়',
      titleEn: 'Step 2: Ride the Wave — Urges Peak & Fade in 10 Minutes',
      instructionBn:
          'জর্দা, পান, ধূমপান বা তীব্র মানসিক কষ্ট ঢেউয়ের মতো আসে এবং কয়েক মিনিট পর কমে যায়। এক গ্লাস পানি খান, ২ মিনিট হাঁটুন অথবা একটি লবঙ্গ/এলাচ মুখে দিন।',
      instructionEn:
          'Cravings (betel nut/jarda, smoking) and emotional waves crest and subside within 10 minutes. Sip water, walk for 2 minutes, or chew cardamom/clove as a healthy swap.',
      emoji: '🌊',
    ),
    CopingStep(
      stepNumber: 3,
      titleBn: 'ধাপ ৩: মানুষের সাথে কথা বলুন — আপনি একা নন',
      titleEn: 'Step 3: Connect With a Caring Human Voice',
      instructionBn:
          'যদি এখনো খুব অস্থির বা অসহায় লাগে, নিচের বাটনে চাপ দিয়ে সরাসরি ১৬২৬৩ বা কান পেতে রই হেল্পলাইনে কথা বলুন অথবা আপনার স্বনির্ভর দলের লিডারকে ডাকুন।',
      instructionEn:
          'If distress still feels overwhelming, tap below to speak directly with a compassionate counselor at 16263 or Kaan Pete Roi, or call a trusted SHG sister.',
      emoji: '📞',
    ),
  ];
}

