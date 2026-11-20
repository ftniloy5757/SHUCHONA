import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/offline_sync/firebase_bootstrap_service.dart';
import 'package:shuchona/core/offline_sync/notification_service.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/tts_stt/voice_service.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/shuchona_logo.dart';
import 'package:shuchona/features/blood_alert/blood_alert_provider.dart';

/// Module 1: Authentication (Phone OTP / Email / Instant Offline Demo Mode)
/// + Mandatory Audio-Visual Informed Data Consent Screen before saving any data.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _usePhoneOtp = true;
  bool _otpSent = false;
  bool _isBusy = false;
  bool _autoPlayedConsent = false;
  bool _consentChecked = false;

  final _phoneController = TextEditingController(text: '+880 1712-345678');
  final _otpController = TextEditingController(text: '123456');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneSignIn() async {
    if (!_otpSent) {
      setState(() => _otpSent = true);
      return;
    }
    setState(() => _isBusy = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    await ref
        .read(userSessionProvider.notifier)
        .authenticate(
          identifier: _phoneController.text.trim().isEmpty
              ? '+880 1712-345678'
              : _phoneController.text.trim(),
          isDemoMode: !DemoFallbackService.instance.isFirebaseConnected,
        );
    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _handleEmailSignIn() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    if (email.isEmpty || pass.length < 4) {
      final s = AppStrings(ref.read(localeProvider));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.tr(
              'অনুগ্রহ করে সঠিক ইমেইল ও কমপক্ষে ৪ অক্ষরের পাসওয়ার্ড দিন।',
              'Please enter a valid email and a password of at least 4 characters.',
            ),
          ),
        ),
      );
      return;
    }
    setState(() => _isBusy = true);
    final res = await DemoFallbackService.instance.signInEmailOrDemo(
      email: email,
      password: pass,
    );
    await ref
        .read(userSessionProvider.notifier)
        .authenticate(identifier: email, isDemoMode: res.isLocalFallback);
    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _handleInstantDemoMode() async {
    setState(() => _isBusy = true);
    await ref
        .read(userSessionProvider.notifier)
        .authenticate(identifier: 'SHG Demo Member (Savar)', isDemoMode: true);
    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _acceptConsentAndEnter() async {
    await ref.read(voiceControllerProvider.notifier).stopSpeaking();
    await ref.read(userSessionProvider.notifier).acceptInformedConsent();
    // Request Android 13+ notification permission right after consent so
    // medication voice alarms and emergency Blood SOS alerts work immediately.
    await NotificationService.instance.requestPermissions();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final session = ref.watch(userSessionProvider);
    final s = AppStrings(locale);

    final showingConsent =
        session.isAuthenticated && !session.hasGivenInformedConsent;

    final consentSpeechText = s.tr(
      'সূচনায় স্বাগতম। আপনার ব্যক্তিগত তথ্য আমাদের কাছে সম্পূর্ণ নিরাপদ। আপনার কোনো স্বাস্থ্য তথ্য, অভ্যাস বা লিডারবোর্ডের নাম কখনো অন্য কাউকে দেখানো হয় না। সব পরিচয় আপনার ফোনেই গোপন রাখা হয় এবং এনজিও বিশ্লেষণে কোনো ব্যক্তিগত পরিচয় পাঠানো হয় না। সূচনা শুধুমাত্র প্রাথমিক স্বাস্থ্য তথ্য দেয়, কোনো ডাক্তারি চিকিৎসা নয়। আপনি রাজি থাকলে নিচের সম্মতি বাটনে চাপ দিন।',
      'Welcome to SHUCHONA. Your health data stays private and protected. Your real name is never shown on the Habit Leaderboard, and all personal identifiers are stripped on your phone before anonymous community analytics. SHUCHONA provides educational AI guidance only, not medical diagnoses. Tap I Agree and Continue if you consent.',
    );

    if (showingConsent && !_autoPlayedConsent) {
      _autoPlayedConsent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(voiceControllerProvider.notifier)
              .speak(consentSpeechText, locale: locale, tag: 'consent_audio');
        }
      });
    }

    final primary = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const ShuchonaLogo(size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                s.tr('সূচনা', 'SHUCHONA'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
            icon: const Icon(Icons.translate_rounded, size: 18),
            label: Text(
              s.isBn ? 'English' : 'বাংলা',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: s.tr('পর্দার রং বদলান', 'Change screen contrast'),
            onPressed: () =>
                ref.read(highContrastDarkProvider.notifier).toggle(),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.contrast_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ((MediaQuery.sizeOf(context).width - 560) / 2).clamp(
              16.0,
              double.infinity,
            ),
            vertical: 20,
          ),
          child: showingConsent
              ? _buildConsentStep(
                  context,
                  s: s,
                  primary: primary,
                  isDark: isDark,
                  consentSpeechText: consentSpeechText,
                )
              : _buildAuthStep(context, s: s, primary: primary, isDark: isDark),
        ),
      ),
    );
  }

  Widget _buildAuthStep(
    BuildContext context, {
    required AppStrings s,
    required Color primary,
    required bool isDark,
  }) {
    final introSpeech = s.tr(
      'সূচনা — বাংলাদেশের গ্রামীণ নারী ও যুব সমাজের জন্য অফলাইন বাংলা ভয়েস ও প্রেসক্রিপশন স্বাস্থ্য সাথী। শুরু করতে ফোন নম্বর দিন অথবা নিচের অফলাইন ডেমো মোড বাটনে চাপ দিন।',
      'SHUCHONA — Offline-first Bangla voice and vision AI healthcare companion for rural women’s self-help groups and youth in Bangladesh. Sign in with phone or email, or tap Continue in Offline Demo Mode.',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Brand Header
        AccessibleCard(
          backgroundColor: isDark
              ? AppColors.darkTealBg
              : AppColors.primaryTealLight,
          borderColor: primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShuchonaLogo(size: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.tr('সূচনা (SHUCHONA)', 'SHUCHONA (সূচনা)'),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.tr(
                            'কথা বলে ও ছবি তুলে নিরাপদ স্বাস্থ্য সহায়তা',
                            'Health information by voice and photo',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TtsListenButton(
                textToSpeak: introSpeech,
                tag: 'onboarding_welcome',
                labelOverride: s.tr(
                  '🔊 সূচনা সম্পর্কে শুনুন',
                  '🔊 Listen to Welcome',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Instant Offline Demo CTA (Prominent for Judges & First-Time Users)
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondaryEmeraldDark,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(62),
          ),
          onPressed: _isBusy ? null : _handleInstantDemoMode,
          icon: const Icon(Icons.flash_on_rounded, size: 26),
          label: Text(
            s.tr(
              'অফলাইন ডেমো মোডে সরাসরি শুরু করুন',
              'Continue in offline demo mode',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 18),

        // Auth Card: Phone OTP or Email
        AccessibleCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      selected: _usePhoneOtp,
                      label: Center(
                        child: Text(
                          s.tr('মোবাইল', 'Phone'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      onSelected: (_) => setState(() => _usePhoneOtp = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      selected: !_usePhoneOtp,
                      label: Center(
                        child: Text(
                          s.tr('ইমেইল', 'Email'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      onSelected: (_) => setState(() => _usePhoneOtp = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_usePhoneOtp) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: s.tr(
                      'মোবাইল নম্বর (বাংলাদেশ)',
                      'Phone Number (Bangladesh)',
                    ),
                    hintText: s.tr('যেমন 01712345678', 'Example 01712345678'),
                    prefixIcon: const Icon(Icons.phone_android_rounded),
                  ),
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: s.tr(
                        '৬-অঙ্কের OTP কোড (ডেমো: 123456)',
                        '6-Digit OTP Code (Demo: 123456)',
                      ),
                      prefixIcon: const Icon(Icons.lock_clock_rounded),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isBusy ? null : _handlePhoneSignIn,
                  icon: Icon(
                    _otpSent ? Icons.verified_user_rounded : Icons.sms_rounded,
                  ),
                  label: Text(
                    _otpSent
                        ? s.tr('কোড দিয়ে এগিয়ে যান', 'Verify OTP & Continue')
                        : s.tr('ফোনে কোড পাঠান', 'Send OTP Code'),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: s.tr('ইমেইল ঠিকানা', 'Email Address'),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: s.tr('পাসওয়ার্ড', 'Password'),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isBusy ? null : _handleEmailSignIn,
                  icon: const Icon(Icons.login_rounded),
                  label: Text(s.tr('সাইন ইন / নিবন্ধন', 'Sign In / Sign Up')),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Upazila Selector
        AccessibleCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.tr(
                  'আপনার উপজেলা নির্বাচন করুন',
                  'Select Your Upazila / District',
                ),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: ref.watch(userSessionProvider).upazila,
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
                onChanged: (val) {
                  if (val != null) {
                    ref.read(userSessionProvider.notifier).updateUpazila(val);
                    ref
                        .read(bloodNetworkProvider.notifier)
                        .updateDonorProfile(upazila: val);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsentStep(
    BuildContext context, {
    required AppStrings s,
    required Color primary,
    required bool isDark,
    required String consentSpeechText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccessibleCard(
          backgroundColor: isDark
              ? AppColors.darkEmeraldBg
              : AppColors.secondaryEmeraldLight,
          borderColor: AppColors.secondaryEmerald.withValues(alpha: 0.5),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShuchonaLogo(size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.tr(
                        'তথ্য গোপনীয়তা ও অবহিত সম্মতি',
                        'Informed Data Privacy Consent',
                      ),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                s.tr(
                  'কোনো স্বাস্থ্য তথ্য সংরক্ষণের আগে অনুগ্রহ করে নিচের শর্তগুলো শুনুন বা পড়ুন:',
                  'Before saving any profile or health data, please listen to or read how SHUCHONA protects your privacy:',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: TtsListenButton(
                  textToSpeak: consentSpeechText,
                  tag: 'consent_audio',
                  accentColor: AppColors.secondaryEmeraldDark,
                  labelOverride: s.tr(
                    '🔊 সম্মতিপত্র বাংলায় শুনুন',
                    '🔊 Listen to Consent',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4 Clear Privacy Pillars
        _ConsentBulletCard(
          icon: Icons.lock_person_rounded,
          title: s.tr('ব্যক্তিগত পরিচয় সম্পূর্ণ গোপন', '100% Private Identity'),
          body: s.tr(
            'অভ্যাস লিডারবোর্ডে আপনার আসল নাম নয় — শুধু ফুল/প্রকৃতির ছদ্মনাম দেখাবে। আপনার কোনো সংবেদনশীল অভ্যাস অন্য কেউ দেখবে না।',
            'Your real name never appears on the Habit Leaderboard — only your chosen floral/nature pseudonym. Private habits stay strictly private.',
          ),
        ),
        const SizedBox(height: 10),
        _ConsentBulletCard(
          icon: Icons.no_accounts_rounded,
          title: s.tr(
            'ডিভাইসেই পরিচয় মুছে ফেলা হয় (Zero PII)',
            'Zero-PII On-Device Stripping',
          ),
          body: s.tr(
            'জনস্বাস্থ্য বা এনজিও ড্যাশবোর্ডে শুধু সমষ্টিগত (নামহীন) পরিসংখ্যান যায় — কোনো ফোন নম্বর বা ব্যক্তিগত পরিচয় পাঠানো হয় না।',
            'All personal identifiers are stripped on-device before contributing anonymous regional statistics to NGO/public health analytics.',
          ),
        ),
        const SizedBox(height: 10),
        _ConsentBulletCard(
          icon: Icons.medical_information_rounded,
          title: s.tr(
            'চিকিৎসকের বিকল্প নয়',
            'Educational Guidance — Not Diagnosis',
          ),
          body: s.mandatoryDisclaimer,
        ),
        const SizedBox(height: 16),

        // Explicit Checkbox + Big CTA
        AccessibleCard(
          onTap: () => setState(() => _consentChecked = !_consentChecked),
          borderColor: _consentChecked ? primary : null,
          borderWidth: _consentChecked ? 2 : 1,
          child: Row(
            children: [
              Transform.scale(
                scale: 1.25,
                child: Checkbox(
                  value: _consentChecked,
                  onChanged: (v) =>
                      setState(() => _consentChecked = v ?? false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.tr(
                    'আমি সূচনার গোপনীয়তা নীতি ও স্বাস্থ্য সতর্কতা বুঝেছি এবং সম্মতি দিচ্ছি।',
                    'I understand how SHUCHONA protects my anonymized health data and I agree to continue.',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(62),
          ),
          onPressed: _consentChecked ? _acceptConsentAndEnter : null,
          icon: const Icon(Icons.check_circle_rounded, size: 26),
          label: Text(s.tr('আমি সম্মত ও এগিয়ে যান', 'I Agree & Continue')),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            ref.read(voiceControllerProvider.notifier).stopSpeaking();
            setState(() {
              _autoPlayedConsent = false;
              _consentChecked = false;
              _otpSent = false;
            });
            ref.read(userSessionProvider.notifier).signOutToOnboarding();
          },
          child: Text(s.tr('পিছনে ফিরে যান', 'Go Back')),
        ),
      ],
    );
  }
}

class _ConsentBulletCard extends StatelessWidget {
  const _ConsentBulletCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;

    return AccessibleCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
