import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/submission_service.dart';
import '../../models/submission_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizId = ModalRoute.of(context)!.settings.arguments as String;
    final myUid = context.read<AuthProvider>().firebaseUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2D2D5A))),
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      size: 16, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(child: Text('لوحة المتصدرين',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
              const Text('🏆', style: TextStyle(fontSize: 24)),
            ]),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: StreamBuilder<List<SubmissionModel>>(
              stream: SubmissionService().getLeaderboard(quizId),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final subs = snap.data ?? [];
                if (subs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.leaderboard_outlined,
                    title: 'لا توجد نتائج بعد',
                    subtitle: 'كن أول من يجيب على هذا الاختبار!',
                  );
                }

                return Column(children: [
                  // Podium
                  if (subs.length >= 1)
                    _Podium(subs: subs, myUid: myUid)
                        .animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 4),

                  // Rest of list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: subs.length,
                      itemBuilder: (ctx, i) => _Row(
                        rank: i + 1,
                        sub: subs[i],
                        isMe: subs[i].userId == myUid,
                        index: i,
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Podium ─────────────────────────────────────
class _Podium extends StatelessWidget {
  final List<SubmissionModel> subs;
  final String myUid;
  const _Podium({required this.subs, required this.myUid});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A1A3E), Color(0xFF13132A)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFF2D2D5A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (subs.length >= 2)
            _Pillar(sub: subs[1], rank: 2, height: 74, medal: '🥈',
                color: const Color(0xFFB0BEC5),
                isMe: subs[1].userId == myUid),
          const SizedBox(width: 10),
          _Pillar(sub: subs[0], rank: 1, height: 96, medal: '🥇',
              color: const Color(0xFFFBBF24),
              isMe: subs[0].userId == myUid),
          const SizedBox(width: 10),
          if (subs.length >= 3)
            _Pillar(sub: subs[2], rank: 3, height: 56, medal: '🥉',
                color: const Color(0xFFCD7F32),
                isMe: subs[2].userId == myUid),
        ],
      ),
    );
  }
}

class _Pillar extends StatelessWidget {
  final SubmissionModel sub;
  final int rank;
  final double height;
  final String medal;
  final Color color;
  final bool isMe;
  const _Pillar({required this.sub, required this.rank, required this.height,
      required this.medal, required this.color, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(medal, style: const TextStyle(fontSize: 26)),
      const SizedBox(height: 5),
      Stack(alignment: Alignment.center, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15), shape: BoxShape.circle,
            border: Border.all(
                color: isMe ? AppTheme.primary : color.withOpacity(0.4),
                width: isMe ? 3 : 2)),
          child: Center(child: Text(
            sub.userName.isNotEmpty ? sub.userName[0].toUpperCase() : '؟',
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900),
          )),
        ),
        if (isMe) Positioned(bottom: 0, right: 0,
          child: Container(width: 14, height: 14,
            decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle,
                border: Border.all(color: AppTheme.bgCard, width: 2)))),
      ]),
      const SizedBox(height: 5),
      SizedBox(width: 70, child: Text(
        sub.userName.length > 7 ? '${sub.userName.substring(0,7)}..' : sub.userName,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary),
        textAlign: TextAlign.center, maxLines: 1,
      )),
      Text('${sub.score}',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
      if (sub.timeTakenSeconds > 0)
        Text(sub.timeTakenFormatted,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
      const SizedBox(height: 6),
      Container(
        width: 74, height: height,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          border: Border.all(color: color.withOpacity(0.3))),
        child: Center(child: Text('$rank',
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.w900))),
      ),
    ]);
  }
}

// ── List row ───────────────────────────────────
class _Row extends StatelessWidget {
  final int rank;
  final SubmissionModel sub;
  final bool isMe;
  final int index;
  const _Row({required this.rank, required this.sub,
      required this.isMe, required this.index});

  Color get _c {
    if (rank == 1) return const Color(0xFFFBBF24);
    if (rank == 2) return const Color(0xFFB0BEC5);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppTheme.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primary.withOpacity(0.1) : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? AppTheme.primary.withOpacity(0.4) : const Color(0xFF2D2D5A),
          width: isMe ? 1.5 : 1)),
      child: Row(children: [
        SizedBox(width: 34,
          child: rank <= 3
              ? Text(['🥇','🥈','🥉'][rank-1],
                  style: const TextStyle(fontSize: 20), textAlign: TextAlign.center)
              : Text('$rank', style: TextStyle(
                  fontWeight: FontWeight.w800, color: _c, fontSize: 14),
                  textAlign: TextAlign.center)),
        const SizedBox(width: 10),
        UserAvatar(name: sub.userName, radius: 18, color: _c),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(sub.userName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            if (isMe) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('أنت', style: TextStyle(
                    color: AppTheme.primaryLight, fontSize: 10,
                    fontWeight: FontWeight.w700)),
              ),
            ],
          ]),
          Row(children: [
            Text('${sub.correctCount}/${sub.totalQuestions} ✓',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            if (sub.timeTakenSeconds > 0) ...[
              const Text(' · ', style: TextStyle(color: AppTheme.textMuted)),
              Text('⏱ ${sub.timeTakenFormatted}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${sub.score}', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w900, color: _c)),
          const Text('pts', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ]),
      ]),
    ).animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }
}
