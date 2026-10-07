import 'package:flutter/material.dart';

import '../models/learning_content.dart';
import '../services/learning_analytics_service.dart';
import '../services/techstep_database.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  late Future<List<ChallengeLevel>> _levelsFuture;

  List<ChallengeLevel> levels = [];
  List<LearningQuestion> levelQuestions = [];
  List<bool> completedBoxes = [];
  List<bool> wrongBoxes = [];
  final Map<String, String> firstSelectedAnswers = {};

  int selectedLevel = -1;
  int currentBox = 0;
  bool loadingLevel = false;
  bool savingLevel = false;

  final List<Color> levelColors = const [
    Color(0xFF4F46E5),
    Color(0xFF6366F1),
    Color(0xFF7C3AED),
    Color(0xFF8B5CF6),
    Color(0xFF312E81),
  ];

  @override
  void initState() {
    super.initState();
    _levelsFuture = TechStepDatabase.instance.getChallengeLevels();
  }

  void _reloadLevels() {
    _levelsFuture = TechStepDatabase.instance.getChallengeLevels();
  }

  bool isLevelUnlocked(int level) {
    if (level == 0) {
      return true;
    }

    if (level - 1 >= levels.length) {
      return false;
    }

    return levels[level - 1].completed;
  }

  Future<void> openLevel(int level) async {
    if (!isLevelUnlocked(level)) {
      return;
    }

    setState(() {
      loadingLevel = true;
    });

    final questions = await TechStepDatabase.instance.getChallengeQuestions(
      levels[level].id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      selectedLevel = level;
      currentBox = 0;
      levelQuestions = questions;
      completedBoxes = List<bool>.filled(questions.length, false);
      wrongBoxes = List<bool>.filled(questions.length, false);
      firstSelectedAnswers.clear();
      loadingLevel = false;
    });
  }

  void exitLevel() {
    setState(() {
      selectedLevel = -1;
      currentBox = 0;
      levelQuestions = [];
      completedBoxes = [];
      wrongBoxes = [];
      firstSelectedAnswers.clear();
    });
  }

  void answerQuestion(String selectedAnswerKey) {
    final question = levelQuestions[currentBox];
    firstSelectedAnswers.putIfAbsent(question.id, () => selectedAnswerKey);

    if (selectedAnswerKey == question.correctOptionKey) {
      setState(() {
        completedBoxes[currentBox] = true;
        wrongBoxes[currentBox] = false;
      });

      _showCorrectAnswerDialog();
    } else {
      setState(() {
        wrongBoxes[currentBox] = true;
      });

      _showWrongAnswerDialog();
    }
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Jawaban Benar'),
          content: const Text(
            'Kotak ini sudah selesai. Kamu bisa lanjut ke kotak berikutnya.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _moveToNextBox();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Lanjut'),
            ),
          ],
        );
      },
    );
  }

  void _showWrongAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Jawaban Salah'),
          content: const Text(
            'Jawaban kamu belum tepat. Kotak ini tetap merah. Coba lagi sampai jawabanmu benar.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _moveToNextBox() async {
    final isLastBox = currentBox == levelQuestions.length - 1;

    if (!isLastBox) {
      setState(() {
        currentBox++;
      });
      return;
    }

    setState(() {
      savingLevel = true;
    });

    await LearningAnalyticsService.instance.recordChallengeResult(
      levelId: levels[selectedLevel].id,
      questions: levelQuestions,
      firstSelectedOptionKeys: firstSelectedAnswers,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      savingLevel = false;
      _reloadLevels();
    });

    _showLevelComplete();
  }

  void _showLevelComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final lastLevel = selectedLevel == levels.length - 1;

        return AlertDialog(
          title: const Text('Level Selesai'),
          content: Text(
            lastLevel
                ? 'Selamat! Kamu telah menyelesaikan semua level Computer Challenge.'
                : 'Kamu telah menyelesaikan ${levels[selectedLevel].name}.\n\nLevel berikutnya sekarang sudah terbuka.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                exitLevel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kembali'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loadingLevel) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (selectedLevel != -1) {
      return _buildLevelPage();
    }

    return FutureBuilder<List<ChallengeLevel>>(
      future: _levelsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F7FB),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        levels = snapshot.data!;
        return _buildChallengeHome();
      },
    );
  }

  Widget _buildChallengeHome() {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Computer Challenge',
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
              _buildChallengeHeader(),
              const SizedBox(height: 24),
              const Text(
                'Level Tantangan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Setiap level berisi 5 soal dari bank soal Computer Challenge pada dokumen bahan ajar.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 14),
              ...List.generate(
                levels.length,
                (index) => _buildLevelCard(index),
              ),
              const SizedBox(height: 10),
              _buildRubricCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeHeader() {
    final completedCount = levels.where((item) => item.completed).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF312E81)],
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
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.sports_esports_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Computer Challenge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lewati setiap langkah engklek dan uji pemahaman sistem komputer secara bertahap.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                '$completedCount dari ${levels.length} level selesai',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(int index) {
    final unlocked = isLevelUnlocked(index);
    final level = levels[index];
    final completed = level.completed;

    return InkWell(
      onTap: unlocked
          ? () {
              openLevel(index);
            }
          : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: unlocked ? Colors.white : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: completed
                ? const Color(0xFF4F46E5)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: unlocked
                    ? levelColors[index % levelColors.length]
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                completed
                    ? Icons.check_rounded
                    : unlocked
                    ? Icons.sports_esports_rounded
                    : Icons.lock_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${level.id} - ${level.name}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: unlocked
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: unlocked
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    completed
                        ? 'Nilai terbaik ${level.bestScore}%'
                        : '5 kotak - 5 tantangan',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: unlocked
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              completed
                  ? Icons.check_circle_rounded
                  : unlocked
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.lock_outline_rounded,
              color: completed
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF9CA3AF),
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRubricCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: const Text(
        'Rubrik level: 0-1 benar = belum siap, 2-3 benar = mulai memahami, 4 benar = cukup dikuasai, 5 benar = dikuasai dengan baik.',
        style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF4B5563)),
      ),
    );
  }

  Widget _buildLevelPage() {
    final question = levelQuestions[currentBox];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
          onPressed: savingLevel ? null : exitLevel,
        ),
        title: Text(
          'Level ${levels[selectedLevel].id}',
          style: const TextStyle(
            fontSize: 20,
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
              _buildLevelTitle(),
              const SizedBox(height: 20),
              _buildHopscotchMap(),
              const SizedBox(height: 24),
              _buildCurrentQuestion(question),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelTitle() {
    final color = levelColors[selectedLevel % levelColors.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level ${levels[selectedLevel].id}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            levels[selectedLevel].name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            levels[selectedLevel].description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHopscotchMap() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Text(
            'Papan Engklek',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 22),
          _buildHopscotchBox(4),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHopscotchBox(2),
              const SizedBox(width: 8),
              _buildHopscotchBox(3),
            ],
          ),
          const SizedBox(height: 8),
          _buildHopscotchBox(1),
          const SizedBox(height: 8),
          _buildHopscotchBox(0),
        ],
      ),
    );
  }

  Widget _buildHopscotchBox(int boxIndex) {
    if (boxIndex >= levelQuestions.length) {
      return const SizedBox.shrink();
    }

    final active = boxIndex == currentBox;
    final completed = completedBoxes[boxIndex];
    final wrong = wrongBoxes[boxIndex];
    final levelColor = levelColors[selectedLevel % levelColors.length];

    late Color backgroundColor;
    late Color borderColor;
    late Color textColor;
    late IconData icon;

    if (completed) {
      backgroundColor = const Color(0xFFDCFCE7);
      borderColor = const Color(0xFF22C55E);
      textColor = const Color(0xFF166534);
      icon = Icons.check_circle_rounded;
    } else if (wrong) {
      backgroundColor = const Color(0xFFFEE2E2);
      borderColor = const Color(0xFFDC2626);
      textColor = const Color(0xFFB91C1C);
      icon = Icons.close_rounded;
    } else if (active) {
      backgroundColor = levelColor;
      borderColor = levelColor;
      textColor = Colors.white;
      icon = Icons.location_on_rounded;
    } else {
      backgroundColor = const Color(0xFFF3F4F6);
      borderColor = const Color(0xFFD1D5DB);
      textColor = const Color(0xFF9CA3AF);
      icon = Icons.circle_outlined;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 130,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: active || wrong || completed ? 2 : 1,
        ),
        boxShadow: active && !wrong && !completed
            ? [
                BoxShadow(
                  color: levelColor.withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 21),
          const SizedBox(width: 8),
          Text(
            'Kotak ${boxIndex + 1}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentQuestion(LearningQuestion question) {
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
                'Kotak ${currentBox + 1}/${levelQuestions.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kompetensi: ${question.competencyTitle}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),
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
              child: _buildAnswerButton(option),
            ),
          ),
          if (savingLevel) ...[
            const SizedBox(height: 8),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerButton(AnswerOption option) {
    return InkWell(
      onTap: savingLevel
          ? null
          : () {
              answerQuestion(option.key);
            },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: Text(
                option.key,
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.text,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
