import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;
    final isHost = auth.isHost;
    final isGuest = auth.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // ── Avatar & name ──
          Center(
            child: Column(children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: isHost ? AppTheme.primaryGradient : AppTheme.successGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.primaryShadow,
                ),
                child: Center(
                  child: Text(
                    isGuest ? '👤'
                        : user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : '؟',
                    style: TextStyle(
                        fontSize: isGuest ? 44 : 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 16),

              Text(isGuest ? 'مستخدم ضيف' : (user?.name ?? 'مستخدم'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))
                  .animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isHost ? AppTheme.primaryGradient : AppTheme.successGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isGuest ? '👤 ضيف' : isHost ? '🎓 معلم / مضيف' : '🎒 طالب / مشارك',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ).animate(delay: 200.ms).fadeIn(),
            ]),
          ),

          const SizedBox(height: 36),

          // ── Info ──
          if (!isGuest) ...[
            GlassCard(
              child: Column(children: [
                _InfoRow(icon: Icons.person_outline_rounded,
                    label: 'الاسم الكامل', value: user?.name ?? '-'),
                const Divider(height: 24),
                _InfoRow(icon: Icons.alternate_email_rounded,
                    label: 'البريد الإلكتروني', value: user?.email ?? '-'),
                const Divider(height: 24),
                _InfoRow(icon: Icons.badge_outlined,
                    label: 'الدور', value: isHost ? 'معلم (مضيف)' : 'طالب (مشارك)'),
              ]),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 32),
          ] else ...[
            GlassCard(
              borderColor: AppTheme.warning.withOpacity(0.3),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      color: AppTheme.warning, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(child: Text(
                  'أنت مسجّل كضيف. أنشئ حساباً للاحتفاظ بنتائجك.',
                  style: TextStyle(color: AppTheme.textSecondary,
                      fontSize: 13, height: 1.5),
                )),
              ]),
            ).animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: 16),
            GradientButton(
              text: 'إنشاء حساب',
              icon: Icons.person_add_rounded,
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/register');
                }
              },
            ).animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 24),
          ],

          // ── Logout ──
          GestureDetector(
            onTap: () => _logout(context, auth),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.error.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
                  SizedBox(width: 8),
                  Text('تسجيل الخروج',
                      style: TextStyle(
                          color: AppTheme.error, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ).animate(delay: 500.ms).fadeIn(),
        ]),
      ),
    );
  }

  Future<void> _logout(BuildContext ctx, AuthProvider auth) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد الخروج من حسابك؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                minimumSize: const Size(80, 40)),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (ok == true && ctx.mounted) {
      await auth.signOut();
      if (ctx.mounted) Navigator.pushReplacementNamed(ctx, '/login');
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryLight, size: 18),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
            color: AppTheme.textMuted, fontSize: 11)),
        Text(value, style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14)),
      ])),
    ]);
  }
}
