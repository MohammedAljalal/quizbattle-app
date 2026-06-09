import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'participant';
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
        _emailCtrl.text, _passCtrl.text, _nameCtrl.text, _role);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(
          context, _role == 'host' ? '/host-dashboard' : '/participant-home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'حدث خطأ'),
            backgroundColor: AppTheme.bgElevated),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إنشاء حساب جديد',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))
                  .animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 6),
              const Text('انضم إلى آلاف المتنافسين!',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 15))
                  .animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 36),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.badge_outlined)),
                validator: (v) => v == null || v.isEmpty ? 'أدخل اسمك' : null,
              ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.1),

              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.alternate_email_rounded)),
                validator: (v) => v == null || !v.contains('@')
                    ? 'بريد غير صالح' : null,
              ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),

              const SizedBox(height: 14),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => v == null || v.length < 6
                    ? 'على الأقل 6 أحرف' : null,
              ).animate(delay: 250.ms).fadeIn().slideX(begin: -0.1),

              const SizedBox(height: 28),

              const Text('أنا ...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
                  .animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: 14),

              Row(
                children: [
                  _RoleCard(
                    icon: '🎓',
                    title: 'معلم',
                    subtitle: 'أنشئ اختبارات',
                    selected: _role == 'host',
                    gradient: AppTheme.primaryGradient,
                    onTap: () => setState(() => _role = 'host'),
                  ),
                  const SizedBox(width: 12),
                  _RoleCard(
                    icon: '🎒',
                    title: 'طالب',
                    subtitle: 'انضم وتنافس',
                    selected: _role == 'participant',
                    gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF0D9488)]),
                    onTap: () => setState(() => _role = 'participant'),
                  ),
                ],
              ).animate(delay: 350.ms).fadeIn(),

              const SizedBox(height: 36),
              GradientButton(
                text: 'إنشاء الحساب',
                icon: Icons.rocket_launch_rounded,
                isLoading: auth.isLoading,
                onPressed: _register,
              ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لديك حساب؟',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تسجيل الدخول',
                        style: TextStyle(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ],
              ).animate(delay: 500.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String icon, title, subtitle;
  final bool selected;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon, required this.title, required this.subtitle,
    required this.selected, required this.gradient, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            gradient: selected ? gradient : null,
            color: selected ? null : AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? Colors.transparent : const Color(0xFF2D2D5A),
              width: 1.5,
            ),
            boxShadow: selected ? AppTheme.primaryShadow : [],
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppTheme.textPrimary)),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white70 : AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
