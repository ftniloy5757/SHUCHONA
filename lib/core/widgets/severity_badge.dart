import 'package:flutter/material.dart';
import 'package:shuchona/core/theme/app_colors.dart';

enum BadgeTone { clinicalTeal, emeraldSafe, amberCaution, crimsonAlert, neutral }

/// High-contrast color-coded severity/status badge for low-literacy visual clarity.
class SeverityBadge extends StatelessWidget {
  const SeverityBadge({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color bg, Color fg) = switch (tone) {
      BadgeTone.clinicalTeal => isDark
          ? (AppColors.darkTealBg, AppColors.darkAccentBlue)
          : (AppColors.primaryTealLight, AppColors.primaryTealDark),
      BadgeTone.emeraldSafe => isDark
          ? (AppColors.darkEmeraldBg, const Color(0xFF6EE7B7))
          : (AppColors.secondaryEmeraldLight, AppColors.secondaryEmeraldDark),
      BadgeTone.amberCaution => isDark
          ? (AppColors.darkCautionBg, const Color(0xFFFCD34D))
          : (AppColors.cautionAmberLight, AppColors.cautionAmberDark),
      BadgeTone.crimsonAlert => isDark
          ? (AppColors.darkAlertBg, const Color(0xFFFCA5A5))
          : (AppColors.alertCrimsonLight, AppColors.alertCrimsonDark),
      BadgeTone.neutral => isDark
          ? (AppColors.darkCardElevated, AppColors.darkTextSecondary)
          : (const Color(0xFFF1F5F9), AppColors.lightTextSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

