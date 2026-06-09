import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/submission_model.dart';
import '../../providers/quiz_provider.dart';
import '../../services/submission_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _myRank = 0;
  bool _loadingRank = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRank());
  }

  Future<void> _loadRank() async {
    final sub = ModalRoute.of(context)!.settings.arguments as SubmissionModel;
    final rank = await SubmissionService().getUserRank(sub.quizId, sub.userId);
    if (mounted) setState(() { _myRank = rank; _loadingRank = false; });
  }

  @override
  Widget build(BuildContext context) {
    final sub = ModalRoute.of(context)!.settings.arguments as SubmissionModel;
    final stars = sub.starCount;
    final pct = sub.percentage;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -80,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 320,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    (stars == 3 ? AppTheme.secondary : AppTheme.primary).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: Column(children: [

                // ── Trophy ──
                _TrophyHeader(stars: stars, pct: pct),
                const SizedBox(height: 24),

                // ── Stars ──
                _StarsRow(stars: stars),
                const SizedBox(height: 28),

                // ── Score + Rank card ──
                _ScoreCard(sub: sub, myRank: _myRank, loadingRank: _loadingRank),
                const SizedBox(height: 20),

                // ── Accuracy ring + time ──
                _StatsRow(sub: sub),
                const SizedBox(height: 20),

                // ── Per-question breakdown ──
                if (sub.answers.isNotEmpty) _AnswerBreakdown(sub: sub),
                const SizedBox(height: 24),

                // ── Actions ──
                GradientButton(
                  text: 'عرض الترتيب الكامل',
                  icon: Icons.leaderboard_rounded,
                  onPressed: () => Navigator.pushNamed(
                      context, '/leaderboard', arguments: sub.quizId),
                ).animate(delay: 900.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () {
                    context.read<QuizProvider>().resetQuiz();
                    Navigator.pushReplacementNamed(context, '/participant-home');
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('العودة للرئيسية'),
                ).animate(delay: 1000.ms).fadeIn(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _TrophyHeader extends StatelessWidget {
  final int stars;
  final double pct;
  const _TrophyHeader({required this.stars, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 110, height: 110,
        decoration: BoxDecoration(
          gradient: stars == 3 ? AppTheme.goldGradient : AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: (stars == 3 ? AppTheme.secondary : AppTheme.primary).withOpacity(0.45),
            blurRadius: 40, spreadRadius: -4,
          )],
        ),
        child: Icon(
          stars == 3 ? Icons.emoji_events_rounded
              : stars == 2 ? Icons.military_tech_rounded
              : Icons.school_rounded,
          size: 60, color: Colors.white,
        ),
      ).animate().scale(begin: const Offset(0.2, 0.2),
          duration: 700.ms, curve: Curves.elasticOut).fadeIn(),

      const SizedBox(height: 20),

      Text(stars == 3 ? 'رائع جداً! 🎉' : stars == 2 ? 'أداء جيد! 👏' : 'حاول مجدداً! 💪',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900))
          .animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

      const SizedBox(height: 6),
      Text('${pct.toStringAsFixed(0)}% إجابات صحيحة',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15))
          .animate(delay: 400.ms).fadeIn(),
    ]);
  }
}

class _StarsRow extends StatelessWidget {
  final int stars;
  const _StarsRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 56,
            color: filled ? AppTheme.secondary : AppTheme.textMuted,
          ).animate(delay: Duration(milliseconds: 500 + i * 180))
              .scale(begin: const Offset(0.2, 0.2),
                  duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(),
        );
      }),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final SubmissionModel sub;
  final int myRank;
  final bool loadingRank;
  const _ScoreCard({required this.sub, required this.myRank, required this.loadingRank});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppTheme.primary.withOpacity(0.25),
      child: Column(children: [
        // Score
        ShaderMask(
          shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
          child: Text('${sub.score}',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ).animate(delay: 600.ms).fadeIn().scale(begin: const Offset(0.7, 0.7)),

        const Text('نقطة',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 18)),

        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 20),

        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _StatCol(label: 'صحيح', value: '${sub.correctCount}',
              icon: Icons.check_circle_rounded, color: AppTheme.success),
          _Divider(),
          _StatCol(label: 'خطأ', value: '${sub.totalQuestions - sub.correctCount}',
              icon: Icons.cancel_rounded, color: AppTheme.error),
          _Divider(),
          _StatCol(label: 'الأسئلة', value: '${sub.totalQuestions}',
              icon: Icons.quiz_rounded, color: AppTheme.primary),
          _Divider(),
          // Live rank
          loadingRank
              ? const _StatColLoading(label: 'ترتيبي')
              : _StatCol(label: 'ترتيبي', value: '#$myRank',
                  icon: Icons.leaderboard_rounded, color: AppTheme.secondary),
        ]),
      ]),
    ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2);
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 50, color: const Color(0xFF2D2D5A));
}

class _StatCol extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCol({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
    ]);
  }
}

class _StatColLoading extends StatelessWidget {
  final String label;
  const _StatColLoading({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Icon(Icons.leaderboard_rounded, color: AppTheme.textMuted, size: 22),
      const SizedBox(height: 6),
      const SizedBox(
        width: 14, height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textMuted),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
    ]);
  }
}

// ─── Stats Row: accuracy ring + time taken ────
class _StatsRow extends StatelessWidget {
  final SubmissionModel sub;
  const _StatsRow({required this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Accuracy donut
      Expanded(
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            SizedBox(
              height: 80,
              child: PieChart(PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 26,
                sections: [
                  PieChartSectionData(
                    value: sub.correctCount.toDouble(),
                    color: AppTheme.success,
                    radius: 14,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: (sub.totalQuestions - sub.correctCount).toDouble(),
                    color: AppTheme.error.withOpacity(0.4),
                    radius: 14,
                    title: '',
                  ),
                ],
              )),
            ),
            const SizedBox(height: 8),
            Text('${sub.percentage.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const Text('الدقة', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ),
      ),
      const SizedBox(width: 12),
      // Time taken
      Expanded(
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_rounded, color: AppTheme.info, size: 28),
              ),
              const SizedBox(height: 10),
              Text(sub.timeTakenFormatted,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20,
                      color: AppTheme.info)),
              const Text('الوقت المستغرق',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ]).animate(delay: 700.ms).fadeIn().slideY(begin: 0.15);
  }
}

// ─── Answer Breakdown ─────────────────────────
class _AnswerBreakdown extends StatefulWidget {
  final SubmissionModel sub;
  const _AnswerBreakdown({required this.sub});
  @override
  State<_AnswerBreakdown> createState() => _AnswerBreakdownState();
}

class _AnswerBreakdownState extends State<_AnswerBreakdown> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final qp = context.read<QuizProvider>();
    final questions = qp.currentQuiz?.questions ?? [];
    if (questions.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        // Header toggle
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Icon(Icons.analytics_outlined, color: AppTheme.primaryLight, size: 20),
              const SizedBox(width: 10),
              const Expanded(child: Text('تحليل الإجابات',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
              Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppTheme.textSecondary),
            ]),
          ),
        ),

        if (_expanded) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                questions.length.clamp(0, widget.sub.answers.length),
                (i) {
                  final q = questions[i];
                  final userAnswer = widget.sub.answers[i];
                  final isCorrect = userAnswer == q.correctAnswer;
                  final wasSkipped = userAnswer < 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: wasSkipped
                          ? AppTheme.bgElevated
                          : isCorrect
                              ? AppTheme.success.withOpacity(0.08)
                              : AppTheme.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: wasSkipped
                            ? const Color(0xFF2D2D5A)
                            : isCorrect
                                ? AppTheme.success.withOpacity(0.3)
                                : AppTheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: wasSkipped
                                ? AppTheme.textMuted.withOpacity(0.2)
                                : isCorrect
                                    ? AppTheme.success.withOpacity(0.2)
                                    : AppTheme.error.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              wasSkipped ? Icons.remove
                                  : isCorrect ? Icons.check_rounded : Icons.close_rounded,
                              size: 14,
                              color: wasSkipped ? AppTheme.textMuted
                                  : isCorrect ? AppTheme.success : AppTheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('س${i + 1}',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12,
                                color: wasSkipped ? AppTheme.textMuted
                                    : isCorrect ? AppTheme.success : AppTheme.error)),
                        const Spacer(),
                        if (widget.sub.timePerQuestion.length > i)
                          Text('${widget.sub.timePerQuestion[i]}ث',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ]),
                      const SizedBox(height: 6),
                      Text(q.questionText,
                          style: const TextStyle(fontSize: 12, height: 1.4),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (!wasSkipped && !isCorrect) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 12, color: AppTheme.success),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'الصحيح: ${q.options[q.correctAnswer]}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.success),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ],
                    ]),
                  );
                },
              ),
            ),
          ),
        ],
      ]),
    ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.1);
  }
}
