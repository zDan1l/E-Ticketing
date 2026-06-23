import 'package:flutter/material.dart';

/// Design tokens — HelpDesk Insight
/// Sourced from style-guide.html tailwind.config.
///
/// Rules enforced:
///   • Solid colors only — no gradients, no withOpacity blending.
///   • Every value maps 1-to-1 to a named token in the style guide.
///   • Removed: all LinearGradient constants (gradients are not part of the
///     solid-color design system), glassmorphism helpers, and card-glow colors.
///   • Kept:  shimmerGradient — it is a loading-skeleton utility, not a
///     decorative gradient, so it stays for practical use.
class AppColors {
  AppColors._();

  // ── PRIMARY ────────────────────────────────────────────────────────────────
  static const Color primary              = Color(0xFF3D31A3); // #3d31a3
  static const Color onPrimary            = Color(0xFFFFFFFF);
  static const Color primaryContainer     = Color(0xFF554BBC); // #554bbc
  static const Color onPrimaryContainer   = Color(0xFFD4CFFF); // #d4cfff
  static const Color primaryFixed         = Color(0xFFE3DFFF); // #e3dfff
  static const Color onPrimaryFixed       = Color(0xFF140067); // #140067
  static const Color primaryFixedDim      = Color(0xFFC5C0FF); // #c5c0ff
  static const Color onPrimaryFixedVariant= Color(0xFF3F34A6); // #3f34a6

  // ── SECONDARY ──────────────────────────────────────────────────────────────
  static const Color secondary              = Color(0xFF875203); // #875203
  static const Color onSecondary            = Color(0xFFFFFFFF);
  static const Color secondaryContainer     = Color(0xFFFCB564); // #fcb564
  static const Color onSecondaryContainer   = Color(0xFF754600); // #754600
  static const Color secondaryFixed         = Color(0xFFFFDDBB); // #ffddbb
  static const Color onSecondaryFixed       = Color(0xFF2B1700); // #2b1700
  static const Color secondaryFixedDim      = Color(0xFFFFB868); // #ffb868
  static const Color onSecondaryFixedVariant= Color(0xFF673D00); // #673d00

  // ── TERTIARY ───────────────────────────────────────────────────────────────
  static const Color tertiary              = Color(0xFF213F8E); // #213f8e
  static const Color onTertiary            = Color(0xFFFFFFFF);
  static const Color tertiaryContainer     = Color(0xFF3C57A7); // #3c57a7
  static const Color onTertiaryContainer   = Color(0xFFC8D3FF); // #c8d3ff
  static const Color tertiaryFixed         = Color(0xFFDBE1FF); // #dbe1ff
  static const Color onTertiaryFixed       = Color(0xFF00174D); // #00174d
  static const Color tertiaryFixedDim      = Color(0xFFB5C4FF); // #b5c4ff
  static const Color onTertiaryFixedVariant= Color(0xFF244191); // #244191

  // ── ERROR ──────────────────────────────────────────────────────────────────
  static const Color error            = Color(0xFFBA1A1A); // #ba1a1a
  static const Color onError          = Color(0xFFFFFFFF);
  static const Color errorContainer   = Color(0xFFFFDAD6); // #ffdad6
  static const Color onErrorContainer = Color(0xFF93000A); // #93000a

  // ── SURFACE & BACKGROUND ───────────────────────────────────────────────────
  static const Color background       = Color(0xFFFDF8F8); // #fdf8f8
  static const Color onBackground     = Color(0xFF1C1B1B); // #1c1b1b
  static const Color surface          = Color(0xFFFDF8F8); // #fdf8f8  (surface-bright)
  static const Color onSurface        = Color(0xFF1C1B1B); // #1c1b1b
  static const Color surfaceVariant   = Color(0xFFE6E1E1); // #e6e1e1
  static const Color onSurfaceVariant = Color(0xFF474553); // #474553
  static const Color surfaceTint      = Color(0xFF584EBF); // #584ebf

  // Surface container levels (light)
  static const Color surfaceContainerLowest  = Color(0xFFFFFFFF); // #ffffff
  static const Color surfaceContainerLow     = Color(0xFFF7F2F2); // #f7f2f2
  static const Color surfaceContainer        = Color(0xFFF1EDEC); // #f1edec
  static const Color surfaceContainerHigh    = Color(0xFFECE7E7); // #ece7e7
  static const Color surfaceContainerHighest = Color(0xFFE6E1E1); // #e6e1e1
  static const Color surfaceDim              = Color(0xFFDDD9D8); // #ddd9d8
  static const Color surfaceBright           = Color(0xFFFDF8F8); // #fdf8f8

  // ── OUTLINE ────────────────────────────────────────────────────────────────
  static const Color outline        = Color(0xFF787584); // #787584
  static const Color outlineVariant = Color(0xFFC8C4D5); // #c8c4d5

  // ── INVERSE ────────────────────────────────────────────────────────────────
  static const Color inverseSurface   = Color(0xFF313030); // #313030
  static const Color inverseOnSurface = Color(0xFFF4F0EF); // #f4f0ef
  static const Color inversePrimary   = Color(0xFFC5C0FF); // #c5c0ff

  // ── CANVAS ─────────────────────────────────────────────────────────────────
  static const Color canvas = Color(0xFFF6F3F2); // #f6f3f2

  // ── ACCENT COLORS ──────────────────────────────────────────────────────────
  static const Color successAccent = Color(0xFF89E18D); // #89e18d
  static const Color warningAccent = Color(0xFFFFB867); // #ffb867

  // ── TICKET PRIORITY ────────────────────────────────────────────────────────
  static const Color priorityLow      = Color(0xFF89E18D); // success-accent
  static const Color priorityMedium   = Color(0xFFFFB867); // warning-accent
  static const Color priorityHigh     = Color(0xFFFFB868); // secondary-fixed-dim
  static const Color priorityCritical = Color(0xFFBA1A1A); // error

  // ── TICKET STATUS ──────────────────────────────────────────────────────────
  static const Color statusOpen       = Color(0xFF554BBC); // primary-container
  static const Color statusInProgress = Color(0xFF875203); // secondary
  static const Color statusResolved   = Color(0xFF89E18D); // success-accent
  static const Color statusClosed     = Color(0xFF9E9E9E); // neutral grey
  static const Color statusReopened   = Color(0xFFFFB867); // warning-accent

  // ── SHIMMER (loading skeleton utility — not a decorative gradient) ─────────
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
    colors: [
      Color(0xFFE6E1E1), // surface-container-highest
      Color(0xFFF7F2F2), // surface-container-low
      Color(0xFFE6E1E1),
    ],
    stops: [0.0, 0.5, 1.0],
    tileMode: TileMode.clamp,
  );

  // ── ALIASES (convenience shortcuts used across the app) ────────────────────
  static const Color white          = Color(0xFFFFFFFF);
  static const Color success        = successAccent;
  static const Color border         = outlineVariant;
  static const Color disabled       = outline;
  static const Color textPrimary    = onSurface;
  static const Color textSecondary  = onSurfaceVariant;
  static const Color textTertiary   = outline;
  static const Color divider        = outlineVariant;
  static const Color info           = tertiary;
  static const Color surfaceBackground = canvas;
}