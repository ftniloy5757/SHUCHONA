import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuchona/app.dart';
import 'package:shuchona/core/localization/app_locale.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/seed_data/blood_donors_seed.dart';
import 'package:shuchona/core/seed_data/dgda_dims_drug_dataset.dart';
import 'package:shuchona/core/seed_data/red_flag_rules.dart';
import 'package:shuchona/core/seed_data/sample_prescriptions.dart';
import 'package:shuchona/features/prescribe_safe/prescribe_safe_engine.dart';
import 'package:shuchona/features/voice_chatbot/chatbot_provider.dart';

void main() {
  group('SHUCHONA Clinical Safety & PrescribeSafe BD Engine', () {
    test('DGDA/DIMS dataset contains at least 35 Bangladeshi drugs', () {
      expect(DgdaDimsDrugDataset.drugs.length, greaterThanOrEqualTo(35));
    });

    test('Tier 1 Red-Flag Engine intercepts Bangla & English emergency inputs', () {
      final bnMatch = RedFlagEngine.evaluate('আমার অতিরিক্ত রক্তপাত হচ্ছে');
      expect(bnMatch, isNotNull);
      expect(bnMatch!.ruleId, equals('severe_hemorrhage'));

      final enMatch = RedFlagEngine.evaluate('Hard fixed breast lump with skin dimpling');
      expect(enMatch, isNotNull);
      expect(enMatch!.ruleId, equals('breast_red_flag'));

      final safeMatch = RedFlagEngine.evaluate('Mild headache after walking');
      expect(safeMatch, isNull);
    });

    test('PrescribeSafe BD flags duplicate Paracetamol, <85% OCR gate, and BDT savings', () {
      final sample1 = SamplePrescriptionsSeed.presets.first;
      final result = PrescribeSafeEngine.analyzeExtracted(
        doctorName: sample1.doctorName,
        clinicName: sample1.clinicName,
        patientInfo: sample1.patientInfo,
        clinicalNotes: sample1.clinicalNotes,
        rawItems: sample1.rawItems,
        usedLiveVisionApi: false,
      );

      // Duplicate Paracetamol (Napa Extend + Ace Plus) caught deterministically
      expect(
        result.ddiAlerts.any((a) => a.isDuplicateIngredient),
        isTrue,
      );
      // Fesol-Z at 74% triggers <85% Amber Pharmacist Verification Gate
      expect(result.lowConfidenceCount, equals(1));
      // Generic savings in BDT ৳ should be substantial
      expect(result.totalSavingsBdt, greaterThan(100));
      expect(result.overallSavingsPercent, greaterThanOrEqualTo(30));

      // Voice dosage scheduler must NOT auto-schedule <85% unverified drugs
      final alarms = PrescribeSafeEngine.buildVoiceDosageAlarms(result);
      expect(alarms.isNotEmpty, isTrue);
      expect(
        alarms.any((a) => a.titleEn.contains('Fesol-Z')),
        isFalse,
      );
    });

    test('PrescribeSafe BD flags Severe Aspirin + Naproxen DDI & Dual PPI on Sample 2', () {
      final sample2 = SamplePrescriptionsSeed.presets[1];
      final result = PrescribeSafeEngine.analyzeExtracted(
        doctorName: sample2.doctorName,
        clinicName: sample2.clinicName,
        patientInfo: sample2.patientInfo,
        clinicalNotes: sample2.clinicalNotes,
        rawItems: sample2.rawItems,
        usedLiveVisionApi: false,
      );

      expect(
        result.ddiAlerts.any((a) => a.id == 'aspirin_naproxen'),
        isTrue,
      );
      expect(
        result.ddiAlerts.any((a) => a.id == 'dup_ppi'),
        isTrue,
      );
      expect(result.lowConfidenceCount, equals(1)); // Smudged Amdocal 5mg
    });

    test('Blood donor network enforces 90-day medical cooldown', () {
      final inCooldown = BloodDonorsSeed.donors.where((d) => !d.isEligible);
      final eligible = BloodDonorsSeed.donors.where((d) => d.isEligible);
      expect(inCooldown.isNotEmpty, isTrue);
      expect(eligible.isNotEmpty, isTrue);
      for (final d in inCooldown) {
        expect(d.daysSinceLastDonation, lessThan(90));
      }
    });

    test('Chatbot welcome message localizes between Bangla and English', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialMsg = container.read(chatbotProvider).messages.first;
      expect(initialMsg.localizedText(AppLocale.bn), contains('সূচনা'));
      expect(initialMsg.localizedText(AppLocale.en), contains('SHUCHONA'));
    });
  });

  testWidgets(
      'SHUCHONA auto-logs into Demo Mode on fresh install and supports onboarding/consent flow',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ShuchonaApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Testers land directly on Home Dashboard without credentials
    expect(find.textContaining('সূচনা'), findsWidgets);
    expect(find.text('কথা বলে সাহায্য নিন'), findsOneWidget);

    // Signing out opens the Audio-Visual Onboarding & Consent flow cleanly
    await container.read(userSessionProvider.notifier).signOutToOnboarding();
    await tester.pumpAndSettle();

    expect(find.text('অফলাইন ডেমো মোডে সরাসরি শুরু করুন'), findsOneWidget);

    await tester.tap(find.text('অফলাইন ডেমো মোডে সরাসরি শুরু করুন'));
    await tester.pumpAndSettle();

    expect(find.text('তথ্য গোপনীয়তা ও অবহিত সম্মতি'), findsOneWidget);
    expect(find.text('আমি সম্মত ও এগিয়ে যান'), findsOneWidget);
  });
}
