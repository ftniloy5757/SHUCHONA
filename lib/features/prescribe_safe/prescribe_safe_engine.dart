import 'dart:typed_data';
import 'package:shuchona/core/offline_sync/notification_service.dart';
import 'package:shuchona/core/seed_data/ddi_matrix.dart';
import 'package:shuchona/core/seed_data/dgda_dims_drug_dataset.dart';
import 'package:shuchona/core/seed_data/sample_prescriptions.dart';
import 'package:shuchona/features/prescribe_safe/prescribe_safe_models.dart';
import 'package:uuid/uuid.dart';

/// Pipeline A: PrescribeSafe BD Engine
/// 1. Parses Bangladeshi clinical shorthand (`1+0+1`, `আহারের পর/পূর্বে`)
/// 2. Grounds drugs in bundled DGDA/DIMS dataset (42 brands & generics)
/// 3. Applies <85% Confidence Gate -> Pharmacist Verification Flag
/// 4. Runs Deterministic DDI & Duplicate Active Ingredient Guard
/// 5. Computes exact BDT (৳) generic arbitrage savings
/// 6. Generates Bangla Voice Dosage Reminder schedules
abstract final class PrescribeSafeEngine {
  static const _uuid = Uuid();

  static PrescriptionAnalysisResult analyzeExtracted({
    required String doctorName,
    required String clinicName,
    required String patientInfo,
    required String clinicalNotes,
    required List<RawExtractedMed> rawItems,
    required bool usedLiveVisionApi,
    bool isPregnantContext = false,
    String? assetImagePath,
    Uint8List? capturedImageBytes,
  }) {
    final decodedItems = <DecodedMedicationItem>[];
    final matchedDrugs = <DgdaDrugEntry>[];

    for (final raw in rawItems) {
      final matched = DgdaDimsDrugDataset.findByBrandOrGeneric(raw.brandName);
      if (matched != null) {
        matchedDrugs.add(matched);
      }
      final cheaper = matched != null
          ? DgdaDimsDrugDataset.findCheaperGenericAlternative(matched)
          : null;

      final dailyUnits = _parseDailyUnits(raw.scheduleCode);
      final totalUnits = (dailyUnits * raw.durationDays).clamp(1, 360);

      final brandUnitPrice = matched?.unitPriceBdt ?? 6.0;
      final genericUnitPrice = cheaper?.unitPriceBdt ?? brandUnitPrice;

      final (bnInstr, enInstr) = buildSpokenDosageInstruction(
        brandName: raw.brandName,
        dosageForm: raw.dosageForm,
        scheduleCode: raw.scheduleCode,
        mealInstruction: raw.mealInstruction,
        durationDays: raw.durationDays,
      );

      decodedItems.add(
        DecodedMedicationItem(
          rawBrandName: raw.brandName,
          dosageForm: raw.dosageForm,
          strength: raw.strength.isNotEmpty
              ? raw.strength
              : (matched?.strength ?? ''),
          scheduleCode: raw.scheduleCode,
          mealInstruction: raw.mealInstruction,
          durationDays: raw.durationDays,
          ocrConfidence: raw.ocrConfidence,
          matchedDrug: matched,
          cheaperGeneric: cheaper,
          dosageInstructionBn: bnInstr,
          dosageInstructionEn: enInstr,
          totalUnitsRequired: totalUnits,
          brandCourseCostBdt: brandUnitPrice * totalUnits,
          genericCourseCostBdt: genericUnitPrice * totalUnits,
        ),
      );
    }

    final alerts = DdiMatrix.analyzeDrugs(
      matchedDrugs,
      isPregnant: isPregnantContext,
    );

    return PrescriptionAnalysisResult(
      id: _uuid.v4(),
      doctorName: doctorName,
      clinicName: clinicName,
      patientInfo: patientInfo,
      clinicalNotes: clinicalNotes,
      items: decodedItems,
      ddiAlerts: alerts,
      usedLiveVisionApi: usedLiveVisionApi,
      analyzedAt: DateTime.now(),
      assetImagePath: assetImagePath,
      capturedImageBytes: capturedImageBytes,
    );
  }

  static int _parseDailyUnits(String scheduleCode) {
    final parts = scheduleCode
        .split(RegExp(r'[+\-\s]+'))
        .map((p) => int.tryParse(p.trim()) ?? 0)
        .toList();
    final sum = parts.fold<int>(0, (a, b) => a + b);
    return sum > 0 ? sum : 1;
  }

  static (int morning, int noon, int night) parseSlots(String scheduleCode) {
    final parts = scheduleCode
        .split(RegExp(r'[+\-\s]+'))
        .map((p) => int.tryParse(p.trim()) ?? 0)
        .toList();
    if (parts.length >= 3) {
      return (parts[0], parts[1], parts[2]);
    }
    if (parts.length == 2) {
      return (parts[0], 0, parts[1]);
    }
    return (1, 0, 0);
  }

  /// Converts Bangladeshi prescription shorthand (`1+0+1`, `before_meal`) into
  /// warm, natural spoken Bangla & English audio dosage instructions.
  static (String bn, String en) buildSpokenDosageInstruction({
    required String brandName,
    required String dosageForm,
    required String scheduleCode,
    required String mealInstruction,
    required int durationDays,
  }) {
    final (m, n, e) = parseSlots(scheduleCode);
    final formBn = dosageForm.toLowerCase().contains('cap')
        ? 'ক্যাপসুল'
        : 'ট্যাবলেট';
    final formEn = dosageForm.toLowerCase().contains('cap')
        ? 'capsule'
        : 'tablet';

    final bnParts = <String>[];
    final enParts = <String>[];
    if (m > 0) {
      bnParts.add('সকালে ${_bnNum(m)}টি');
      enParts.add('$m in the morning');
    }
    if (n > 0) {
      bnParts.add('দুপুরে ${_bnNum(n)}টি');
      enParts.add('$n at noon');
    }
    if (e > 0) {
      bnParts.add('রাতে ${_bnNum(e)}টি');
      enParts.add('$e at night');
    }

    final mealBn = switch (mealInstruction) {
      'before_meal' => 'খাওয়ার ৩০ মিনিট আগে',
      'at_night' => 'রাতে ঘুমানোর আগে',
      'any_time' => 'যেকোনো সময়',
      _ => 'খাওয়ার পরে (ভরা পেটে)',
    };

    final mealEn = switch (mealInstruction) {
      'before_meal' => '30 minutes before meals',
      'at_night' => 'at bedtime',
      'any_time' => 'any time',
      _ => 'after meals',
    };

    final bn =
        '$brandName $formBn: ${bnParts.join(", ")} — $mealBn, মোট ${_bnNum(durationDays)} দিন।';
    final en =
        '$brandName ($formEn): ${enParts.join(", ")} — $mealEn for $durationDays days.';

    return (bn, en);
  }

  /// Converts all high-confidence prescription items into local Bangla voice alarms.
  static List<ScheduledVoiceReminder> buildVoiceDosageAlarms(
    PrescriptionAnalysisResult result,
  ) {
    final reminders = <ScheduledVoiceReminder>[];
    var baseId = 400;

    for (final item in result.items) {
      // Never auto-schedule unverified <85% drugs until pharmacist confirms!
      if (item.needsPharmacistVerification) continue;

      final (m, n, e) = parseSlots(item.scheduleCode);
      final mealBn = item.mealInstruction == 'before_meal'
          ? 'খাওয়ার আগে'
          : 'খাওয়ার পরে';
      final mealEn = item.mealInstruction == 'before_meal'
          ? 'before meals'
          : 'after meals';
      final formBn = item.dosageForm.toLowerCase().contains('cap')
          ? 'ক্যাপসুল'
          : 'ট্যাবলেট';

      if (m > 0) {
        reminders.add(
          ScheduledVoiceReminder(
            id: baseId++,
            titleBn: 'সকালের ওষুধ: ${item.rawBrandName}',
            titleEn: 'Morning Dose: ${item.rawBrandName}',
            spokenMessageBn:
                'সকালের ওষুধ খাওয়ার সময় হয়েছে — ${item.rawBrandName} ${_bnNum(m)}টি $formBn $mealBn।',
            spokenMessageEn:
                'Time for your morning dose — take $m ${item.rawBrandName} $mealEn.',
            hour: item.mealInstruction == 'before_meal' ? 7 : 8,
            minute: item.mealInstruction == 'before_meal' ? 30 : 30,
            category: 'medication',
          ),
        );
      }
      if (n > 0) {
        reminders.add(
          ScheduledVoiceReminder(
            id: baseId++,
            titleBn: 'দুপুরের ওষুধ: ${item.rawBrandName}',
            titleEn: 'Noon Dose: ${item.rawBrandName}',
            spokenMessageBn:
                'দুপুরের ওষুধ খাওয়ার সময় হয়েছে — ${item.rawBrandName} ${_bnNum(n)}টি $formBn $mealBn।',
            spokenMessageEn:
                'Time for your afternoon dose — take $n ${item.rawBrandName} $mealEn.',
            hour: 13,
            minute: 30,
            category: 'medication',
          ),
        );
      }
      if (e > 0) {
        reminders.add(
          ScheduledVoiceReminder(
            id: baseId++,
            titleBn: 'রাতের ওষুধ: ${item.rawBrandName}',
            titleEn: 'Night Dose: ${item.rawBrandName}',
            spokenMessageBn:
                'রাতের ওষুধ খাওয়ার সময় হয়েছে — ${item.rawBrandName} ${_bnNum(e)}টি $formBn $mealBn।',
            spokenMessageEn:
                'Time for your night dose — take $e ${item.rawBrandName} $mealEn.',
            hour: item.mealInstruction == 'before_meal' ? 20 : 21,
            minute: 30,
            category: 'medication',
          ),
        );
      }
    }

    return reminders;
  }

  static String _bnNum(int n) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var s = n.toString();
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(en[i], bn[i]);
    }
    return s;
  }
}

