import 'dart:typed_data';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/seed_data/ddi_matrix.dart';
import 'package:shuchona/core/seed_data/dgda_dims_drug_dataset.dart';

/// A single decoded medication item grounded in the DGDA/DIMS dataset.
class DecodedMedicationItem {
  const DecodedMedicationItem({
    required this.rawBrandName,
    required this.dosageForm,
    required this.strength,
    required this.scheduleCode,
    required this.mealInstruction,
    required this.durationDays,
    required this.ocrConfidence,
    required this.matchedDrug,
    required this.cheaperGeneric,
    required this.dosageInstructionBn,
    required this.dosageInstructionEn,
    required this.totalUnitsRequired,
    required this.brandCourseCostBdt,
    required this.genericCourseCostBdt,
  });

  final String rawBrandName;
  final String dosageForm;
  final String strength;
  final String scheduleCode; // e.g., 1+0+1
  final String mealInstruction; // before_meal | after_meal | at_night | any_time
  final int durationDays;
  final double ocrConfidence;
  final DgdaDrugEntry? matchedDrug;
  final DgdaDrugEntry? cheaperGeneric;
  final String dosageInstructionBn;
  final String dosageInstructionEn;
  final int totalUnitsRequired;
  final double brandCourseCostBdt;
  final double genericCourseCostBdt;

  /// Confidence Gate (< 85% triggers Amber "Verify with Local Pharmacist").
  bool get needsPharmacistVerification =>
      ocrConfidence < AppConstants.ocrConfidenceThreshold ||
      matchedDrug == null;

  double get savingsBdt =>
      (brandCourseCostBdt - genericCourseCostBdt).clamp(0, double.infinity);

  int get savingsPercent {
    if (brandCourseCostBdt <= 0 || savingsBdt <= 0) return 0;
    return ((savingsBdt / brandCourseCostBdt) * 100).round();
  }
}

/// Complete analyzed result of a handwritten Bangladeshi prescription.
class PrescriptionAnalysisResult {
  const PrescriptionAnalysisResult({
    required this.id,
    required this.doctorName,
    required this.clinicName,
    required this.patientInfo,
    required this.clinicalNotes,
    required this.items,
    required this.ddiAlerts,
    required this.usedLiveVisionApi,
    required this.analyzedAt,
    this.assetImagePath,
    this.capturedImageBytes,
  });

  final String id;
  final String doctorName;
  final String clinicName;
  final String patientInfo;
  final String clinicalNotes;
  final List<DecodedMedicationItem> items;
  final List<DdiAlert> ddiAlerts;
  final bool usedLiveVisionApi;
  final DateTime analyzedAt;
  final String? assetImagePath;
  final Uint8List? capturedImageBytes;

  double get totalBrandCostBdt =>
      items.fold(0.0, (sum, item) => sum + item.brandCourseCostBdt);

  double get totalGenericCostBdt =>
      items.fold(0.0, (sum, item) => sum + item.genericCourseCostBdt);

  double get totalSavingsBdt =>
      (totalBrandCostBdt - totalGenericCostBdt).clamp(0, double.infinity);

  int get overallSavingsPercent {
    if (totalBrandCostBdt <= 0) return 0;
    return ((totalSavingsBdt / totalBrandCostBdt) * 100).round();
  }

  int get lowConfidenceCount =>
      items.where((i) => i.needsPharmacistVerification).length;
}

