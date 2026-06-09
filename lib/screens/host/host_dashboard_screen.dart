import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/quiz_service.dart';
import '../../services/submission_service.dart';
import '../../models/quiz_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});
  @override State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.userModel?.name ?? 'معلم';

    return Scaffold(
      body: StreamBuilder<List<QuizModel>>(
        stream: QuizService().getHostQuizzes(auth.firebaseUser?.uid ?? ''),
        builder: (ctx, snap) {
          final all = snap.data ?? [];
          final shown = _filter == 'open'
              ? all.where((q) => q.isAvailable).toList()
              : _filter == 'closed'
                  ? all.where((q) => !q.isAvailable).toList()
                  : all;
          final openCt = all.where((q) => q.isAvailable).length;
          final partCt = all.fold<int>(0, (s, q) => s + q.participantCount);

          return CustomScrollView(slivers: [

            // ── Header ─────────────────────────────────────────────────────
            SliverToBoxAdapter(child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.heroGradient,
              ),
              child: SafeArea(bottom: false, child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      UserAvatar(name: name, radius: 21, color: Colors.white),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name,
                            style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('لوحة المعلم',
                            style: AppTheme.body(12, color: Colors.white60)),
                      ]),
                    ]),
                    Row(children: [
                      TapIcon(icon: Icons.person_outline_rounded,
                          bg: Colors.white12, color: Colors.white,
                          onTap: () => Navigator.pushNamed(context, '/profile')),
                      const SizedBox(width: 8),
                      TapIcon(icon: Icons.logout_rounded,
                          bg: Colors.white12, color: Colors.white,
                          onTap: () async {
                            await auth.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          }),
                    ]),
                  ]),

                  const SizedBox(height: 28),

                  // Metric strip
                  Row(children: [
                    _MetricBox(value: '${all.length}', label: 'اختبار', icon: '📋'),
                    const SizedBox(width: 10),
                    _MetricBox(value: '$openCt', label: 'مفتوح', icon: '🟢'),
                    const SizedBox(width: 10),
                    _MetricBox(value: '$partCt', label: 'مشارك', icon: '👥'),
                  ]),
                ]),
              )),
            )),

            // ── Filter strip ───────────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                for (final f in [('all','الكل'), ('open','مفتوح'), ('closed','مغلق')])
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: _filter == f.$1 ? AppTheme.primary : AppTheme.canvasRaised,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(
                              color: _filter == f.$1 ? Colors.transparent : AppTheme.canvasBorder)),
                        child: Text(f.$2,
                            style: AppTheme.label(12,
                                color: _filter == f.$1 ? Colors.white : AppTheme.inkSecondary)),
                      ),
                    ),
                  ),
                const Spacer(),
                Text('${shown.length} نتيجة',
                    style: AppTheme.body(11, color: AppTheme.inkMuted)),
              ]),
            )),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── List ───────────────────────────────────────────────────────
            if (snap.connectionState == ConnectionState.waiting)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  const ShimmerBox(height: 130), const SizedBox(height: 12),
                  const ShimmerBox(height: 130), const SizedBox(height: 12),
                  const ShimmerBox(height: 130),
                ])),
              )
            else if (shown.isEmpty)
              SliverToBoxAdapter(child: EmptyState(
                icon: Icons.quiz_outlined,
                title: _filter == 'all' ? 'لا توجد اختبارات بعد' : 'لا توجد نتائج',
                subtitle: 'اضغط الزر أدناه لإنشاء أول اختبار',
                actionLabel: 'إنشاء اختبار',
                onAction: () => Navigator.pushNamed(context, '/create-quiz'),
              ))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _QuizCard(quiz: shown[i], index: i)),
                  childCount: shown.length,
                )),
              ),
          ]);
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/create-quiz'),
        child: Container(
          height: 52, padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              boxShadow: AppTheme.primaryShadow),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('إنشاء اختبار',
                style: AppTheme.label(14, color: Colors.white)),
          ]),
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String value, label, icon;
  const _MetricBox({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w800,
                  color: Colors.white)),
          Text(label, style: AppTheme.body(10, color: Colors.white60),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final int index;
  const _QuizCard({required this.quiz, required this.index});

  @override
  Widget build(BuildContext context) {
    final open = quiz.isAvailable;
    final signalColor = open ? AppTheme.signalGreen : AppTheme.inkMuted;

    return SignalCard(
      signalColor: signalColor,
      onTap: () => Navigator.pushNamed(context, '/quiz-details', arguments: quiz),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(quiz.title,
                style: AppTheme.body(15, w: FontWeight.w700, color: AppTheme.ink),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Text(quiz.category,
                  style: AppTheme.body(12, color: AppTheme.inkSecondary)),
              const SizedBox(width: 6),
              Text(quiz.difficultyEmoji),
            ]),
          ])),
          const SizedBox(width: 12),
          StatusBadge(isOpen: open),
        ]),

        const SizedBox(height: 14),
        Container(height: 1, color: AppTheme.canvasBorder),
        const SizedBox(height: 12),

        Row(children: [
          // Room code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: AppTheme.primaryGlow,
                borderRadius: BorderRadius.circular(AppTheme.radiusXs)),
            child: Text(quiz.roomCode,
                style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppTheme.primaryHover, letterSpacing: 1)),
          ),
          const SizedBox(width: 10),
          Icon(Icons.help_outline_rounded, size: 13, color: AppTheme.inkMuted),
          const SizedBox(width: 3),
          Text('${quiz.questionCount}س',
              style: AppTheme.body(12, color: AppTheme.inkSecondary)),
          const SizedBox(width: 10),
          StreamBuilder(
            stream: SubmissionService().getLeaderboard(quiz.quizId),
            builder: (ctx, snap) {
              final ct = snap.data?.length ?? quiz.participantCount;
              return Row(children: [
                Icon(Icons.people_outline_rounded, size: 13, color: AppTheme.inkMuted),
                const SizedBox(width: 3),
                Text('$ct', style: AppTheme.body(12, color: AppTheme.inkSecondary)),
              ]);
            },
          ),
          if (quiz.timeLimitSeconds != null) ...[
            const SizedBox(width: 10),
            Icon(Icons.timer_outlined, size: 13, color: AppTheme.signalAmber),
            const SizedBox(width: 3),
            Text('${quiz.timeLimitSeconds}ث',
                style: AppTheme.body(12, color: AppTheme.signalAmber)),
          ],
          const Spacer(),
          Text(DateFormat('d MMM').format(quiz.endTime),
              style: AppTheme.body(11, color: AppTheme.inkMuted)),
        ]),
      ]),
    ).animate(delay: Duration(milliseconds: 70 * index)).fadeIn().slideY(begin: 0.12);
  }
}
