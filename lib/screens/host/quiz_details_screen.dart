import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/quiz_model.dart';
import '../../models/submission_model.dart';
import '../../services/quiz_service.dart';
import '../../services/submission_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class QuizDetailsScreen extends StatelessWidget {
  const QuizDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = ModalRoute.of(context)!.settings.arguments as QuizModel;
    final qs = QuizService();
    final ss = SubmissionService();

    return Scaffold(
      body: StreamBuilder<QuizModel?>(
        stream: qs.watchQuiz(quiz.quizId),
        builder: (context, snap) {
          final live = snap.data ?? quiz;
          return CustomScrollView(
            slivers: [

              // ── SliverAppBar ─────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        size: 16, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppTheme.error),
                    ),
                    onPressed: () => _delete(context, qs, live),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: live.isAvailable
                            ? [const Color(0xFF5B21B6), const Color(0xFFEC4899)]
                            : [const Color(0xFF1F2937), const Color(0xFF374151)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              StatusBadge(isOpen: live.isAvailable),
                              const SizedBox(width: 8),
                              _DifficultyBadge(difficulty: live.difficulty),
                              const Spacer(),
                              RoomCodeBadge(code: live.roomCode),
                            ]),
                            const SizedBox(height: 14),
                            Text(live.title, style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900,
                                color: Colors.white)),
                            if (live.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(live.description, style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                                  maxLines: 2),
                            ],
                            const SizedBox(height: 6),
                            Text('${live.category} · ${live.questionCount} سؤال'
                                '${live.timeLimitSeconds != null ? " · ${live.timeLimitSeconds}ث/سؤال" : ""}',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Stats row
                      StreamBuilder<List<SubmissionModel>>(
                        stream: ss.getLeaderboard(live.quizId),
                        builder: (ctx, subSnap) {
                          final subs = subSnap.data ?? [];
                          final avg = subs.isEmpty ? '-'
                              : '${(subs.fold<int>(0, (s, e) => s + e.score) / subs.length).round()}';
                          final maxScore = subs.isEmpty ? '-'
                              : '${subs.first.score}';
                          return Column(children: [
                            Row(children: [
                              StatBadge(icon: Icons.people_rounded,
                                  value: '${live.participantCount}',
                                  label: 'مشارك', color: AppTheme.primary),
                              const SizedBox(width: 10),
                              StatBadge(icon: Icons.bar_chart_rounded,
                                  value: avg, label: 'متوسط', color: AppTheme.success),
                              const SizedBox(width: 10),
                              StatBadge(icon: Icons.emoji_events_rounded,
                                  value: maxScore, label: 'أعلى', color: AppTheme.secondary),
                            ]).animate().fadeIn(),
                            // Score distribution chart
                            if (subs.length >= 3) ...[
                              const SizedBox(height: 16),
                              _ScoreChart(subs: subs),
                            ],
                          ]);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Time range card
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          _TimeTile(
                            icon: Icons.play_circle_outline_rounded,
                            label: 'البداية',
                            value: DateFormat('d MMM y - h:mm a').format(live.startTime),
                            color: AppTheme.success),
                          const SizedBox(height: 10),
                          _TimeTile(
                            icon: Icons.stop_circle_outlined,
                            label: 'الانتهاء',
                            value: DateFormat('d MMM y - h:mm a').format(live.endTime),
                            color: AppTheme.error),
                        ]),
                      ).animate(delay: 100.ms).fadeIn(),

                      const SizedBox(height: 16),

                      // Open/Close button
                      if (live.isOpen)
                        GestureDetector(
                          onTap: () => _close(context, qs, live),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.error.withOpacity(0.4))),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline_rounded, color: AppTheme.error, size: 20),
                                SizedBox(width: 8),
                                Text('إغلاق الاختبار',
                                    style: TextStyle(color: AppTheme.error,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ).animate(delay: 150.ms).fadeIn()
                      else
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                              color: AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2D2D5A))),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_rounded, color: AppTheme.textMuted, size: 18),
                              SizedBox(width: 8),
                              Text('الاختبار مغلق',
                                  style: TextStyle(color: AppTheme.textMuted)),
                            ],
                          ),
                        ).animate(delay: 150.ms).fadeIn(),

                      const SizedBox(height: 28),

                      // Submissions list
                      const SectionHeader(title: 'نتائج المشاركين'),
                      const SizedBox(height: 14),

                      StreamBuilder<List<SubmissionModel>>(
                        stream: ss.getHostSubmissions(live.quizId),
                        builder: (ctx, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Column(children: [
                              ShimmerBox(height: 70),
                              SizedBox(height: 8),
                              ShimmerBox(height: 70),
                              SizedBox(height: 8),
                              ShimmerBox(height: 70),
                            ]);
                          }
                          final subs = snap.data ?? [];
                          if (subs.isEmpty) {
                            return const EmptyState(
                              icon: Icons.people_outline_rounded,
                              title: 'لا يوجد مشاركون بعد',
                              subtitle: 'شارك رمز الغرفة مع طلابك',
                            );
                          }
                          return Column(
                            children: subs.asMap().entries.map((e) {
                              final i = e.key;
                              final sub = e.value;
                              final rankColor = i == 0
                                  ? const Color(0xFFFBBF24)
                                  : i == 1 ? const Color(0xFFB0BEC5)
                                  : i == 2 ? const Color(0xFFCD7F32)
                                  : AppTheme.textMuted;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    color: AppTheme.bgCard,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF2D2D5A))),
                                child: Row(children: [
                                  // Rank medal
                                  SizedBox(
                                    width: 28,
                                    child: i < 3
                                        ? Text(['🥇','🥈','🥉'][i],
                                            style: const TextStyle(fontSize: 20),
                                            textAlign: TextAlign.center)
                                        : Text('${i+1}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: rankColor, fontSize: 14),
                                            textAlign: TextAlign.center),
                                  ),
                                  const SizedBox(width: 10),
                                  UserAvatar(name: sub.userName, radius: 20, color: rankColor),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sub.userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700, fontSize: 14)),
                                      Row(children: [
                                        Text('${sub.correctCount}/${sub.totalQuestions} صحيح',
                                            style: const TextStyle(
                                                color: AppTheme.textMuted, fontSize: 11)),
                                        if (sub.timeTakenSeconds > 0) ...[
                                          const Text(' · ',
                                              style: TextStyle(color: AppTheme.textMuted)),
                                          Text(sub.timeTakenFormatted,
                                              style: const TextStyle(
                                                  color: AppTheme.textMuted, fontSize: 11)),
                                        ],
                                      ]),
                                    ],
                                  )),
                                  // Score + mini bar
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text('${sub.score}',
                                        style: TextStyle(
                                            fontSize: 20, fontWeight: FontWeight.w900,
                                            color: rankColor)),
                                    const Text('pts',
                                        style: TextStyle(
                                            color: AppTheme.textMuted, fontSize: 10)),
                                  ]),
                                ]),
                              ).animate(delay: Duration(milliseconds: 60 * i))
                                  .fadeIn().slideX(begin: 0.05);
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _close(BuildContext ctx, QuizService qs, QuizModel quiz) async {
    final ok = await showDialog<bool>(context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('إغلاق الاختبار'),
        content: const Text('لن يتمكن أحد من الانضمام بعد الإغلاق.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error, minimumSize: const Size(80, 40)),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
    if (ok == true) await qs.closeRoom(quiz.quizId);
  }

  Future<void> _delete(BuildContext ctx, QuizService qs, QuizModel quiz) async {
    final ok = await showDialog<bool>(context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('حذف الاختبار'),
        content: const Text('سيتم حذف الاختبار وجميع نتائجه نهائياً.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error, minimumSize: const Size(80, 40)),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok == true && ctx.mounted) {
      await qs.deleteQuiz(quiz.quizId);
      if (ctx.mounted) Navigator.pop(ctx);
    }
  }
}

// ── Score distribution bar chart ──────────────
class _ScoreChart extends StatelessWidget {
  final List<SubmissionModel> subs;
  const _ScoreChart({required this.subs});

  @override
  Widget build(BuildContext context) {
    // Build 5 buckets: 0-200, 200-400, 400-600, 600-800, 800-1000
    final buckets = List.filled(5, 0);
    for (final s in subs) {
      final idx = (s.score / 200).floor().clamp(0, 4);
      buckets[idx]++;
    }
    final maxY = buckets.reduce((a, b) => a > b ? a : b).toDouble();

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.bar_chart_rounded, color: AppTheme.primaryLight, size: 16),
          SizedBox(width: 6),
          Text('توزيع الدرجات',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                  color: AppTheme.primaryLight)),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: BarChart(BarChartData(
            maxY: maxY + 1,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final labels = ['0-200','200-400','400-600','600-800','800+'];
                    final idx = v.toInt();
                    if (idx < 0 || idx >= labels.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(labels[idx],
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 9)),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(5, (i) => BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(
                toY: buckets[i].toDouble(),
                gradient: LinearGradient(
                  colors: [AppTheme.primary.withOpacity(0.6), AppTheme.primary],
                  begin: Alignment.bottomCenter, end: Alignment.topCenter),
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              )],
            )),
          )),
        ),
      ]),
    ).animate(delay: 200.ms).fadeIn();
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color c = difficulty == 'easy'
        ? AppTheme.success : difficulty == 'hard'
        ? AppTheme.error : AppTheme.warning;
    String label = difficulty == 'easy' ? 'سهل'
        : difficulty == 'hard' ? 'صعب' : 'متوسط';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: c.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.withOpacity(0.4))),
      child: Text(label,
          style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _TimeTile({required this.icon, required this.label,
      required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    ]);
  }
}
