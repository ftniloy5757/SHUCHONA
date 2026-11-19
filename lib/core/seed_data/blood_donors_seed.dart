import 'package:shuchona/core/constants/app_constants.dart';

class BloodDonor {
  const BloodDonor({
    required this.id,
    required this.aliasBn,
    required this.aliasEn,
    required this.bloodGroup,
    required this.upazila,
    required this.phoneMasked,
    required this.daysSinceLastDonation,
    required this.verifiedByShg,
  });

  final String id;
  final String aliasBn;
  final String aliasEn;
  final String bloodGroup;
  final String upazila;
  final String phoneMasked;
  final int daysSinceLastDonation;
  final bool verifiedByShg;

  /// Enforces mandatory 90-day medical cooldown before eligible to donate again.
  bool get isEligible =>
      bloodGroup != 'Unknown' &&
      daysSinceLastDonation >= AppConstants.bloodCooldownDays;

  int get cooldownDaysRemaining =>
      isEligible ? 0 : AppConstants.bloodCooldownDays - daysSinceLastDonation;
}

enum BloodUrgency { critical, urgent, planned }

class BloodSosRequest {
  const BloodSosRequest({
    required this.id,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.hospitalNameBn,
    required this.hospitalNameEn,
    required this.upazila,
    required this.urgency,
    required this.contactPhone,
    required this.reasonBn,
    required this.reasonEn,
    required this.createdAt,
    required this.notifiedEligibleDonorsCount,
    required this.respondingDonorsCount,
    this.userPledged = false,
    this.sharedCount = 0,
  });

  final String id;
  final String bloodGroup;
  final int unitsNeeded;
  final String hospitalNameBn;
  final String hospitalNameEn;
  final String upazila;
  final BloodUrgency urgency;
  final String contactPhone;
  final String reasonBn;
  final String reasonEn;
  final DateTime createdAt;
  final int notifiedEligibleDonorsCount;
  final int respondingDonorsCount;
  final bool userPledged;
  final int sharedCount;

  BloodSosRequest copyWith({
    int? respondingDonorsCount,
    bool? userPledged,
    int? sharedCount,
  }) {
    return BloodSosRequest(
      id: id,
      bloodGroup: bloodGroup,
      unitsNeeded: unitsNeeded,
      hospitalNameBn: hospitalNameBn,
      hospitalNameEn: hospitalNameEn,
      upazila: upazila,
      urgency: urgency,
      contactPhone: contactPhone,
      reasonBn: reasonBn,
      reasonEn: reasonEn,
      createdAt: createdAt,
      notifiedEligibleDonorsCount: notifiedEligibleDonorsCount,
      respondingDonorsCount:
          respondingDonorsCount ?? this.respondingDonorsCount,
      userPledged: userPledged ?? this.userPledged,
      sharedCount: sharedCount ?? this.sharedCount,
    );
  }
}

abstract final class BloodDonorsSeed {
  static const List<BloodDonor> donors = [
    BloodDonor(
      id: 'd1',
      aliasBn: 'তানভীর (সাভার যুব নেটওয়ার্ক)',
      aliasEn: 'Tanvir (Savar Youth Network)',
      bloodGroup: 'O+',
      upazila: 'Savar, Dhaka',
      phoneMasked: '017XX-XXX214',
      daysSinceLastDonation: 145,
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd2',
      aliasBn: 'নুসরাত (বিরুলিয়া SHG)',
      aliasEn: 'Nusrat (Birulia SHG)',
      bloodGroup: 'O+',
      upazila: 'Savar, Dhaka',
      phoneMasked: '018XX-XXX890',
      daysSinceLastDonation: 190,
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd3',
      aliasBn: 'রাশেদ (সাভার কলেজ স্বেচ্ছাসেবী)',
      aliasEn: 'Rashed (Savar College Volunteer)',
      bloodGroup: 'O+',
      upazila: 'Savar, Dhaka',
      phoneMasked: '019XX-XXX412',
      daysSinceLastDonation: 42, // In 90-day cooldown — filtered out!
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd4',
      aliasBn: 'সুমাইয়া (আশুলিয়া স্বনির্ভর দল)',
      aliasEn: 'Sumaiya (Ashulia SHG)',
      bloodGroup: 'B+',
      upazila: 'Savar, Dhaka',
      phoneMasked: '017XX-XXX663',
      daysSinceLastDonation: 120,
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd5',
      aliasBn: 'মাহমুদ (সাভার ব্লাড ক্লাব)',
      aliasEn: 'Mahmud (Savar Blood Club)',
      bloodGroup: 'A+',
      upazila: 'Savar, Dhaka',
      phoneMasked: '016XX-XXX118',
      daysSinceLastDonation: 210,
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd6',
      aliasBn: 'কামরুল (সাভার)',
      aliasEn: 'Kamrul (Savar)',
      bloodGroup: 'O-',
      upazila: 'Savar, Dhaka',
      phoneMasked: '017XX-XXX771',
      daysSinceLastDonation: 132,
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd7',
      aliasBn: 'ফারজানা (ধামরাই আলো দল)',
      aliasEn: 'Farjana (Dhamrai Alo Circle)',
      bloodGroup: 'O+',
      upazila: 'Dhamrai, Dhaka',
      phoneMasked: '018XX-XXX509',
      daysSinceLastDonation: 165,
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd8',
      aliasBn: 'ইমরান (কুমিল্লা যুব সংঘ)',
      aliasEn: 'Imran (Cumilla Youth Guild)',
      bloodGroup: 'B+',
      upazila: 'Cumilla Sadar, Cumilla',
      phoneMasked: '017XX-XXX932',
      daysSinceLastDonation: 112,
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd9',
      aliasBn: 'শামীমা (কুমিল্লা প্রগতি)',
      aliasEn: 'Shamima (Cumilla Progoti)',
      bloodGroup: 'O+',
      upazila: 'Cumilla Sadar, Cumilla',
      phoneMasked: '019XX-XXX204',
      daysSinceLastDonation: 60, // Cooldown!
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd10',
      aliasBn: 'আরিফ (বগুড়া স্বেচ্ছাসেবী)',
      aliasEn: 'Arif (Bogura Volunteer)',
      bloodGroup: 'AB+',
      upazila: 'Bogura Sadar, Bogura',
      phoneMasked: '017XX-XXX815',
      daysSinceLastDonation: 150,
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd11',
      aliasBn: 'রিফাত (রংপুর জাগরণ)',
      aliasEn: 'Rifat (Rangpur Jagoron)',
      bloodGroup: 'A+',
      upazila: 'Rangpur Sadar, Rangpur',
      phoneMasked: '017XX-XXX339',
      daysSinceLastDonation: 105,
      verifiedByShg: true,
    ),
    BloodDonor(
      id: 'd12',
      aliasBn: 'সাদিয়া (সাভার যুব নেটওয়ার্ক)',
      aliasEn: 'Sadia (Savar Youth Network)',
      bloodGroup: 'O+',
      upazila: 'Savar, Dhaka',
      phoneMasked: '017XX-XXX994',
      daysSinceLastDonation: 118,
      verifiedByShg: true,
    ),
  ];

  static List<BloodSosRequest> initialRequests() {
    final now = DateTime.now();
    return [
      BloodSosRequest(
        id: 'sos_savar_maternal',
        bloodGroup: 'O+',
        unitsNeeded: 2,
        hospitalNameBn: 'সাভার উপজেলা স্বাস্থ্য কমপ্লেক্স (প্রসূতি ওয়ার্ড)',
        hospitalNameEn: 'Savar Upazila Health Complex (Maternity Ward)',
        upazila: 'Savar, Dhaka',
        urgency: BloodUrgency.critical,
        contactPhone: '01730324401',
        reasonBn: 'প্রসব-পরবর্তী জরুরি রক্তক্ষরণ (পোস্টপার্টাম হেমোরেজ)',
        reasonEn: 'Emergency Postpartum Maternal Care',
        createdAt: now.subtract(const Duration(minutes: 12)),
        notifiedEligibleDonorsCount: 14,
        respondingDonorsCount: 3,
      ),
      BloodSosRequest(
        id: 'sos_cumilla_thalassemia',
        bloodGroup: 'B+',
        unitsNeeded: 1,
        hospitalNameBn: 'কুমিল্লা সদর হাসপাতাল',
        hospitalNameEn: 'Cumilla Sadar Hospital',
        upazila: 'Cumilla Sadar, Cumilla',
        urgency: BloodUrgency.urgent,
        contactPhone: '01730324512',
        reasonBn: 'থ্যালাসেমিয়া শিশুর নিয়মিত রক্ত সঞ্চালন',
        reasonEn: 'Pediatric Thalassemia Transfusion',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 20)),
        notifiedEligibleDonorsCount: 9,
        respondingDonorsCount: 2,
      ),
    ];
  }
}

