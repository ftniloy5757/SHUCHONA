import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/seed_data/ddi_matrix.dart';
import 'package:shuchona/core/seed_data/sample_prescriptions.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/tts_stt/voice_service.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/mandatory_disclaimer_banner.dart';
import 'package:shuchona/core/widgets/progress_ring.dart';
import 'package:shuchona/core/widgets/severity_badge.dart';
import 'package:shuchona/core/widgets/shuchona_app_bar.dart';
import 'package:shuchona/features/prescribe_safe/prescribe_safe_models.dart';
import 'package:shuchona/features/prescribe_safe/prescribe_safe_provider.dart';

/// Module 7: PrescribeSafe BD — Handwritten Prescription Scanner, Confidence Gate (<85%),
/// Deterministic DDI & Duplicate Ingredient Guard, DGDA/DIMS Generic Price Arbitrage (BDT ৳),
/// and One-Tap Bangla Voice Dosage Scheduler.
class PrescribeSafeScreen extends ConsumerStatefulWidget {
  const PrescribeSafeScreen({super.key});

  @override
  ConsumerState<PrescribeSafeScreen> createState() =>
      _PrescribeSafeScreenState();
}

class _PrescribeSafeScreenState extends ConsumerState<PrescribeSafeScreen> {
  final _picker = ImagePicker();

  Future<void> _captureImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final result = await ref
          .read(prescribeSafeProvider.notifier)
          .analyzeCapturedImage(bytes);
      _speakQuickSummary(result);
    } catch (e) {
      if (!mounted) return;
      final s = AppStrings(ref.read(localeProvider));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.tr(
              'ক্যামেরা চালু হয়নি — নিচের বাস্তব নমুনা প্রেসক্রিপশন দিয়ে ১ ট্যাপে পরীক্ষা করুন।',
              'Camera unavailable on this device — tap one of the bundled Bangladeshi prescriptions below.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _runSamplePreset(SamplePrescriptionPreset preset) async {
    final result = await ref
        .read(prescribeSafeProvider.notifier)
        .analyzeSamplePreset(preset);
    _speakQuickSummary(result);
  }

  void _speakQuickSummary(PrescriptionAnalysisResult result) {
    final locale = ref.read(localeProvider);
    final s = AppStrings(locale);
    final summary = locale.isBangla
        ? 'প্রেসক্রিপশন বিশ্লেষণ সম্পন্ন। মোট ${s.formatDigits(result.items.length.toString())}টি ওষুধ পাওয়া গেছে। ${result.ddiAlerts.isNotEmpty ? "সতর্কতা: ${s.formatDigits(result.ddiAlerts.length.toString())}টি গুরুত্বপূর্ণ ওষুধ বিক্রিয়া বা দ্বৈত উপাদান পাওয়া গেছে। " : ""}ডিজিডিএ জেনেরিক ওষুধে প্রায় ${s.formatDigits(result.overallSavingsPercent.toString())} শতাংশ বা ${s.formatTaka(result.totalSavingsBdt)} সাশ্রয় সম্ভব।'
        : 'Prescription decoded. Found ${result.items.length} medicines. ${result.ddiAlerts.isNotEmpty ? "Warning: ${result.ddiAlerts.length} drug interaction or duplicate ingredient alert found. " : ""}DGDA generic equivalents can save ${result.overallSavingsPercent}% or ${result.totalSavingsBdt.round()} Taka.';

    ref
        .read(voiceControllerProvider.notifier)
        .speak(summary, locale: locale, tag: 'rx_summary_${result.id}');
  }

  Future<void> _scheduleAllVoiceAlarms() async {
    final count = await ref
        .read(prescribeSafeProvider.notifier)
        .scheduleVoiceDosageAlarms();
    if (!mounted) return;
    final locale = ref.read(localeProvider);
    final s = AppStrings(locale);
    final msg = s.tr(
      'সফল! $countটি বাংলা ভয়েস ওষুধের অ্যালার্ম সেট করা হয়েছে। যেমন: "সকালের ওষুধ খাওয়ার সময় হয়েছে — ১টি ট্যাবলেট খাওয়ার পরে"।',
      'Scheduled $count spoken Bangla & English voice dosage reminders! Example: "Time for your morning dose — 1 tablet after meals".',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondaryEmeraldDark,
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        action: SnackBarAction(
          label: s.tr('অ্যালার্ম দেখুন', 'View Alarms'),
          textColor: Colors.white,
          onPressed: () => context.push('/care?tab=alarms'),
        ),
      ),
    );
    await ref
        .read(voiceControllerProvider.notifier)
        .speak(
          s.tr(
            'ওষুধের অ্যালার্ম সেট হয়েছে। সকালের ওষুধ খাওয়ার সময় হয়েছে — ১টি ট্যাবলেট খাওয়ার পরে।',
            'Dosage alarms scheduled. Time for your morning medicine — take 1 tablet after meals.',
          ),
          locale: locale,
          tag: 'alarm_confirm',
        );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final state = ref.watch(prescribeSafeProvider);
    final s = AppStrings(locale);
    final primary = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;

    final gutter = ((MediaQuery.sizeOf(context).width - 760) / 2).clamp(
      16.0,
      double.infinity,
    );

    return Scaffold(
      appBar: ShuchonaAppBar(title: s.tr('প্রেসক্রিপশন', 'Prescription')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 24),
        children: [
          // Hero Capture Card
          AccessibleCard(
            backgroundColor: isDark
                ? AppColors.darkTealBg
                : AppColors.primaryTealLight,
            borderColor: primary.withValues(alpha: 0.4),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.document_scanner_rounded,
                        color: isDark ? AppColors.darkCanvas : Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.tr(
                              'প্রেসক্রিপশনের ছবি দিন',
                              'Add a photo of your prescription',
                            ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.tr(
                              'ওষুধের নাম ও খরচ দেখুন। লেখা অস্পষ্ট হলে ফার্মাসিস্টের সাহায্য নিন।',
                              'See medicine names and costs. Ask a pharmacist if the writing is unclear.',
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: state.isAnalyzing
                          ? null
                          : () => _captureImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded, size: 22),
                      label: Text(s.tr('ছবি তুলুন', 'Take a photo')),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: state.isAnalyzing
                          ? null
                          : () => _captureImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded, size: 22),
                      label: Text(s.tr('ফোন থেকে ছবি নিন', 'Choose a photo')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Pregnancy Safety Context Switch
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: state.isPregnantToggle,
                  onChanged: (v) => ref
                      .read(prescribeSafeProvider.notifier)
                      .togglePregnancyContext(v),
                  title: Text(
                    s.tr(
                      'গর্ভবতী / স্তন্যদানকারী মায়ের নিরাপত্তা যাচাই চালু করুন',
                      'Enable Pregnancy / Lactation Safety Screening',
                    ),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // One-Tap Realistic Bangladeshi Sample Prescriptions (For Instant Stage Demo!)
          Text(
            s.tr(
              'এক ট্যাপে নমুনা বাংলাদেশি প্রেসক্রিপশন পরীক্ষা করুন',
              'One-Tap Realistic Bangladeshi Prescription Samples',
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: SamplePrescriptionsSeed.presets.map((preset) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: preset == SamplePrescriptionsSeed.presets.first
                        ? 8
                        : 0,
                    left: preset == SamplePrescriptionsSeed.presets.last
                        ? 8
                        : 0,
                  ),
                  child: AccessibleCard(
                    onTap: state.isAnalyzing
                        ? null
                        : () => _runSamplePreset(preset),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1.15,
                            child: Image.asset(
                              preset.assetPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.tr(preset.titleBn, preset.titleEn),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.tr(preset.subtitleBn, preset.subtitleEn),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Analyzing Spinner
          if (state.isAnalyzing)
            AccessibleCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircularProgressIndicator(strokeWidth: 3),
                  const SizedBox(height: 14),
                  Text(
                    s.tr(
                      'Vision OCR + DGDA/DIMS ডেটাবেজ + DDI সুরক্ষা বিশ্লেষণ চলছে...',
                      'Running Vision OCR + DGDA/DIMS RAG + Deterministic DDI Guard...',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            )
          else if (state.currentResult != null) ...[
            _buildAnalysisReport(
              context,
              state.currentResult!,
              state.alarmsScheduledForId == state.currentResult!.id,
              s,
              primary,
              isDark,
            ),
          ] else ...[
            const MandatoryDisclaimerBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisReport(
    BuildContext context,
    PrescriptionAnalysisResult result,
    bool alarmsScheduled,
    AppStrings s,
    Color primary,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Prescription Preview Header
        AccessibleCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (result.capturedImageBytes != null ||
                  result.assetImagePath != null)
                GestureDetector(
                  onTap: () => _showFullPrescriptionDialog(context, result),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 74,
                      height: 92,
                      child: result.capturedImageBytes != null
                          ? Image.memory(
                              result.capturedImageBytes!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              result.assetImagePath!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SeverityBadge(
                      label: result.usedLiveVisionApi
                          ? s.tr(
                              'Gemini Vision + DGDA RAG',
                              'Gemini Vision + DGDA RAG',
                            )
                          : s.tr(
                              'অফলাইন DGDA/DIMS ভিশন পাইপলাইন',
                              'Offline DGDA/DIMS Pipeline',
                            ),
                      tone: BadgeTone.clinicalTeal,
                      icon: Icons.verified_rounded,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.doctorName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      result.clinicName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      result.patientInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. RED DDI & Duplicate Active Ingredient Alerts (Highest Visual Priority!)
        if (result.ddiAlerts.isNotEmpty) ...[
          Text(
            s.tr(
              '⚠️ ওষুধের বিক্রিয়া ও দ্বৈত উপাদান সতর্কতা (${s.formatDigits(result.ddiAlerts.length.toString())})',
              '⚠️ Drug Interaction & Duplicate Alerts (${result.ddiAlerts.length})',
            ),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.alertCrimson,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...result.ddiAlerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DdiAlertCard(alert: alert, s: s, isDark: isDark),
            ),
          ),
          const SizedBox(height: 6),
        ],

        // 3. Generic Price Savings Summary Card (BDT ৳ + %)
        AccessibleCard(
          backgroundColor: isDark
              ? AppColors.darkEmeraldBg
              : AppColors.secondaryEmeraldLight,
          borderColor: AppColors.secondaryEmerald.withValues(alpha: 0.6),
          borderWidth: 1.5,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProgressRing(
                    progress: (result.overallSavingsPercent / 100).clamp(
                      0.05,
                      1.0,
                    ),
                    centerText:
                        '${s.formatDigits(result.overallSavingsPercent.toString())}%',
                    subtitle: s.tr('সাশ্রয়', 'Saved'),
                    size: 76,
                    color: AppColors.secondaryEmerald,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SeverityBadge(
                          label: s.tr(
                            'DGDA অনুমোদিত জেনেরিক সাশ্রয়',
                            'DGDA Generic Price Savings',
                          ),
                          tone: BadgeTone.emeraldSafe,
                          icon: Icons.savings_rounded,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.tr(
                            'মোট সাশ্রয়: ${s.formatTaka(result.totalSavingsBdt)}',
                            'Total Savings: ${s.formatTaka(result.totalSavingsBdt)}',
                          ),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: isDark
                                    ? const Color(0xFF6EE7B7)
                                    : AppColors.secondaryEmeraldDark,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.tr(
                            'ব্র্যান্ডেড মূল্য: ${s.formatTaka(result.totalBrandCostBdt)}  →  জেনেরিক: ${s.formatTaka(result.totalGenericCostBdt)}',
                            'Branded: ${s.formatTaka(result.totalBrandCostBdt)}  →  Generic: ${s.formatTaka(result.totalGenericCostBdt)}',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondaryEmeraldDark,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _scheduleAllVoiceAlarms,
                      icon: Icon(
                        alarmsScheduled
                            ? Icons.alarm_on_rounded
                            : Icons.notifications_active_rounded,
                      ),
                      label: Text(
                        alarmsScheduled
                            ? s.tr(
                                'বাংলা ভয়েস অ্যালার্ম চালু আছে',
                                'Voice Dosage Alarms Active',
                              )
                            : s.tr(
                                'এক ট্যাপে বাংলা ভয়েস অ্যালার্ম সেট করুন',
                                'Set Bangla Voice Dosage Alarms',
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 4. Decoded Medications List (with <85% Amber Confidence Gate & TTS on every card!)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                s.tr(
                  'ওষুধের বিস্তারিত ও খাওয়ার নিয়ম (${s.formatDigits(result.items.length.toString())})',
                  'Decoded Medicines & Dosage (${result.items.length})',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (result.lowConfidenceCount > 0)
              SeverityBadge(
                label: s.tr(
                  '${s.formatDigits(result.lowConfidenceCount.toString())}টি যাচাই প্রয়োজন',
                  '${result.lowConfidenceCount} Verify',
                ),
                tone: BadgeTone.amberCaution,
                icon: Icons.warning_amber_rounded,
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...result.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DecodedMedCard(
              item: item,
              s: s,
              primary: primary,
              isDark: isDark,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 5. Pinned Pharmacist-in-the-Loop & Clinical Disclaimer
        const MandatoryDisclaimerBanner(),
      ],
    );
  }

  void _showFullPrescriptionDialog(
    BuildContext context,
    PrescriptionAnalysisResult result,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              InteractiveViewer(
                child: result.capturedImageBytes != null
                    ? Image.memory(result.capturedImageBytes!)
                    : Image.asset(result.assetImagePath!),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DdiAlertCard extends StatelessWidget {
  const _DdiAlertCard({
    required this.alert,
    required this.s,
    required this.isDark,
  });

  final DdiAlert alert;
  final AppStrings s;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final title = s.tr(alert.titleBn, alert.titleEn);
    final desc = s.tr(alert.explanationBn, alert.explanationEn);
    final action = s.tr(alert.actionBn, alert.actionEn);
    final speech = '$title। $desc $action';

    return AccessibleCard(
      backgroundColor: isDark
          ? AppColors.darkAlertBg
          : AppColors.alertCrimsonLight,
      borderColor: AppColors.alertCrimson,
      borderWidth: 1.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.dangerous_rounded,
                color: AppColors.alertCrimson,
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? const Color(0xFFFECACA)
                        : AppColors.alertCrimsonDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: alert.drugNames
                .map(
                  (d) => SeverityBadge(label: d, tone: BadgeTone.crimsonAlert),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(desc, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            action,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          TtsListenButton(
            textToSpeak: speech,
            compact: true,
            accentColor: AppColors.alertCrimson,
            tag: 'ddi_${alert.id}',
            labelOverride: s.tr(
              '🔊 সতর্কতা বাংলায় শুনুন',
              '🔊 Listen to Alert',
            ),
          ),
        ],
      ),
    );
  }
}

class _DecodedMedCard extends StatelessWidget {
  const _DecodedMedCard({
    required this.item,
    required this.s,
    required this.primary,
    required this.isDark,
  });

  final DecodedMedicationItem item;
  final AppStrings s;
  final Color primary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lowConf = item.needsPharmacistVerification;
    final confPct = (item.ocrConfidence * 100).round();
    final dosageText = s.tr(item.dosageInstructionBn, item.dosageInstructionEn);

    final fullSpeech = lowConf
        ? s.tr(
            'সতর্কতা: ${item.rawBrandName} ওষুধটির হাতের লেখা অস্পষ্ট, কনফিডেন্স $confPct শতাংশ। খাওয়ার আগে অবশ্যই স্থানীয় ফার্মাসিস্টের সাথে যাচাই করুন।',
            'Caution: Handwriting for ${item.rawBrandName} has $confPct% OCR confidence. Please verify with a local pharmacist before taking.',
          )
        : '$dosageText ${item.matchedDrug != null ? s.tr(item.matchedDrug!.purposeBn, item.matchedDrug!.purposeEn) : ""}${item.cheaperGeneric != null ? s.tr(" এর সাশ্রয়ী ডিজিডিএ জেনেরিক বিকল্প হলো ${item.cheaperGeneric!.brandName}, প্রতি পিস ${s.formatTaka(item.cheaperGeneric!.unitPriceBdt)}।", " Cheaper DGDA generic equivalent: ${item.cheaperGeneric!.brandName} at ${s.formatTaka(item.cheaperGeneric!.unitPriceBdt)} per unit.") : ""}';

    return AccessibleCard(
      backgroundColor: lowConf
          ? (isDark ? AppColors.darkCautionBg : AppColors.cautionAmberLight)
          : null,
      borderColor: lowConf ? AppColors.cautionAmber : null,
      borderWidth: lowConf ? 1.8 : 1.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Drug Name + Confidence Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.dosageForm}. ${item.rawBrandName} ${item.strength}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.matchedDrug != null)
                      Text(
                        '${item.matchedDrug!.genericName} • ${item.matchedDrug!.manufacturer}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SeverityBadge(
                label: lowConf
                    ? s.tr(
                        'অস্পষ্ট (${s.formatDigits(confPct.toString())}%)',
                        'Low OCR ($confPct%)',
                      )
                    : '${s.formatDigits(confPct.toString())}% OCR',
                tone: lowConf ? BadgeTone.amberCaution : BadgeTone.emeraldSafe,
                icon: lowConf
                    ? Icons.help_outline_rounded
                    : Icons.verified_rounded,
              ),
            ],
          ),

          // AMBER <85% CONFIDENCE GATE BANNER
          if (lowConf) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cautionAmber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_pharmacy_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.tr(
                        'স্থানীয় ফার্মাসিস্টের সাথে যাচাই করুন (Verify with Local Pharmacist) — হাতের লেখা ৮৫%-এর কম নিশ্চিত, অনুমান করা হয়নি।',
                        'Verify with Local Pharmacist — OCR confidence is below 85%. SHUCHONA will never guess ambiguous handwriting.',
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          // Schedule Pill + Plain Language Instruction
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCardElevated
                  : AppColors.lightCanvas,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.scheduleCode,
                    style: TextStyle(
                      color: isDark ? AppColors.darkCanvas : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dosageText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (item.matchedDrug != null) ...[
            const SizedBox(height: 8),
            Text(
              '${s.tr("কাজ", "Purpose")}: ${s.tr(item.matchedDrug!.purposeBn, item.matchedDrug!.purposeEn)} (${item.matchedDrug!.dgdaRegNo})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],

          // Side-by-Side Generic Price Savings Box
          if (item.cheaperGeneric != null && item.matchedDrug != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkEmeraldBg
                    : AppColors.secondaryEmeraldLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondaryEmerald.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.tr('প্রেসক্রিপশন ব্র্যান্ড', 'Prescribed Brand'),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          '${item.matchedDrug!.brandName} (${s.formatTaka(item.matchedDrug!.unitPriceBdt)}/${s.tr("পিস", "unit")})',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                        ),
                        Text(
                          '${s.tr("মোট", "Course")}: ${s.formatTaka(item.brandCourseCostBdt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.secondaryEmerald,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.tr('DGDA সাশ্রয়ী জেনেরিক', 'DGDA Generic Alt'),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.secondaryEmeraldDark,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          '${item.cheaperGeneric!.brandName} (${s.formatTaka(item.cheaperGeneric!.unitPriceBdt)}/${s.tr("পিস", "unit")})',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? const Color(0xFF6EE7B7)
                                    : AppColors.secondaryEmeraldDark,
                              ),
                        ),
                        Text(
                          '${s.tr("সাশ্রয়", "Save")} ${s.formatDigits(item.savingsPercent.toString())}% (${s.formatTaka(item.savingsBdt)})',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.secondaryEmerald,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          TtsListenButton(
            textToSpeak: fullSpeech,
            compact: true,
            accentColor: lowConf ? AppColors.cautionAmber : primary,
            tag: 'med_${item.rawBrandName}_${item.scheduleCode}',
            labelOverride: s.tr(
              '🔊 ওষুধের নিয়ম শুনুন',
              '🔊 Listen to Dosage & Price',
            ),
          ),
        ],
      ),
    );
  }
}
