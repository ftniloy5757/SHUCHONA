import 'package:flutter/material.dart';
import 'package:shuchona/core/theme/app_colors.dart';

/// Official SHUCHONA brand mark backed by `assets/branding/shuchona_logo.png`.
class ShuchonaLogo extends StatelessWidget {
  const ShuchonaLogo({
    super.key,
    this.size = 40,
    this.borderRadius,
  });

  final double size;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? (size * 0.24);

    return Semantics(
      image: true,
      label: 'SHUCHONA (সূচনা) Logo',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isDark
                ? AppColors.darkAccentBlue.withValues(alpha: 0.45)
                : const Color(0xFF043E2D).withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          'assets/branding/shuchona_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
