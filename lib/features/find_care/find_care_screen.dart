import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/offline_sync/notification_service.dart';
import 'package:shuchona/core/seed_data/upazila_clinics_seed.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/severity_badge.dart';
import 'package:shuchona/core/widgets/shuchona_app_bar.dart';
import 'package:shuchona/features/find_care/find_care_provider.dart';

/// Modules 14, 15, 16 & 17:
/// - Offline Find Care Directory (Upazila Health Complexes, Community Clinics,
///   Women's Health Centers, National Helplines 16263/109/Kaan Pete Roi) with
///   distance tags, spoken Bangla directions, GPS proximity, and one-tap Call.
/// - Smart Local Voice Reminders Manager (Medication & Habit Alarms) + Offline Sync & Settings.
class FindCareScreen extends ConsumerStatefulWidget {
  const FindCareScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<FindCareScreen> createState() => _FindCareScreenState();
}

class _FindCareScreenState extends ConsumerState<FindCareScreen> {
  late int _selectedTab; // 0 = Find Care, 1 = Smart Voice Reminders & Settings

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  void didUpdateWidget(covariant FindCareScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedTab = widget.initialTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final s = AppStrings(locale);
    final primary = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;
    final gutter = ((MediaQuery.sizeOf(context).width - 760) / 2).clamp(
      16.0,
      double.infinity,
    );

    return Scaffold(
      appBar: ShuchonaAppBar(
        title: s.tr('হাসপাতাল ও অ্যালার্ম', 'Care & Alarms'),
        showBackButton: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 8),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    selected: _selectedTab == 0,
                    showCheckmark: false,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    label: Center(
                      child: Text(
                        s.tr('🏥 ক্লিনিক', '🏥 Clinics'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    onSelected: (_) => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    selected: _selectedTab == 1,
                    showCheckmark: false,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    label: Center(
                      child: Text(
                        s.tr('⏰ ভয়েস অ্যালার্ম', '⏰ Alarms'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    onSelected: (_) => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? _buildClinicsTab(context, s, primary, isDark, gutter)
                : _buildRemindersSettingsTab(
                    context, s, primary, isDark, gutter),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicsTab(
    BuildContext context,
    AppStrings s,
    Color primary,
    bool isDark,
    double gutter,
  ) {
    final care = ref.watch(findCareProvider);

    final filtered = care.facilities.where((item) {
      final f = item.facility;
      if (care.onlyFreeBloodTest && !f.offersFreeBloodTest) {
        return false;
      }
      if (care.selectedUpazila != 'All' &&
          f.upazila != 'All Bangladesh' &&
          f.upazila != care.selectedUpazila) {
        return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 96),
      children: [
        // Offline Directory Filter & GPS Proximity Bar
        AccessibleCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: care.selectedUpazila,
                      decoration: InputDecoration(
                        labelText: s.tr('উপজেলা ফিল্টার', 'Filter Upazila'),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'All',
                          child: Text(s.tr('সব উপজেলা', 'All Upazilas')),
                        ),
                        ...AppConstants.bangladeshUpazilas.map(
                          (u) => DropdownMenuItem(
                            value: u,
                            child: Text(s.isBn
                                ? (AppConstants.upazilaBanglaNames[u] ?? u)
                                : u),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(findCareProvider.notifier).selectUpazila(v);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: care.isLocating
                          ? null
                          : () => ref
                              .read(findCareProvider.notifier)
                              .refreshGpsProximity(),
                      icon: care.isLocating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded, size: 20),
                      label: Text(s.tr('GPS', 'GPS')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilterChip(
                    selected: care.onlyFreeBloodTest,
                    avatar: const Icon(Icons.biotech_rounded, size: 16),
                    label: Text(
                      s.tr('বিনামূল্যে রক্তের গ্রুপ টেস্ট',
                          'Free Blood Group Test'),
                    ),
                    onSelected: (v) => ref
                        .read(findCareProvider.notifier)
                        .toggleFreeBloodTestFilter(v),
                  ),
                  SeverityBadge(
                    label: s.tr('অফলাইনেও উপলব্ধ', 'Offline Ready'),
                    tone: BadgeTone.emeraldSafe,
                    icon: Icons.offline_pin_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Facilities List
        ...filtered.map((entry) {
          final f = entry.facility;
          final isHelpline = f.type == CareFacilityType.nationalHelpline;
          final name = s.tr(f.nameBn, f.nameEn);
          final address = s.tr(f.addressBn, f.addressEn);
          final directions = s.tr(f.directionsBn, f.directionsEn);
          final services = s.isBn ? f.servicesBn : f.servicesEn;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AccessibleCard(
              borderColor: isHelpline
                  ? AppColors.alertCrimson.withValues(alpha: 0.55)
                  : null,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (isHelpline
                                  ? AppColors.alertCrimson
                                  : primary)
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isHelpline
                              ? Icons.support_agent_rounded
                              : Icons.local_hospital_rounded,
                          color: isHelpline ? AppColors.alertCrimson : primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              address,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (!isHelpline)
                        SeverityBadge(
                          label:
                              '${s.formatDigits(entry.distanceKm.toString())} ${s.tr("কি.মি.", "km")}',
                          tone: BadgeTone.clinicalTeal,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (f.open24x7)
                        SeverityBadge(
                          label: s.tr('২৪/৭ খোলা', 'Open 24/7'),
                          tone: BadgeTone.emeraldSafe,
                        ),
                      if (f.offersFreeBloodTest)
                        SeverityBadge(
                          label: s.tr('ফ্রি রক্ত পরীক্ষা', 'Free Blood Test'),
                          tone: BadgeTone.amberCaution,
                        ),
                      ...services.take(3).map(
                            (srv) => SeverityBadge(
                              label: srv,
                              tone: BadgeTone.neutral,
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    directions,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: isHelpline
                                ? AppColors.alertCrimson
                                : AppColors.secondaryEmeraldDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onPressed: () =>
                              FindCareNotifier.dialPhoneNumber(f.phone),
                          icon: const Icon(Icons.call_rounded, size: 18),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${s.tr("কল", "Call")} ${f.phone}',
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TtsListenButton(
                        textToSpeak: '$name। $directions',
                        compact: true,
                        tag: 'clinic_${f.id}',
                        labelOverride: s.tr('🔊 দিকনির্দেশনা', '🔊 Directions'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRemindersSettingsTab(
    BuildContext context,
    AppStrings s,
    Color primary,
    bool isDark,
    double gutter,
  ) {
    final reminders = ref.watch(remindersProvider);
    final sync = ref.watch(offlineSyncProvider);
    final isAdmin = ref.watch(adminRoleProvider);

    return ListView(
      padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 96),
      children: [
        // Smart Voice Reminders Header + Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                s.tr(
                  'স্মার্ট বাংলা ভয়েস রিমাইন্ডার (${s.formatDigits(reminders.length.toString())})',
                  'Smart Voice Reminders (${reminders.length})',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(56, 44)),
              onPressed: () => _showAddReminderSheet(context, s),
              icon: const Icon(Icons.add_alarm_rounded, size: 20),
              label: Text(s.tr('যোগ করুন', 'Add')),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...reminders.map((r) {
          final title = s.tr(r.titleBn, r.titleEn);
          final speech = s.tr(r.spokenMessageBn, r.spokenMessageEn);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AccessibleCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (r.category == 'medication'
                                  ? AppColors.secondaryEmerald
                                  : primary)
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          r.formattedTime,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: r.category == 'medication'
                                ? AppColors.secondaryEmeraldDark
                                : primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      Switch.adaptive(
                        value: r.enabled,
                        onChanged: (_) => ref
                            .read(remindersProvider.notifier)
                            .toggleReminder(r.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(speech, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TtsListenButton(
                        textToSpeak: speech,
                        compact: true,
                        tag: 'rem_${r.id}',
                        labelOverride:
                            s.tr('🔊 অ্যালার্ম টেস্ট শুনুন', '🔊 Test Voice'),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: s.tr('মুছুন', 'Delete'),
                        onPressed: () => ref
                            .read(remindersProvider.notifier)
                            .removeReminder(r.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),

        // Offline Sync & Role Switcher Settings Card
        AccessibleCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.tr('অফলাইন সিঙ্ক ও ভূমিকা সেটিংস',
                    'Offline Sync & Role Switcher'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: sync.simulatedOffline,
                onChanged: (_) => ref
                    .read(offlineSyncProvider.notifier)
                    .toggleSimulatedOffline(),
                title: Text(
                  s.tr('অফলাইন মোড টেস্ট করুন (লোকাল Hive কিউ)',
                      'Simulate Offline Mode (Test Local Hive Queue)'),
                ),
                subtitle: Text(
                  s.tr(
                    'অপেক্ষমাণ সিঙ্ক আইটেম: ${s.formatDigits(sync.pendingQueueCount.toString())}',
                    'Pending sync queue items: ${sync.pendingQueueCount}',
                  ),
                ),
              ),
              if (sync.pendingQueueCount > 0 && sync.effectivelyOnline)
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(offlineSyncProvider.notifier).syncNow(),
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(s.tr('এখনই সিঙ্ক করুন', 'Flush Sync Queue Now')),
                ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.analytics_rounded,
                    color: AppColors.primaryTeal),
                title: Text(
                  isAdmin ? s.communityUserView : s.adminDashboardView,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(s.zeroPiiBadge),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  final next = !isAdmin;
                  ref.read(adminRoleProvider.notifier).state = next;
                  if (next) {
                    context.push('/admin');
                  } else {
                    context.go('/home');
                  }
                },
              ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.verified_user_rounded,
                    color: AppColors.indigoSoft),
                title: Text(
                  s.tr('লগইন ও গোপনীয়তা সম্মতি দেখুন',
                      'Account, Login & Privacy Consent'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  s.tr(
                    'অটো-ডেমো সেশন • চাইলে ফোন OTP বা ইমেইল দিয়ে সাইন ইন করুন',
                    'Auto Demo Active • Switch to Phone OTP / Email or review consent',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ref.read(adminRoleProvider.notifier).state = false;
                  ref.read(userSessionProvider.notifier).signOutToOnboarding();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAddReminderSheet(BuildContext context, AppStrings s) async {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    var selectedTime = const TimeOfDay(hour: 9, minute: 0);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.tr('নতুন ভয়েস রিমাইন্ডার যোগ করুন', 'Add Smart Voice Reminder'),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: s.tr('শিরোনাম', 'Title'),
                  hintText: s.tr('যেমন: বিকালের হাঁটার সময়', 'e.g. Evening Walk'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: msgCtrl,
                decoration: InputDecoration(
                  labelText: s.tr('ভয়েস বার্তা', 'Spoken Voice Message'),
                  hintText: s.tr('২০ মিনিট হাঁটার সময় হয়েছে!',
                      'Time for your 20-minute healthy walk!'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setModalState(() => selectedTime = picked);
                  }
                },
                icon: const Icon(Icons.access_time_rounded),
                label: Text(
                  '${s.tr("সময় নির্বাচন", "Time")}: ${selectedTime.format(ctx)}',
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  final msg = msgCtrl.text.trim().isEmpty
                      ? title
                      : msgCtrl.text.trim();
                  ref.read(remindersProvider.notifier).addOrUpdateReminders([
                    ScheduledVoiceReminder(
                      id: DateTime.now().millisecondsSinceEpoch % 100000,
                      titleBn: title,
                      titleEn: title,
                      spokenMessageBn: msg,
                      spokenMessageEn: msg,
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                      category: 'habit',
                    ),
                  ]);
                  Navigator.of(ctx).pop();
                },
                child: Text(s.tr('রিমাইন্ডার সেভ করুন', 'Save Voice Reminder')),
              ),
            ],
          ),
        ),
      ),
    );
    titleCtrl.dispose();
    msgCtrl.dispose();
  }
}

