/// Two authentic Bangladeshi handwritten prescription test cases bundled in assets
/// so judges and users can test PrescribeSafe BD end-to-end with one tap.
class SamplePrescriptionPreset {
  const SamplePrescriptionPreset({
    required this.id,
    required this.assetPath,
    required this.titleBn,
    required this.titleEn,
    required this.subtitleBn,
    required this.subtitleEn,
    required this.doctorName,
    required this.clinicName,
    required this.patientInfo,
    required this.clinicalNotes,
    required this.rawItems,
  });

  final String id;
  final String assetPath;
  final String titleBn;
  final String titleEn;
  final String subtitleBn;
  final String subtitleEn;
  final String doctorName;
  final String clinicName;
  final String patientInfo;
  final String clinicalNotes;
  final List<RawExtractedMed> rawItems;
}

class RawExtractedMed {
  const RawExtractedMed({
    required this.brandName,
    required this.dosageForm,
    required this.strength,
    required this.scheduleCode,
    required this.mealInstruction,
    required this.durationDays,
    required this.ocrConfidence,
  });

  final String brandName;
  final String dosageForm;
  final String strength;
  final String scheduleCode;
  final String mealInstruction; // before_meal | after_meal | at_night | any_time
  final int durationDays;
  final double ocrConfidence;
}

abstract final class SamplePrescriptionsSeed {
  static const List<SamplePrescriptionPreset> presets = [
    SamplePrescriptionPreset(
      id: 'rx_maternal_duplicate',
      assetPath: 'assets/prescriptions/rx_sample_multi_doctor.jpg',
      titleBn: 'নমুনা ১: রহিমা বেগম (দ্বৈত প্যারাসিটামল + ৪২% সাশ্রয়)',
      titleEn: 'Sample 1: Rahima Begum (Duplicate Paracetamol + 42% Savings)',
      subtitleBn: 'ডা. এম. এ. রহমান • সাভার হেলথ কেয়ার • ৫টি ওষুধ (১টি অস্পষ্ট)',
      subtitleEn: 'Dr. M. A. Rahman • Savar Health Care • 5 meds (1 low-confidence)',
      doctorName: 'Dr. M. A. Rahman, MBBS, FCPS (Medicine)',
      clinicName: 'Savar Health Care Chamber, Dhaka',
      patientInfo: 'Mrs. Rahima Begum, Age 28Y (Female)',
      clinicalNotes: 'C/C: Weakness, Acidity, Fever, Body ache | BP: 110/70 mmHg',
      rawItems: [
        RawExtractedMed(
          brandName: 'Nexum',
          dosageForm: 'Tab',
          strength: '20mg',
          scheduleCode: '1+0+1',
          mealInstruction: 'before_meal',
          durationDays: 14,
          ocrConfidence: 0.96,
        ),
        RawExtractedMed(
          brandName: 'Napa Extend',
          dosageForm: 'Tab',
          strength: '665mg',
          scheduleCode: '1+0+1',
          mealInstruction: 'after_meal',
          durationDays: 5,
          ocrConfidence: 0.95,
        ),
        RawExtractedMed(
          brandName: 'Ace Plus',
          dosageForm: 'Tab',
          strength: '500mg+65mg',
          scheduleCode: '1+1+1',
          mealInstruction: 'after_meal',
          durationDays: 5,
          ocrConfidence: 0.93,
        ),
        RawExtractedMed(
          brandName: 'Clofenac',
          dosageForm: 'Tab',
          strength: '50mg',
          scheduleCode: '1+0+1',
          mealInstruction: 'after_meal',
          durationDays: 5,
          ocrConfidence: 0.91,
        ),
        RawExtractedMed(
          brandName: 'Fesol-Z',
          dosageForm: 'Cap',
          strength: '50mg+0.5mg+61.8mg',
          scheduleCode: '0+1+0',
          mealInstruction: 'after_meal',
          durationDays: 30,
          ocrConfidence: 0.74, // Triggers <85% Amber Pharmacist Verify Gate!
        ),
      ],
    ),
    SamplePrescriptionPreset(
      id: 'rx_chronic_ddi',
      assetPath: 'assets/prescriptions/rx_sample_chronic_ddi.jpg',
      titleBn: 'নমুনা ২: আব্দুল করিম (গুরুতর DDI + ৪৭% সাশ্রয়)',
      titleEn: 'Sample 2: Abdul Karim (Severe DDI Alert + 47% Generic Savings)',
      subtitleBn: 'ডা. ফারহানা ইয়াসমিন • কুমিল্লা ক্লিনিক • ৬টি ওষুধ (১টি ঝাপসা)',
      subtitleEn: 'Dr. Farhana Yasmin • Cumilla Clinic • 6 meds (1 smudged)',
      doctorName: 'Dr. Farhana Yasmin, MBBS, MD (Internal Medicine)',
      clinicName: 'Cumilla Community Clinic',
      patientInfo: 'Mr. Abdul Karim, Age 54Y (Male)',
      clinicalNotes: 'O/E: BP 145/90, RBS 11.2 mmol/L, Knee pain, Wt 72kg',
      rawItems: [
        RawExtractedMed(
          brandName: 'Ecosprin',
          dosageForm: 'Tab',
          strength: '75mg',
          scheduleCode: '0+1+0',
          mealInstruction: 'after_meal',
          durationDays: 30,
          ocrConfidence: 0.97,
        ),
        RawExtractedMed(
          brandName: 'Naproxen Plus',
          dosageForm: 'Tab',
          strength: '500mg+20mg',
          scheduleCode: '1+0+1',
          mealInstruction: 'after_meal',
          durationDays: 7,
          ocrConfidence: 0.95,
        ),
        RawExtractedMed(
          brandName: 'Comet',
          dosageForm: 'Tab',
          strength: '500mg',
          scheduleCode: '1+0+1',
          mealInstruction: 'after_meal',
          durationDays: 30,
          ocrConfidence: 0.96,
        ),
        RawExtractedMed(
          brandName: 'Atova',
          dosageForm: 'Tab',
          strength: '20mg',
          scheduleCode: '0+0+1',
          mealInstruction: 'at_night',
          durationDays: 30,
          ocrConfidence: 0.95,
        ),
        RawExtractedMed(
          brandName: 'Seclo',
          dosageForm: 'Cap',
          strength: '20mg',
          scheduleCode: '1+0+1',
          mealInstruction: 'before_meal',
          durationDays: 14,
          ocrConfidence: 0.94,
        ),
        RawExtractedMed(
          brandName: 'Amdocal',
          dosageForm: 'Tab',
          strength: '5mg',
          scheduleCode: '1+0+0',
          mealInstruction: 'after_meal',
          durationDays: 30,
          ocrConfidence: 0.72, // Smudged on image -> Triggers <85% Amber Gate!
        ),
      ],
    ),
  ];
}

