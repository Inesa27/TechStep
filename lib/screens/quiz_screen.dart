import 'package:flutter/material.dart';

import '../models/learning_content.dart';
import '../services/learning_analytics_service.dart';
import '../services/techstep_database.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<LearningQuestion>> _questionsFuture;

  List<LearningQuestion> questions = [];
  List<String?> selectedAnswers = [];

  int currentQuestion = 0;
  int score = 0;

  bool quizStarted = false;
  bool quizFinished = false;
  bool savingResult = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = TechStepDatabase.instance.getQuizQuestions();
  }

  void startQuiz(List<LearningQuestion> loadedQuestions) {
    setState(() {
      questions = loadedQuestions;
      selectedAnswers = List<String?>.filled(questions.length, null);
      quizStarted = true;
      quizFinished = false;
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
    final selected = selectedAnswers[currentQuestion];

    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih salah satu jawaban terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
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

    setState(() {
      savingResult = true;
    });

    await LearningAnalyticsService.instance.recordQuizResult(
      questions: questions,
      selectedOptionKeys: selectedMap,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      score = totalScore;
      quizFinished = true;
      savingResult = false;
    });
  }

  int getTopicScore(String materialId) {
    var correct = 0;
    var total = 0;

    for (var i = 0; i < questions.length; i++) {
      if (questions[i].materialId == materialId) {
        total++;

        if (selectedAnswers[i] == questions[i].correctOptionKey) {
          correct++;
        }
      }
    }

    if (total == 0) {
      return 0;
    }

    return ((correct / total) * 100).round();
  }

  String getStatus(int value) {
    return LearningAnalyticsService.instance.competencyStatus(value);
  }

  Future<bool> _confirmExitQuiz() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Keluar dari Quiz?'),
          content: const Text(
            'Progress dan jawaban quiz yang sedang dikerjakan akan hilang.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!quizStarted) {
      return FutureBuilder<List<LearningQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              backgroundColor: Color(0xFFF6F7FB),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return _buildQuizHome(snapshot.data!);
        },
      );
    }

    if (quizFinished) {
      return _buildResultPage();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final shouldExit = await _confirmExitQuiz();

        if (shouldExit && mounted) {
          _backToQuizHome();
        }
      },
      child: _buildQuestionPage(),
    );
  }

  Widget _buildQuizHome(List<LearningQuestion> loadedQuestions) {
    final hardwareCount = _countMaterial(loadedQuestions, 'hardware');
    final softwareCount = _countMaterial(loadedQuestions, 'software');
    final osCount = _countMaterial(loadedQuestions, 'sistem_operasi');

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
                'Materi yang Diujikan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              _buildTopicInfo(
                title: 'Hardware',
                subtitle: '$hardwareCount soal dari bahan ajar',
                icon: Icons.memory_rounded,
              ),
              const SizedBox(height: 10),
              _buildTopicInfo(
                title: 'Software',
                subtitle: '$softwareCount soal dari bahan ajar',
                icon: Icons.apps_rounded,
              ),
              const SizedBox(height: 10),
              _buildTopicInfo(
                title: 'Sistem Operasi',
                subtitle: '$osCount soal dari bahan ajar',
                icon: Icons.desktop_windows_rounded,
              ),
              const SizedBox(height: 24),
              _buildMappingInfo(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    startQuiz(loadedQuestions);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Mulai Quiz',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _countMaterial(
    List<LearningQuestion> loadedQuestions,
    String materialId,
  ) {
    return loadedQuestions
        .where((item) => item.materialId == materialId)
        .length;
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
            child: const Icon(
              Icons.quiz_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Quiz Kompetensi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalQuestions soal pilihan ganda dipetakan ke kompetensi Hardware, Software, dan Sistem Operasi.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicInfo({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMappingInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aturan Competency Mapping',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Setiap soal terhubung ke kompetensi. Skor 80-100% = Dikuasai, 60-79% = Cukup, dan di bawah 60% = Perlu Diperkuat.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF6B7280),
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
        title: const Text(
          'Quiz',
          style: TextStyle(
            fontSize: 21,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    savingResult
                        ? 'Menyimpan...'
                        : currentQuestion == questions.length - 1
                        ? 'Selesaikan Quiz'
                        : 'Soal Berikutnya',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
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
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4F46E5),
              ),
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
            style: const TextStyle(
              fontSize: 19,
              height: 1.4,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
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
      onTap: () {
        selectAnswer(option.key);
      },
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
                color: selected
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 17)
                  : Text(
                      option.key,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B7280),
                      ),
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
    final finalScore = ((score / questions.length) * 100).round();
    final hardwareScore = getTopicScore('hardware');
    final softwareScore = getTopicScore('software');
    final osScore = getTopicScore('sistem_operasi');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Hasil Quiz',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            children: [
              _buildScoreHeader(finalScore),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Penguasaan per Materi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                title: 'Hardware',
                score: hardwareScore,
                icon: Icons.memory_rounded,
              ),
              const SizedBox(height: 10),
              _buildResultCard(
                title: 'Software',
                score: softwareScore,
                icon: Icons.apps_rounded,
              ),
              const SizedBox(height: 10),
              _buildResultCard(
                title: 'Sistem Operasi',
                score: osScore,
                icon: Icons.desktop_windows_rounded,
              ),
              const SizedBox(height: 24),
              _buildResultNote(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    startQuiz(questions);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Ulangi Quiz',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
          const Text(
            'Quiz Selesai',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$finalScore',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              height: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Nilai Quiz',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              getStatus(finalScore),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required int score,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: const Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Text(
                '$score%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4F46E5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              getStatus(score),
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF4F46E5)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Jawaban quiz tersimpan ke SQLite. Learning Analytics menghitung penguasaan per kompetensi, lalu Profile mengambil hasilnya untuk rekomendasi dan Learning Report.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
