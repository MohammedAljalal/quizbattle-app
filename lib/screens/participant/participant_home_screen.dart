import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../services/quiz_service.dart';
import '../../services/submission_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class ParticipantHomeScreen extends StatefulWidget {
  const ParticipantHomeScreen({super.key});
  @override
  State<ParticipantHomeScreen> createState() => _ParticipantHomeScreenState();
}

class _ParticipantHomeScreenState extends State<ParticipantHomeScreen> {
  final _codeCtrl = TextEditingController();
  bool _joining = false;

  @override
  void dispose() { _codeCtrl.dispose(); super.dispose(); }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) { _snack('أدخل رمز الغرفة'); return; }
    setState(() => _joining = true);
    final auth = context.read<AuthProvider>();
    final qs = QuizService();
    final ss = SubmissionService();
    final qp = context.read<QuizProvider>();
    try {
      final quiz = await qs.getQuizByRoomCode(code);
      if (quiz == null) { _snack('رمز الغرفة غير صحيح ❌', err: true); return; }
      if (!quiz.isOpen)  { _snack('هذا الاختبار مغلق 🔒', err: true); return; }
      if (quiz.isExpired) { _snack('انتهى وقت الاختبار ⏰', err: true); return; }
      if (quiz.isFull)   { _snack('الاختبار ممتلئ 🚫', err: true); return; }
      final uid = auth.firebaseUser!.uid;
      final existing = await ss.getUserSubmission(quiz.quizId, uid);
      if (existing != null) { _snack('أجبت على هذا الاختبار مسبقاً ✓', err: true); return; }
      await qs.addParticipant(quiz.quizId, uid);
      qp.startQuiz(quiz);
      if (mounted) Navigator.pushNamed(context, '/quiz');
    } catch (_) {
      _snack('حدث خطأ، حاول مجدداً', err: true);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  void _snack(String msg, {bool err = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: err ? AppTheme.bgElevated : AppTheme.success));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.userModel?.name ?? 'مشارك';

    return Scaffold(
      body: CustomScrollView(
        slivers: [

          // ── Hero header ──────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D0D1A), Color(0xFF1A1A35)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('أهلاً، $name! 👋',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            const Text('جاهز للتحدي؟',
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 14)),
                          ]),
                          Row(children: [
                            _Btn(icon: Icons.person_outline_rounded,
                                onTap: () => Navigator.pushNamed(context, '/profile')),
                            const SizedBox(width: 8),
                            _Btn(icon: Icons.logout_rounded,
                                onTap: () async {
                                  await auth.signOut();
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  }
                                }),
                          ]),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Join card
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        borderColor: AppTheme.primary.withOpacity(0.3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              Icon(Icons.vpn_key_rounded,
                                  color: AppTheme.primaryLight, size: 16),
                              SizedBox(width: 8),
                              Text('أدخل رمز الغرفة',
                                  style: TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryLight)),
                            ]),
                            const SizedBox(height: 14),
                            Row(children: [
                              Expanded(
                                child: TextField(
                                  controller: _codeCtrl,
                                  textCapitalization: TextCapitalization.characters,
                                  onSubmitted: (_) => _join(),
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.w900,
                                      letterSpacing: 4,
                                      color: AppTheme.primaryLight),
                                  decoration: InputDecoration(
                                    hintText: 'QB-XXXX',
                                    hintStyle: TextStyle(
                                        color: AppTheme.textMuted,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w400, fontSize: 18),
                                    fillColor: AppTheme.bgElevated,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _joining ? null : _join,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 54, height: 54,
                                  decoration: BoxDecoration(
                                      gradient: _joining ? null : AppTheme.primaryGradient,
                                      color: _joining ? AppTheme.bgElevated : null,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: _joining ? [] : AppTheme.primaryShadow),
                                  child: _joining
                                      ? const Padding(padding: EdgeInsets.all(14),
                                          child: CircularProgressIndicator(
                                              color: Colors.white, strokeWidth: 2))
                                      : const Icon(Icons.arrow_forward_rounded,
                                          color: Colors.white, size: 24),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── How it works ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: const SectionHeader(title: 'كيف يعمل؟'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _Step(step:'١', icon: Icons.vpn_key_rounded, color: AppTheme.primary,
                    title:'أدخل رمز الغرفة',
                    desc:'احصل على الرمز من معلمك وأدخله أعلاه'),
                const SizedBox(height: 10),
                _Step(step:'٢', icon: Icons.quiz_rounded, color: AppTheme.accent,
                    title:'أجب على الأسئلة',
                    desc:'اختر الإجابة الصحيحة لكل سؤال'),
                const SizedBox(height: 10),
                _Step(step:'٣', icon: Icons.leaderboard_rounded, color: AppTheme.success,
                    title:'شاهد ترتيبك',
                    desc:'تنافس مع زملائك على المراكز الأولى'),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2D2D5A))),
      child: Icon(icon, size: 18, color: AppTheme.textSecondary),
    ),
  );
}

class _Step extends StatelessWidget {
  final String step, title, desc;
  final IconData icon;
  final Color color;
  const _Step({required this.step, required this.title, required this.desc,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3))),
          child: Center(child: Icon(icon, color: color, size: 22)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          Text(desc, style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
        ])),
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Center(child: Text(step,
              style: TextStyle(color: color, fontSize: 13,
                  fontWeight: FontWeight.w800))),
        ),
      ]),
    );
  }
}
