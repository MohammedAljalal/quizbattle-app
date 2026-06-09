import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  final _pages = [
    _PageData(
      gradient: AppTheme.primaryGradient,
      icon: Icons.groups_rounded,
      emoji: '🏆',
      title: 'تحدّ زملاءك',
      subtitle: 'أنشئ اختبارات تنافسية وشاهد من يتصدّر القائمة',
    ),
    _PageData(
      gradient: LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      icon: Icons.schedule_rounded,
      emoji: '⏰',
      title: 'شارك في أي وقت',
      subtitle: 'لا قيود على التوقيت، أجب على الأسئلة متى يناسبك',
    ),
    _PageData(
      gradient: LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      icon: Icons.leaderboard_rounded,
      emoji: '🌟',
      title: 'لوحة المتصدرين',
      subtitle: 'تابع ترتيبك واحتلّ المراكز الأولى مع نقاط فورية',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.bg,
                  _pages[_page].gradient.colors.first.withOpacity(0.15),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          PageView.builder(
            controller: _ctrl,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (ctx, i) {
              final p = _pages[i];
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // Icon container
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: p.gradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: p.gradient.colors.first.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: -4,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(p.emoji,
                                style: const TextStyle(fontSize: 48)),
                          ],
                        ),
                      )
                          .animate(key: ValueKey(i))
                          .scale(
                              begin: const Offset(0.7, 0.7),
                              duration: 600.ms,
                              curve: Curves.elasticOut)
                          .fadeIn(),

                      const SizedBox(height: 56),

                      Text(p.title,
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.2),
                          textAlign: TextAlign.center)
                          .animate(key: ValueKey('t$i'))
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.3),

                      const SizedBox(height: 16),

                      Text(p.subtitle,
                          style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              height: 1.7),
                          textAlign: TextAlign.center)
                          .animate(key: ValueKey('s$i'))
                          .fadeIn(delay: 350.ms),
                    ],
                  ),
                ),
              );
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _page == i ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: _page == i ? _pages[_page].gradient : null,
                            color: _page == i ? null : AppTheme.textMuted,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 28),

                    // Next button
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: _pages[_page].gradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppTheme.primaryShadow,
                        ),
                        child: Center(
                          child: Text(
                            _page == _pages.length - 1 ? 'ابدأ الآن 🚀' : 'التالي',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (_page < _pages.length - 1) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _finish,
                        child: const Text('تخطّي',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 14)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  final LinearGradient gradient;
  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  const _PageData({
    required this.gradient,
    required this.icon,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}
