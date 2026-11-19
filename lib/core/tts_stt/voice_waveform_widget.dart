import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shuchona/core/theme/app_colors.dart';

/// Animated live audio waveform bars used during Push-to-Talk Bangla/English STT
/// and active TTS voice guidance.
class VoiceWaveformWidget extends StatefulWidget {
  const VoiceWaveformWidget({
    super.key,
    required this.isActive,
    this.soundLevel = 0.5,
    this.color,
    this.barCount = 9,
    this.height = 36,
  });

  final bool isActive;
  final double soundLevel;
  final Color? color;
  final int barCount;
  final double height;

  @override
  State<VoiceWaveformWidget> createState() => _VoiceWaveformWidgetState();
}

class _VoiceWaveformWidgetState extends State<VoiceWaveformWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VoiceWaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = widget.color ??
        (isDark ? AppColors.darkAccentBlue : AppColors.primaryTeal);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.barCount, (index) {
              final phase =
                  (_controller.value * 2 * math.pi) + (index * 0.65);
              final wave = widget.isActive
                  ? (0.3 + 0.7 * ((math.sin(phase) + 1) / 2)) *
                      (0.45 + 0.55 * widget.soundLevel.clamp(0.15, 1.0))
                  : 0.18;
              final barH = (widget.height * wave).clamp(6.0, widget.height);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 110),
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 4.5,
                height: barH,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: widget.isActive ? 0.95 : 0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

