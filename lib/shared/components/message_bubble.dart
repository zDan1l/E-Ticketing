import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';

/// Premium Message Bubble with rounded corners, shadows, and outgoing gradient fill
class MessageBubble extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isOutgoing;
  final Widget? avatar;
  final VoidCallback? onTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    this.isOutgoing = false,
    this.avatar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bubbleColor = isOutgoing 
        ? null 
        : (isDark ? const Color(0xFF2E2E2E) : Colors.white);
    
    final bubbleGradient = isOutgoing ? AppColors.primaryGradient : null;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isOutgoing && avatar != null) ...[
              avatar!,
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      gradient: bubbleGradient,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isOutgoing ? 20 : 4),
                        bottomRight: Radius.circular(isOutgoing ? 4 : 20),
                      ),
                      boxShadow: AppColors.softShadow,
                      border: !isOutgoing
                          ? Border.all(
                              color: isDark 
                                  ? AppColors.outlineVariant.withValues(alpha: 0.1) 
                                  : AppColors.outlineVariant.withValues(alpha: 0.4),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isOutgoing ? AppColors.onPrimary : (isDark ? Colors.white : AppColors.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      timestamp,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isOutgoing && avatar != null) ...[
              const SizedBox(width: 8),
              avatar!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Premium Message input text area with shadows and clean button orbs
class MessageInput extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;
  final String hint;

  const MessageInput({
    super.key,
    this.controller,
    this.onSend,
    this.onAttach,
    this.hint = 'Tulis pesan...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2E2E) : Colors.white,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: AppColors.softShadow,
        border: Border.all(
          color: isDark 
              ? AppColors.outlineVariant.withValues(alpha: 0.15) 
              : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file_rounded),
            onPressed: onAttach,
            color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            iconSize: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white.withValues(alpha: 0.35) : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.onSurface,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: onSend != null ? (_) => onSend!() : null,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppColors.glowShadow,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded),
              onPressed: onSend,
              color: AppColors.onPrimary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}