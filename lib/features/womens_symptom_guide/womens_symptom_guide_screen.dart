import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/seed_data/red_flag_rules.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/tts_stt/voice_service.dart';
import 'package:shuchona/core/tts_stt/voice_waveform_widget.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/mandatory_disclaimer_banner.dart';
import 'package:shuchona/core/widgets/severity_badge.dart';
import 'package:shuchona/core/widgets/shuchona_app_bar.dart';
import 'package:shuchona/features/find_care/find_care_provider.dart';
import 'package:shuchona/features/womens_symptom_guide/symptom_guide_provider.dart';

/// Modules 5 & 6: Women's Health Symptom Guide & Deterministic Tier 1 Red-Flag Gatekeeper.
class WomensSymptomGuideScreen extends ConsumerStatefulWidget {
  const WomensSymptomGuideScreen({super.key});

  @override
  ConsumerState<WomensSymptomGuideScreen> createState() =>
      _WomensSymptomGuideScreenState();
}

class _WomensSymptomGuideScreenState
    extends ConsumerState<WomensSymptomGuideScreen> {
  final _voiceTextController = TextEditingController();
  bool _whyExpanded = true;

  @override
  void dispose() {
    _voiceTextController.dispose();
    super.dispose();
  }

  Future<void> _handleVoiceOrTextCheck(String text) async {
    if (text.trim().isEmpty) return;
    final flag = ref.read(symptomGuideProvider.notifier).evaluateFreeText(text);
    if (flag != null) {
      await _speakRedFlag(flag);
    }
  }

  Future<void> _speakRedFlag(RedFlagMatch flag) async {
    final locale = ref.read(localeProvider);
    await ref
        .read(voiceControllerProvider.notifier)
        .speak(
          locale.isBangla ? flag.spokenAlertBn : flag.spokenAlertEn,
          locale: locale,
          tag: 'red_flag_alert_${flag.ruleId}',
        );
  }

  Future<void> _toggleMic() async {
    final voice = ref.read(voiceControllerProvider);
    final notifier = ref.read(voiceControllerProvider.notifier);
    final locale = ref.read(localeProvider);

    if (voice.isListening) {
      await notifier.stopListening();
      if (_voiceTextController.text.trim().isNotEmpty) {
        await _handleVoiceOrTextCheck(_voiceTextController.text);
      }
      return;
    }

    await notifier.startListening(
      locale: locale,
      onResult: (words, isFinal) {
        _voiceTextController.text = words;
        if (isFinal && words.trim().isNotEmpty) {
          _handleVoiceOrTextCheck(words);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final state = ref.watch(symptomGuideProvider);
    final voice = ref.watch(voiceControllerProvider);
    final s = AppStrings(locale);
    final primary = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;

    final gutter = ((MediaQuery.sizeOf(context).width - 760) / 2).clamp(
      16.0,
      double.infinity,
    );

    return Scaffold(
      appBar: ShuchonaAppBar(title: s.tr('নারী স্বাস্থ্য', 'Women’s health')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 24),
        children: [
          // Header Intro & Voice/Text Instant Tier 1 Screening Bar
          AccessibleCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SeverityBadge(
                            label: s.tr(
                              'ইন্টারনেট ছাড়াও জরুরি লক্ষণের সতর্কতা',
                              'Urgent symptom alerts work offline',
                            ),
                            tone: BadgeTone.emeraldSafe,
                            icon: Icons.verified_user_rounded,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.tr(
                              'আপনার লক্ষণ বলুন বা নিচের বিষয় বেছে নিন',
                              'Speak Your Symptoms or Choose a Topic',
                            ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    TtsListenButton(
                      textToSpeak: s.tr(
                        'আপনার মাসিক, তলপেটে ব্যথা, হরমোন বা স্তনের কোনো সমস্যা থাকলে লজ্জা না করে মাইক্রোফোনে বলুন অথবা নিচের কার্ডে চাপ দিন। জরুরি বিপদ চিহ্ন থাকলে সূচনা সাথে সাথে সতর্ক করবে।',
                        'Share any menstrual, hormonal, PCOS, or breast health concern by speaking into the microphone or tapping a topic card below. SHUCHONA screens red-flag emergencies instantly on-device.',
                      ),
                      compact: true,
                      tag: 'symptom_intro',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (voice.isListening)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        VoiceWaveformWidget(
                          isActive: true,
                          soundLevel: voice.soundLevel,
                          color: AppColors.alertCrimson,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          s.tr(
                            'শুনছি... লক্ষণ বলুন',
                            'Listening... Describe symptoms',
                          ),
                          style: TextStyle(
                            color: AppColors.alertCrimson,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: voice.isListening
                              ? AppColors.alertCrimson
                              : primary,
                        ),
                        onPressed: _toggleMic,
                        child: Icon(
                          voice.isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _voiceTextController,
                        onSubmitted: _handleVoiceOrTextCheck,
                        decoration: InputDecoration(
                          hintText: s.tr(
                            'যেমন: অতিরিক্ত রক্তপাত, শক্ত চাকা, অনিয়মিত মাসিক...',
                            'e.g. heavy bleeding, hard breast lump, irregular period...',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.secondaryEmerald,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () =>
                            _handleVoiceOrTextCheck(_voiceTextController.text),
                        icon: const Icon(Icons.search_rounded, size: 26),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // One-tap Red-Flag Demo Trigger for Judges
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      avatar: const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.alertCrimson,
                      ),
                      label: Text(
                        s.tr(
                          'জরুরি টেস্ট: অতিরিক্ত রক্তপাত',
                          'Test Red-Flag: Heavy Bleeding',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        final sample = s.isBn
                            ? 'আমার অতিরিক্ত রক্তপাত হচ্ছে এবং মাথা ঘুরে যাচ্ছে'
                            : 'Severe heavy bleeding and feeling faint';
                        _voiceTextController.text = sample;
                        _handleVoiceOrTextCheck(sample);
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.alertCrimson,
                      ),
                      label: Text(
                        s.tr(
                          'জরুরি টেস্ট: স্তনে শক্ত চাকা',
                          'Test Red-Flag: Hard Breast Lump',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        final sample = s.isBn
                            ? 'স্তনে শক্ত চাকা ও চামড়া কুঁচকে গেছে'
                            : 'Hard fixed breast lump with skin dimpling';
                        _voiceTextController.text = sample;
                        _handleVoiceOrTextCheck(sample);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TIER 1 RED FLAG URGENT CRIMSON CARD (Takes absolute priority!)
          if (state.redFlagMatch != null) ...[
            _buildRedFlagCard(context, state.redFlagMatch!, s, isDark),
            const SizedBox(height: 16),
            const MandatoryDisclaimerBanner(),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                _voiceTextController.clear();
                ref.read(symptomGuideProvider.notifier).reset();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                s.tr('নতুন করে লক্ষণ যাচাই করুন', 'Start New Symptom Check'),
              ),
            ),
          ] else if (state.selectedTopic == null) ...[
            // Topic Selection Grid
            Text(
              s.tr(
                'বিষয় নির্বাচন করুন (৫টি নারী স্বাস্থ্য গাইড)',
                'Choose a Guided Health Topic',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...WomensSymptomTopics.all.map(
              (topic) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AccessibleCard(
                  onTap: () => ref
                      .read(symptomGuideProvider.notifier)
                      .selectTopic(topic),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            topic.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.tr(topic.titleBn, topic.titleEn),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              s.tr(topic.subtitleBn, topic.subtitleEn),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 28,
                        color: primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const MandatoryDisclaimerBanner(),
          ] else if (!state.showResult) ...[
            // Tier 2 Structured Follow-Up Questions
            _buildFollowUpFlow(context, state, s, primary),
          ] else ...[
            // Tier 2 Grounded Guidance Result + "Why This Guidance?" + Mandatory Disclaimer
            _buildGroundedResult(
              context,
              state.selectedTopic!,
              s,
              primary,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRedFlagCard(
    BuildContext context,
    RedFlagMatch flag,
    AppStrings s,
    bool isDark,
  ) {
    final fullSpeech = s.isBn
        ? '${flag.spokenAlertBn} ${flag.actionStepsBn.join(" ")}'
        : '${flag.spokenAlertEn} ${flag.actionStepsEn.join(" ")}';

    return AccessibleCard(
      backgroundColor: isDark
          ? AppColors.darkAlertBg
          : AppColors.alertCrimsonLight,
      borderColor: AppColors.alertCrimson,
      borderWidth: 2.2,
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
                  color: AppColors.alertCrimson,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SeverityBadge(
                      label: s.tr(
                        'টিয়ার-১ জরুরি সতর্কতা (অবিলম্বে পদক্ষেপ নিন)',
                        'TIER 1 URGENT RED-FLAG ALERT',
                      ),
                      tone: BadgeTone.crimsonAlert,
                      icon: Icons.priority_high_rounded,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.tr(flag.urgentTitleBn, flag.urgentTitleEn),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark
                            ? const Color(0xFFFECACA)
                            : AppColors.alertCrimsonDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.alertCrimson,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.tr(flag.spokenAlertBn, flag.spokenAlertEn),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(flag.actionStepsBn.length, (i) {
            final step = s.isBn ? flag.actionStepsBn[i] : flag.actionStepsEn[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_circle_right_rounded,
                    color: AppColors.alertCrimson,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: TtsListenButton(
              textToSpeak: fullSpeech,
              accentColor: AppColors.alertCrimson,
              tag: 'red_flag_alert_${flag.ruleId}',
              labelOverride: s.tr(
                '🔊 জরুরি সতর্কতা আবার শুনুন',
                '🔊 Replay Urgent Voice Alert',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.alertCrimson,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(58),
                  ),
                  onPressed: () => FindCareNotifier.dialPhoneNumber(
                    flag.recommendedHelpline,
                  ),
                  icon: const Icon(Icons.call_rounded, size: 24),
                  label: Text(
                    flag.recommendedHelpline ==
                            AppConstants.shasthoBatayonHelpline
                        ? s.call16263
                        : s.tr('হেল্পলাইনে কল', 'Call Helpline'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.alertCrimson,
                    side: const BorderSide(
                      color: AppColors.alertCrimson,
                      width: 1.8,
                    ),
                    minimumSize: const Size.fromHeight(58),
                  ),
                  onPressed: () {
                    ref
                        .read(findCareProvider.notifier)
                        .toggleFreeBloodTestFilter(false);
                    context.push('/care?tab=clinics');
                  },
                  icon: const Icon(Icons.local_hospital_rounded, size: 22),
                  label: Text(s.findClinic),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpFlow(
    BuildContext context,
    SymptomGuideState state,
    AppStrings s,
    Color primary,
  ) {
    final topic = state.selectedTopic!;
    final allAnswered = topic.questions.every(
      (q) => state.answers.containsKey(q.id),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () => ref.read(symptomGuideProvider.notifier).reset(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(s.tr('সব বিষয়', 'All Topics')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${topic.emoji} ${s.tr(topic.titleBn, topic.titleEn)}',
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...topic.questions.asMap().entries.map((entry) {
          final idx = entry.key;
          final q = entry.value;
          final selected = state.answers[q.id];
          final qText = s.tr(q.questionBn, q.questionEn);
          final opts = s.isBn ? q.optionsBn : q.optionsEn;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AccessibleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${s.formatDigits((idx + 1).toString())}. $qText',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TtsListenButton(
                        textToSpeak: qText,
                        compact: true,
                        tag: 'sym_q_${q.id}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...opts.asMap().entries.map((optEntry) {
                    final oIdx = optEntry.key;
                    final label = optEntry.value;
                    final isSelected = selected == oIdx;
                    final isRedFlagOption = q.redFlagOptionIndex == oIdx;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            backgroundColor: isSelected
                                ? primary.withValues(alpha: 0.14)
                                : null,
                            side: BorderSide(
                              color: isSelected
                                  ? primary
                                  : (isRedFlagOption
                                        ? AppColors.alertCrimson.withValues(
                                            alpha: 0.45,
                                          )
                                        : Theme.of(
                                            context,
                                          ).colorScheme.outline),
                              width: isSelected ? 2 : 1.2,
                            ),
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            ref
                                .read(symptomGuideProvider.notifier)
                                .answerQuestion(q, oIdx);
                            final updatedFlag = ref
                                .read(symptomGuideProvider)
                                .redFlagMatch;
                            if (updatedFlag != null) {
                              _speakRedFlag(updatedFlag);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected ? primary : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(label)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 6),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(60),
          ),
          onPressed: allAnswered
              ? () =>
                    ref.read(symptomGuideProvider.notifier).completeGuidedFlow()
              : null,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text(
            s.tr(
              'প্রাথমিক স্বাস্থ্য তথ্য দেখুন',
              'View Grounded Health Guidance',
            ),
          ),
        ),
        const SizedBox(height: 14),
        const MandatoryDisclaimerBanner(),
      ],
    );
  }

  Widget _buildGroundedResult(
    BuildContext context,
    SymptomTopic topic,
    AppStrings s,
    Color primary,
    bool isDark,
  ) {
    final title = s.tr(topic.guidanceTitleBn, topic.guidanceTitleEn);
    final patterns = s.tr(topic.possiblePatternsBn, topic.possiblePatternsEn);
    final why = s.tr(topic.whyThisGuidanceBn, topic.whyThisGuidanceEn);
    final steps = s.isBn ? topic.selfCareStepsBn : topic.selfCareStepsEn;

    final fullSpeech =
        '$title। $patterns ${steps.join(" ")} ${s.mandatoryDisclaimer}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccessibleCard(
          padding: const EdgeInsets.all(18),
          borderColor: primary.withValues(alpha: 0.45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(topic.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(patterns, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 14),

              // Transparent "Why This Guidance?" Pill
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _whyExpanded = !_whyExpanded),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkTealBg
                        : AppColors.primaryTealLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primary.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.tr(
                                'কেন এই পরামর্শ? (Why This Guidance?)',
                                'Why This Guidance?',
                              ),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          Icon(
                            _whyExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: primary,
                          ),
                        ],
                      ),
                      if (_whyExpanded) ...[
                        const SizedBox(height: 8),
                        Text(
                          why,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                s.tr('নিরাপদ করণীয়:', 'Safe Next Steps:'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...steps.map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.secondaryEmerald,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: TtsListenButton(
                  textToSpeak: fullSpeech,
                  tag: 'symptom_result_${topic.id.name}',
                  labelOverride: s.tr(
                    '🔊 সম্পূর্ণ পরামর্শ শুনুন',
                    '🔊 Listen to Full Guidance',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Permanently Pinned Mandatory Disclaimer on Every Result
        const MandatoryDisclaimerBanner(),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  ref
                      .read(findCareProvider.notifier)
                      .toggleFreeBloodTestFilter(false);
                  context.push('/care?tab=clinics');
                },
                icon: const Icon(Icons.local_hospital_rounded),
                label: Text(s.findClinic),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(symptomGuideProvider.notifier).reset(),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(s.tr('নতুন পরীক্ষা', 'Check Another')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
