import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL CARD — the signature element of QuizBattle
// A frosted dark card with a 3px colored left border "signal strip"
// ─────────────────────────────────────────────────────────────────────────────
class SignalCard extends StatelessWidget {
  final Widget child;
  final Color? signalColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double radius;
  final bool highlight;

  const SignalCard({
    super.key,
    required this.child,
    this.signalColor,
    this.padding,
    this.onTap,
    this.radius = AppTheme.radiusLg,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = signalColor ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: highlight ? color.withOpacity(0.07) : AppTheme.canvasCard,
          borderRadius: BorderRadius.circular(radius),
          border: Border(
            left: BorderSide(color: color, width: 3),
            top: BorderSide(color: AppTheme.canvasBorder, width: 1),
            right: BorderSide(color: AppTheme.canvasBorder, width: 1),
            bottom: BorderSide(color: AppTheme.canvasBorder, width: 1),
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PILL BUTTON — gradient primary action
// ─────────────────────────────────────────────────────────────────────────────
class PillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Gradient? gradient;
  final double height;
  final double? width;

  const PillButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradient,
    this.height = 52,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final inactive = onPressed == null || isLoading;
    return GestureDetector(
      onTap: inactive ? null : () {
        HapticFeedback.lightImpact();
        onPressed!();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          gradient: inactive
              ? const LinearGradient(colors: [Color(0xFF1E1E3A), Color(0xFF1E1E3A)])
              : (gradient ?? AppTheme.heroGradient),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: inactive ? [] : AppTheme.primaryShadow,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.2))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[
                    Icon(icon, color: inactive ? AppTheme.inkMuted : Colors.white, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text,
                      style: AppTheme.label(15,
                          w: FontWeight.w700,
                          color: inactive ? AppTheme.inkMuted : Colors.white)),
                ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ICON BUTTON (small, square)
// ─────────────────────────────────────────────────────────────────────────────
class TapIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? bg;
  final double size;

  const TapIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.bg,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: bg ?? AppTheme.canvasRaised,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppTheme.canvasBorder),
        ),
        child: Icon(icon, size: size, color: color ?? AppTheme.inkSecondary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT TILE — compact metric display
// ─────────────────────────────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData? icon;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 5),
          ],
          Text(value,
              style: AppTheme.display(18, color: color),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.body(11, color: AppTheme.inkSecondary),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROOM CODE BADGE
// ─────────────────────────────────────────────────────────────────────────────
class RoomCodeBadge extends StatelessWidget {
  final String code;
  final bool large;
  const RoomCodeBadge({super.key, required this.code, this.large = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نسخ رمز الغرفة ✓')));
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: large ? 22 : 10, vertical: large ? 12 : 5),
        decoration: BoxDecoration(
          color: AppTheme.primaryGlow,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(code,
              style: GoogleFonts.sora(
                fontSize: large ? 30 : 13,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryHover,
                letterSpacing: large ? 5 : 1,
              )),
          SizedBox(width: large ? 10 : 6),
          Icon(Icons.copy_rounded,
              size: large ? 18 : 12,
              color: AppTheme.primary.withOpacity(0.7)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final bool isOpen;
  const StatusBadge({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final c = isOpen ? AppTheme.signalGreen : AppTheme.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(isOpen ? 'مفتوح' : 'مغلق',
            style: AppTheme.label(11, color: c)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AVATAR
// ─────────────────────────────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? color;

  const UserAvatar({super.key, required this.name, this.radius = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Container(
      width: radius * 2, height: radius * 2,
      decoration: BoxDecoration(
        color: c.withOpacity(0.15), shape: BoxShape.circle,
        border: Border.all(color: c.withOpacity(0.35), width: 1.5),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTheme.display(radius * 0.7, color: c),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER LOADER
// ─────────────────────────────────────────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  const ShimmerBox({super.key, this.width = double.infinity,
      this.height = 60, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        color: AppTheme.canvasRaised,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ).animate(onPlay: (c) => c.repeat())
        .shimmer(duration: const Duration(milliseconds: 1400),
            color: AppTheme.canvasMuted);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.icon, required this.title,
      required this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.07), shape: BoxShape.circle,
              border: Border.all(color: AppTheme.canvasBorder),
            ),
            child: Icon(icon, size: 36, color: AppTheme.inkMuted),
          ),
          const SizedBox(height: 20),
          Text(title,
              style: AppTheme.body(17, w: FontWeight.w700, color: AppTheme.ink),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle,
              style: AppTheme.body(13, color: AppTheme.inkSecondary),
              textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 24),
            SizedBox(width: 160,
                child: PillButton(text: actionLabel!, onPressed: onAction, height: 44)),
          ],
        ]).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTheme.body(16, w: FontWeight.w700, color: AppTheme.ink)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: AppTheme.label(13, color: AppTheme.primaryHover)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLASS CARD (legacy alias kept for compat)
// ─────────────────────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({super.key, required this.child, this.padding,
      this.borderRadius = AppTheme.radiusLg, this.borderColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.canvasCard,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor ?? AppTheme.canvasBorder),
          boxShadow: AppTheme.cardShadow,
        ),
        child: child,
      ),
    );
  }
}

// keep GradientButton as alias
class GradientButton extends PillButton {
  const GradientButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading = false,
    super.icon,
    super.gradient,
    super.height = 52,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// DIFFICULTY BADGE
// ─────────────────────────────────────────────────────────────────────────────
class DiffBadge extends StatelessWidget {
  final String difficulty;
  const DiffBadge({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (Color c, String label) = switch (difficulty) {
      'easy' => (AppTheme.signalGreen, 'سهل'),
      'hard' => (AppTheme.signalRed,   'صعب'),
      _      => (AppTheme.signalAmber, 'متوسط'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Text(label, style: AppTheme.label(11, color: c)),
    );
  }
}

// ── Backward-compat alias ──────────────────────────────────────────────────
typedef StatBadge = StatTile;
