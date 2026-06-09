import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { super.initState(); _nav(); }

  Future<void> _nav() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(
          context, auth.isHost ? '/host-dashboard' : '/participant-home');
    } else if (!(prefs.getBool('onboarded') ?? false)) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Stack(children: [
        // Glow blobs
        Positioned(top: -120, right: -80,
          child: Container(width: 320, height: 320,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppTheme.primary.withOpacity(0.18), Colors.transparent])))),
        Positioned(bottom: -80, left: -60,
          child: Container(width: 280, height: 280,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppTheme.coral.withOpacity(0.12), Colors.transparent])))),

        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Logomark: bold Q in a rounded square
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppTheme.primaryShadow,
            ),
            child: Center(
              child: Text('QB',
                  style: GoogleFonts.sora(fontSize: 30, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: -1)),
            ),
          ).animate()
              .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // Wordmark
          RichText(text: TextSpan(children: [
            TextSpan(text: 'Quiz',
                style: GoogleFonts.sora(fontSize: 36, fontWeight: FontWeight.w900,
                    color: AppTheme.ink, letterSpacing: -1)),
            TextSpan(text: 'Battle',
                style: GoogleFonts.sora(fontSize: 36, fontWeight: FontWeight.w300,
                    color: AppTheme.primary, letterSpacing: -1)),
          ])).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

          const SizedBox(height: 8),
          Text('تعلّم · تنافس · تفوّق',
              style: AppTheme.body(14, color: AppTheme.inkSecondary))
              .animate(delay: 350.ms).fadeIn(),

          const SizedBox(height: 56),

          // Progress line
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                backgroundColor: AppTheme.canvasMuted,
                color: AppTheme.primary, minHeight: 3,
              ),
            ),
          ).animate(delay: 500.ms).fadeIn(),
        ])),
      ]),
    );
  }
}
