import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_model.dart';
import '../../models/question_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/quiz_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});
  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  String _category = 'برمجة';
  String _difficulty = 'medium';
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(days: 1));
  bool _showCorrectAnswer = true;
  int? _timeLimitSeconds;      // null = no timer
  int _maxParticipants = 0;    // 0 = unlimited
  bool _publishing = false;

  final _categories = [
    ('برمجة','💻'), ('رياضيات','📐'), ('لغة عربية','📖'),
    ('لغة إنجليزية','🌐'), ('علوم','🔬'), ('تاريخ','🏛️'),
    ('عام','🎯'), ('أخرى','✨'),
  ];
  final _difficulties = [
    ('easy','سهل','🟢'), ('medium','متوسط','🟡'), ('hard','صعب','🔴'),
  ];
  final _timerOptions = [
    (null, 'بلا وقت'), (15, '15 ث'), (30, '30 ث'),
    (60, '60 ث'), (90, '90 ث'), (120, '2 د'),
  ];

  final List<_QData> _questions = [];
  bool _publishing2 = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDT(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startTime : _endTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() { if (isStart) _startTime = dt; else _endTime = dt; });
  }

  void _addQuestion() => setState(() => _questions.add(_QData()));

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) { _snack('أضف سؤالاً واحداً على الأقل'); return; }
    for (int i = 0; i < _questions.length; i++) {
      if (_questions[i].textCtrl.text.trim().isEmpty) {
        _snack('أدخل نص السؤال ${i + 1}'); return;
      }
      if (_questions[i].optCtrls.any((c) => c.text.trim().isEmpty)) {
        _snack('أدخل جميع خيارات السؤال ${i + 1}'); return;
      }
    }
    setState(() => _publishing = true);
    final auth = context.read<AuthProvider>();
    final qs = QuizService();
    final code = qs.generateRoomCode();
    final quiz = QuizModel(
      quizId: '',
      title: _titleCtrl.text.trim(),
      category: _category,
      hostId: auth.firebaseUser!.uid,
      hostName: auth.userModel?.name ?? '',
      roomCode: code,
      startTime: _startTime,
      endTime: _endTime,
      isOpen: true,
      participants: [],
      description: _descCtrl.text.trim(),
      difficulty: _difficulty,
      showCorrectAnswer: _showCorrectAnswer,
      timeLimitSeconds: _timeLimitSeconds,
      maxParticipants: _maxParticipants,
      questions: _questions.map((q) => QuestionModel(
        questionText: q.textCtrl.text.trim(),
        options: q.optCtrls.map((c) => c.text.trim()).toList(),
        correctAnswer: q.correct,
      )).toList(),
    );
    try {
      await qs.createQuiz(quiz);
      if (!mounted) return;
      await _showSuccess(code);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) _snack('خطأ في النشر، حاول مجدداً');
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _showSuccess(String code) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: AppTheme.bgCard,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                  gradient: AppTheme.successGradient, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            const Text('تم نشر الاختبار! 🎉',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('شارك هذا الرمز مع طلابك',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            RoomCodeBadge(code: code, large: true),
            const SizedBox(height: 24),
            GradientButton(text: 'رائع!', onPressed: () => Navigator.pop(ctx), height: 48),
          ]),
        ),
      ),
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppTheme.bgElevated));

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار جديد'),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // ══ STEP 1: Basic info ══════════════════
            _StepHeader(num: '١', title: 'معلومات الاختبار').animate().fadeIn(),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'عنوان الاختبار *',
                prefixIcon: Icon(Icons.drive_file_rename_outline_rounded)),
              validator: (v) => v == null || v.isEmpty ? 'أدخل عنواناً' : null,
            ).animate(delay: 50.ms).fadeIn(),

            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'وصف الاختبار (اختياري)',
                prefixIcon: Icon(Icons.description_outlined)),
            ).animate(delay: 80.ms).fadeIn(),

            const SizedBox(height: 20),

            // Category chips
            const Text('التصنيف',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _categories.map((cat) {
                final sel = _category == cat.$1;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: sel ? AppTheme.primaryGradient : null,
                      color: sel ? null : AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? Colors.transparent : const Color(0xFF2D2D5A))),
                    child: Text('${cat.$2} ${cat.$1}',
                        style: TextStyle(
                            color: sel ? Colors.white : AppTheme.textSecondary,
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 20),

            // Difficulty
            const Text('المستوى',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 10),
            Row(
              children: _difficulties.map((d) {
                final sel = _difficulty == d.$1;
                Color diffColor = d.$1 == 'easy'
                    ? AppTheme.success
                    : d.$1 == 'hard'
                        ? AppTheme.error
                        : AppTheme.warning;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _difficulty = d.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? diffColor.withOpacity(0.15) : AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: sel ? diffColor : const Color(0xFF2D2D5A),
                            width: sel ? 2 : 1)),
                      child: Column(children: [
                        Text(d.$3, style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(d.$2,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: sel ? diffColor : AppTheme.textSecondary)),
                      ]),
                    ),
                  ),
                );
              }).toList(),
            ).animate(delay: 120.ms).fadeIn(),

            const SizedBox(height: 28),

            // ══ STEP 2: Schedule ════════════════════
            _StepHeader(num: '٢', title: 'جدولة الاختبار').animate(delay: 150.ms).fadeIn(),
            const SizedBox(height: 14),

            Row(children: [
              Expanded(child: _DTTile(
                label: 'البداية', value: _fmt(_startTime),
                icon: Icons.play_circle_outline_rounded, color: AppTheme.success,
                onTap: () => _pickDT(true))),
              const SizedBox(width: 10),
              Expanded(child: _DTTile(
                label: 'الانتهاء', value: _fmt(_endTime),
                icon: Icons.stop_circle_outlined, color: AppTheme.error,
                onTap: () => _pickDT(false))),
            ]).animate(delay: 170.ms).fadeIn(),

            const SizedBox(height: 28),

            // ══ STEP 3: Settings ════════════════════
            _StepHeader(num: '٣', title: 'إعدادات الاختبار').animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 16),

            // Timer per question
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.timer_outlined, color: AppTheme.primaryLight, size: 18),
                  SizedBox(width: 8),
                  Text('وقت كل سؤال',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ]),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _timerOptions.map((opt) {
                    final sel = _timeLimitSeconds == opt.$1;
                    return GestureDetector(
                      onTap: () => setState(() => _timeLimitSeconds = opt.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primary.withOpacity(0.15) : AppTheme.bgElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel ? AppTheme.primary : const Color(0xFF2D2D5A),
                              width: sel ? 2 : 1)),
                        child: Text(opt.$2,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: sel ? AppTheme.primaryLight : AppTheme.textSecondary)),
                      ),
                    );
                  }).toList(),
                ),
              ]),
            ).animate(delay: 220.ms).fadeIn(),

            const SizedBox(height: 12),

            // Show correct answer toggle
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.visibility_outlined,
                      color: AppTheme.success, size: 20),
                ),
                const SizedBox(width: 14),
                const Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إظهار الإجابة الصحيحة',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('تظهر للطالب بعد كل سؤال',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                )),
                Switch.adaptive(
                  value: _showCorrectAnswer,
                  onChanged: (v) => setState(() => _showCorrectAnswer = v),
                  activeColor: AppTheme.success,
                ),
              ]),
            ).animate(delay: 240.ms).fadeIn(),

            const SizedBox(height: 12),

            // Max participants
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.people_outline_rounded, color: AppTheme.accent, size: 18),
                  SizedBox(width: 8),
                  Text('الحد الأقصى للمشاركين',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ]),
                const SizedBox(height: 4),
                Text(_maxParticipants == 0 ? 'غير محدود' : '$_maxParticipants مشارك',
                    style: TextStyle(
                        color: _maxParticipants == 0 ? AppTheme.textMuted : AppTheme.accent,
                        fontSize: 13)),
                Slider(
                  value: _maxParticipants.toDouble(),
                  min: 0, max: 200, divisions: 20,
                  activeColor: AppTheme.accent,
                  inactiveColor: AppTheme.bgElevated,
                  label: _maxParticipants == 0 ? 'غير محدود' : '$_maxParticipants',
                  onChanged: (v) => setState(() => _maxParticipants = v.round()),
                ),
              ]),
            ).animate(delay: 260.ms).fadeIn(),

            const SizedBox(height: 28),

            // ══ STEP 4: Questions ═══════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StepHeader(num: '٤', title: 'الأسئلة (${_questions.length})'),
                GestureDetector(
                  onTap: _addQuestion,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('إضافة', style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                  ),
                ),
              ],
            ).animate(delay: 280.ms).fadeIn(),
            const SizedBox(height: 14),

            if (_questions.isEmpty)
              GestureDetector(
                onTap: _addQuestion,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3),
                        style: BorderStyle.solid)),
                  child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: AppTheme.primaryLight, size: 32),
                    SizedBox(height: 8),
                    Text('اضغط لإضافة أول سؤال',
                        style: TextStyle(color: AppTheme.primaryLight)),
                  ])),
                ),
              ).animate(delay: 300.ms).fadeIn(),

            ..._questions.asMap().entries.map((e) {
              final i = e.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _QuestionCard(
                  index: i, data: e.value,
                  onRemove: () => setState(() => _questions.removeAt(i)),
                  onUpdate: () => setState(() {}),
                ).animate(delay: Duration(milliseconds: 40 * i)).fadeIn().slideY(begin: 0.1),
              );
            }),

            const SizedBox(height: 24),
            GradientButton(
              text: 'نشر الاختبار',
              icon: Icons.rocket_launch_rounded,
              isLoading: _publishing,
              onPressed: _publish,
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────
class _StepHeader extends StatelessWidget {
  final String num, title;
  const _StepHeader({required this.num, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
        child: Center(child: Text(num,
            style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.w800, fontSize: 13))),
      ),
      const SizedBox(width: 10),
      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _DTTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DTTile({required this.label, required this.value,
      required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _QData {
  final textCtrl = TextEditingController();
  final optCtrls = List.generate(4, (_) => TextEditingController());
  int correct = 0;
}

class _QuestionCard extends StatefulWidget {
  final int index;
  final _QData data;
  final VoidCallback onRemove, onUpdate;
  const _QuestionCard({required this.index, required this.data,
      required this.onRemove, required this.onUpdate});
  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  final _labels = ['أ', 'ب', 'ج', 'د'];
  final _optColors = [
    AppTheme.primary, AppTheme.accent,
    const Color(0xFF0EA5E9), AppTheme.success,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2D2D5A))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text('${widget.index + 1}',
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w800, fontSize: 14))),
          ),
          const SizedBox(width: 10),
          const Text('سؤال',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const Spacer(),
          GestureDetector(
            onTap: widget.onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.error, size: 18),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        TextField(
          controller: widget.data.textCtrl,
          onChanged: (_) => widget.onUpdate(),
          decoration: const InputDecoration(
              hintText: 'أدخل نص السؤال هنا...', labelText: 'نص السؤال'),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const Text('الخيارات — اضغط للتحديد كإجابة صحيحة:',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 10),
        ...List.generate(4, (j) {
          final isCor = widget.data.correct == j;
          final c = _optColors[j];
          return GestureDetector(
            onTap: () => setState(() => widget.data.correct = j),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isCor ? c.withOpacity(0.12) : AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isCor ? c : const Color(0xFF2D2D5A),
                    width: isCor ? 1.5 : 1)),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                      color: isCor ? c : c.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text(_labels[j],
                      style: TextStyle(
                          color: isCor ? Colors.white : c,
                          fontWeight: FontWeight.w800, fontSize: 13))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.data.optCtrls[j],
                    decoration: InputDecoration(
                      hintText: 'الخيار ${_labels[j]}',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false, contentPadding: EdgeInsets.zero),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                if (isCor) Icon(Icons.check_circle_rounded, color: c, size: 18)
                    .animate().scale(duration: 200.ms),
              ]),
            ),
          );
        }),
      ]),
    );
  }
}
