import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/offline_sync/gemini_ai_service.dart';
import 'package:shuchona/core/seed_data/sample_prescriptions.dart';
import 'package:shuchona/features/prescribe_safe/prescribe_safe_engine.dart';
import 'package:shuchona/features/prescribe_safe/prescribe_safe_models.dart';

class PrescribeSafeState {
  const PrescribeSafeState({
    this.isAnalyzing = false,
    this.currentResult,
    this.isPregnantToggle = false,
    this.alarmsScheduledForId,
    this.errorMessage,
  });

  final bool isAnalyzing;
  final PrescriptionAnalysisResult? currentResult;
  final bool isPregnantToggle;
  final String? alarmsScheduledForId;
  final String? errorMessage;

  PrescribeSafeState copyWith({
    bool? isAnalyzing,
    PrescriptionAnalysisResult? currentResult,
    bool clearResult = false,
    bool? isPregnantToggle,
    String? alarmsScheduledForId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PrescribeSafeState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      currentResult: clearResult ? null : (currentResult ?? this.currentResult),
      isPregnantToggle: isPregnantToggle ?? this.isPregnantToggle,
      alarmsScheduledForId: alarmsScheduledForId ?? this.alarmsScheduledForId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PrescribeSafeNotifier extends StateNotifier<PrescribeSafeState> {
  PrescribeSafeNotifier(this._ref) : super(const PrescribeSafeState());

  final Ref _ref;

  void togglePregnancyContext(bool value) {
    state = state.copyWith(isPregnantToggle: value);
    // Re-evaluate current result if already loaded so pregnancy contraindications update live
    final cur = state.currentResult;
    if (cur != null) {
      final rawItems = cur.items
          .map(
            (i) => RawExtractedMed(
              brandName: i.rawBrandName,
              dosageForm: i.dosageForm,
              strength: i.strength,
              scheduleCode: i.scheduleCode,
              mealInstruction: i.mealInstruction,
              durationDays: i.durationDays,
              ocrConfidence: i.ocrConfidence,
            ),
          )
          .toList();
      final updated = PrescribeSafeEngine.analyzeExtracted(
        doctorName: cur.doctorName,
        clinicName: cur.clinicName,
        patientInfo: cur.patientInfo,
        clinicalNotes: cur.clinicalNotes,
        rawItems: rawItems,
        usedLiveVisionApi: cur.usedLiveVisionApi,
        isPregnantContext: value,
        assetImagePath: cur.assetImagePath,
        capturedImageBytes: cur.capturedImageBytes,
      );
      state = state.copyWith(currentResult: updated);
    }
  }

  /// Runs a realistic one-tap Bangladeshi sample prescription preset for instant testing.
  Future<PrescriptionAnalysisResult> analyzeSamplePreset(
    SamplePrescriptionPreset preset,
  ) async {
    state = state.copyWith(isAnalyzing: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final result = PrescribeSafeEngine.analyzeExtracted(
      doctorName: preset.doctorName,
      clinicName: preset.clinicName,
      patientInfo: preset.patientInfo,
      clinicalNotes: preset.clinicalNotes,
      rawItems: preset.rawItems,
      usedLiveVisionApi: false,
      isPregnantContext: state.isPregnantToggle,
      assetImagePath: preset.assetPath,
    );

    state = state.copyWith(isAnalyzing: false, currentResult: result);
    _recordAnonymizedSavings(result);
    return result;
  }

  /// Runs multimodal Vision OCR (Gemini API if configured & online, else offline DGDA pipeline)
  /// on a photo taken from Camera or Gallery.
  Future<PrescriptionAnalysisResult> analyzeCapturedImage(
    Uint8List imageBytes,
  ) async {
    state = state.copyWith(isAnalyzing: true, clearError: true);
    final isOnline = _ref.read(offlineSyncProvider).effectivelyOnline;

    final extracted = await GeminiAiService.instance.extractPrescriptionFromImage(
      imageBytes: imageBytes,
      isOnline: isOnline,
    );

    final result = PrescribeSafeEngine.analyzeExtracted(
      doctorName: extracted.doctorName,
      clinicName: extracted.clinicName,
      patientInfo: extracted.patientInfo,
      clinicalNotes: extracted.clinicalNotes,
      rawItems: extracted.items,
      usedLiveVisionApi: extracted.usedLiveVisionApi,
      isPregnantContext: state.isPregnantToggle,
      capturedImageBytes: imageBytes,
    );

    state = state.copyWith(isAnalyzing: false, currentResult: result);
    _recordAnonymizedSavings(result);
    return result;
  }

  /// Converts decoded prescription into local Bangla voice dosage reminders!
  Future<int> scheduleVoiceDosageAlarms() async {
    final result = state.currentResult;
    if (result == null) return 0;

    final alarms = PrescribeSafeEngine.buildVoiceDosageAlarms(result);
    if (alarms.isEmpty) return 0;

    await _ref.read(remindersProvider.notifier).addOrUpdateReminders(alarms);
    state = state.copyWith(alarmsScheduledForId: result.id);
    return alarms.length;
  }

  void _recordAnonymizedSavings(PrescriptionAnalysisResult result) {
    if (_ref.read(shgGuestModeProvider)) return;
    if (result.totalSavingsBdt > 0) {
      _ref
          .read(userSessionProvider.notifier)
          .recordPrescriptionSavings(result.totalSavingsBdt);
      _ref.read(offlineSyncProvider.notifier).recordSyncableAction(
        actionType: 'prescribe_safe_savings',
        anonymizedPayload: {
          'savedBdt': result.totalSavingsBdt.round(),
          'ddiFlags': result.ddiAlerts.length,
          'upazila': _ref.read(userSessionProvider).upazila,
        },
      );
    }
  }

  void clearResult() {
    state = state.copyWith(clearResult: true, clearError: true);
  }
}

final prescribeSafeProvider =
    StateNotifierProvider<PrescribeSafeNotifier, PrescribeSafeState>((ref) {
  return PrescribeSafeNotifier(ref);
});

