import 'package:flutter/material.dart';

import '../models/learning_content.dart';
import '../services/learning_analytics_service.dart';
import '../services/techstep_database.dart';

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

class _QuizScreenState extends State<QuizScreen> {
  static const int questionsPerQuiz = 10;

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
    _historyFuture = TechStepDatabase.instance.getQuizHistory(limit: 30);
  }

  String get _selectedMaterialTitle {
    return _quizMaterials
        .firstWhere(
          (material) => material.id == selectedMaterialId,
          orElse: () => _quizMaterials.first,
        )
        .title;
  }

  void startQuiz(List<LearningQuestion> allQuestions, String materialId) {
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
      selectedAnswers = List<String?>.filled(questions.length, null);
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
          content: Text('Pilih salah satu jawaban terlebih dahulu.'),
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
        _historyFuture = TechStepDatabase.instance.getQuizHistory(limit: 30);
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
          title: const Text('Keluar dari kuis?'),
          content: const Text(
            'Progress dan jawaban kuis yang sedang dikerjakan akan hilang.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
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
      _questionsFuture = TechStepDatabase.instance.getQuizQuestions();
      _historyFuture = TechStepDatabase.instance.getQuizHistory(limit: 30);
    });
  }

  Future<void> _openProgressPage() async {
    await LearningAnalyticsService.instance.refresh();
    if (!mounted) return;
    setState(() {
      showProgressPage = true;
      _historyFuture = TechStepDatabase.instance.getQuizHistory(limit: 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!quizStarted) {
      return FutureBuilder<List<LearningQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: Color(0xFFF6F7FB),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return _buildLoadError(snapshot.error.toString());
          }

          final loadedQuestions = snapshot.data ?? const <LearningQuestion>[];
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
        if (shouldExit && mounted) _backToQuizHome();
      },
      child: _buildQuestionPage(),
    );
  }

  Widget _buildLoadError(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text(
                'Soal kuis gagal dimuat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _questionsFuture = TechStepDatabase.instance.getQuizQuestions();
                  });
                },
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizHome(List<LearningQuestion> loadedQuestions) {
    final analytics = LearningAnalyticsService.instance;
    final scoreByMaterial = <String, int>{
      'hardware': analytics.hardwareQuizScore,
      'software': analytics.softwareQuizScore,
      'sistem_operasi': analytics.operatingSystemQuizScore,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Quiz',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
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
              const SizedBox(height: 24),
              const Text(
                'Pilih Kuis Berdasarkan Materi',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Setiap kuis berisi maksimal 10 soal pilihan ganda.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),
              ..._quizMaterials.map((material) {
                final count = loadedQuestions
                    .where((question) => question.materialId == material.id)
                    .length;
                final questionCount = count < questionsPerQuiz
                    ? count
                    : questionsPerQuiz;
                final completed = analytics.completedQuizMaterialIds
                    .contains(material.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _buildMaterialQuizCard(
                    material: material,
                    questionCount: questionCount,
                    isCompleted: completed,
                    latestScore: completed ? scoreByMaterial[material.id] : null,
                    onTap: count == 0
                        ? null
                        : () => startQuiz(loadedQuestions, material.id),
                  ),
                );
              }),
              const SizedBox(height: 8),
              _buildProgressEntryCard(onTap: _openProgressPage),
              const SizedBox(height: 20),
              _buildMappingInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizIntro(int totalQuestions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 18),
          const Text(
            'Latihan Kompetensi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalQuestions soal tersedia dalam tiga materi. Pilih satu materi untuk mulai mengerjakan kuis secara bertahap.',
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialQuizCard({
    required _QuizMaterial material,
    required int questionCount,
    required bool isCompleted,
    required int? latestScore,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(material.icon, color: const Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      questionCount == 0
                          ? 'Soal belum tersedia'
                          : '$questionCount soal • ${material.subtitle}',
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (isCompleted && latestScore != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Nilai terakhir: $latestScore%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCompleted ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
                size: isCompleted ? 22 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressEntryCard({required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFF111827),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.query_stats_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
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
                    SizedBox(height: 4),
                    Text(
                      'Lihat nilai terbaru, rata-rata, dan riwayat kuis.',
                      style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMappingInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF4F46E5)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Setiap soal terhubung dengan kompetensi. Nilai 80–100% berarti Dikuasai, 60–79% berarti Cukup, dan di bawah 60% berarti Perlu Diperkuat.',
              style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage() {
    final question = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Keluar dari kuis',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            final shouldExit = await _confirmExitQuiz();
            if (shouldExit && mounted) _backToQuizHome();
          },
        ),
        title: Text(
          'Quiz $_selectedMaterialTitle',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
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
              const SizedBox(height: 20),
              _buildQuestionCard(question),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: savingResult ? null : nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    savingResult
                        ? 'Menyimpan...'
                        : currentQuestion == questions.length - 1
                            ? 'Selesaikan Quiz'
                            : 'Soal Berikutnya',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(LearningQuestion question, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  question.materialTitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Soal ${currentQuestion + 1}/${questions.length}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Kompetensi: ${question.competencyTitle}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(LearningQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(fontSize: 19, height: 1.4, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 22),
          ...question.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildAnswerOption(option),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(AnswerOption option) {
    final selected = selectedAnswers[currentQuestion] == option.key;
    return InkWell(
      onTap: () => selectAnswer(option.key),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 17)
                  : Text(
                      option.key,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPage() {
    final finalScore = questions.isEmpty ? 0 : ((score / questions.length) * 100).round();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Kembali ke menu Quiz',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _backToQuizHome,
        ),
        title: const Text(
          'Hasil Quiz',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            children: [
              _buildScoreHeader(finalScore),
              const SizedBox(height: 14),
              Text(
                'Kamu menjawab $score dari ${questions.length} soal dengan benar pada materi $_selectedMaterialTitle.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 18),
              _buildScoreSummary(finalScore),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final allQuestions = questions;
                    final materialId = selectedMaterialId ?? 'hardware';
                    startQuiz(allQuestions, materialId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Ulangi Kuis Ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _backToQuizHome,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    side: const BorderSide(color: Color(0xFF4F46E5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Kembali ke Menu Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreHeader(int finalScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 14),
          const Text('Quiz Selesai', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            '$finalScore%',
            style: const TextStyle(color: Colors.white, fontSize: 48, height: 1, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
            child: Text(
              getStatus(finalScore),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(int finalScore) {
    final Color statusColor = finalScore >= 80
        ? const Color(0xFF15803D)
        : finalScore >= 60
            ? const Color(0xFFB45309)
            : const Color(0xFFB91C1C);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(Icons.track_changes_rounded, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Penguasaan materi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                const SizedBox(height: 4),
                Text(getStatus(finalScore), style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text('$score/${questions.length}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
        ],
      ),
    );
  }

  Widget _buildScoreProgressPage() {
    return FutureBuilder<List<Map<String, Object?>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        final analytics = LearningAnalyticsService.instance;
        final history = snapshot.data ?? const <Map<String, Object?>>[];
        final attempted = analytics.completedQuizMaterialIds;
        final scoresByMaterial = <String, int>{
          'hardware': analytics.hardwareQuizScore,
          'software': analytics.softwareQuizScore,
          'sistem_operasi': analytics.operatingSystemQuizScore,
        };
        final availableScores = _quizMaterials
            .where((material) => attempted.contains(material.id))
            .map((material) => scoresByMaterial[material.id] ?? 0)
            .toList();
        final average = availableScores.isEmpty
            ? null
            : (availableScores.reduce((a, b) => a + b) / availableScores.length).round();

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              tooltip: 'Kembali ke menu Quiz',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() => showProgressPage = false),
            ),
            title: const Text(
              'Nilai & Perkembangan',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
          ),
          body: SafeArea(
            child: snapshot.connectionState != ConnectionState.done
                ? const Center(child: CircularProgressIndicator())
                : snapshot.hasError
                    ? Center(child: Text('Riwayat nilai gagal dimuat: ${snapshot.error}'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProgressSummary(average, attempted.length),
                            const SizedBox(height: 24),
                            const Text(
                              'Nilai Terbaru per Materi',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            ),
                            const SizedBox(height: 12),
                            ..._quizMaterials.map((material) {
                              final isCompleted = attempted.contains(material.id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildLatestScoreCard(
                                  material: material,
                                  score: isCompleted ? scoresByMaterial[material.id] : null,
                                  attemptCount: history.where((row) => row['material_id']?.toString() == material.id).length,
                                ),
                              );
                            }),
                            const SizedBox(height: 14),
                            const Text(
                              'Riwayat Kuis',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            ),
                            const SizedBox(height: 10),
                            if (history.isEmpty)
                              _buildEmptyHistory()
                            else
                              ...history.map(_buildHistoryItem),
                            const SizedBox(height: 12),
                            const Text(
                              'Nilai terbaru tiap materi digunakan untuk menghitung rata-rata. Semua percobaan yang tersimpan ditampilkan pada riwayat.',
                              style: TextStyle(fontSize: 11, height: 1.5, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSummary(int? average, int completedCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(21)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Nilai', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 5),
          Text(
            average == null ? 'Belum ada nilai' : '$average%',
            style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            '$completedCount dari ${_quizMaterials.length} kuis selesai',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completedCount / _quizMaterials.length,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                child: Icon(material.icon, color: const Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                    const SizedBox(height: 3),
                    Text(
                      score == null ? 'Belum dikerjakan' : '$attemptCount percobaan tersimpan',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Text(
                score == null ? '—' : '$score%',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
              ),
            ],
          ),
          if (score != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 7,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
              ),
            ),
            const SizedBox(height: 7),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(getStatus(score), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
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
    final materialTitle = row['material_title']?.toString() ?? 'Kuis';
    final dateText = _formatDate(row['created_at']?.toString());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.quiz_rounded, color: Color(0xFF4F46E5), size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(materialTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                const SizedBox(height: 3),
                Text('$correct dari $total benar • $dateText', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Text('$score%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, size: 34, color: Color(0xFF9CA3AF)),
          SizedBox(height: 8),
          Text('Belum ada riwayat kuis', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          SizedBox(height: 4),
          Text('Kerjakan salah satu kuis untuk mulai mencatat perkembangan nilai.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

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
