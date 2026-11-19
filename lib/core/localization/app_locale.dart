/// Supported runtime languages for SHUCHONA (সূচনা).
/// Bangla (বাংলা) is the default language.
enum AppLocale {
  bn,
  en;

  bool get isBangla => this == AppLocale.bn;
  bool get isEnglish => this == AppLocale.en;

  String get ttsLanguageCode => isBangla ? 'bn-BD' : 'en-US';
  String get sttLocaleId => isBangla ? 'bn_BD' : 'en_US';
  String get shortLabel => isBangla ? 'বাংলা' : 'EN';
  String get toggleTargetLabel => isBangla ? 'EN' : 'বাংলা';

  AppLocale get toggled => isBangla ? AppLocale.en : AppLocale.bn;
}

/// Bilingual text container ensuring every label, clinical prompt, and voice
/// narration seamlessly switches between Bangla and English at runtime.
class BiText {
  const BiText({required this.bn, required this.en});

  final String bn;
  final String en;

  String of(AppLocale locale) => locale.isBangla ? bn : en;
}

