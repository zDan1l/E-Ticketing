import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Blue (Traveloka-like)
  static const Color primary = Color(0xFF0194F3);
  static const Color primaryLight = Color(0xFF4DB8FF);
  static const Color primaryDark = Color(0xFF0068B8);
  static const Color primarySurface = Color(0xFFE8F4FD);

  // Secondary
  static const Color secondary = Color(0xFF1A1A2E);
  static const Color secondaryLight = Color(0xFF16213E);

  // Status Colors
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF3D00);
  static const Color info = Color(0xFF2979FF);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8ECF0);
  static const Color divider = Color(0xFFF0F2F5);
  static const Color disabled = Color(0xFFBCC4CC);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Ticket Priority
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityHigh = Color(0xFFFF5722);
  static const Color priorityCritical = Color(0xFFD32F2F);

  // Ticket Status
  static const Color statusOpen = Color(0xFF2196F3);
  static const Color statusInProgress = Color(0xFFFF9800);
  static const Color statusResolved = Color(0xFF4CAF50);
  static const Color statusClosed = Color(0xFF9E9E9E);
  static const Color statusReopened = Color(0xFFFF5722);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0194F3), Color(0xFF0068B8)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0194F3), Color(0xFF4DB8FF)],
  );

  // New Gradient Variations
  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F4FD), Color(0xFFD0E8F8)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
    colors: [
      Color(0xFFE8ECF0),
      Color(0xFFF5F5F5),
      Color(0xFFE8ECF0),
    ],
    stops: [0.0, 0.5, 1.0],
    tileMode: TileMode.clamp,
  );
}
