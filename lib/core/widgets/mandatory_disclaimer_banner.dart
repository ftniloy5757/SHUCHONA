import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/localization/app_strings.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/theme/app_colors.dart';
import 'package:shuchona/core/tts_stt/tts_listen_button.dart';

/// Pinned mandatory clinical safety disclaimer displayed on every AI symptom
/// and prescription guidance result in Bangla and English.
class MandatoryDisclaimerBanner extends ConsumerWidget {
  const MandatoryDisclaimerBanner({super.key, this.showListenButton = true});

  final bool showListenButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final s = AppStrings(locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCautionBg : AppColors.cautionAmberLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cautionAmber.withValues(alpha: isDark ? 0.7 : 0.5),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.cautionAmber,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.mandatoryDisclaimer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFFDE68A)
                            : AppColors.cautionAmberDark,
                      ),
                ),
                if (showListenButton) ...[
                  const SizedBox(height: 8),
                  TtsListenButton(
                    textToSpeak: s.mandatoryDisclaimer,
                    compact: true,
                    accentColor: AppColors.cautionAmber,
                    tag: 'mandatory_disclaimer',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

