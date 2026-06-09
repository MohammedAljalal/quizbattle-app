import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC  = TextEditingController();
  bool _obscure = true;

  @override void dispose() { _emailC.dispose(); _passC.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_emailC.text, _passC.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(
          context, auth.isHost ? '/host-dashboard' : '/participant-home');
    } else {
      _toast(auth.error ?? 'حدث خطأ');
    }
  }

  Future<void> _guestLogin() async {
    final nc = TextEditingController();
    final ok = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('دخول كضيف'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('سيظهر اسمك في الترتيب', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          TextField(controller: nc, autofocus: true,
              decoration: const InputDecoration(hintText: 'اكتب اسمك هنا')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          PillButton(text: 'دخول', height: 40, width: 90,
              onPressed: () => Navigator.pop(ctx, true)),
          const SizedBox(width: 4),
        ],
      ),
    );
    if (ok == true && nc.text.trim().isNotEmpty && mounted) {
      final auth = context.read<AuthProvider>();
      if (await auth.signInAsGuest(nc.text.trim()) && mounted) {
        Navigator.pushReplacementNamed(context, '/participant-home');
      }
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Row(children: [
      const Icon(Icons.warning_rounded, color: AppTheme.signalAmber, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(msg)),
    ])));

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Stack(children: [
        Positioned(top: -100, left: -100,
          child: Container(width: 300, height: 300,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppTheme.primary.withOpacity(0.15), Colors.transparent])))),

        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(key: _form, child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 28),

              // Logomark
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.primaryShadow,
                ),
                child: Center(child: Text('QB',
                    style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: -1))),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: 20),
              Text('QuizBattle',
                  style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w800,
                      color: AppTheme.ink, letterSpacing: -0.5))
                  .animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 4),
              Text('مرحباً بعودتك',
                  style: AppTheme.body(14, color: AppTheme.inkSecondary))
                  .animate(delay: 180.ms).fadeIn(),

              const SizedBox(height: 40),

              TextFormField(
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.alternate_email_rounded)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'أدخل بريدك الإلكتروني' : null,
              ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.06),

              const SizedBox(height: 12),

              TextFormField(
                controller: _passC, obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure)),
                ),
                validator: (v) => v == null || v.length < 6 ? 'كلمة المرور قصيرة' : null,
              ).animate(delay: 250.ms).fadeIn().slideX(begin: -0.06),

              const SizedBox(height: 28),

              PillButton(
                text: 'تسجيل الدخول',
                icon: Icons.login_rounded,
                isLoading: auth.isLoading,
                onPressed: _login,
              ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.15),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: auth.isLoading ? null : _guestLogin,
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('دخول كضيف'),
              ).animate(delay: 380.ms).fadeIn(),

              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('ليس لديك حساب؟',
                    style: AppTheme.body(14, color: AppTheme.inkSecondary)),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text('إنشاء حساب',
                      style: AppTheme.label(14, color: AppTheme.primaryHover)),
                ),
              ]).animate(delay: 440.ms).fadeIn(),
            ],
          )),
        )),
      ]),
    );
  }
}
