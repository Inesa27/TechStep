
import 'package:flutter/material.dart';

import '../models/learning_content.dart';
import '../services/learning_analytics_service.dart';
import '../services/techstep_database.dart';

// ============================================================
// QUIZ MATERIAL
// ============================================================

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizMaterial {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _QuizMaterial({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

// ============================================================
// QUIZ STATE
// ============================================================

class _QuizScreenState extends State<QuizScreen> {
  static const int questionsPerQuiz = 10;

  static const Color _background = Color(0xFFF4F3FC);
  static const Color _primary = Color(0xFF5547E8);
  static const Color _primarySoft = Color(0xFFEEEDFF);
  static const Color _textPrimary = Color(0xFF242438);
  static const Color _textSecondary = Color(0xFF77778B);
  static const Color _border = Color(0xFFE7E5F2);
  static const Color _success = Color(0xFF239B70);
  static const Color _danger = Color(0xFFD93649);

  static const List<_QuizMaterial> _quizMaterials = [
    _QuizMaterial(
      id: 'hardware',
      title: 'Hardware',
      subtitle: 'Perangkat keras komputer',
      icon: Icons.memory_rounded,
    ),
    _QuizMaterial(
      id: 'software',
      title: 'Software',
      subtitle: 'Perangkat lunak komputer',
      icon: Icons.apps_rounded,
    ),
    _QuizMaterial(
      id: 'sistem_operasi',
      title: 'Sistem Operasi',
      subtitle: 'Fungsi dan pengelolaan sistem operasi',
      icon: Icons.desktop_windows_rounded,
    ),
  ];

  late Future<List<LearningQuestion>> _questionsFuture;
  late Future<List<Map<String, Object?>>> _historyFuture;

  List<LearningQuestion> questions = [];
  List<String?> selectedAnswers = [];

  int currentQuestion = 0;
  int score = 0;
  String? selectedMaterialId;

  bool quizStarted = false;
  bool quizFinished = false;
  bool savingResult = false;
  bool showProgressPage = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = TechStepDatabase.instance.getQuizQuestions();
    _historyFuture =
        TechStepDatabase.instance.getQuizHistory(limit: 30);
  }

  String get _selectedMaterialTitle {
    return _quizMaterials
        .firstWhere(
          (material) => material.id == selectedMaterialId,
          orElse: () => _quizMaterials.first,
        )
        .title;
  }

  // ==========================================================
  // LOGIKA KUIS
  // ==========================================================

  void startQuiz(
    List<LearningQuestion> allQuestions,
    String materialId,
  ) {
    final selectedQuestions = allQuestions
        .where((question) => question.materialId == materialId)
        .take(questionsPerQuiz)
        .toList();

    if (selectedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soal untuk materi ini belum tersedia.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      questions = selectedQuestions;
      selectedMaterialId = materialId;
      selectedAnswers =
          List<String?>.filled(questions.length, null);
      quizStarted = true;
      quizFinished = false;
      showProgressPage = false;
      currentQuestion = 0;
      score = 0;
    });
  }

  void selectAnswer(String answerKey) {
    setState(() {
      selectedAnswers[currentQuestion] = answerKey;
    });
  }

  Future<void> nextQuestion() async {
    if (selectedAnswers[currentQuestion] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih salah satu jawaban terlebih dahulu.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() => currentQuestion++);
    } else {
      await calculateScore();
    }
  }

  Future<void> calculateScore() async {
    var totalScore = 0;
    final selectedMap = <String, String>{};

    for (var i = 0; i < questions.length; i++) {
      final selected = selectedAnswers[i] ?? '';
      selectedMap[questions[i].id] = selected;

      if (selected == questions[i].correctOptionKey) {
        totalScore++;
      }
    }

    setState(() => savingResult = true);

    try {
      await LearningAnalyticsService.instance.recordQuizResult(
        questions: questions,
        selectedOptionKeys: selectedMap,
      );

      if (!mounted) return;

      setState(() {
        score = totalScore;
        quizFinished = true;
        savingResult = false;
        _historyFuture =
            TechStepDatabase.instance.getQuizHistory(limit: 30);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => savingResult = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nilai belum berhasil disimpan: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String getStatus(int value) {
    return LearningAnalyticsService.instance.competencyStatus(value);
  }

  Future<bool> _confirmExitQuiz() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Keluar dari kuis?'),
          content: const Text(
            'Progress dan jawaban kuis yang sedang dikerjakan '
            'akan hilang.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _backToQuizHome() {
    setState(() {
      quizStarted = false;
      quizFinished = false;
      currentQuestion = 0;
      score = 0;
      selectedAnswers = [];
      selectedMaterialId = null;
      showProgressPage = false;
      _questionsFuture =
          TechStepDatabase.instance.getQuizQuestions();
      _historyFuture =
          TechStepDatabase.instance.getQuizHistory(limit: 30);
    });
  }

  Future<void> _openProgressPage() async {
    await LearningAnalyticsService.instance.refresh();

    if (!mounted) return;

    setState(() {
      showProgressPage = true;
      _historyFuture =
          TechStepDatabase.instance.getQuizHistory(limit: 30);
    });
  }

  // ==========================================================
  // PEMILIHAN HALAMAN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (!quizStarted) {
      return FutureBuilder<List<LearningQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: _background,
              body: Center(
                child: CircularProgressIndicator(
                  color: _primary,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildLoadError(snapshot.error.toString());
          }

          final loadedQuestions =
              snapshot.data ?? const <LearningQuestion>[];

          if (showProgressPage) {
            return _buildScoreProgressPage();
          }

          return _buildQuizHome(loadedQuestions);
        },
      );
    }

    if (quizFinished) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _backToQuizHome();
        },
        child: _buildResultPage(),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _confirmExitQuiz();

        if (shouldExit && mounted) {
          _backToQuizHome();
        }
      },
      child: _buildQuestionPage(),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildLoadError(String message) {
    return Scaffold(
      backgroundColor: _background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEBEC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 38,
                  color: _danger,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Soal kuis gagal dimuat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _questionsFuture =
                          TechStepDatabase.instance.getQuizQuestions();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HALAMAN UTAMA QUIZ
  // ==========================================================

  Widget _buildQuizHome(List<LearningQuestion> loadedQuestions) {
    final analytics = LearningAnalyticsService.instance;

    final scoreByMaterial = <String, int>{
      'hardware': analytics.hardwareQuizScore,
      'software': analytics.softwareQuizScore,
      'sistem_operasi': analytics.operatingSystemQuizScore,
    };

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Quiz',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuizIntro(loadedQuestions.length),
              const SizedBox(height: 28),

              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Kuis',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Uji pemahamanmu berdasarkan materi.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              ..._quizMaterials.map((material) {
                final count = loadedQuestions
                    .where(
                      (question) =>
                          question.materialId == material.id,
                    )
                    .length;

                final questionCount = count < questionsPerQuiz
                    ? count
                    : questionsPerQuiz;

                final completed = analytics
                    .completedQuizMaterialIds
                    .contains(material.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildMaterialQuizCard(
                    material: material,
                    questionCount: questionCount,
                    isCompleted: completed,
                    latestScore: completed
                        ? scoreByMaterial[material.id]
                        : null,
                    onTap: count == 0
                        ? null
                        : () => startQuiz(
                              loadedQuestions,
                              material.id,
                            ),
                  ),
                );
              }),

              const SizedBox(height: 4),
              _buildProgressEntryCard(
                onTap: _openProgressPage,
              ),
              const SizedBox(height: 16),
              _buildMappingInfo(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // KARTU PEMBUKA QUIZ
  // ==========================================================

  Widget _buildQuizIntro(int totalQuestions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -55,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'UJI KOMPETENSI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              const Text(
                'Saatnya Uji\nPemahamanmu!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Kerjakan latihan soal untuk mengetahui '
                'seberapa jauh kamu memahami materi komputer.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 21),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.library_books_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bank soal tersedia',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalQuestions soal',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '3 Materi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // KARTU MATERI KUIS
  // ==========================================================

  Widget _buildMaterialQuizCard({
    required _QuizMaterial material,
    required int questionCount,
    required bool isCompleted,
    required int? latestScore,
    required VoidCallback? onTap,
  }) {
    final accent = isCompleted ? _success : _primary;
    final softColor = isCompleted
        ? const Color(0xFFE7F7EF)
        : _primarySoft;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: softColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      material.icon,
                      color: accent,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            material.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    color: accent,
                    size: 23,
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  _QuizPill(
                    icon: Icons.help_outline_rounded,
                    label: questionCount == 0
                        ? 'Belum ada soal'
                        : '$questionCount soal',
                  ),
                  const SizedBox(width: 8),
                  if (isCompleted)
                    const _QuizPill(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Pernah dikerjakan',
                      isSuccess: true,
                    )
                  else
                    const _QuizPill(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'Siap dikerjakan',
                    ),
                ],
              ),
              if (isCompleted && latestScore != null) ...[
                const SizedBox(height: 17),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F6FC),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nilai terakhir',
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '$latestScore%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _scoreColor(latestScore),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (questionCount == 0) ...[
                const SizedBox(height: 12),
                const Text(
                  'Soal untuk materi ini belum tersedia.',
                  style: TextStyle(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // NILAI DAN PERKEMBANGAN
  // ==========================================================

  Widget _buildProgressEntryCard({
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF353054),
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.query_stats_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nilai & Perkembangan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Lihat nilai terbaru, rata-rata, dan riwayat kuis.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMappingInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _primarySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDDDBFF),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _primary,
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemetaan Kompetensi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Setiap soal terhubung dengan kompetensi. Nilai '
                  '80–100% berarti Dikuasai, 60–79% berarti Cukup, '
                  'dan di bawah 60% berarti Perlu Diperkuat.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HALAMAN PENGERJAAN SOAL
  // ==========================================================

  Widget _buildQuestionPage() {
    final question = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Keluar dari kuis',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _textPrimary,
          ),
          onPressed: () async {
            final shouldExit = await _confirmExitQuiz();
            if (shouldExit && mounted) _backToQuizHome();
          },
        ),
        title: Text(
          'Quiz $_selectedMaterialTitle',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuestionHeader(question, progress),
              const SizedBox(height: 18),
              _buildQuestionCard(question),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: savingResult ? null : nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBEB8F7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: savingResult
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Menyimpan hasil...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentQuestion == questions.length - 1
                                  ? 'Selesaikan Kuis'
                                  : 'Soal Berikutnya',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              currentQuestion == questions.length - 1
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 19,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  selectedAnswers[currentQuestion] == null
                      ? 'Pilih jawaban yang menurutmu paling tepat.'
                      : 'Jawaban sudah dipilih. Kamu bisa melanjutkan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(
    LearningQuestion question,
    double progress,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  question.materialTitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Soal ${currentQuestion + 1}/${questions.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF0EFF7),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.track_changes_rounded,
                color: _primary,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Kompetensi: ${question.competencyTitle}',
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: _textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(LearningQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primarySoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: _primary,
              size: 23,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pertanyaan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 19,
              height: 1.5,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 23),
          ...question.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: _buildAnswerOption(option),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(AnswerOption option) {
    final selected = selectedAnswers[currentQuestion] == option.key;

    return Material(
      color: selected ? _primarySoft : Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => selectAnswer(option.key),
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? _primary : _border,
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _primary : const Color(0xFFF4F3FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        option.key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _textSecondary,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle_rounded,
                  color: _primary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HALAMAN HASIL KUIS
  // ==========================================================

  Widget _buildResultPage() {
    final finalScore = questions.isEmpty
        ? 0
        : ((score / questions.length) * 100).round();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Kembali ke menu Quiz',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _backToQuizHome,
        ),
        title: const Text(
          'Hasil Kuis',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            children: [
              _buildScoreHeader(finalScore),
              const SizedBox(height: 17),
              Text(
                'Kamu menjawab $score dari ${questions.length} '
                'soal dengan benar pada materi $_selectedMaterialTitle.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.65,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _buildScoreSummary(finalScore),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final allQuestions = questions;
                    final materialId =
                        selectedMaterialId ?? 'hardware';

                    startQuiz(allQuestions, materialId);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Ulangi Kuis Ini',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _backToQuizHome,
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text(
                    'Kembali ke Menu Quiz',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: _primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreHeader(int finalScore) {
    final scoreColor = _scoreColor(finalScore);

    final message = finalScore >= 80
        ? 'Hebat! Kamu sudah menguasai materi.'
        : finalScore >= 60
            ? 'Bagus! Terus tingkatkan pemahamanmu.'
            : 'Ayo pelajari kembali materi dan coba lagi.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              finalScore >= 80
                  ? Icons.emoji_events_rounded
                  : finalScore >= 60
                      ? Icons.workspace_premium_rounded
                      : Icons.menu_book_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Kuis Selesai!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _selectedMaterialTitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            '$finalScore%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 54,
              height: 1.05,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              getStatus(finalScore),
              style: TextStyle(
                color: scoreColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(int finalScore) {
    final statusColor = _scoreColor(finalScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.track_changes_rounded,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penguasaan Materi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ringkasan hasil pengerjaanmu',
                      style: TextStyle(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$score/${questions.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: _buildScoreStat(
                  icon: Icons.check_circle_rounded,
                  label: 'Jawaban benar',
                  value: '$score',
                  color: _success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildScoreStat(
                  icon: Icons.cancel_rounded,
                  label: 'Jawaban salah',
                  value: '${questions.length - score}',
                  color: _danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Status kompetensi',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                ),
              ),
              Text(
                getStatus(finalScore),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: finalScore / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFF0EFF7),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HALAMAN NILAI DAN RIWAYAT
  // ==========================================================

  Widget _buildScoreProgressPage() {
    return FutureBuilder<List<Map<String, Object?>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        final analytics = LearningAnalyticsService.instance;
        final history =
            snapshot.data ?? const <Map<String, Object?>>[];
        final attempted = analytics.completedQuizMaterialIds;

        final scoresByMaterial = <String, int>{
          'hardware': analytics.hardwareQuizScore,
          'software': analytics.softwareQuizScore,
          'sistem_operasi': analytics.operatingSystemQuizScore,
        };

        final availableScores = _quizMaterials
            .where((material) => attempted.contains(material.id))
            .map(
              (material) => scoresByMaterial[material.id] ?? 0,
            )
            .toList();

        final average = availableScores.isEmpty
            ? null
            : (availableScores.reduce((a, b) => a + b) /
                    availableScores.length)
                .round();

        return Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              tooltip: 'Kembali ke menu Quiz',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                setState(() => showProgressPage = false);
              },
            ),
            title: const Text(
              'Nilai & Perkembangan',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child: snapshot.connectionState != ConnectionState.done
                ? const Center(
                    child: CircularProgressIndicator(
                      color: _primary,
                    ),
                  )
                : snapshot.hasError
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Riwayat nilai gagal dimuat: '
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          8,
                          20,
                          30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProgressSummary(
                              average,
                              attempted.length,
                            ),
                            const SizedBox(height: 27),
                            const Text(
                              'Nilai Terbaru per Materi',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Pantau pencapaian untuk setiap materi.',
                              style: TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._quizMaterials.map((material) {
                              final isCompleted =
                                  attempted.contains(material.id);

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 13,
                                ),
                                child: _buildLatestScoreCard(
                                  material: material,
                                  score: isCompleted
                                      ? scoresByMaterial[material.id]
                                      : null,
                                  attemptCount: history
                                      .where(
                                        (row) =>
                                            row['material_id']
                                                ?.toString() ==
                                            material.id,
                                      )
                                      .length,
                                ),
                              );
                            }),
                            const SizedBox(height: 17),
                            const Text(
                              'Riwayat Kuis',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Daftar hasil pengerjaan yang tersimpan.',
                              style: TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (history.isEmpty)
                              _buildEmptyHistory()
                            else
                              ...history.map(_buildHistoryItem),
                            const SizedBox(height: 14),
                            const Text(
                              'Nilai terbaru tiap materi digunakan untuk '
                              'menghitung rata-rata. Semua percobaan yang '
                              'tersimpan ditampilkan pada riwayat.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.6,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSummary(
    int? average,
    int completedCount,
  ) {
    final progress = completedCount / _quizMaterials.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Nilai',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      average == null ? '—' : '$average%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 39,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 57,
                height: 57,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$completedCount dari ${_quizMaterials.length} kuis selesai',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 19),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Progres penyelesaian ${(progress * 100).round()}%',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestScoreCard({
    required _QuizMaterial material,
    required int? score,
    required int attemptCount,
  }) {
    final color = score == null ? _textSecondary : _scoreColor(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  material.icon,
                  color: _primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score == null
                          ? 'Belum dikerjakan'
                          : '$attemptCount percobaan tersimpan',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                score == null ? '—' : '$score%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (score != null) ...[
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: (score / 100).clamp(0.0, 1.0).toDouble(),
                minHeight: 7,
                backgroundColor: const Color(0xFFF0EFF7),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    getStatus(score),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 17,
                  color: _success,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, Object?> row) {
    final score = _asInt(row['score_percent']);
    final correct = _asInt(row['total_correct']);
    final total = _asInt(row['total_questions']);
    final materialTitle =
        row['material_title']?.toString() ?? 'Kuis';
    final dateText = _formatDate(
      row['created_at']?.toString(),
    );

    final color = _scoreColor(score);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: _primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  materialTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$correct dari $total benar',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$score%',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 42,
            color: _primary,
          ),
          SizedBox(height: 12),
          Text(
            'Belum Ada Riwayat Kuis',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Kerjakan salah satu kuis untuk mulai mencatat '
            'perkembangan nilai.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HELPER
  // ==========================================================

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDate(String? value) {
    final parsed = DateTime.tryParse(value ?? '')?.toLocal();

    if (parsed == null) return 'Tanggal tidak tersedia';

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');

    return '$day/$month/${parsed.year} $hour:$minute';
  }
}

// ============================================================
// WIDGET PENDUKUNG QUIZ
// ============================================================

class _QuizPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSuccess;

  const _QuizPill({
    required this.icon,
    required this.label,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSuccess
        ? const Color(0xFF239B70)
        : const Color(0xFF5547E8);

    final background = isSuccess
        ? const Color(0xFFE7F7EF)
        : const Color(0xFFEEEDFF);

    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _scoreColor(int score) {
  if (score >= 80) return const Color(0xFF239B70);
  if (score >= 60) return const Color(0xFFB7791F);
  return const Color(0xFFD93649);
}
