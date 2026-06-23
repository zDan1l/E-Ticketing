import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — HelpDesk Insight
//
// Sourced from style-guide.html.  Rules enforced throughout:
//   • No shadows, no gradients — every surface is a single flat solid color.
//   • No withOpacity() — all alpha values are baked into explicit hex literals.
//   • All color references go through AppColors constants.
//   • Border radii follow the token scale:
//       default=16  large=32  xlarge=48  full=9999
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  const AppTheme();

  // ── SPACING TOKENS ──────────────────────────────────────────────────────────
  static const double stackGap         = 16.0; // 1rem
  static const double containerPadding = 24.0; // 1.5rem
  static const double cardPadding      = 20.0; // 1.25rem
  static const double elementGap       =  8.0; // 0.5rem

  // ── BORDER RADIUS TOKENS ────────────────────────────────────────────────────
  static const double radiusDefault =   16.0; // 1rem
  static const double radiusLarge   =   32.0; // 2rem
  static const double radiusXLarge  =   48.0; // 3rem
  static const double radiusFull    = 9999.0;

  // ── TYPOGRAPHY ──────────────────────────────────────────────────────────────
  // All roles use Plus Jakarta Sans — the single typeface in style-guide.html.

  TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64, // -0.02em × 32
    height: 40 / 32,
  );

  TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.24, // -0.01em × 24
    height: 32 / 24,
  );

  TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
  );

  TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
  );

  // label-caps — 12 / bold / +0.05em — used for ALL badge, nav, and chip labels
  TextStyle get labelCaps => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.60, // 0.05em × 12
    height: 16 / 12,
  );

  // ── LIGHT THEME ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const t = AppTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ── COLOR SCHEME ────────────────────────────────────────────────────────
      colorScheme: const ColorScheme(
        brightness: Brightness.light,

        primary:              AppColors.primary,
        onPrimary:            AppColors.onPrimary,
        primaryContainer:     AppColors.primaryContainer,
        onPrimaryContainer:   AppColors.onPrimaryContainer,

        secondary:              AppColors.secondary,
        onSecondary:            AppColors.onSecondary,
        secondaryContainer:     AppColors.secondaryContainer,
        onSecondaryContainer:   AppColors.onSecondaryContainer,

        tertiary:               AppColors.tertiary,
        onTertiary:             AppColors.onTertiary,
        tertiaryContainer:      AppColors.tertiaryContainer,
        onTertiaryContainer:    AppColors.onTertiaryContainer,

        error:              AppColors.error,
        onError:            AppColors.onError,
        errorContainer:     AppColors.errorContainer,
        onErrorContainer:   AppColors.onErrorContainer,

        surface:            AppColors.surface,
        onSurface:          AppColors.onSurface,
        surfaceVariant:     AppColors.surfaceVariant,
        onSurfaceVariant:   AppColors.onSurfaceVariant,

        outline:            AppColors.outline,
        outlineVariant:     AppColors.outlineVariant,

        shadow:             Colors.black,
        scrim:              Colors.black,

        inverseSurface:     AppColors.inverseSurface,
        onInverseSurface:   AppColors.inverseOnSurface,
        inversePrimary:     AppColors.inversePrimary,
      ),

      scaffoldBackgroundColor: AppColors.canvas,
      primaryColor: AppColors.primary,

      // ── TEXT THEME ──────────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge:   t.displayLarge.copyWith(color: AppColors.primary),
        displayMedium:  t.headlineMedium.copyWith(color: AppColors.onSurface),
        displaySmall:   t.headlineMedium.copyWith(color: AppColors.onSurface),
        headlineLarge:  t.headlineMedium.copyWith(color: AppColors.onSurface),
        headlineMedium: t.headlineMedium.copyWith(color: AppColors.onSurface),
        headlineSmall:  t.headlineSmall.copyWith(color: AppColors.onSurface),
        titleLarge:     t.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface),
        titleMedium:    t.bodyLarge.copyWith(color: AppColors.onSurface),
        titleSmall:     t.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface),
        bodyLarge:      t.bodyLarge.copyWith(color: AppColors.onSurface),
        bodyMedium:     t.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        bodySmall:      t.bodyMedium.copyWith(fontSize: 12, color: AppColors.onSurfaceVariant),
        labelLarge:     t.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
        labelMedium:    t.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
        labelSmall:     t.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
      ),

      // ── APP BAR ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        titleSpacing: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          height: 28 / 20,
        ),
      ),

      // ── CARD ────────────────────────────────────────────────────────────────
      // White fill (#ffffff = surfaceContainerLowest), solid outline-variant
      // border (1 px), radius-default (16).  Zero elevation, zero shadow.
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          side: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── ELEVATED BUTTON (primary pill) ──────────────────────────────────────
      // Solid primary fill, full-radius pill, zero elevation / zero shadow.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 24 / 15,
          ),
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),

      // ── OUTLINED BUTTON ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          side: const BorderSide(color: AppColors.primary, width: 2),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── TEXT / GHOST BUTTON ─────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── INPUT DECORATION ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest, // white
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.60, // label-caps
          color: AppColors.onSurfaceVariant,
        ),
      ),

      // ── CHIP ────────────────────────────────────────────────────────────────
      // surface-container-low fill, full-radius pill, no border, label-caps type.
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.50,
          color: AppColors.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // ── DIVIDER ─────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ── FAB ─────────────────────────────────────────────────────────────────
      // White circle, primary icon, zero elevation everywhere.
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        foregroundColor: AppColors.primary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: CircleBorder(),
        extendedPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),

      // ── ICON BUTTON ─────────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),

      // ── LIST TILE ───────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
      ),

      // ── DIALOG ──────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        elevation: 0,
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
      ),

      // ── SNACK BAR ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inverseSurface,
        elevation: 0,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.inverseOnSurface,
        ),
      ),

      // ── BOTTOM NAVIGATION BAR ───────────────────────────────────────────────
      // Flat surface bg, zero elevation, no divider shadow.
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
      ),

      // ── NAVIGATION BAR (Material 3) ─────────────────────────────────────────
      // Height 80, flat surface, zero elevation.
      // Active indicator: solid secondary-container (#fcb564) rounded rect —
      // mirrors the HTML's active tab pill (bg-secondary-container).
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        height: 80,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.onSurfaceVariant);
        }),
      ),
    );
  }

  // ── DARK THEME ──────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const t = AppTheme();

    // Dark-mode surface values (not in AppColors because AppColors is light-only)
    const Color darkSurface         = Color(0xFF1C1B1B);
    const Color darkSurfaceCard     = Color(0xFF2E2E2E);
    const Color darkOnSurface       = Color(0xFFECE7E7); // surface-container-high
    const Color darkOnSurfaceVariant= Color(0xFFC8C4D5); // #c8c4d5
    const Color darkOutlineVariant  = Color(0xFF474553); // #474553
    const Color darkOutline         = Color(0xFF938F99); // #938f99
    const Color darkScaffold        = Color(0xFF131313);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,

        primary:              AppColors.primary,
        onPrimary:            AppColors.onPrimary,
        primaryContainer:     AppColors.primaryContainer,
        onPrimaryContainer:   AppColors.onPrimaryContainer,

        secondary:              AppColors.secondary,
        onSecondary:            AppColors.onSecondary,
        secondaryContainer:     AppColors.secondaryContainer,
        onSecondaryContainer:   AppColors.onSecondaryContainer,

        tertiary:               AppColors.tertiary,
        onTertiary:             AppColors.onTertiary,
        tertiaryContainer:      AppColors.tertiaryContainer,
        onTertiaryContainer:    AppColors.onTertiaryContainer,

        error:              AppColors.error,
        onError:            AppColors.onError,
        errorContainer:     AppColors.errorContainer,
        onErrorContainer:   AppColors.onErrorContainer,

        surface:            darkSurface,
        onSurface:          darkOnSurface,
        surfaceVariant:     darkOutlineVariant,
        onSurfaceVariant:   darkOnSurfaceVariant,

        outline:            darkOutline,
        outlineVariant:     darkOutlineVariant,

        shadow:             Colors.black,
        scrim:              Colors.black,

        inverseSurface:     AppColors.inverseSurface,
        onInverseSurface:   AppColors.inverseOnSurface,
        inversePrimary:     AppColors.inversePrimary,
      ),

      scaffoldBackgroundColor: darkScaffold,
      primaryColor: AppColors.primary,

      textTheme: TextTheme(
        displayLarge:   t.displayLarge.copyWith(color: AppColors.primary),
        displayMedium:  t.headlineMedium.copyWith(color: darkOnSurface),
        displaySmall:   t.headlineMedium.copyWith(color: darkOnSurface),
        headlineLarge:  t.headlineMedium.copyWith(color: darkOnSurface),
        headlineMedium: t.headlineMedium.copyWith(color: darkOnSurface),
        headlineSmall:  t.headlineSmall.copyWith(color: darkOnSurface),
        titleLarge:     t.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: darkOnSurface),
        titleMedium:    t.bodyLarge.copyWith(color: darkOnSurface),
        titleSmall:     t.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: darkOnSurface),
        bodyLarge:      t.bodyLarge.copyWith(color: darkOnSurface),
        bodyMedium:     t.bodyMedium.copyWith(color: darkOnSurfaceVariant),
        bodySmall:      t.bodyMedium.copyWith(fontSize: 12, color: darkOnSurfaceVariant),
        labelLarge:     t.labelCaps.copyWith(color: darkOnSurfaceVariant),
        labelMedium:    t.labelSmall.copyWith(color: darkOnSurfaceVariant),
        labelSmall:     t.labelSmall.copyWith(color: darkOnSurfaceVariant),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        titleSpacing: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          height: 28 / 20,
        ),
      ),

      // Dark card: #2e2e2e fill, solid #474553 border
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurfaceCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          side: const BorderSide(color: darkOutlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 24 / 15,
          ),
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          side: const BorderSide(color: AppColors.primary, width: 2),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: darkOutlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: darkOutlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkOutline,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.60,
          color: darkOnSurfaceVariant,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceCard,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.50,
          color: darkOnSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      dividerTheme: const DividerThemeData(
        color: darkOutlineVariant,
        thickness: 1,
        space: 1,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkSurfaceCard,
        foregroundColor: AppColors.primary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: CircleBorder(),
        extendedPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        elevation: 0,
        backgroundColor: darkSurfaceCard,
        surfaceTintColor: Colors.transparent,
      ),

      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inverseSurface,
        elevation: 0,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.inverseOnSurface,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: darkOutline,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        height: 80,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: darkOutline,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: darkOutline);
        }),
      ),
    );
  }
}