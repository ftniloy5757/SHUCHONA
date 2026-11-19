import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/offline_sync/hive_storage_service.dart';
import 'package:shuchona/core/offline_sync/notification_service.dart';
import 'package:shuchona/core/seed_data/blood_donors_seed.dart';
import 'package:uuid/uuid.dart';

class UserDonorProfile {
  const UserDonorProfile({
    required this.optedIn,
    required this.bloodGroup,
    required this.upazila,
    required this.lastDonationDate,
  });

  final bool optedIn;
  final String bloodGroup; // A+, ..., Unknown
  final String upazila;
  final DateTime? lastDonationDate;

  int get daysSinceLastDonation {
    if (lastDonationDate == null) return 180;
    return DateTime.now().difference(lastDonationDate!).inDays;
  }

  /// Mandatory 90-day medical cooldown guard.
  bool get isEligibleNow =>
      optedIn &&
      bloodGroup != 'Unknown' &&
      daysSinceLastDonation >= AppConstants.bloodCooldownDays;

  int get cooldownDaysLeft {
    if (bloodGroup == 'Unknown' || lastDonationDate == null) return 0;
    final rem = AppConstants.bloodCooldownDays - daysSinceLastDonation;
    return rem > 0 ? rem : 0;
  }

  UserDonorProfile copyWith({
    bool? optedIn,
    String? bloodGroup,
    String? upazila,
    DateTime? lastDonationDate,
    bool clearLastDonation = false,
  }) {
    return UserDonorProfile(
      optedIn: optedIn ?? this.optedIn,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      upazila: upazila ?? this.upazila,
      lastDonationDate: clearLastDonation
          ? null
          : (lastDonationDate ?? this.lastDonationDate),
    );
  }
}

class BloodNetworkState {
  const BloodNetworkState({
    required this.userProfile,
    required this.allDonors,
    required this.activeRequests,
    this.lastBroadcastNoticeBn,
    this.lastBroadcastNoticeEn,
  });

  final UserDonorProfile userProfile;
  final List<BloodDonor> allDonors;
  final List<BloodSosRequest> activeRequests;
  final String? lastBroadcastNoticeBn;
  final String? lastBroadcastNoticeEn;

  BloodNetworkState copyWith({
    UserDonorProfile? userProfile,
    List<BloodDonor>? allDonors,
    List<BloodSosRequest>? activeRequests,
    String? lastBroadcastNoticeBn,
    String? lastBroadcastNoticeEn,
  }) {
    return BloodNetworkState(
      userProfile: userProfile ?? this.userProfile,
      allDonors: allDonors ?? this.allDonors,
      activeRequests: activeRequests ?? this.activeRequests,
      lastBroadcastNoticeBn:
          lastBroadcastNoticeBn ?? this.lastBroadcastNoticeBn,
      lastBroadcastNoticeEn:
          lastBroadcastNoticeEn ?? this.lastBroadcastNoticeEn,
    );
  }
}

class BloodNetworkNotifier extends StateNotifier<BloodNetworkState> {
  BloodNetworkNotifier(this._ref) : super(_loadInitial(_ref));

  final Ref _ref;
  final _uuid = const Uuid();

  static BloodNetworkState _loadInitial(Ref ref) {
    final s = HiveStorageService.instance;
    final optedIn = s.read<bool>(AppConstants.boxBlood, 'opted_in') ?? true;
    final group = s.read<String>(AppConstants.boxBlood, 'blood_group') ?? 'O+';
    final upazila = s.read<String>(AppConstants.boxBlood, 'upazila') ??
        ref.read(userSessionProvider).upazila;
    final lastDateIso =
        s.read<String>(AppConstants.boxBlood, 'last_donation_iso');

    return BloodNetworkState(
      userProfile: UserDonorProfile(
        optedIn: optedIn,
        bloodGroup: group,
        upazila: upazila,
        lastDonationDate: lastDateIso != null
            ? DateTime.tryParse(lastDateIso)
            : DateTime.now().subtract(const Duration(days: 125)),
      ),
      allDonors: BloodDonorsSeed.donors,
      activeRequests: BloodDonorsSeed.initialRequests(),
    );
  }

  Future<void> updateDonorProfile({
    bool? optedIn,
    String? bloodGroup,
    String? upazila,
    DateTime? lastDonationDate,
    bool clearLastDonation = false,
  }) async {
    final updated = state.userProfile.copyWith(
      optedIn: optedIn,
      bloodGroup: bloodGroup,
      upazila: upazila,
      lastDonationDate: lastDonationDate,
      clearLastDonation: clearLastDonation,
    );
    state = state.copyWith(userProfile: updated);

    if (!_ref.read(shgGuestModeProvider)) {
      final s = HiveStorageService.instance;
      await s.write(AppConstants.boxBlood, 'opted_in', updated.optedIn);
      await s.write(AppConstants.boxBlood, 'blood_group', updated.bloodGroup);
      await s.write(AppConstants.boxBlood, 'upazila', updated.upazila);
      await s.write(
        AppConstants.boxBlood,
        'last_donation_iso',
        updated.lastDonationDate?.toIso8601String(),
      );
    }
  }

  /// Returns strictly eligible (out of 90-day medical cooldown) donors in the same Upazila.
  List<BloodDonor> filterEligibleDonors({
    required String bloodGroup,
    required String upazila,
  }) {
    return state.allDonors.where((d) {
      final sameArea = d.upazila == upazila;
      final groupMatch = d.bloodGroup == bloodGroup || d.bloodGroup == 'O-';
      return sameArea && groupMatch && d.isEligible;
    }).toList();
  }

  /// Counts donors filtered OUT because they are within the 90-day cooldown window.
  int countCooldownExcluded({
    required String bloodGroup,
    required String upazila,
  }) {
    return state.allDonors.where((d) {
      final sameArea = d.upazila == upazila;
      final groupMatch = d.bloodGroup == bloodGroup || d.bloodGroup == 'O-';
      return sameArea && groupMatch && !d.isEligible;
    }).length;
  }

  /// Broadcasts a Geofenced One-Tap Blood SOS alert to eligible Upazila donors!
  Future<BloodSosRequest> broadcastBloodSos({
    required String bloodGroup,
    required int unitsNeeded,
    required String hospitalName,
    required String upazila,
    required BloodUrgency urgency,
    required String contactPhone,
    required String reason,
  }) async {
    final eligible = filterEligibleDonors(
      bloodGroup: bloodGroup,
      upazila: upazila,
    );
    final excludedCooldown = countCooldownExcluded(
      bloodGroup: bloodGroup,
      upazila: upazila,
    );
    // Include verified SHG youth pool in the Upazila simulation
    final notifiedCount = eligible.length + 8;

    final req = BloodSosRequest(
      id: _uuid.v4(),
      bloodGroup: bloodGroup,
      unitsNeeded: unitsNeeded,
      hospitalNameBn: hospitalName,
      hospitalNameEn: hospitalName,
      upazila: upazila,
      urgency: urgency,
      contactPhone: contactPhone,
      reasonBn: reason,
      reasonEn: reason,
      createdAt: DateTime.now(),
      notifiedEligibleDonorsCount: notifiedCount,
      respondingDonorsCount: 1,
    );

    final upazilaBn = AppConstants.upazilaBanglaNames[upazila] ?? upazila;
    final noticeBn =
        'জরুরি রক্ত SOS পাঠানো হয়েছে! $upazilaBn এলাকায় ৯০ দিনের কুলডাউন মুক্ত $notifiedCount জন যোগ্য $bloodGroup রক্তদাতার কাছে বাংলা ভয়েস ও পুশ অ্যালার্ট পৌঁছেছে ($excludedCooldown জন কুলডাউনে থাকায় বাদ পড়েছেন)।';
    final noticeEn =
        'Blood SOS Broadcast Live! Sent high-priority Bangla voice & push alert to $notifiedCount eligible out-of-cooldown $bloodGroup donors in $upazila ($excludedCooldown donor(s) protected by 90-day medical cooldown).';

    state = state.copyWith(
      activeRequests: [req, ...state.activeRequests],
      lastBroadcastNoticeBn: noticeBn,
      lastBroadcastNoticeEn: noticeEn,
    );

    await NotificationService.instance.showImmediateAlert(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '🩸 জরুরি $bloodGroup রক্ত প্রয়োজন — $hospitalName',
      body: noticeBn,
    );

    _ref.read(offlineSyncProvider.notifier).recordSyncableAction(
      actionType: 'blood_sos_broadcast',
      anonymizedPayload: {
        'bloodGroup': bloodGroup,
        'upazila': upazila,
        'units': unitsNeeded,
        'notifiedCount': notifiedCount,
      },
    );

    return req;
  }

  void toggleDonorPledge(String requestId) {
    state = state.copyWith(
      activeRequests: [
        for (final req in state.activeRequests)
          if (req.id == requestId)
            req.copyWith(
              userPledged: !req.userPledged,
              respondingDonorsCount: req.userPledged
                  ? (req.respondingDonorsCount - 1).clamp(0, 999)
                  : req.respondingDonorsCount + 1,
            )
          else
            req,
      ],
    );
  }

  void incrementShareCount(String requestId) {
    state = state.copyWith(
      activeRequests: [
        for (final req in state.activeRequests)
          if (req.id == requestId)
            req.copyWith(sharedCount: req.sharedCount + 1)
          else
            req,
      ],
    );
  }
}

final bloodNetworkProvider =
    StateNotifierProvider<BloodNetworkNotifier, BloodNetworkState>((ref) {
  return BloodNetworkNotifier(ref);
});

