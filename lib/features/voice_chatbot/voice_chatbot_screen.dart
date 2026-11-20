import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuchona/core/constants/app_constants.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';
import 'package:shuchona/core/tts_stt/voice_service.dart';
import 'package:shuchona/core/tts_stt/voice_waveform_widget.dart';
import 'package:shuchona/core/widgets/accessible_card.dart';
import 'package:shuchona/core/widgets/mandatory_disclaimer_banner.dart';
import 'package:shuchona/core/widgets/severity_badge.dart';
import 'package:shuchona/core/widgets/shuchona_app_bar.dart';
import 'package:shuchona/core/widgets/shuchona_logo.dart';
import 'package:shuchona/features/find_care/find_care_provider.dart';
import 'package:shuchona/features/voice_chatbot/chatbot_provider.dart';

/// Modules 2, 3 & 4: Multilingual Safety-Aligned AI Chatbot (Voice STT + TTS).
/// - Push-to-Talk Bangla/English STT with animated waveform indicator
/// - Structured assistant cards with prominent `🔊 Read Aloud` button
/// - Tier 1 Deterministic Red-Flag interception BEFORE any LLM call
class VoiceChatbotScreen extends ConsumerStatefulWidget {
  const VoiceChatbotScreen({super.key});

  @override
  ConsumerState<VoiceChatbotScreen> createState() => _VoiceChatbotScreenState();
}

class _VoiceChatbotScreenState extends ConsumerState<VoiceChatbotScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitText(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    final reply = await ref.read(chatbotProvider.notifier).sendMessage(text);
    _scrollToBottom();

    // Auto-speak urgent red-flag alert immediately for low-literacy safety!
    final locale = ref.read(localeProvider);
    if (reply.redFlagMatch != null) {
      await ref
          .read(voiceControllerProvider.notifier)
          .speak(
            locale.isBangla
                ? reply.redFlagMatch!.spokenAlertBn
                : reply.redFlagMatch!.spokenAlertEn,
            locale: locale,
            tag: reply.id,
          );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 180,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleVoiceListening() async {
    final voice = ref.read(voiceControllerProvider);
    final notifier = ref.read(voiceControllerProvider.notifier);
    final locale = ref.read(localeProvider);

    if (voice.isListening) {
      await notifier.stopListening();
      if (_controller.text.trim().isNotEmpty) {
        await _submitText(_controller.text);
      }
      return;
    }

    await notifier.startListening(
      locale: locale,
      onResult: (words, isFinal) {
        _controller.text = words;
        if (isFinal && words.trim().isNotEmpty) {
          _submitText(words);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(highContrastDarkProvider);
    final chat = ref.watch(chatbotProvider);
    final voice = ref.watch(voiceControllerProvider);
    final s = AppStrings(locale);
    final primary = isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal;

    final quickPrompts = s.isBn
        ? [
            'আমার ২ মাস ধরে মাসিক অনিয়মিত',
            'রক্তশূন্যতা ও দুর্বলতা দূর করতে কী খাব?',
            'জর্দা ছাড়ার পর মন খুব অস্থির লাগছে',
            'অতিরিক্ত রক্তপাত হচ্ছে ও মাথা ঘুরে যাচ্ছে',
          ]
        : [
            'My periods have been irregular for 2 months',
            'What local foods help anemia and weakness?',
            'Feeling stressed trying to quit betel nut',
            'Having severe heavy bleeding and fainting',
          ];

    return Scaffold(
      appBar: ShuchonaAppBar(
        title: s.tr('সূচনাকে বলুন', 'Talk to Shuchona'),
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Quick Starter Voice Phrases (Helpful for low-literacy & live stage demos)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: quickPrompts
                    .map(
                      (prompt) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: Icon(
                            Icons.record_voice_over_rounded,
                            size: 16,
                            color: primary,
                          ),
                          label: Text(prompt),
                          onPressed: () => _submitText(prompt),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // Chat Stream
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              itemCount: chat.messages.length + (chat.isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= chat.messages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AccessibleCard(
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.tr(
                                'সূচনা উত্তর প্রস্তুত করছে...',
                                'SHUCHONA is preparing safe guidance...',
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final msg = chat.messages[index];
                if (msg.isUser) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12, left: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? AppColors.darkCanvas : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }

                // Assistant Message Card (Crimson Urgent Card if Red Flag, else Clinical Card)
                final isRedFlag = msg.redFlagMatch != null;
                final displayText = msg.localizedText(locale);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14, right: 16),
                  child: AccessibleCard(
                    backgroundColor: isRedFlag
                        ? (isDark
                              ? AppColors.darkAlertBg
                              : AppColors.alertCrimsonLight)
                        : null,
                    borderColor: isRedFlag ? AppColors.alertCrimson : null,
                    borderWidth: isRedFlag ? 1.8 : 1.0,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const ShuchonaLogo(size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SeverityBadge(
                                label: s.tr(
                                  msg.sourceBadgeBn ?? 'সূচনা গাইড',
                                  msg.sourceBadgeEn ?? 'SHUCHONA Guidance',
                                ),
                                tone: isRedFlag
                                    ? BadgeTone.crimsonAlert
                                    : BadgeTone.clinicalTeal,
                                icon: isRedFlag
                                    ? Icons.warning_amber_rounded
                                    : Icons.verified_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          displayText,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: isRedFlag
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TtsListenButton(
                              textToSpeak: displayText,
                              tag: msg.id,
                              compact: true,
                              accentColor: isRedFlag
                                  ? AppColors.alertCrimson
                                  : primary,
                              labelOverride: s.tr(
                                'পড়ে শোনান',
                                'Read Aloud',
                              ),
                            ),
                            if (isRedFlag) ...[
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.alertCrimson,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(56, 44),
                                ),
                                onPressed: () =>
                                    FindCareNotifier.dialPhoneNumber(
                                      msg.redFlagMatch?.recommendedHelpline ??
                                          AppConstants.shasthoBatayonHelpline,
                                    ),
                                icon: const Icon(Icons.call_rounded, size: 18),
                                label: Text(s.call16263),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.alertCrimson,
                                  side: const BorderSide(
                                    color: AppColors.alertCrimson,
                                  ),
                                  minimumSize: const Size(56, 44),
                                ),
                                onPressed: () {
                                  ref
                                      .read(findCareProvider.notifier)
                                      .toggleFreeBloodTestFilter(false);
                                  context.push('/care?tab=clinics');
                                },
                                icon: const Icon(
                                  Icons.local_hospital_rounded,
                                  size: 18,
                                ),
                                label: Text(s.findClinic),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Pinned Compact Disclaimer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: MandatoryDisclaimerBanner(showListenButton: false),
          ),

          // Voice Waveform + Push-to-Talk Bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (voice.isListening) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        VoiceWaveformWidget(
                          isActive: true,
                          soundLevel: voice.soundLevel,
                          color: AppColors.alertCrimson,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            s.tr('শুনছি... কথা বলুন', 'Listening... Speak now'),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColors.alertCrimson,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ] else if (voice.statusMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        voice.statusMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.cautionAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      // Big 56x56 Push-to-Talk Mic Button
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Tooltip(
                          message: voice.isListening
                              ? s.tr('কথা বলা থামান', 'Stop recording')
                              : s.tr('কথা বলুন', 'Speak'),
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: voice.isListening
                                  ? AppColors.alertCrimson
                                  : primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _toggleVoiceListening,
                            child: Icon(
                              voice.isListening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _submitText,
                          decoration: InputDecoration(
                            hintText: s.tr(
                              'প্রশ্ন লিখুন',
                              'Type your question',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: IconButton.filled(
                          tooltip: s.tr('পাঠান', 'Send'),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.secondaryEmeraldDark,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _submitText(_controller.text),
                          icon: const Icon(Icons.send_rounded, size: 24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
