import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';

/// Premium Text Input Field with Focus Glow shadow animations
class StyledInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final bool readOnly;
  final Color? backgroundColor;
  final int? maxLength;

  const StyledInput({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.readOnly = false,
    this.backgroundColor,
    this.maxLength,
  });

  @override
  State<StyledInput> createState() => _StyledInputState();
}

class _StyledInputState extends State<StyledInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label!.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused ? AppColors.glowShadow : AppColors.softShadow,
          ),
          child: TextFormField(
            focusNode: _focusNode,
            controller: _controller,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLength: widget.maxLength,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: isDark ? Colors.white70 : AppColors.onSurfaceVariant, size: 20)
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(widget.suffixIcon),
                      onPressed: widget.onSuffixIconPressed,
                      color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
                      iconSize: 20,
                    )
                  : null,
              filled: true,
              fillColor: widget.backgroundColor ?? 
                  (isDark ? const Color(0xFF2E2E2E) : Colors.white),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.outlineVariant.withValues(alpha: 0.2) : AppColors.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.outlineVariant.withValues(alpha: 0.2) : AppColors.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              hintStyle: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Premium Dropdown selector card
class StyledDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final IconData? icon;
  final String? Function(T?)? validator;

  const StyledDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label!.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow,
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            icon: const Icon(Icons.expand_more_rounded, color: AppColors.onSurfaceVariant),
            dropdownColor: isDark ? const Color(0xFF2E2E2E) : Colors.white,
            elevation: 4,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: isDark ? const Color(0xFF2E2E2E) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.outlineVariant.withValues(alpha: 0.2) : AppColors.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.outlineVariant.withValues(alpha: 0.2) : AppColors.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              hintStyle: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.onSurfaceVariant,
              ),
            ),
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: isDark ? Colors.white : AppColors.onSurface,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}

/// Premium upload area card with subtle gradient dashed design
class FileUploadArea extends StatelessWidget {
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final IconData? icon;

  const FileUploadArea({
    super.key,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2F).withValues(alpha: 0.5) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 2,
            style: BorderStyle.solid, // Simulated dashed border using simple solid tint
          ),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.cloud_upload_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}