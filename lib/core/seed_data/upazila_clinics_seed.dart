enum CareFacilityType {
  upazilaHealthComplex,
  communityClinic,
  womensHealthCenter,
  nationalHelpline,
}

class CareFacility {
  const CareFacility({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.type,
    required this.upazila,
    required this.phone,
    required this.addressBn,
    required this.addressEn,
    required this.directionsBn,
    required this.directionsEn,
    required this.latitude,
    required this.longitude,
    required this.defaultDistanceKm,
    required this.servicesBn,
    required this.servicesEn,
    this.open24x7 = false,
    this.offersFreeBloodTest = false,
  });

  final String id;
  final String nameBn;
  final String nameEn;
  final CareFacilityType type;
  final String upazila;
  final String phone;
  final String addressBn;
  final String addressEn;
  final String directionsBn;
  final String directionsEn;
  final double latitude;
  final double longitude;
  final double defaultDistanceKm;
  final List<String> servicesBn;
  final List<String> servicesEn;
  final bool open24x7;
  final bool offersFreeBloodTest;
}

abstract final class UpazilaClinicsSeed {
  static const List<CareFacility> facilities = [
    // National Helplines
    CareFacility(
      id: 'helpline_16263',
      nameBn: 'স্বাস্থ্য বাতায়ন — জাতীয় স্বাস্থ্য হেল্পলাইন (১৬২৬৩)',
      nameEn: 'Shastho Batayon — National Health Helpline (16263)',
      type: CareFacilityType.nationalHelpline,
      upazila: 'All Bangladesh',
      phone: '16263',
      addressBn: '২৪/৭ সরকারি ডাক্তার ও অ্যাম্বুলেন্স সহায়তা (ডিজিএইচএস)',
      addressEn: '24/7 Government Doctor Consultation & Ambulance (DGHS)',
      directionsBn:
          'যেকোনো মোবাইল ফোন থেকে ১৬২৬৩ ডায়াল করলে সরাসরি সরকারি ডাক্তারের পরামর্শ পাওয়া যাবে।',
      directionsEn:
          'Dial 16263 from any mobile phone across Bangladesh to speak directly with a licensed doctor 24/7.',
      latitude: 23.8103,
      longitude: 90.4125,
      defaultDistanceKm: 0.0,
      servicesBn: ['২৪ ঘণ্টা ডাক্তার', 'অ্যাম্বুলেন্স', 'মাতৃস্বাস্থ্য'],
      servicesEn: ['24/7 Doctors', 'Ambulance', 'Maternal Health'],
      open24x7: true,
    ),
    CareFacility(
      id: 'helpline_kaan_pete_roi',
      nameBn: 'কান পেতে রই — মানসিক সহায়তা হেল্পলাইন',
      nameEn: 'Kaan Pete Roi — Emotional Crisis & Mental Health Helpline',
      type: CareFacilityType.nationalHelpline,
      upazila: 'All Bangladesh',
      phone: '01779554391',
      addressBn: 'গোপনীয় মানসিক সহায়তা ও আত্মহত্যা প্রতিরোধ হেল্পলাইন',
      addressEn: 'Confidential emotional support & crisis listening helpline',
      directionsBn:
          'মানসিক চাপ, মন খারাপ বা সংকটে ০১৭৭৯৫৫৪৩৯১ নম্বরে কল করে গোপনে কথা বলতে পারেন।',
      directionsEn:
          'Call 01779554391 for confidential, empathetic crisis counseling in Bangla or English.',
      latitude: 23.8103,
      longitude: 90.4125,
      defaultDistanceKm: 0.0,
      servicesBn: ['কাউন্সেলিং', 'মানসিক সহায়তা', 'সম্পূর্ণ গোপনীয়'],
      servicesEn: ['Counseling', 'Crisis Support', '100% Confidential'],
      open24x7: false,
    ),
    CareFacility(
      id: 'helpline_109',
      nameBn: 'নারী ও শিশু নির্যাতন প্রতিরোধ হেল্পলাইন (১০৯)',
      nameEn: 'National Helpline for Women & Children (109)',
      type: CareFacilityType.nationalHelpline,
      upazila: 'All Bangladesh',
      phone: '109',
      addressBn: 'টোল-ফ্রি ২৪/৭ সরকারি সহায়তা কেন্দ্র',
      addressEn: 'Toll-free 24/7 Government Support Center',
      directionsBn: 'যেকোনো জরুরি নারী ও শিশু সুরক্ষা সহায়তার জন্য ১০৯ ডায়াল করুন।',
      directionsEn: 'Dial 109 toll-free anywhere in Bangladesh for urgent women and child support.',
      latitude: 23.8103,
      longitude: 90.4125,
      defaultDistanceKm: 0.0,
      servicesBn: ['টোল-ফ্রি', 'নারী সুরক্ষা', 'আইনি ও স্বাস্থ্য সহায়তা'],
      servicesEn: ['Toll-Free', 'Women Protection', 'Medical & Legal Aid'],
      open24x7: true,
    ),

    // Savar & Dhamrai Facilities
    CareFacility(
      id: 'savar_uhc',
      nameBn: 'সাভার উপজেলা স্বাস্থ্য কমপ্লেক্স',
      nameEn: 'Savar Upazila Health Complex',
      type: CareFacilityType.upazilaHealthComplex,
      upazila: 'Savar, Dhaka',
      phone: '01730324401',
      addressBn: 'থানা স্ট্যান্ড রোড, সাভার, ঢাকা-১৩৪০',
      addressEn: 'Thana Stand Road, Savar, Dhaka-1340',
      directionsBn:
          'সাভার বাজার বাস স্ট্যান্ড থেকে উত্তর দিকে ৫ মিনিট হাঁটলেই থানা স্ট্যান্ডের পাশে সাভার উপজেলা স্বাস্থ্য কমপ্লেক্স। এখানে জরুরি বিভাগ ও ব্লাড ব্যাংক ২৪ ঘণ্টা খোলা থাকে।',
      directionsEn:
          '5 minutes north of Savar Bazar Bus Stand beside Thana Stand. 24/7 Emergency Ward, Maternal Unit, and Blood Bank available.',
      latitude: 23.8583,
      longitude: 90.2667,
      defaultDistanceKm: 1.4,
      servicesBn: ['২৪/৭ জরুরি বিভাগ', 'ব্লাড ব্যাংক', 'বিনামূল্যে রক্তের গ্রুপ পরীক্ষা', 'প্রসূতি সেবা'],
      servicesEn: ['24/7 Emergency', 'Blood Bank', 'Free Blood Grouping', 'Maternal Care'],
      open24x7: true,
      offersFreeBloodTest: true,
    ),
    CareFacility(
      id: 'savar_womens_center',
      nameBn: 'সাভার মা ও শিশু কল্যাণ কেন্দ্র (নারী স্বাস্থ্য)',
      nameEn: 'Savar Maternal & Women’s Health Center (MCWC)',
      type: CareFacilityType.womensHealthCenter,
      upazila: 'Savar, Dhaka',
      phone: '01715229810',
      addressBn: 'ব্যাংক কলোনি সংলগ্ন, সাভার, ঢাকা',
      addressEn: 'Adjacent to Bank Colony, Savar, Dhaka',
      directionsBn:
          'সাভার ব্যাংক কলোনি মোড় থেকে পূর্ব দিকে ২০০ মিটার ভেতরে নারী ও মা-শিশু কল্যাণ কেন্দ্র। নারী ডাক্তার সকাল ৯টা থেকে দুপুর ২টা পর্যন্ত বসেন।',
      directionsEn:
          '200m east from Savar Bank Colony intersection. Female physicians available for PCOS, menstrual care, breast screening, and antenatal visits.',
      latitude: 23.8492,
      longitude: 90.2584,
      defaultDistanceKm: 2.1,
      servicesBn: ['নারী চিকিৎসক', 'স্তন পরীক্ষা', 'পিসিওএস ও মাসিক সেবা', 'আয়রন ট্যাবলেট'],
      servicesEn: ['Female Doctors', 'Breast Screening', 'PCOS & Period Care', 'Free Iron Tabs'],
      offersFreeBloodTest: true,
    ),
    CareFacility(
      id: 'birulia_cc',
      nameBn: 'বিরুলিয়া কমিউনিটি ক্লিনিক',
      nameEn: 'Birulia Community Clinic',
      type: CareFacilityType.communityClinic,
      upazila: 'Savar, Dhaka',
      phone: '01819442108',
      addressBn: 'বিরুলিয়া ইউনিয়ন পরিষদ সংলগ্ন, সাভার',
      addressEn: 'Near Birulia Union Parishad, Savar',
      directionsBn:
          'বিরুলিয়া বাজার পেরিয়ে ইউনিয়ন পরিষদ ভবনের ডান পাশে কমিউনিটি ক্লিনিক। বিনামূল্যে প্রাথমিক ওষুধ ও প্রেসার মাপা হয়।',
      directionsEn:
          'Right next to Birulia Union Parishad past Birulia Bazar. Free essential medicines, BP checks, and blood grouping camps.',
      latitude: 23.8721,
      longitude: 90.3012,
      defaultDistanceKm: 3.6,
      servicesBn: ['বিনামূল্যে ওষুধ', 'ব্লাড প্রেসার পরীক্ষা', 'রক্তের গ্রুপ টেস্ট'],
      servicesEn: ['Free Medicines', 'BP Check', 'Free Blood Group Test'],
      offersFreeBloodTest: true,
    ),
    CareFacility(
      id: 'dhamrai_uhc',
      nameBn: 'ধামরাই উপজেলা স্বাস্থ্য কমপ্লেক্স',
      nameEn: 'Dhamrai Upazila Health Complex',
      type: CareFacilityType.upazilaHealthComplex,
      upazila: 'Dhamrai, Dhaka',
      phone: '01730324405',
      addressBn: 'ঢাকা-আরিচা মহাসড়ক সংলগ্ন, ধামরাই, ঢাকা',
      addressEn: 'Dhaka-Aricha Highway, Dhamrai, Dhaka',
      directionsBn:
          'ধামরাই ঢুলিভিটা বাস স্ট্যান্ড থেকে ৩ মিনিট পশ্চিমে প্রধান সড়কের পাশেই উপজেলা স্বাস্থ্য কমপ্লেক্স।',
      directionsEn:
          '3 minutes west of Dhamrai Dhulivita Bus Stand along the main highway. 24/7 Emergency and Maternity ward.',
      latitude: 23.9082,
      longitude: 90.2145,
      defaultDistanceKm: 7.8,
      servicesBn: ['২৪/৭ জরুরি সেবা', 'রক্ত সঞ্চালন', 'গাইনি ও প্রসূতি'],
      servicesEn: ['24/7 Emergency', 'Blood Transfusion', 'OB/GYN Care'],
      open24x7: true,
      offersFreeBloodTest: true,
    ),

    // Cumilla, Bogura, Rangpur, Sylhet
    CareFacility(
      id: 'cumilla_uhc',
      nameBn: 'কুমিল্লা সদর হাসপাতাল ও ব্লাড ব্যাংক',
      nameEn: 'Cumilla Sadar Hospital & Blood Bank',
      type: CareFacilityType.upazilaHealthComplex,
      upazila: 'Cumilla Sadar, Cumilla',
      phone: '01730324512',
      addressBn: 'চকবাজার রোড, কুমিল্লা সদর',
      addressEn: 'Chawkbazar Road, Cumilla Sadar',
      directionsBn:
          'কুমিল্লা কান্দিরপাড় থেকে রিকশায় ১০ মিনিট পূর্বে চকবাজার রোডে সদর হাসপাতাল অবস্থিত।',
      directionsEn:
          '10 minutes east by rickshaw from Kandirpar along Chawkbazar Road. 24/7 Blood Bank and Women’s Ward.',
      latitude: 23.4607,
      longitude: 91.1809,
      defaultDistanceKm: 1.9,
      servicesBn: ['২৪/৭ ব্লাড ব্যাংক', 'জরুরি বিভাগ', 'নারী ওয়ার্ড'],
      servicesEn: ['24/7 Blood Bank', 'Emergency', 'Women’s Ward'],
      open24x7: true,
      offersFreeBloodTest: true,
    ),
    CareFacility(
      id: 'bogura_mcwc',
      nameBn: 'বগুড়া মা ও শিশু কল্যাণ কেন্দ্র',
      nameEn: 'Bogura Maternal & Women’s Wellness Center',
      type: CareFacilityType.womensHealthCenter,
      upazila: 'Bogura Sadar, Bogura',
      phone: '01716552901',
      addressBn: 'সাতমাথা থেকে শেরপুর রোড, বগুড়া',
      addressEn: 'Sherpur Road near Satmatha, Bogura',
      directionsBn:
          'বগুড়া সাতমাথা মোড় থেকে শেরপুর রোড ধরে দক্ষিণ দিকে ৪০০ মিটার এগোলেই মা ও শিশু কল্যাণ কেন্দ্র।',
      directionsEn:
          '400m south along Sherpur Road from Satmatha intersection. Free maternal checkups and iron supplements.',
      latitude: 24.8465,
      longitude: 89.3773,
      defaultDistanceKm: 2.5,
      servicesBn: ['গর্ভকালীন চেকআপ', 'নারী স্বাস্থ্য', 'বিনামূল্যে রক্ত পরীক্ষা'],
      servicesEn: ['Antenatal Care', 'Women’s Health', 'Free Blood Testing'],
      offersFreeBloodTest: true,
    ),
    CareFacility(
      id: 'rangpur_uhc',
      nameBn: 'রংপুর সদর উপজেলা স্বাস্থ্য ও পরিবার পরিকল্পনা কেন্দ্র',
      nameEn: 'Rangpur Sadar Upazila Health & Family Welfare Center',
      type: CareFacilityType.upazilaHealthComplex,
      upazila: 'Rangpur Sadar, Rangpur',
      phone: '01730324618',
      addressBn: 'মেডিকেল মোড় সংলগ্ন, রংপুর সদর',
      addressEn: 'Near Medical Mor, Rangpur Sadar',
      directionsBn:
          'রংপুর মেডিকেল মোড় থেকে উত্তর দিকে ৩ মিনিট হাঁটলেই স্বাস্থ্য কমপ্লেক্স।',
      directionsEn:
          '3 minutes north of Rangpur Medical Mor. Emergency maternal care and blood grouping available.',
      latitude: 25.7439,
      longitude: 89.2752,
      defaultDistanceKm: 3.1,
      servicesBn: ['২৪/৭ জরুরি সেবা', 'ব্লাড ব্যাংক', 'কমিউনিটি ক্লিনিক রেফারেল'],
      servicesEn: ['24/7 Emergency', 'Blood Bank', 'Clinic Referral'],
      open24x7: true,
      offersFreeBloodTest: true,
    ),
    CareFacility(
      id: 'sylhet_womens',
      nameBn: 'সিলেট সদর নারী ও কিশোরী স্বাস্থ্য কেন্দ্র',
      nameEn: 'Sylhet Sadar Women & Adolescent Health Clinic',
      type: CareFacilityType.womensHealthCenter,
      upazila: 'Sylhet Sadar, Sylhet',
      phone: '01712889432',
      addressBn: 'চৌহাট্টা, সিলেট সদর',
      addressEn: 'Chouhatta, Sylhet Sadar',
      directionsBn:
          'সিলেট চৌহাট্টা পয়েন্টের কাছেই নারী ও কিশোরী স্বাস্থ্য কেন্দ্র অবস্থিত।',
      directionsEn:
          'Located near Chouhatta Point, Sylhet. Adolescent menstrual health, PCOS guidance, and free anemia screening.',
      latitude: 24.8949,
      longitude: 91.8687,
      defaultDistanceKm: 2.3,
      servicesBn: ['কিশোরী স্বাস্থ্য', 'রক্তশূন্যতা পরীক্ষা', 'নারী ডাক্তার'],
      servicesEn: ['Adolescent Care', 'Anemia Screening', 'Female Physicians'],
      offersFreeBloodTest: true,
    ),
  ];
}

