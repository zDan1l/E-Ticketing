import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';

/// Flat Message Bubble component from style-guide.html
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOutgoing ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isOutgoing ? 16 : 0),
                        bottomRight: Radius.circular(isOutgoing ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isOutgoing ? AppColors.onPrimary : AppColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.outline,
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

/// Message text entry console component with flat border definitions
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
    this.hint = 'Type a message...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: onAttach,
            color: AppColors.onSurfaceVariant,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurface,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: onSend != null ? (_) => onSend!() : null,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: onSend,
              color: AppColors.onPrimary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}