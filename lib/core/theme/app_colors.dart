import 'package:flutter/material.dart';

/// Shared color palette for SHUCHONA (সূচনা).
/// Supports crisp Light Clinical Theme and High-Contrast Dark Mode.
abstract final class AppColors {
  // Brand & Clinical Semantics (Light Mode)
  static const Color primaryTeal = Color(0xFF0D6E6E);
  static const Color primaryTealDark = Color(0xFF084C4C);
  static const Color primaryTealLight = Color(0xFFE6F4F4);

  static const Color secondaryEmerald = Color(0xFF10B981);
  static const Color secondaryEmeraldDark = Color(0xFF047857);
  static const Color secondaryEmeraldLight = Color(0xFFECFDF5);

  static const Color alertCrimson = Color(0xFFDC2626);
  static const Color alertCrimsonDark = Color(0xFF991B1B);
  static const Color alertCrimsonLight = Color(0xFFFEF2F2);

  static const Color cautionAmber = Color(0xFFD97706);
  static const Color cautionAmberDark = Color(0xFF92400E);
  static const Color cautionAmberLight = Color(0xFFFFFBEB);

  // Light Mode Surfaces & Neutrals
  static const Color lightCanvas = Color(0xFFF4F8F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFDDE8E5);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF334155);
  static const Color lightTextMuted = Color(0xFF64748B);

  // High-Contrast Dark Mode (Pitch-Slate + White + Electric Blue)
  static const Color darkCanvas = Color(0xFF090D16);
  static const Color darkCard = Color(0xFF111827);
  static const Color darkCardElevated = Color(0xFF1A2438);
  static const Color darkBorder = Color(0xFF2D3B55);
  static const Color darkAccentBlue = Color(0xFF38BDF8);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFE2E8F0);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // Dark Mode Semantic Tints
  static const Color darkAlertBg = Color(0xFF3B0D14);
  static const Color darkCautionBg = Color(0xFF382408);
  static const Color darkEmeraldBg = Color(0xFF092E24);
  static const Color darkTealBg = Color(0xFF0B2A30);

  // Accent Helpers
  static const Color indigoSoft = Color(0xFF4F46E5);
  static const Color roseAccent = Color(0xFFE11D48);
  static const Color skyAccent = Color(0xFF0284C7);
}
