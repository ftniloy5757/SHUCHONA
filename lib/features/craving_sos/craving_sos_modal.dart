import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/seed_data/wellness_tips_seed.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/tts_stt/voice_service.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/shuchona_logo.dart';
import 'package:shuchona/features/find_care/find_care_provider.dart';

enum _BreathPhase { inhale, hold, exhale }

/// Module 11: One-Tap Craving & Crisis Support Mode.
/// Calming full-screen modal with:
/// - Interactive 4-4-6 Guided Breathing Animation + spoken Bangla/English audio pacing
/// - 3 step-by-step Grounding & Coping Cards with TTS
/// - Direct one-tap fallback buttons to call live human counselors (`16263` / Kaan Pete Roi)
class CravingSosModal extends ConsumerStatefulWidget {
  const CravingSosModal({super.key});

  @override
  ConsumerState<CravingSosModal> createState() => _CravingSosModalState();
}

class _CravingSosModalState extends ConsumerState<CravingSosModal> {
  Timer? _timer;
  bool _isRunning = false;
  _BreathPhase _phase = _BreathPhase.inhale;
  int _secondsLeft = 4;
  int _completedCycles = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startOrStopBreathing() {
    if (_isRunning) {
      _timer?.cancel();
      ref.read(voiceControllerProvider.notifier).stopSpeaking();
      setState(() => _isRunning = false);
      return;
    }

    setState(() {
      _isRunning = true;
      _phase = _BreathPhase.inhale;
      _secondsLeft = 4;
    });
    _speakPhase(_BreathPhase.inhale);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          switch (_phase) {
            case _BreathPhase.inhale:
              _phase = _BreathPhase.hold;
              _secondsLeft = 4;
              _speakPhase(_BreathPhase.hold);
            case _BreathPhase.hold:
              _phase = _BreathPhase.exhale;
              _secondsLeft = 6;
              _speakPhase(_BreathPhase.exhale);
            case _BreathPhase.exhale:
              _completedCycles++;
              _phase = _BreathPhase.inhale;
              _secondsLeft = 4;
              _speakPhase(_BreathPhase.inhale);
          }
        }
      });
    });
  }

  void _speakPhase(_BreathPhase phase) {
    final locale = ref.read(localeProvider);
    final text = switch (phase) {
      _BreathPhase.inhale => locale.isBangla
          ? 'ধীরে ধীরে নাক দিয়ে ৪ সেকেন্ড শ্বাস নিন'
          : 'Breathe in slowly through your nose for 4 seconds',
      _BreathPhase.hold => locale.isBangla
          ? 'শান্তভাবে ৪ সেকেন্ড শ্বাস ধরে রাখুন'
          : 'Hold your breath gently for 4 seconds',
      _BreathPhase.exhale => locale.isBangla
          ? 'মুখ দিয়ে আস্তে আস্তে ৬ সেকেন্ড শ্বাস ছেড়ে দিন'
          : 'Exhale slowly through your mouth for 6 seconds',
    };
    ref.read(voiceControllerProvider.notifier).speak(
          text,
          locale: locale,
          tag: 'breath_${phase.name}',
        );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final s = AppStrings(locale);

    final (String phaseLabel, Color circleColor, double targetSize) =
        switch (_phase) {
      _BreathPhase.inhale => (
          s.tr('শ্বাস নিন (৪ সেকেন্ড)', 'Breathe In (4s)'),
          AppColors.primaryTeal,
          178.0,
        ),
      _BreathPhase.hold => (
          s.tr('ধরে রাখুন (৪ সেকেন্ড)', 'Hold Gently (4s)'),
          AppColors.secondaryEmerald,
          178.0,
        ),
      _BreathPhase.exhale => (
          s.tr('ধীরে ছাড়ুন (৬ সেকেন্ড)', 'Breathe Out (6s)'),
          AppColors.skyAccent,
          118.0,
        ),
    };

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _timer?.cancel();
          ref.read(voiceControllerProvider.notifier).stopSpeaking();
        }
      },
      child: Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : const Color(0xFFF0F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Row(
          children: [
            const ShuchonaLogo(size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s.tr(
                  'শান্ত হোন — সূচনা পাশে আছে',
                  'Calm Support — You Are Safe',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 28),
          onPressed: () {
            _timer?.cancel();
            ref.read(voiceControllerProvider.notifier).stopSpeaking();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
        children: [
          // 4-4-6 Guided Breathing Interactive Circle Card
          AccessibleCard(
            padding: const EdgeInsets.all(20),
            borderColor: circleColor.withValues(alpha: 0.45),
            child: Column(
              children: [
                Text(
                  s.tr(
                    '৪-৪-৬ শান্ত শ্বাস-প্রশ্বাস অনুশীলন',
                    '4-4-6 Guided Calming Breath',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  s.tr(
                    'বাংলা ভয়েস নির্দেশনাসহ শ্বাস নিন — ২ মিনিটেই অস্থিরতা ও তাড়না কমে যাবে',
                    'With spoken Bangla/English audio pacing to ease cravings & anxiety',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 196,
                  child: Center(
                    child: AnimatedContainer(
                      duration: Duration(
                        seconds: _isRunning
                            ? (_phase == _BreathPhase.exhale ? 6 : 4)
                            : 1,
                      ),
                      curve: Curves.easeInOut,
                      width: _isRunning ? targetSize : 140,
                      height: _isRunning ? targetSize : 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            circleColor.withValues(alpha: 0.92),
                            circleColor.withValues(alpha: 0.35),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: circleColor.withValues(alpha: 0.3),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isRunning
                                  ? s.formatDigits(_secondsLeft.toString())
                                  : '4-4-6',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                _isRunning
                                    ? phaseLabel
                                    : s.tr('শুরু করতে চাপুন', 'Tap Start'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_completedCycles > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    s.tr(
                      'সম্পন্ন চক্র: ${s.formatDigits(_completedCycles.toString())} বার 🌿 দারুণ করছেন!',
                      'Completed cycles: $_completedCycles 🌿 You are doing great!',
                    ),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.secondaryEmerald,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _isRunning
                          ? AppColors.cautionAmber
                          : AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(58),
                    ),
                    onPressed: _startOrStopBreathing,
                    icon: Icon(
                      _isRunning
                          ? Icons.pause_circle_rounded
                          : Icons.play_circle_filled_rounded,
                      size: 26,
                    ),
                    label: Text(
                      _isRunning
                          ? s.tr('শ্বাস অনুশীলন থামান', 'Pause Breathing')
                          : s.tr('বাংলা ভয়েসসহ শ্বাস অনুশীলন শুরু করুন',
                              'Start Guided Voice Breathing'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3 Step-by-Step Grounding & Coping Cards
          Text(
            s.tr('তাৎক্ষণিক ৩টি প্রশান্তি ধাপ', '3 Step-by-Step Grounding Steps'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...WellnessTipsSeed.crisisCopingSteps.map((step) {
            final title = s.tr(step.titleBn, step.titleEn);
            final body = s.tr(step.instructionBn, step.instructionEn);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AccessibleCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(step.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(body, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 10),
                    TtsListenButton(
                      textToSpeak: '$title। $body',
                      compact: true,
                      tag: 'coping_step_${step.stepNumber}',
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),

          // Direct One-Tap Live Human Counselor / National Helplines
          AccessibleCard(
            backgroundColor:
                isDark ? AppColors.darkAlertBg : AppColors.alertCrimsonLight,
            borderColor: AppColors.alertCrimson,
            borderWidth: 1.6,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.tr(
                    'সরাসরি মানুষের সাথে কথা বলুন (সম্পূর্ণ গোপনীয়)',
                    'Speak Directly With a Live Counselor (Confidential)',
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFFFECACA)
                            : AppColors.alertCrimsonDark,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.alertCrimson,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(58),
                  ),
                  onPressed: () => FindCareNotifier.dialPhoneNumber(
                    AppConstants.shasthoBatayonHelpline,
                  ),
                  icon: const Icon(Icons.call_rounded, size: 24),
                  label: Text(
                    s.tr('১৬২৬৩ — জাতীয় স্বাস্থ্য হেল্পলাইন',
                        'Call 16263 — National Health Helpline'),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.alertCrimson,
                    side: const BorderSide(
                        color: AppColors.alertCrimson, width: 1.6),
                    minimumSize: const Size.fromHeight(58),
                  ),
                  onPressed: () => FindCareNotifier.dialPhoneNumber(
                    AppConstants.kaanPeteRoiHelpline,
                  ),
                  icon: const Icon(Icons.support_agent_rounded, size: 24),
                  label: Text(
                    s.tr('কান পেতে রই — মানসিক সহায়তা (01779-554391)',
                        'Call Kaan Pete Roi Counselor (01779-554391)'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

