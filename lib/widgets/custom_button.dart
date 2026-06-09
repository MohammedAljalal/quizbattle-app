// Re-export GradientButton as CustomButton for backwards compatibility
export 'ui_components.dart' show GradientButton;

// Alias
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: onPressed == null || isLoading
              ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700])
              : color != null
                  ? LinearGradient(colors: [color!, color!.withOpacity(0.8)])
                  : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: onPressed != null && !isLoading ? AppTheme.primaryShadow : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(text, style: const TextStyle(
                        color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w700)),
                  ],
                ),
        ),
      ),
    );
  }
}
