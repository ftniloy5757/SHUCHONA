import 'package:shuchona/core/seed_data/dgda_dims_drug_dataset.dart';

enum InteractionSeverity { critical, high, moderate }

/// Represents a detected Drug-Drug Interaction or Duplicate Active Ingredient warning.
class DdiAlert {
  const DdiAlert({
    required this.id,
    required this.severity,
    required this.drugNames,
    required this.isDuplicateIngredient,
    required this.titleBn,
    required this.titleEn,
    required this.explanationBn,
    required this.explanationEn,
    required this.actionBn,
    required this.actionEn,
  });

  final String id;
  final InteractionSeverity severity;
  final List<String> drugNames;
  final bool isDuplicateIngredient;
  final String titleBn;
  final String titleEn;
  final String explanationBn;
  final String explanationEn;
  final String actionBn;
  final String actionEn;
}

class _DdiRule {
  const _DdiRule({
    required this.id,
    required this.ingredientA,
    required this.ingredientB,
    required this.severity,
    required this.titleBn,
    required this.titleEn,
    required this.explanationBn,
    required this.explanationEn,
    required this.actionBn,
    required this.actionEn,
  });

  final String id;
  final String ingredientA;
  final String ingredientB;
  final InteractionSeverity severity;
  final String titleBn;
  final String titleEn;
  final String explanationBn;
  final String explanationEn;
  final String actionBn;
  final String actionEn;
}

/// Deterministic Drug-Drug Interaction (DDI) and Duplicate Active Ingredient Engine.
/// Never relies on probabilistic LLM guesswork for medication safety alerts.
abstract final class DdiMatrix {
  static const List<_DdiRule> _rules = [
    _DdiRule(
      id: 'aspirin_naproxen',
      ingredientA: 'aspirin',
      ingredientB: 'naproxen',
      severity: InteractionSeverity.critical,
      titleBn: 'গুরুতর ওষুধ বিক্রিয়া: অ্যাসপিরিন ও ন্যাপ্রোক্সেন',
      titleEn: 'Severe Drug Interaction: Aspirin + Naproxen (NSAID)',
      explanationBn:
          'একসাথে অ্যাসপিরিন (Ecosprin) ও ব্যথার ওষুধ ন্যাপ্রোক্সেন (Naproxen Plus) খেলে পাকস্থলীতে রক্তক্ষরণের ঝুঁকি অনেক বেড়ে যায় এবং হার্টের সুরক্ষা কমে যেতে পারে।',
      explanationEn:
          'Combining low-dose Aspirin with Naproxen significantly increases stomach bleeding risk and can blunt Aspirin’s heart-protective effect.',
      actionBn:
          'ডাক্তারের সাথে কথা না বলে দুটি ওষুধ একসাথে খাবেন না। বিকল্প ব্যথার ওষুধের জন্য চিকিৎসকের পরামর্শ নিন।',
      actionEn:
          'Do not take together without consulting your prescribing doctor for a safer pain relief alternative.',
    ),
    _DdiRule(
      id: 'aspirin_diclofenac',
      ingredientA: 'aspirin',
      ingredientB: 'diclofenac',
      severity: InteractionSeverity.critical,
      titleBn: 'গুরুতর সতর্কতা: অ্যাসপিরিন ও ডাইক্লোফেনাক',
      titleEn: 'Severe Interaction: Aspirin + Diclofenac',
      explanationBn:
          'রক্ত পাতলা রাখার অ্যাসপিরিন ও ডাইক্লোফেনাক একসাথে খেলে আলসার ও পাকস্থলীতে রক্তপাতের ঝুঁকি তীব্র হয়।',
      explanationEn:
          'Taking Aspirin and Diclofenac together raises the risk of severe gastrointestinal ulceration and bleeding.',
      actionBn: 'দ্রুত আপনার ডাক্তার বা ফার্মাসিস্টের সাথে পরামর্শ করুন।',
      actionEn: 'Consult your physician or licensed pharmacist before combining.',
    ),
    _DdiRule(
      id: 'diclofenac_naproxen',
      ingredientA: 'diclofenac',
      ingredientB: 'naproxen',
      severity: InteractionSeverity.critical,
      titleBn: 'দ্বৈত ব্যথার ওষুধ (NSAID) ঝুঁকি',
      titleEn: 'Dual NSAID Toxicity: Diclofenac + Naproxen',
      explanationBn:
          'একই সময়ে দুটি ভিন্ন ব্যথার ওষুধ (NSAID) খেলে কিডনি ও পাকস্থলীর মারাত্মক ক্ষতি হতে পারে।',
      explanationEn:
          'Concurrent use of two NSAIDs markedly elevates risk of gastric bleeding and acute kidney injury.',
      actionBn: 'একটির বেশি NSAID খাবেন না — ডাক্তারের কাছে নিশ্চিত হোন।',
      actionEn: 'Avoid taking two NSAIDs simultaneously; verify with your doctor.',
    ),
    _DdiRule(
      id: 'azithromycin_atorvastatin',
      ingredientA: 'azithromycin',
      ingredientB: 'atorvastatin',
      severity: InteractionSeverity.moderate,
      titleBn: 'মাঝারি সতর্কতা: অ্যাজিথ্রোমাইসিন ও অ্যাটোরভাস্ট্যাটিন',
      titleEn: 'Moderate Interaction: Azithromycin + Atorvastatin',
      explanationBn:
          'এই দুটি ওষুধ একসাথে খেলে পেশীতে ব্যথা বা দুর্বলতা বাড়তে পারে।',
      explanationEn:
          'Co-administration may elevate statin blood levels, increasing risk of muscle aches or weakness.',
      actionBn: 'অস্বাভাবিক পেশী ব্যথা হলে ডাক্তারকে জানান।',
      actionEn: 'Report any unexplained muscle pain or weakness to your doctor.',
    ),
    _DdiRule(
      id: 'ciprofloxacin_iron',
      ingredientA: 'ciprofloxacin',
      ingredientB: 'iron',
      severity: InteractionSeverity.high,
      titleBn: 'ওষুধ শোষণে বাধা: সিপ্রোফ্লক্সাসিন ও আয়রন',
      titleEn: 'Absorption Conflict: Ciprofloxacin + Iron Supplement',
      explanationBn:
          'আয়রন বা ক্যালসিয়াম ট্যাবলেট অ্যান্টিবায়োটিক সিপ্রোফ্লক্সাসিনের কার্যকারিতা কমিয়ে দেয়।',
      explanationEn:
          'Iron binds to Ciprofloxacin in the stomach and blocks antibiotic absorption.',
      actionBn: 'দুটি ওষুধের মাঝে কমপক্ষে ২ থেকে ৪ ঘণ্টা বিরতি রাখুন।',
      actionEn: 'Separate doses by at least 2 to 4 hours.',
    ),
    _DdiRule(
      id: 'metformin_diclofenac',
      ingredientA: 'metformin',
      ingredientB: 'diclofenac',
      severity: InteractionSeverity.moderate,
      titleBn: 'সতর্কতা: ডায়াবেটিস ও ব্যথার ওষুধ',
      titleEn: 'Renal Caution: Metformin + Diclofenac',
      explanationBn:
          'দীর্ঘদিন ব্যথার ওষুধ (NSAID) ও মেটফরমিন একসাথে খেলে কিডনির ওপর চাপ পড়তে পারে।',
      explanationEn:
          'Prolonged NSAID use alongside Metformin may stress kidney function, especially if dehydrated.',
      actionBn: 'পর্যাপ্ত পানি পান করুন এবং ব্যথার ওষুধ স্বল্পমেয়াদে খান।',
      actionEn: 'Stay hydrated and keep NSAID courses short under doctor guidance.',
    ),
  ];

  /// Evaluates a list of matched DGDA drugs for:
  /// 1) Duplicate active ingredients (e.g., Napa Extend + Ace Plus both contain Paracetamol)
  /// 2) Duplicate therapeutic PPIs (e.g., Esomeprazole + Omeprazole)
  /// 3) Known clinical Drug-Drug Interactions (DDIs)
  static List<DdiAlert> analyzeDrugs(
    List<DgdaDrugEntry> matchedDrugs, {
    bool isPregnant = false,
  }) {
    final alerts = <DdiAlert>[];
    final seenAlertIds = <String>{};

    // 1. Check duplicate active ingredients across different prescribed items
    final ingredientToBrands = <String, List<String>>{};
    for (final drug in matchedDrugs) {
      for (final ing in drug.activeIngredients) {
        ingredientToBrands.putIfAbsent(ing, () => []).add(drug.brandName);
      }
    }

    ingredientToBrands.forEach((ingredient, brands) {
      if (brands.length > 1) {
        final key = 'dup_$ingredient';
        if (seenAlertIds.add(key)) {
          final isParacetamol = ingredient == 'paracetamol';
          alerts.add(
            DdiAlert(
              id: key,
              severity: isParacetamol
                  ? InteractionSeverity.critical
                  : InteractionSeverity.high,
              drugNames: brands,
              isDuplicateIngredient: true,
              titleBn: isParacetamol
                  ? 'দ্বৈত উপাদান সতর্কতা: দুই ওষুধে প্যারাসিটামল!'
                  : 'একই উপাদান দুটি ওষুধে রয়েছে ($ingredient)',
              titleEn: isParacetamol
                  ? 'Duplicate Active Ingredient: Double Paracetamol Overdose Risk!'
                  : 'Duplicate Active Ingredient Detected ($ingredient)',
              explanationBn: isParacetamol
                  ? '${brands.join(" এবং ")} — দুটি ওষুধেই প্যারাসিটামল আছে। একসাথে খেলে দৈনিক মাত্রা অতিরিক্ত হয়ে লিভারের মারাত্মক ক্ষতি হতে পারে।'
                  : '${brands.join(" এবং ")} দুটি ওষুধেই একই সক্রিয় উপাদান রয়েছে। এটি অপ্রয়োজনীয় ডবল ডোজ তৈরি করছে।',
              explanationEn: isParacetamol
                  ? 'Both ${brands.join(" and ")} contain Paracetamol. Taking them together risks exceeding the safe daily limit and causing serious liver toxicity.'
                  : 'Both ${brands.join(" and ")} contain the same active ingredient ($ingredient), creating a double-dosing risk.',
              actionBn:
                  'ডাক্তার বা ফার্মাসিস্টের সাথে যাচাই করে যেকোনো একটি ওষুধ বেছে নিন।',
              actionEn:
                  'Confirm with your doctor or pharmacist before taking both medicines together.',
            ),
          );
        }
      }
    });

    // 2. Check duplicate PPI class (e.g. Esomeprazole inside Naproxen Plus + Omeprazole Seclo)
    final ppiDrugs = matchedDrugs
        .where(
          (d) =>
              d.activeIngredients.contains('esomeprazole') ||
              d.activeIngredients.contains('omeprazole'),
        )
        .toList();
    if (ppiDrugs.length > 1 && seenAlertIds.add('dup_ppi')) {
      final names = ppiDrugs.map((d) => d.brandName).toList();
      alerts.add(
        DdiAlert(
          id: 'dup_ppi',
          severity: InteractionSeverity.high,
          drugNames: names,
          isDuplicateIngredient: true,
          titleBn: 'একসাথে দুটি গ্যাস্ট্রিকের ওষুধ (PPI) রয়েছে!',
          titleEn: 'Duplicate Gastric Acid Medicine (Dual PPI)',
          explanationBn:
              '${names.join(" এবং ")} — দুটি ওষুধেই গ্যাস্ট্রিকের উপাদান (PPI) আছে। একসাথে দুটি খাওয়ার প্রয়োজন হয় না এবং এতে বাড়তি খরচ হয়।',
          explanationEn:
              '${names.join(" and ")} both provide proton pump inhibitors (acid reducers). Duplicating PPIs is clinically unnecessary and increases out-of-pocket cost.',
          actionBn: 'ডাক্তার বা ফার্মাসিস্টের পরামর্শে অতিরিক্ত গ্যাস্ট্রিকের ওষুধটি বাদ দিন।',
          actionEn: 'Verify with your physician/pharmacist whether the extra PPI is needed.',
        ),
      );
    }

    // 3. Pairwise DDI Matrix Check
    for (var i = 0; i < matchedDrugs.length; i++) {
      for (var j = i + 1; j < matchedDrugs.length; j++) {
        final dA = matchedDrugs[i];
        final dB = matchedDrugs[j];
        for (final rule in _rules) {
          final matchForward = dA.activeIngredients.contains(rule.ingredientA) &&
              dB.activeIngredients.contains(rule.ingredientB);
          final matchReverse = dA.activeIngredients.contains(rule.ingredientB) &&
              dB.activeIngredients.contains(rule.ingredientA);
          if ((matchForward || matchReverse) && seenAlertIds.add(rule.id)) {
            alerts.add(
              DdiAlert(
                id: rule.id,
                severity: rule.severity,
                drugNames: [dA.brandName, dB.brandName],
                isDuplicateIngredient: false,
                titleBn: rule.titleBn,
                titleEn: rule.titleEn,
                explanationBn: rule.explanationBn,
                explanationEn: rule.explanationEn,
                actionBn: rule.actionBn,
                actionEn: rule.actionEn,
              ),
            );
          }
        }
      }
    }

    // 4. Optional Pregnancy Contraindication Check
    if (isPregnant) {
      final risky = matchedDrugs.where((d) => d.pregnancyCaution).toList();
      if (risky.isNotEmpty && seenAlertIds.add('pregnancy_caution')) {
        final names = risky.map((d) => d.brandName).toList();
        alerts.add(
          DdiAlert(
            id: 'pregnancy_caution',
            severity: InteractionSeverity.critical,
            drugNames: names,
            isDuplicateIngredient: false,
            titleBn: 'গর্ভাবস্থায় বিশেষ সতর্কতা!',
            titleEn: 'Pregnancy Contraindication Caution!',
            explanationBn:
                '${names.join(", ")} গর্ভাবস্থায় (বিশেষ করে তৃতীয় ত্রৈমাসিকে) ক্ষতিকর হতে পারে।',
            explanationEn:
                '${names.join(", ")} carry pregnancy cautions and may be unsafe during gestation.',
            actionBn: 'গর্ভবতী অবস্থায় এই ওষুধ খাওয়ার আগে গাইনি ডাক্তারের পরামর্শ নিন।',
            actionEn: 'Consult an OB/GYN before taking any flagged drug during pregnancy.',
          ),
        );
      }
    }

    return alerts;
  }
}

