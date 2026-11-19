import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/voice_service.dart';

/// Accessible audio-first Speaker button (`🔊 শুনুন` / `🔊 Listen`)
/// designed for low-literacy users with >= 56dp touch height or tap target.
class TtsListenButton extends ConsumerWidget {
  const TtsListenButton({
    super.key,
    required this.textToSpeak,
    this.tag,
    this.compact = false,
    this.accentColor,
    this.labelOverride,
  });

  final String textToSpeak;
  final String? tag;
  final bool compact;
  final Color? accentColor;
  final String? labelOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final voiceState = ref.watch(voiceControllerProvider);
    final s = AppStrings(locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveTag = tag ?? textToSpeak.hashCode.toString();
    final isThisPlaying =
        voiceState.isSpeaking && voiceState.speakingTag == effectiveTag;

    final color =
        accentColor ??
        (isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal);

    final rawLabel = isThisPlaying
        ? s.stopListeningAudio
        : (labelOverride ?? s.listen);
    // Avoid double speaker icon since this widget already displays Icons.volume_up_rounded
    final label = rawLabel.replaceFirst(RegExp(r'^🔊\s*'), '').trim();

    if (compact) {
      return Semantics(
        button: true,
        label: label,
        child: Material(
          color: isThisPlaying
              ? color
              : color.withValues(alpha: isDark ? 0.18 : 0.10),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => ref
                .read(voiceControllerProvider.notifier)
                .speak(textToSpeak, locale: locale, tag: effectiveTag),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isThisPlaying
                          ? Icons.stop_circle_rounded
                          : Icons.volume_up_rounded,
                      size: 20,
                      color: isThisPlaying
                          ? (isDark ? AppColors.darkCanvas : Colors.white)
                          : color,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: isThisPlaying
                                  ? (isDark
                                        ? AppColors.darkCanvas
                                        : Colors.white)
                                  : color,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: isThisPlaying
            ? color
            : color.withValues(alpha: isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ref
              .read(voiceControllerProvider.notifier)
              .speak(textToSpeak, locale: locale, tag: effectiveTag),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isThisPlaying
                        ? Icons.stop_circle_rounded
                        : Icons.volume_up_rounded,
                    size: 24,
                    color: isThisPlaying
                        ? (isDark ? AppColors.darkCanvas : Colors.white)
                        : color,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isThisPlaying
                            ? (isDark ? AppColors.darkCanvas : Colors.white)
                            : color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
