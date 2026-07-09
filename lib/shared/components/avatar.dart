import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/app_config.dart';

class UserAvatar extends StatelessWidget {
  final String? avatar;
  final String? localImagePath;
  final String? name;
  final double size;
  final double fontSize;
  final Color? textColor;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const UserAvatar({
    super.key,
    this.avatar,
    this.localImagePath,
    this.name,
    this.size = 40,
    this.fontSize = 14,
    this.textColor,
    this.backgroundColor,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    // Determine initials
    String initials = '?';
    if (avatar != null &&
        avatar!.isNotEmpty &&
        avatar!.length <= 2 &&
        !avatar!.contains('/') &&
        !avatar!.contains('\\') &&
        !avatar!.contains('uploads')) {
      initials = avatar!;
    } else if (name != null && name!.isNotEmpty) {
      final parts = name!.trim().split(' ');
      if (parts.length >= 2) {
        initials = (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
      } else if (name!.length >= 2) {
        initials = name!.substring(0, 2).toUpperCase();
      } else {
        initials = name!.substring(0, 1).toUpperCase();
      }
    }

    // Extra safety guard: if initials is still a path or has length > 2, recalculate from name
    if (initials.contains('/') ||
        initials.contains('\\') ||
        initials.contains('uploads') ||
        initials.length > 2) {
      if (name != null && name!.isNotEmpty) {
        final parts = name!.trim().split(' ');
        if (parts.length >= 2) {
          initials = (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
        } else if (name!.length >= 2) {
          initials = name!.substring(0, 2).toUpperCase();
        } else {
          initials = name!.substring(0, 1).toUpperCase();
        }
      } else {
        initials = '?';
      }
    }

    final hasLocalImage = localImagePath != null && localImagePath!.isNotEmpty;

    if (hasLocalImage) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
          boxShadow: boxShadow,
          image: DecorationImage(
            image: FileImage(File(localImagePath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final isUrl = avatar != null &&
        avatar!.isNotEmpty &&
        (avatar!.startsWith('http') ||
            avatar!.contains('uploads') ||
            avatar!.contains('uploads/') ||
            avatar!.contains('uploads\\'));

    final effectiveBgColor = backgroundColor ?? AppColors.primaryContainer;
    final effectiveTextColor = textColor ?? AppColors.primary;

    if (isUrl) {
      // Replace backslashes with forward slashes for URL paths
      String normalizedPath = avatar!.replaceAll('\\', '/');
      if (!normalizedPath.startsWith('/') && !normalizedPath.startsWith('http')) {
        normalizedPath = '/$normalizedPath';
      }

      final fullUrl = normalizedPath.startsWith('http')
          ? normalizedPath
          : '${AppConfig.baseUrl}$normalizedPath';

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
          boxShadow: boxShadow,
          image: DecorationImage(
            image: NetworkImage(
              fullUrl,
              headers: const {'ngrok-skip-browser-warning': 'true'},
            ),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Fallback to text avatar on error
            },
          ),
        ),
        // Fallback child in case loading fails or is slow
        child: ClipOval(
          child: Image.network(
            fullUrl,
            headers: const {'ngrok-skip-browser-warning': 'true'},
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: effectiveBgColor,
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: effectiveTextColor,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: effectiveTextColor,
        ),
      ),
    );
  }
}
