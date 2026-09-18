import 'package:flutter/material.dart';

import '../services/learning_analytics_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int score = 0;

  bool quizStarted = false;
  bool quizFinished = false;

  // Menyimpan jawaban siswa untuk 30 soal
  final List<String?> selectedAnswers = List.filled(30, null);

  // ============================================================
  // 30 SOAL
  // 10 HARDWARE
  // 10 SOFTWARE
  // 10 SISTEM OPERASI
  // ============================================================

  final List<Map<String, dynamic>> questions = [
    // ==========================================================
    // HARDWARE - 10 SOAL
    // ==========================================================

    {
      'topic': 'Hardware',
      'question':
          'Komponen yang berfungsi sebagai pusat pemrosesan data pada komputer adalah...',
      'options': [
        'RAM',
        'CPU',
        'Monitor',
        'Keyboard',
      ],
      'answer': 'CPU',
    },
    {
      'topic': 'Hardware',
      'question':
          'Perangkat yang digunakan untuk menyimpan data secara permanen adalah...',
      'options': [
        'RAM',
        'CPU',
        'SSD',
        'Monitor',
      ],
      'answer': 'SSD',
    },
    {
      'topic': 'Hardware',
      'question':
          'Perangkat yang digunakan untuk memasukkan teks ke dalam komputer adalah...',
      'options': [
        'Monitor',
        'Keyboard',
        'Speaker',
        'Projector',
      ],
      'answer': 'Keyboard',
    },
    {
      'topic': 'Hardware',
      'question':
          'Perangkat yang berfungsi menampilkan hasil proses komputer dalam bentuk visual adalah...',
      'options': [
        'Monitor',
        'Mouse',
        'Scanner',
        'Microphone',
      ],
      'answer': 'Monitor',
    },
    {
      'topic': 'Hardware',
      'question':
          'RAM pada komputer berfungsi terutama untuk...',
      'options': [
        'Menyimpan data secara permanen',
        'Menyimpan data sementara saat program berjalan',
        'Menampilkan gambar',
        'Mencetak dokumen',
      ],
      'answer': 'Menyimpan data sementara saat program berjalan',
    },
    {
      'topic': 'Hardware',
      'question':
          'Perangkat berikut yang termasuk perangkat output adalah...',
      'options': [
        'Keyboard',
        'Mouse',
        'Printer',
        'Scanner',
      ],
      'answer': 'Printer',
    },
    {
      'topic': 'Hardware',
      'question':
          'Komponen yang menjadi tempat berbagai komponen komputer terpasang disebut...',
      'options': [
        'Motherboard',
        'Monitor',
        'Keyboard',
        'Speaker',
      ],
      'answer': 'Motherboard',
    },
    {
      'topic': 'Hardware',
      'question':
          'Perangkat yang digunakan untuk menggerakkan pointer pada layar adalah...',
      'options': [
        'Mouse',
        'Printer',
        'Speaker',
        'Flashdisk',
      ],
      'answer': 'Mouse',
    },
    {
      'topic': 'Hardware',
      'question':
          'Perangkat yang dapat digunakan untuk memasukkan gambar atau dokumen fisik ke komputer adalah...',
      'options': [
        'Scanner',
        'Monitor',
        'Speaker',
        'Projector',
      ],
      'answer': 'Scanner',
    },
    {
      'topic': 'Hardware',
      'question':
          'Perangkat yang digunakan untuk menghasilkan suara dari komputer adalah...',
      'options': [
        'Microphone',
        'Speaker',
        'Scanner',
        'Keyboard',
      ],
      'answer': 'Speaker',
    },

    // ==========================================================
    // SOFTWARE - 10 SOAL
    // ==========================================================

    {
      'topic': 'Software',
      'question': 'Software adalah...',
      'options': [
        'Komponen fisik komputer',
        'Kumpulan program atau instruksi untuk menjalankan fungsi tertentu',
        'Perangkat untuk mencetak',
        'Bagian dari motherboard',
      ],
      'answer':
          'Kumpulan program atau instruksi untuk menjalankan fungsi tertentu',
    },
    {
      'topic': 'Software',
      'question': 'Contoh software pengolah kata adalah...',
      'options': [
        'Microsoft Word',
        'Windows',
        'BIOS',
        'RAM',
      ],
      'answer': 'Microsoft Word',
    },
    {
      'topic': 'Software',
      'question':
          'Contoh software yang digunakan untuk menjelajah internet adalah...',
      'options': [
        'Google Chrome',
        'Microsoft Excel',
        'Windows Explorer',
        'BIOS',
      ],
      'answer': 'Google Chrome',
    },
    {
      'topic': 'Software',
      'question':
          'Software yang digunakan untuk mengolah data dalam bentuk tabel adalah...',
      'options': [
        'Microsoft Excel',
        'Microsoft Paint',
        'Google Chrome',
        'VLC Media Player',
      ],
      'answer': 'Microsoft Excel',
    },
    {
      'topic': 'Software',
      'question': 'Manakah yang termasuk software sistem?',
      'options': [
        'Windows',
        'Canva',
        'Microsoft Word',
        'Google Chrome',
      ],
      'answer': 'Windows',
    },
    {
      'topic': 'Software',
      'question':
          'Software yang digunakan untuk membuat dan mengedit gambar atau desain grafis adalah...',
      'options': [
        'Canva',
        'BIOS',
        'RAM',
        'Processor',
      ],
      'answer': 'Canva',
    },
    {
      'topic': 'Software',
      'question':
          'Manakah yang termasuk application software?',
      'options': [
        'Google Chrome',
        'Kernel',
        'Device Driver',
        'BIOS',
      ],
      'answer': 'Google Chrome',
    },
    {
      'topic': 'Software',
      'question':
          'Program yang digunakan untuk memutar video pada komputer termasuk...',
      'options': [
        'Application software',
        'Hardware',
        'Firmware motherboard',
        'Processor',
      ],
      'answer': 'Application software',
    },
    {
      'topic': 'Software',
      'question':
          'Software antivirus digunakan terutama untuk...',
      'options': [
        'Mengedit video',
        'Melindungi komputer dari malware',
        'Mencetak dokumen',
        'Mengganti processor',
      ],
      'answer': 'Melindungi komputer dari malware',
    },
    {
      'topic': 'Software',
      'question':
          'Software yang digunakan untuk mengelola dan mengompres file adalah...',
      'options': [
        '7-Zip',
        'Microsoft Word',
        'Google Chrome',
        'Calculator',
      ],
      'answer': '7-Zip',
    },

    // ==========================================================
    // SISTEM OPERASI - 10 SOAL
    // ==========================================================

    {
      'topic': 'Sistem Operasi',
      'question': 'Sistem operasi adalah...',
      'options': [
        'Perangkat keras komputer',
        'Software yang mengelola sumber daya komputer',
        'Aplikasi untuk membuat dokumen',
        'Perangkat untuk mencetak',
      ],
      'answer': 'Software yang mengelola sumber daya komputer',
    },
    {
      'topic': 'Sistem Operasi',
      'question': 'Manakah yang merupakan contoh sistem operasi?',
      'options': [
        'Windows',
        'Microsoft Word',
        'Google Chrome',
        'Canva',
      ],
      'answer': 'Windows',
    },
    {
      'topic': 'Sistem Operasi',
      'question':
          'Salah satu fungsi utama sistem operasi adalah...',
      'options': [
        'Mengatur sumber daya komputer',
        'Membuat kabel jaringan',
        'Mengganti hardware',
        'Menghasilkan listrik',
      ],
      'answer': 'Mengatur sumber daya komputer',
    },
    {
      'topic': 'Sistem Operasi',
      'question':
          'Sistem operasi yang banyak digunakan pada smartphone adalah...',
      'options': [
        'Android',
        'Microsoft Word',
        'Photoshop',
        'Excel',
      ],
      'answer': 'Android',
    },
    {
      'topic': 'Sistem Operasi',
      'question': 'Linux merupakan...',
      'options': [
        'Sistem operasi',
        'Processor',
        'RAM',
        'Perangkat input',
      ],
      'answer': 'Sistem operasi',
    },
    {
      'topic': 'Sistem Operasi',
      'question':
          'Sistem operasi membantu pengguna berinteraksi dengan komputer melalui...',
      'options': [
        'User Interface',
        'RAM',
        'Power Supply',
        'Hard Disk',
      ],
      'answer': 'User Interface',
    },
    {
      'topic': 'Sistem Operasi',
      'question':
          'Salah satu tugas sistem operasi dalam pengelolaan file adalah...',
      'options': [
        'Mengatur penyimpanan dan pengelolaan file',
        'Membuat hardware baru',
        'Mencetak tanpa printer',
        'Mengganti layar monitor',
      ],
      'answer': 'Mengatur penyimpanan dan pengelolaan file',
    },
    {
      'topic': 'Sistem Operasi',
      'question':
          'Sistem operasi mengatur penggunaan RAM agar...',
      'options': [
        'Program dapat menggunakan memori sesuai kebutuhan',
        'Monitor menjadi lebih besar',
        'Keyboard dapat mencetak dokumen',
        'Internet selalu aktif',
      ],
      'answer': 'Program dapat menggunakan memori sesuai kebutuhan',
    },
    {
      'topic': 'Sistem Operasi',
      'question':
          'Contoh sistem operasi yang dikembangkan oleh Apple adalah...',
      'options': [
        'macOS',
        'Ubuntu',
        'Windows',
        'Android',
      ],
      'answer': 'macOS',
    },
    {
      'topic': 'Sistem Operasi',
      'question':
          'Sistem operasi menjadi penghubung antara pengguna, aplikasi, dan...',
      'options': [
        'Hardware',
        'Printer saja',
        'Internet saja',
        'Keyboard saja',
      ],
      'answer': 'Hardware',
    },
  ];

  // ============================================================
  // MULAI QUIZ
  // ============================================================

  void startQuiz() {
    setState(() {
      quizStarted = true;
      quizFinished = false;
      currentQuestion = 0;
      score = 0;

      for (int i = 0; i < selectedAnswers.length; i++) {
        selectedAnswers[i] = null;
      }
    });
  }

  // ============================================================
  // PILIH JAWABAN
  // ============================================================

  void selectAnswer(String answer) {
    setState(() {
      selectedAnswers[currentQuestion] = answer;
    });
  }

  // ============================================================
  // SOAL BERIKUTNYA
  // ============================================================

  void nextQuestion() {
    final selected = selectedAnswers[currentQuestion];

    if (selected == null) {
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
      setState(() {
        currentQuestion++;
      });
    } else {
      calculateScore();
    }
  }

  // ============================================================
  // HITUNG NILAI DAN KIRIM KE LEARNING ANALYTICS
  // ============================================================

  void calculateScore() {
    int totalScore = 0;

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['answer']) {
        totalScore++;
      }
    }

    // Nilai per materi
    final hardwareScore =
        getTopicScore('Hardware');

    final softwareScore =
        getTopicScore('Software');

    final operatingSystemScore =
        getTopicScore('Sistem Operasi');

    // ==========================================================
    // SIMPAN HASIL KE LEARNING ANALYTICS
    // ==========================================================

    LearningAnalyticsService.instance.recordQuizResult(
      totalCorrect: totalScore,
      totalQuestions: questions.length,
      hardwareScore: hardwareScore,
      softwareScore: softwareScore,
      operatingSystemScore: operatingSystemScore,
    );

    setState(() {
      score = totalScore;
      quizFinished = true;
    });
  }

  // ============================================================
  // HITUNG NILAI PER MATERI
  // ============================================================

  int getTopicScore(String topic) {
    int correct = 0;
    int total = 0;

    for (int i = 0; i < questions.length; i++) {
      if (questions[i]['topic'] == topic) {
        total++;

        if (selectedAnswers[i] == questions[i]['answer']) {
          correct++;
        }
      }
    }

    if (total == 0) {
      return 0;
    }

    return ((correct / total) * 100).round();
  }

  // ============================================================
  // STATUS NILAI
  // ============================================================

  String getStatus(int value) {
    if (value >= 80) {
      return 'Sangat Baik';
    }

    if (value >= 60) {
      return 'Baik';
    }

    if (value >= 40) {
      return 'Cukup';
    }

    return 'Perlu Dipelajari';
  }

  // ============================================================
  // KONFIRMASI KELUAR QUIZ
  // ============================================================

  Future<bool> _confirmExitQuiz() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Keluar dari Quiz?',
          ),
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
                backgroundColor:
                    const Color(0xFF4F46E5),
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

  // ============================================================
  // KEMBALI KE HALAMAN AWAL QUIZ
  // ============================================================

  void _backToQuizHome() {
    setState(() {
      quizStarted = false;
      quizFinished = false;
      currentQuestion = 0;
      score = 0;

      for (int i = 0; i < selectedAnswers.length; i++) {
        selectedAnswers[i] = null;
      }
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (!quizStarted) {
      return _buildQuizHome();
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

  // ============================================================
  // HALAMAN UTAMA QUIZ
  // ============================================================

  Widget _buildQuizHome() {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Quiz',
          style: TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildQuizIntro(),

              const SizedBox(height: 24),

              const Text(
                'Materi yang Diujikan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 12),

              _buildTopicInfo(
                title: 'Hardware',
                subtitle:
                    '10 soal mengenai komponen komputer',
                icon:
                    Icons.memory_rounded,
              ),

              const SizedBox(height: 10),

              _buildTopicInfo(
                title: 'Software',
                subtitle:
                    '10 soal mengenai perangkat lunak',
                icon:
                    Icons.apps_rounded,
              ),

              const SizedBox(height: 10),

              _buildTopicInfo(
                title: 'Sistem Operasi',
                subtitle:
                    '10 soal mengenai sistem operasi',
                icon: Icons
                    .desktop_windows_rounded,
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFE5E7EB,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Informasi Quiz',
                      style:
                          TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(
                          0xFF1F2937,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildInfoRow(
                      Icons
                          .help_outline_rounded,
                      'Jumlah soal',
                      '30 soal',
                    ),

                    const SizedBox(height: 10),

                    _buildInfoRow(
                      Icons
                          .menu_book_rounded,
                      'Pembagian',
                      '10 soal per materi',
                    ),

                    const SizedBox(height: 10),

                    _buildInfoRow(
                      Icons
                          .check_circle_outline_rounded,
                      'Jenis soal',
                      'Pilihan ganda',
                    ),

                    const SizedBox(height: 10),

                    _buildInfoRow(
                      Icons
                          .assessment_outlined,
                      'Hasil',
                      'Nilai dan penguasaan materi',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton(
                  onPressed:
                      startQuiz,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF4F46E5,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    'Mulai Quiz',
                    style:
                        TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
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

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildQuizIntro() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration:
          const BoxDecoration(
        gradient:
            LinearGradient(
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF6366F1),
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.all(
          Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withValues(alpha:0.15),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child:
                const Icon(
              Icons.quiz_rounded,
              color:
                  Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Uji Pemahamanmu',
            style: TextStyle(
              color:
                  Colors.white,
              fontSize: 23,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Kerjakan 30 soal untuk mengetahui sejauh mana pemahamanmu terhadap Hardware, Software, dan Sistem Operasi.',
            style:
                TextStyle(
              color:
                  Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO MATERI
  // ============================================================

  Widget _buildTopicInfo({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE5E7EB,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEEF2FF,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color:
                  const Color(
                0xFF4F46E5,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(
                      0xFF1F2937,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Color(
                      0xFF6B7280,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color:
              const Color(
            0xFF4F46E5,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style:
                const TextStyle(
              fontSize: 13,
              color:
                  Color(
                0xFF6B7280,
              ),
            ),
          ),
        ),

        Text(
          value,
          style:
              const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
            color:
                Color(
              0xFF1F2937,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HALAMAN SOAL
  // ============================================================

  Widget _buildQuestionPage() {
    final question =
        questions[currentQuestion];

    final List<String> options =
        List<String>.from(
      question['options'],
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,

        // BACK HANYA DI SINI
        leading:
            IconButton(
          icon:
              const Icon(
            Icons
                .arrow_back_rounded,
            color:
                Color(0xFF111827),
          ),
          onPressed:
              () async {
            final shouldExit =
                await _confirmExitQuiz();

            if (shouldExit &&
                mounted) {
              _backToQuizHome();
            }
          },
        ),

        title: Text(
          'Soal ${currentQuestion + 1} dari ${questions.length}',
          style:
              const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFF111827),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
                child:
                    LinearProgressIndicator(
                  value:
                      (currentQuestion + 1) /
                          questions.length,
                  minHeight: 8,
                  backgroundColor:
                      const Color(
                    0xFFE5E7EB,
                  ),
                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    Color(
                      0xFF4F46E5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEEF2FF,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
                child:
                    Text(
                  question['topic']
                      .toString(),
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(
                      0xFF4F46E5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                question['question']
                    .toString(),
                style:
                    const TextStyle(
                  fontSize: 21,
                  height: 1.35,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(
                    0xFF111827,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child:
                    ListView
                        .separated(
                  itemCount:
                      options.length,
                  separatorBuilder:
                      (context,
                          index) {
                    return const SizedBox(
                      height: 12,
                    );
                  },
                  itemBuilder:
                      (context,
                          index) {
                    final option =
                        options[index];

                    final selected =
                        selectedAnswers[
                                currentQuestion] ==
                            option;

                    return _buildAnswerOption(
                      option:
                          option,
                      selected:
                          selected,
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton(
                  onPressed:
                      nextQuestion,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF4F46E5,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),
                  ),
                  child:
                      Text(
                    currentQuestion ==
                            questions
                                    .length -
                                1
                        ? 'Selesaikan Quiz'
                        : 'Soal Berikutnya',
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
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

  // ============================================================
  // PILIHAN JAWABAN
  // ============================================================

  Widget _buildAnswerOption({
    required String option,
    required bool selected,
  }) {
    return InkWell(
      onTap: () {
        selectAnswer(option);
      },
      borderRadius:
          BorderRadius.circular(
        16,
      ),
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        width:
            double.infinity,
        padding:
            const EdgeInsets.all(
          17,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? const Color(
                  0xFFEEF2FF,
                )
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          border:
              Border.all(
            color: selected
                ? const Color(
                    0xFF4F46E5,
                  )
                : const Color(
                    0xFFE5E7EB,
                  ),
            width:
                selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xFF4F46E5,
                      )
                    : const Color(
                        0xFFF3F4F6,
                      ),
                shape:
                    BoxShape.circle,
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      color:
                          Colors.white,
                      size: 17,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                option,
                style:
                    TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: selected
                      ? FontWeight
                          .w600
                      : FontWeight
                          .w500,
                  color:
                      const Color(
                    0xFF374151,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HASIL QUIZ
  // ============================================================

  Widget _buildResultPage() {
    final finalScore =
        ((score / questions.length) *
                100)
            .round();

    final hardwareScore =
        getTopicScore(
      'Hardware',
    );

    final softwareScore =
        getTopicScore(
      'Software',
    );

    final osScore =
        getTopicScore(
      'Sistem Operasi',
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,

        // TIDAK ADA TOMBOL BACK
        title:
            const Text(
          'Hasil Quiz',
          style:
              TextStyle(
            fontSize: 21,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFF111827),
          ),
        ),
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          child: Column(
            children: [
              // ==================================================
              // NILAI AKHIR
              // ==================================================

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                decoration:
                    const BoxDecoration(
                  gradient:
                      LinearGradient(
                    colors: [
                      Color(
                        0xFF4F46E5,
                      ),
                      Color(
                        0xFF6366F1,
                      ),
                    ],
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.all(
                    Radius.circular(
                      22,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons
                          .emoji_events_rounded,
                      color:
                          Colors.white,
                      size: 48,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    const Text(
                      'Quiz Selesai!',
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 23,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      '$finalScore',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 52,
                        height: 1,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    const Text(
                      'Nilai Quiz',
                      style:
                          TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(alpha:
                          0.14,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                      ),
                      child:
                          Text(
                        getStatus(
                          finalScore,
                        ),
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight
                                  .bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // PENGUASAAN MATERI
              // ==================================================

              const Align(
                alignment:
                    Alignment
                        .centerLeft,
                child: Text(
                  'Penguasaan per Materi',
                  style:
                      TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight
                            .bold,
                    color:
                        Color(
                      0xFF1F2937,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              _buildResultCard(
                title:
                    'Hardware',
                score:
                    hardwareScore,
                icon: Icons
                    .memory_rounded,
              ),

              const SizedBox(
                height: 10,
              ),

              _buildResultCard(
                title:
                    'Software',
                score:
                    softwareScore,
                icon:
                    Icons.apps_rounded,
              ),

              const SizedBox(
                height: 10,
              ),

              _buildResultCard(
                title:
                    'Sistem Operasi',
                score:
                    osScore,
                icon: Icons
                    .desktop_windows_rounded,
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // KETERANGAN
              // ==================================================

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEEF2FF,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFE0E7FF,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Icon(
                      Icons
                          .info_outline_rounded,
                      color:
                          Color(
                        0xFF4F46E5,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        'Hasil quiz menunjukkan tingkat penguasaan siswa pada setiap materi. Data ini digunakan oleh Learning Analytics untuk memperbarui progress pembelajaran.',
                        style:
                            const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color:
                              Color(
                            0xFF4B5563,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // ULANGI QUIZ
              // ==================================================

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton(
                  onPressed:
                      startQuiz,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF4F46E5,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    'Ulangi Quiz',
                    style:
                        TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
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

  // ============================================================
  // RESULT CARD
  // ============================================================

  Widget _buildResultCard({
    required String title,
    required int score,
    required IconData icon,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE5E7EB,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEEF2FF,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(
                    0xFF4F46E5,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight
                            .bold,
                    color:
                        Color(
                      0xFF1F2937,
                    ),
                  ),
                ),
              ),

              Text(
                '$score%',
                style:
                    const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight
                          .bold,
                  color:
                      Color(
                    0xFF4F46E5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            child:
                LinearProgressIndicator(
              value:
                  score / 100,
              minHeight: 8,
              backgroundColor:
                  const Color(
                0xFFE5E7EB,
              ),
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                Color(
                  0xFF4F46E5,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Align(
            alignment:
                Alignment
                    .centerLeft,
            child: Text(
              getStatus(
                score,
              ),
              style:
                  const TextStyle(
                fontSize: 11,
                color:
                    Color(
                  0xFF6B7280,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}