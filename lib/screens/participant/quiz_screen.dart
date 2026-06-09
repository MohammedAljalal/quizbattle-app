import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../services/submission_service.dart';
import '../../services/quiz_service.dart';
import '../../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  bool _submitting = false;
  Timer? _timer;
  int _secondsLeft = 0;
  late AnimationController _timerAnim;

  @override
  void initState() {
    super.initState();
    _timerAnim = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
  }

  void _startTimer() {
    final limit = context.read<QuizProvider>().currentQuiz?.timeLimitSeconds;
    if (limit == null) return;
    _timer?.cancel();
    setState(() => _secondsLeft = limit);
    _timerAnim
      ..duration = Duration(seconds: limit)
      ..forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 3) HapticFeedback.heavyImpact();
      if (_secondsLeft <= 0) { t.cancel(); _autoAdvance(); }
    });
  }

  void _autoAdvance() {
    final qp = context.read<QuizProvider>();
    if (qp.isLastQuestion) _submit(); else { qp.nextQuestion(); _startTimer(); }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    _timer?.cancel();
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final qp   = context.read<QuizProvider>();
    final ss   = SubmissionService();
    final qs   = QuizService();
    try {
      final quiz = qp.currentQuiz!;
      final live = await qs.getQuizByRoomCode(quiz.roomCode);
      if (live == null || !live.isOpen) { if (mounted) _roomClosed(); return; }
      final sub = await ss.submitAnswers(
        quizId: quiz.quizId,
        userId: auth.firebaseUser!.uid,
        userName: auth.userModel?.name ?? 'مشارك',
        answers: qp.selectedAnswers,
        questions: quiz.questions,
        timeTakenSeconds: qp.totalTimeTaken,
        timePerQuestion: qp.timePerQuestion,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/result', arguments: sub);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في الإرسال')));
    } finally { if (mounted) setState(() => _submitting = false); }
  }

  void _roomClosed() => showDialog(context: context, barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('تم إغلاق الاختبار'),
      content: const Text('أغلق المضيف الاختبار.'),
      actions: [ElevatedButton(
        onPressed: () {
          Navigator.pop(ctx);
          Navigator.pushReplacementNamed(context, '/participant-home');
        },
        child: const Text('العودة'),
      )],
    ));

  @override void dispose() { _timer?.cancel(); _timerAnim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final qp       = context.watch<QuizProvider>();
    final quiz     = qp.currentQuiz;
    final question = qp.currentQuestion;
    if (quiz == null || question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final idx      = qp.currentQuestionIndex;
    final total    = quiz.questionCount;
    final selected = qp.currentSelectedAnswer;
    final hasAns   = selected != null && selected >= 0;
    final revealed = qp.answerRevealed;
    final hasTimer = quiz.timeLimitSeconds != null;

    // Option palette: 4 distinct signal colors with their semantics
    final optSchemes = [
      (AppTheme.primary,     AppTheme.primaryHover),
      (AppTheme.coral,       const Color(0xFFFF8080)),
      (AppTheme.signalBlue,  const Color(0xFF80C4FF)),
      (AppTheme.signalGreen, const Color(0xFF60EEB8)),
    ];
    final labels = ['أ', 'ب', 'ج', 'د'];

    return PopScope(
      canPop: false,
      onPopInvoked: (did) async {
        if (did) return;
        final ok = await showDialog<bool>(context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('مغادرة الاختبار'),
            content: const Text('لن تُحفظ إجاباتك إذا غادرت الآن.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('متابعة')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.signalRed, minimumSize: const Size(80, 40)),
                child: const Text('مغادرة'),
              ),
            ],
          ),
        );
        if (ok == true && context.mounted) Navigator.pop(context);
      },
      child: StreamBuilder(
        stream: QuizService().watchQuiz(quiz.quizId),
        builder: (ctx, snap) {
          final live = snap.data;
          if (live != null && !live.isOpen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _roomClosed();
            });
          }
          return Scaffold(
            backgroundColor: AppTheme.canvas,
            body: SafeArea(
              child: Column(children: [

                // ── TOP BAR ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(children: [
                    // Counter pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.canvasRaised,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(color: AppTheme.canvasBorder),
                      ),
                      child: Text('${idx + 1} / $total',
                          style: GoogleFonts.sora(fontSize: 12,
                              fontWeight: FontWeight.w700, color: AppTheme.ink)),
                    ),
                    const SizedBox(width: 12),

                    // Progress track
                    Expanded(child: Stack(children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.canvasMuted,
                          borderRadius: BorderRadius.circular(3)),
                      ),
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 300),
                        widthFactor: qp.progress,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: revealed && hasAns
                                ? (selected == question.correctAnswer
                                    ? AppTheme.successGradient
                                    : AppTheme.coralGradient)
                                : AppTheme.heroGradient,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ])),

                    // Timer
                    if (hasTimer) ...[
                      const SizedBox(width: 12),
                      _TimerRing(secondsLeft: _secondsLeft, total: quiz.timeLimitSeconds!),
                    ],
                  ]),
                ),

                const SizedBox(height: 20),

                // ── QUESTION ───────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.canvasCard,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        border: Border.all(color: AppTheme.canvasBorder),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Question tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGlow,
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          ),
                          child: Text('السؤال ${idx + 1}',
                              style: AppTheme.label(11, color: AppTheme.primaryHover)),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: Center(
                          child: Text(question.questionText,
                              style: AppTheme.body(19, w: FontWeight.w700, color: AppTheme.ink),
                              textAlign: TextAlign.center)
                              .animate(key: ValueKey(idx)).fadeIn(duration: 300.ms),
                        )),
                      ]),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── OPTIONS ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(children: question.options.asMap().entries.map((e) {
                    final j     = e.key;
                    final opt   = e.value;
                    final isSel = selected != null && selected == j;
                    final isRight = j == question.correctAnswer;
                    final (baseColor, textColor) = optSchemes[j % optSchemes.length];

                    Color borderColor = AppTheme.canvasBorder;
                    Color bgColor = AppTheme.canvasCard;
                    Color labelFg = baseColor;

                    if (revealed) {
                      if (isRight)        { borderColor = AppTheme.signalGreen; bgColor = AppTheme.signalGreen.withOpacity(0.09); labelFg = AppTheme.signalGreen; }
                      else if (isSel)     { borderColor = AppTheme.signalRed;   bgColor = AppTheme.signalRed.withOpacity(0.07);   labelFg = AppTheme.signalRed;   }
                    } else if (isSel) {
                      borderColor = baseColor; bgColor = baseColor.withOpacity(0.1);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: GestureDetector(
                        onTap: (hasAns && revealed) ? null
                            : () => context.read<QuizProvider>().selectAnswer(j),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: borderColor, width: isSel || (revealed && isRight) ? 1.5 : 1),
                          ),
                          child: Row(children: [
                            // Label box
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: revealed
                                    ? (isRight ? AppTheme.signalGreen : isSel ? AppTheme.signalRed : baseColor.withOpacity(0.1))
                                    : (isSel ? baseColor : baseColor.withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                              ),
                              child: Center(child: revealed
                                  ? Icon(isRight ? Icons.check_rounded : (isSel ? Icons.close_rounded : null),
                                      color: Colors.white, size: 16)
                                  : Text(labels[j],
                                      style: AppTheme.label(13,
                                          color: isSel ? Colors.white : labelFg,
                                          w: FontWeight.w800))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(opt,
                                style: AppTheme.body(13,
                                    w: isSel ? FontWeight.w600 : FontWeight.w400,
                                    color: revealed
                                        ? (isRight ? AppTheme.signalGreen : isSel ? AppTheme.signalRed : AppTheme.inkSecondary)
                                        : (isSel ? AppTheme.ink : AppTheme.inkSecondary)))),
                            if (revealed && isRight)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppTheme.signalGreen, size: 18)
                                  .animate().scale(duration: 280.ms, curve: Curves.elasticOut),
                            if (revealed && isSel && !isRight)
                              const Icon(Icons.cancel_rounded,
                                  color: AppTheme.signalRed, size: 18)
                                  .animate().scale(duration: 280.ms),
                          ]),
                        ),
                      ).animate(delay: Duration(milliseconds: 40 * j))
                          .fadeIn(duration: 250.ms).slideX(begin: 0.06),
                    );
                  }).toList()),
                ),

                // ── NAV ────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Row(children: [
                    if (idx > 0 && !revealed)
                      Expanded(flex: 1, child: GestureDetector(
                        onTap: () { context.read<QuizProvider>().previousQuestion(); _startTimer(); },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.canvasRaised,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.canvasBorder)),
                          child: const Center(child: Icon(Icons.arrow_back_ios_rounded,
                              size: 16, color: AppTheme.inkSecondary)),
                        ),
                      )),
                    if (idx > 0 && !revealed) const SizedBox(width: 10),

                    Expanded(flex: 3, child: GestureDetector(
                      onTap: !hasAns
                          ? null
                          : revealed
                              ? (qp.isLastQuestion
                                  ? (_submitting ? null : _submit)
                                  : () { qp.nextQuestion(); _startTimer(); })
                              : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: (hasAns && (revealed || !quiz.showCorrectAnswer))
                              ? (qp.isLastQuestion
                                  ? AppTheme.successGradient
                                  : AppTheme.heroGradient)
                              : const LinearGradient(
                                  colors: [AppTheme.canvasMuted, AppTheme.canvasMuted]),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          boxShadow: (hasAns && revealed) ? AppTheme.primaryShadow : [],
                        ),
                        child: Center(
                          child: _submitting
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text(
                                  !hasAns ? 'اختر إجابة'
                                      : revealed
                                          ? (qp.isLastQuestion ? 'إرسال الإجابات ✓' : 'التالي ←')
                                          : '...',
                                  style: AppTheme.label(14,
                                      color: hasAns ? Colors.white : AppTheme.inkMuted)),
                        ),
                      ),
                    )),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  final int secondsLeft, total;
  const _TimerRing({required this.secondsLeft, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? secondsLeft / total : 0.0;
    final color = pct > 0.5 ? AppTheme.signalGreen
        : pct > 0.25 ? AppTheme.signalAmber : AppTheme.signalRed;
    return SizedBox(
      width: 46, height: 46,
      child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(
          value: pct.clamp(0.0, 1.0), strokeWidth: 3,
          backgroundColor: AppTheme.canvasMuted,
          valueColor: AlwaysStoppedAnimation(color),
        ),
        Text('$secondsLeft',
            style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }
}
