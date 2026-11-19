import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/seed_data/blood_donors_seed.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/tts_stt/voice_service.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/severity_badge.dart';
import 'package:shuchona/core/widgets/shuchona_app_bar.dart';
import 'package:shuchona/features/blood_alert/blood_alert_provider.dart';
import 'package:shuchona/features/find_care/find_care_provider.dart';

/// Module 10: Geofenced Blood Demand Alert Network.
/// - Opt-in donor profile with Blood Group (including "Unknown — Find Free Test")
/// - Mandatory 90-day medical cooldown enforcement
/// - One-Tap Blood SOS Broadcast filtering eligible out-of-cooldown donors in same Upazila
/// - Bangla voice/push alert simulation & live donor response tracking (`I Can Donate` / `Share`)
class BloodAlertScreen extends ConsumerWidget {
  const BloodAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final blood = ref.watch(bloodNetworkProvider);
    final s = AppStrings(locale);
    final profile = blood.userProfile;

    final eligibleSameArea = ref
        .read(bloodNetworkProvider.notifier)
        .filterEligibleDonors(
          bloodGroup: profile.bloodGroup == 'Unknown'
              ? 'O+'
              : profile.bloodGroup,
          upazila: profile.upazila,
        );

    final upazilaName = s.isBn
        ? (AppConstants.upazilaBanglaNames[profile.upazila] ?? profile.upazila)
        : profile.upazila;

    final gutter = ((MediaQuery.sizeOf(context).width - 760) / 2).clamp(
      16.0,
      double.infinity,
    );

    return Scaffold(
      appBar: ShuchonaAppBar(title: s.tr('রক্তের সহায়তা', 'Blood help')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 24),
        children: [
          // HERO ONE-TAP BLOOD SOS BROADCAST CARD
          AccessibleCard(
            backgroundColor: isDark
                ? AppColors.darkAlertBg
                : AppColors.alertCrimsonLight,
            borderColor: AppColors.alertCrimson,
            borderWidth: 1.8,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.alertCrimson,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.bloodtype_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.tr(
                              'আপনার উপজেলায় রক্ত চান',
                              'Request blood in your upazila',
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: isDark
                                      ? const Color(0xFFFECACA)
                                      : AppColors.alertCrimsonDark,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.tr(
                              'আপনার উপজেলার যাঁরা এখন রক্ত দিতে পারবেন, কেবল তাঁদের কাছে অনুরোধ যাবে।',
                              'The request goes to eligible donors in your upazila.',
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.alertCrimson,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(58),
                        ),
                        onPressed: () =>
                            _openBroadcastSosSheet(context, ref, s),
                        icon: const Icon(Icons.campaign_rounded, size: 24),
                        label: Text(
                          s.tr('জরুরি রক্তের অনুরোধ পাঠান', 'Request blood'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Instant 1-Tap Live Demo Trigger (Savar Upazila O+ Maternal SOS)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.alertCrimson,
                    side: const BorderSide(color: AppColors.alertCrimson),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () async {
                    final req = await ref
                        .read(bloodNetworkProvider.notifier)
                        .broadcastBloodSos(
                          bloodGroup: 'O+',
                          unitsNeeded: 2,
                          hospitalName: s.tr(
                            'সাভার উপজেলা স্বাস্থ্য কমপ্লেক্স',
                            'Savar Upazila Health Complex',
                          ),
                          upazila: 'Savar, Dhaka',
                          urgency: BloodUrgency.critical,
                          contactPhone: '01730324401',
                          reason: s.tr(
                            'জরুরি মাতৃস্বাস্থ্য রক্তক্ষরণ',
                            'Urgent Maternal Care',
                          ),
                        );
                    final speech = s.tr(
                      'জরুরি রক্ত অ্যালার্ট! সাভার উপজেলা স্বাস্থ্য কমপ্লেক্সে ২ ব্যাগ ও পজিটিভ রক্ত প্রয়োজন। ${s.formatDigits(req.notifiedEligibleDonorsCount.toString())} জন যোগ্য রক্তদাতার কাছে সতর্কতা পাঠানো হয়েছে।',
                      'Urgent Blood Alert! 2 units of O+ blood needed at Savar Upazila Health Complex. Alert sent to ${req.notifiedEligibleDonorsCount} eligible local donors.',
                    );
                    await ref
                        .read(voiceControllerProvider.notifier)
                        .speak(
                          speech,
                          locale: locale,
                          tag: 'blood_sos_${req.id}',
                        );
                  },
                  icon: const Icon(Icons.flash_on_rounded, size: 20),
                  label: Text(
                    s.tr(
                      'লাইভ ডেমো: সাভারে O+ জরুরি SOS টেস্ট করুন',
                      'Live Demo: Trigger O+ SOS at Savar Health Complex',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Last Broadcast Delivery Confirmation Banner
          if (blood.lastBroadcastNoticeBn != null) ...[
            const SizedBox(height: 12),
            AccessibleCard(
              backgroundColor: isDark
                  ? AppColors.darkEmeraldBg
                  : AppColors.secondaryEmeraldLight,
              borderColor: AppColors.secondaryEmerald,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.secondaryEmerald,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.tr(
                            blood.lastBroadcastNoticeBn!,
                            blood.lastBroadcastNoticeEn!,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TtsListenButton(
                    textToSpeak: s.tr(
                      blood.lastBroadcastNoticeBn!,
                      blood.lastBroadcastNoticeEn!,
                    ),
                    compact: true,
                    accentColor: AppColors.secondaryEmeraldDark,
                    tag: 'last_sos_notice',
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // MY DONOR PROFILE & 90-DAY MEDICAL COOLDOWN CARD
          AccessibleCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.tr(
                          'আমার রক্তদাতা প্রোফাইল (৯০-দিন সুরক্ষা)',
                          'My Donor Profile (90-Day Cooldown Guard)',
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Switch.adaptive(
                      value: profile.optedIn,
                      onChanged: (v) => ref
                          .read(bloodNetworkProvider.notifier)
                          .updateDonorProfile(optedIn: v),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Blood Group Selector Chips
                Text(
                  s.tr(
                    'আপনার রক্তের গ্রুপ নির্বাচন করুন:',
                    'Select Your Blood Group:',
                  ),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.bloodGroups.map((bg) {
                    final selected = profile.bloodGroup == bg;
                    final label = bg == 'Unknown'
                        ? s.tr(
                            'জানা নেই — ফ্রি টেস্ট খুঁজুন',
                            'Unknown — Find Free Test',
                          )
                        : bg;
                    return ChoiceChip(
                      selected: selected,
                      selectedColor: AppColors.alertCrimson.withValues(
                        alpha: 0.2,
                      ),
                      label: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: selected ? AppColors.alertCrimson : null,
                        ),
                      ),
                      onSelected: (_) => ref
                          .read(bloodNetworkProvider.notifier)
                          .updateDonorProfile(bloodGroup: bg),
                    );
                  }).toList(),
                ),

                // If "Unknown" blood group -> Direct link to Free Blood Grouping Clinics!
                if (profile.bloodGroup == 'Unknown') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCautionBg
                          : AppColors.cautionAmberLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cautionAmber),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.biotech_rounded,
                              color: AppColors.cautionAmber,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s.tr(
                                  'চিন্তা নেই! নিকটস্থ উপজেলা স্বাস্থ্য কমপ্লেক্স বা কমিউনিটি ক্লিনিকে বিনামূল্যে রক্তের গ্রুপ পরীক্ষা করুন।',
                                  'No worries! Find nearby Community Clinics offering free blood group testing.',
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(56, 44),
                            ),
                            onPressed: () {
                              ref
                                  .read(findCareProvider.notifier)
                                  .toggleFreeBloodTestFilter(true);
                              context.push('/care?tab=clinics');
                            },
                            icon: const Icon(Icons.local_hospital_rounded,
                                size: 18),
                            label: Text(
                              s.tr('ফ্রি টেস্ট ক্লিনিক দেখুন', 'Find Free Test'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Upazila Selector + Last Donation Date (90-day cooldown)
                DropdownButtonFormField<String>(
                  initialValue: profile.upazila,
                  decoration: InputDecoration(
                    labelText: s.tr('উপজেলা / জেলা', 'Upazila / District'),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  items: AppConstants.bangladeshUpazilas
                      .map(
                        (u) => DropdownMenuItem(
                          value: u,
                          child: Text(
                            s.isBn
                                ? (AppConstants.upazilaBanglaNames[u] ?? u)
                                : u,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref
                          .read(bloodNetworkProvider.notifier)
                          .updateDonorProfile(upazila: v);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SeverityBadge(
                      label: profile.bloodGroup == 'Unknown'
                          ? s.tr('রক্তের গ্রুপ অজানা', 'Group Unknown')
                          : (profile.isEligibleNow
                                ? s.tr(
                                    'রক্তদানে যোগ্য (${s.formatDigits(profile.daysSinceLastDonation.toString())} দিন আগে দিয়েছেন)',
                                    'Eligible to Donate (${profile.daysSinceLastDonation}d since last)',
                                  )
                                : s.tr(
                                    '৯০-দিন কুলডাউন: আরও ${s.formatDigits(profile.cooldownDaysLeft.toString())} দিন বাকি',
                                    'Medical Cooldown: ${profile.cooldownDaysLeft}d remaining',
                                  )),
                      tone: profile.isEligibleNow
                          ? BadgeTone.emeraldSafe
                          : BadgeTone.amberCaution,
                      icon: profile.isEligibleNow
                          ? Icons.verified_rounded
                          : Icons.hourglass_top_rounded,
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              profile.lastDonationDate ??
                              DateTime.now().subtract(
                                const Duration(days: 100),
                              ),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          ref
                              .read(bloodNetworkProvider.notifier)
                              .updateDonorProfile(lastDonationDate: picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(s.tr('শেষ দান তারিখ', 'Last Donated')),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  s.tr(
                    '$upazilaName এলাকায় বর্তমানে ${s.formatDigits(eligibleSameArea.length.toString())}+ জন যাচাইকৃত স্বেচ্ছাসেবী রক্তদাতা প্রস্তুত আছেন।',
                    '${eligibleSameArea.length}+ verified out-of-cooldown volunteers ready in $upazilaName.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ACTIVE EMERGENCY BLOOD REQUESTS FEED
          Text(
            s.tr(
              'চলমান জরুরি রক্তের অনুরোধ (${s.formatDigits(blood.activeRequests.length.toString())})',
              'Active Urgent Blood Requests (${blood.activeRequests.length})',
            ),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...blood.activeRequests.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BloodRequestCard(req: req, s: s, isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBroadcastSosSheet(
    BuildContext context,
    WidgetRef ref,
    AppStrings s,
  ) async {
    var selectedGroup = 'O+';
    var units = 2;
    var upazila = ref.read(bloodNetworkProvider).userProfile.upazila;
    var urgency = BloodUrgency.critical;
    final hospitalCtrl = TextEditingController(
      text: s.tr(
        'সাভার উপজেলা স্বাস্থ্য কমপ্লেক্স',
        'Savar Upazila Health Complex',
      ),
    );
    final phoneCtrl = TextEditingController(text: '01730324401');
    final reasonCtrl = TextEditingController(
      text: s.tr(
        'জরুরি মাতৃস্বাস্থ্য / অপারেশন',
        'Emergency Maternal / Surgery',
      ),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.tr(
                  '🩸 নতুন জরুরি রক্ত SOS পাঠান',
                  '🩸 Post Urgent Blood SOS',
                ),
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                  color: AppColors.alertCrimson,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.bloodGroups
                    .where((g) => g != 'Unknown')
                    .map(
                      (g) => ChoiceChip(
                        selected: selectedGroup == g,
                        label: Text(
                          g,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        onSelected: (_) =>
                            setModalState(() => selectedGroup = g),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: units,
                      decoration: InputDecoration(
                        labelText: s.tr('কত ব্যাগ', 'Units Needed'),
                      ),
                      items: [1, 2, 3, 4]
                          .map(
                            (u) => DropdownMenuItem(
                              value: u,
                              child: Text(
                                '${s.formatDigits(u.toString())} ${s.tr("ব্যাগ", "Unit(s)")}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => units = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<BloodUrgency>(
                      initialValue: urgency,
                      decoration: InputDecoration(
                        labelText: s.tr('জরুরি মাত্রা', 'Urgency'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: BloodUrgency.critical,
                          child: Text(
                            s.tr('অতি জরুরি (<২ ঘ.)', 'Critical (<2h)'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: BloodUrgency.urgent,
                          child: Text(s.tr('জরুরি (আজ)', 'Urgent (Today)')),
                        ),
                        DropdownMenuItem(
                          value: BloodUrgency.planned,
                          child: Text(s.tr('নির্ধারিত (৪৮ ঘ.)', 'Scheduled')),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => urgency = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: upazila,
                decoration: InputDecoration(
                  labelText: s.tr('উপজেলা (জিওফেন্স)', 'Upazila (Geofence)'),
                ),
                items: AppConstants.bangladeshUpazilas
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(
                          s.isBn
                              ? (AppConstants.upazilaBanglaNames[u] ?? u)
                              : u,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setModalState(() => upazila = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hospitalCtrl,
                decoration: InputDecoration(
                  labelText: s.tr('হাসপাতালের নাম', 'Hospital Name'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: s.tr('যোগাযোগের নম্বর', 'Contact Phone'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: InputDecoration(
                  labelText: s.tr('রক্তের কারণ', 'Medical Need / Note'),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.alertCrimson,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(58),
                ),
                onPressed: () async {
                  final hospital = hospitalCtrl.text.trim().isEmpty
                      ? s.tr(
                          'নিকটস্থ উপজেলা স্বাস্থ্য কমপ্লেক্স',
                          'Nearest Upazila Health Complex',
                        )
                      : hospitalCtrl.text.trim();
                  final phone = phoneCtrl.text.trim().isEmpty
                      ? AppConstants.shasthoBatayonHelpline
                      : phoneCtrl.text.trim();
                  final reason = reasonCtrl.text.trim().isEmpty
                      ? s.tr('জরুরি চিকিৎসা প্রয়োজন', 'Urgent Medical Care')
                      : reasonCtrl.text.trim();

                  final req = await ref
                      .read(bloodNetworkProvider.notifier)
                      .broadcastBloodSos(
                        bloodGroup: selectedGroup,
                        unitsNeeded: units,
                        hospitalName: hospital,
                        upazila: upazila,
                        urgency: urgency,
                        contactPhone: phone,
                        reason: reason,
                      );
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  final locale = ref.read(localeProvider);
                  await ref
                      .read(voiceControllerProvider.notifier)
                      .speak(
                        locale.isBangla
                            ? 'জরুরি রক্ত অ্যালার্ট পাঠানো হয়েছে! ${req.hospitalNameBn}-এ ${req.bloodGroup} রক্ত প্রয়োজন।'
                            : 'Emergency Blood SOS sent for ${req.bloodGroup} blood at ${req.hospitalNameEn}.',
                        locale: locale,
                        tag: 'sos_cast_${req.id}',
                      );
                },
                icon: const Icon(Icons.send_rounded),
                label: Text(
                  s.tr(
                    'এখনই ভয়েস ও পুশ অ্যালার্ট পাঠান',
                    'Send Geofenced Voice & Push Alert',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    hospitalCtrl.dispose();
    phoneCtrl.dispose();
    reasonCtrl.dispose();
  }
}

class _BloodRequestCard extends ConsumerWidget {
  const _BloodRequestCard({
    required this.req,
    required this.s,
    required this.isDark,
  });

  final BloodSosRequest req;
  final AppStrings s;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCritical = req.urgency == BloodUrgency.critical;
    final hospital = s.tr(req.hospitalNameBn, req.hospitalNameEn);
    final reason = s.tr(req.reasonBn, req.reasonEn);
    final upazilaLabel = s.isBn
        ? (AppConstants.upazilaBanglaNames[req.upazila] ?? req.upazila)
        : req.upazila;

    final spokenSummary = s.tr(
      'জরুরি রক্তের প্রয়োজন: গ্রুপ ${req.bloodGroup}, ${s.formatDigits(req.unitsNeeded.toString())} ব্যাগ। স্থান: $hospital, $upazilaLabel। কারণ: $reason। ইতিমধ্যে ${s.formatDigits(req.respondingDonorsCount.toString())} জন রক্তদাতা সাড়া দিয়েছেন।',
      'Urgent blood request: ${req.bloodGroup}, ${req.unitsNeeded} unit(s) at $hospital, $upazilaLabel. Reason: $reason. ${req.respondingDonorsCount} donor(s) already responding.',
    );

    return AccessibleCard(
      borderColor: isCritical ? AppColors.alertCrimson : AppColors.cautionAmber,
      borderWidth: isCritical ? 1.6 : 1.1,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.alertCrimson,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    req.bloodGroup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SeverityBadge(
                          label: isCritical
                              ? s.tr('অতি জরুরি', 'CRITICAL')
                              : s.tr('জরুরি', 'URGENT'),
                          tone: isCritical
                              ? BadgeTone.crimsonAlert
                              : BadgeTone.amberCaution,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${s.formatDigits(req.unitsNeeded.toString())} ${s.tr("ব্যাগ", "Unit(s)")}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hospital,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$upazilaLabel • $reason',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              SeverityBadge(
                label: s.tr(
                  '${s.formatDigits(req.notifiedEligibleDonorsCount.toString())} জন যোগ্য দাতা অ্যালার্ট পেয়েছেন',
                  '${req.notifiedEligibleDonorsCount} eligible donors alerted',
                ),
                tone: BadgeTone.clinicalTeal,
                icon: Icons.radar_rounded,
              ),
              SeverityBadge(
                label: s.tr(
                  '${s.formatDigits(req.respondingDonorsCount.toString())} জন সাড়া দিয়েছেন',
                  '${req.respondingDonorsCount} responding',
                ),
                tone: BadgeTone.emeraldSafe,
                icon: Icons.volunteer_activism_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: req.userPledged
                        ? AppColors.secondaryEmerald
                        : AppColors.alertCrimson,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => ref
                      .read(bloodNetworkProvider.notifier)
                      .toggleDonorPledge(req.id),
                  icon: Icon(
                    req.userPledged
                        ? Icons.check_circle_rounded
                        : Icons.favorite_rounded,
                  ),
                  label: Text(
                    req.userPledged
                        ? s.tr('আপনি সাড়া দিয়েছেন ✓', 'Pledged to Donate ✓')
                        : s.tr('আমি রক্ত দিতে পারব', 'I Can Donate'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: s.tr('শেয়ার করুন', 'Share'),
                onPressed: () {
                  ref
                      .read(bloodNetworkProvider.notifier)
                      .incrementShareCount(req.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        s.tr(
                          'রক্ত SOS বার্তা আপনার স্বনির্ভর দল (SHG) গ্রুপে শেয়ার করার জন্য কপি হয়েছে!',
                          'Blood SOS alert shared with local SHG network!',
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded),
              ),
              IconButton.outlined(
                tooltip: s.tr('কল করুন', 'Call'),
                onPressed: () =>
                    FindCareNotifier.dialPhoneNumber(req.contactPhone),
                icon: const Icon(
                  Icons.call_rounded,
                  color: AppColors.secondaryEmerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TtsListenButton(
            textToSpeak: spokenSummary,
            compact: true,
            accentColor: AppColors.alertCrimson,
            tag: 'blood_card_${req.id}',
            labelOverride: s.tr('🔊 অনুরোধ শুনুন', '🔊 Listen to Request'),
          ),
        ],
      ),
    );
  }
}
