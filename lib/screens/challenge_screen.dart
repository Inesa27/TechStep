import 'package:flutter/material.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  // ============================================================
  // STATE
  // ============================================================

  int selectedLevel = -1;
  int currentBox = 0;

  // Menyimpan level yang sudah selesai
  final List<bool> completedLevels = [
    false,
    false,
    false,
    false,
    false,
  ];

  // Menyimpan status 5 kotak pada level yang sedang dimainkan
  final List<bool> completedBoxes = [
    false,
    false,
    false,
    false,
    false,
  ];

  // Menyimpan status salah pada kotak yang sedang dimainkan
  final List<bool> wrongBoxes = [
    false,
    false,
    false,
    false,
    false,
  ];

  // ============================================================
  // DATA SOAL
  // 5 LEVEL x 5 SOAL = 25 SOAL
  // ============================================================

  final List<List<Map<String, dynamic>>> levelQuestions = [
    // ==========================================================
    // LEVEL 1 - BEGINNER
    // ==========================================================

    [
      {
        'topic': 'Hardware',
        'question':
            'Komponen komputer yang berfungsi sebagai pusat pemrosesan data adalah...',
        'options': [
          'CPU',
          'Monitor',
          'Keyboard',
          'Speaker',
        ],
        'answer': 'CPU',
      },
      {
        'topic': 'Software',
        'question':
            'Manakah yang merupakan contoh software pengolah kata?',
        'options': [
          'Microsoft Word',
          'RAM',
          'Processor',
          'Motherboard',
        ],
        'answer': 'Microsoft Word',
      },
      {
        'topic': 'Sistem Operasi',
        'question':
            'Manakah yang termasuk sistem operasi?',
        'options': [
          'Windows',
          'Google Chrome',
          'Canva',
          'Microsoft Word',
        ],
        'answer': 'Windows',
      },
      {
        'topic': 'Hardware',
        'question':
            'Perangkat yang digunakan untuk memasukkan teks ke komputer adalah...',
        'options': [
          'Keyboard',
          'Monitor',
          'Speaker',
          'Projector',
        ],
        'answer': 'Keyboard',
      },
      {
        'topic': 'Software',
        'question':
            'Software yang digunakan untuk menjelajah internet adalah...',
        'options': [
          'Web browser',
          'Processor',
          'RAM',
          'Motherboard',
        ],
        'answer': 'Web browser',
      },
    ],

    // ==========================================================
    // LEVEL 2 - INTERMEDIATE
    // ==========================================================

    [
      {
        'topic': 'Hardware',
        'question':
            'Jika komputer membutuhkan tempat penyimpanan data permanen, komponen yang paling sesuai adalah...',
        'options': [
          'SSD',
          'RAM',
          'CPU',
          'Keyboard',
        ],
        'answer': 'SSD',
      },
      {
        'topic': 'Software',
        'question':
            'Seorang siswa ingin membuat tabel dan melakukan perhitungan sederhana. Software yang paling sesuai adalah...',
        'options': [
          'Microsoft Excel',
          'Google Chrome',
          'VLC Media Player',
          'Paint',
        ],
        'answer': 'Microsoft Excel',
      },
      {
        'topic': 'Sistem Operasi',
        'question':
            'Salah satu fungsi utama sistem operasi adalah...',
        'options': [
          'Mengatur sumber daya komputer',
          'Mengganti processor',
          'Mencetak tanpa printer',
          'Membuat listrik',
        ],
        'answer': 'Mengatur sumber daya komputer',
      },
      {
        'topic': 'Hardware',
        'question':
            'Jika pengguna ingin memasukkan dokumen fisik ke komputer dalam bentuk digital, perangkat yang digunakan adalah...',
        'options': [
          'Scanner',
          'Speaker',
          'Monitor',
          'Projector',
        ],
        'answer': 'Scanner',
      },
      {
        'topic': 'Sistem Operasi',
        'question':
            'Sistem operasi membantu pengguna berinteraksi dengan komputer melalui...',
        'options': [
          'User Interface',
          'Power Supply',
          'RAM',
          'Hard Disk',
        ],
        'answer': 'User Interface',
      },
    ],

    // ==========================================================
    // LEVEL 3 - ADVANCED
    // ==========================================================

    [
      {
        'topic': 'Hardware',
        'question':
            'Sebuah komputer terasa lambat ketika menjalankan banyak aplikasi sekaligus. Komponen yang berkaitan dengan kondisi tersebut adalah...',
        'options': [
          'RAM',
          'Monitor',
          'Keyboard',
          'Printer',
        ],
        'answer': 'RAM',
      },
      {
        'topic': 'Software',
        'question':
            'Seorang siswa ingin melindungi komputer dari malware. Software yang tepat adalah...',
        'options': [
          'Antivirus',
          'Calculator',
          'Text Editor',
          'Media Player',
        ],
        'answer': 'Antivirus',
      },
      {
        'topic': 'Sistem Operasi',
        'question':
            'Ketika beberapa program berjalan secara bersamaan, sistem operasi bertugas mengatur penggunaan...',
        'options': [
          'Sumber daya komputer',
          'Kabel listrik',
          'Ukuran monitor',
          'Bentuk keyboard',
        ],
        'answer': 'Sumber daya komputer',
      },
      {
        'topic': 'Hardware + Software',
        'question':
            'Untuk membuat desain grafis, seorang siswa membutuhkan komputer dan aplikasi desain. Kombinasi tersebut menunjukkan penggunaan...',
        'options': [
          'Hardware dan software',
          'Software saja',
          'Hardware saja',
          'Sistem operasi saja',
        ],
        'answer': 'Hardware dan software',
      },
      {
        'topic': 'Software + Sistem Operasi',
        'question':
            'Sebuah aplikasi dapat berjalan di komputer karena sistem operasi menyediakan lingkungan untuk...',
        'options': [
          'Menjalankan dan mengelola aplikasi',
          'Mengganti monitor',
          'Membuat hardware baru',
          'Menghasilkan listrik',
        ],
        'answer': 'Menjalankan dan mengelola aplikasi',
      },
    ],

    // ==========================================================
    // LEVEL 4 - EXPERT
    // ==========================================================

    [
      {
        'topic': 'Hardware',
        'question':
            'Sebuah komputer digunakan untuk mengedit video. Agar proses pengolahan grafis lebih baik, salah satu komponen yang perlu diperhatikan adalah...',
        'options': [
          'GPU',
          'Keyboard',
          'Mouse Pad',
          'Speaker',
        ],
        'answer': 'GPU',
      },
      {
        'topic': 'Software',
        'question':
            'Seorang siswa menemukan program asing yang terus berjalan dan menggunakan sumber daya komputer. Hal pertama yang perlu diperiksa adalah...',
        'options': [
          'Program atau proses yang sedang berjalan',
          'Ukuran monitor',
          'Warna keyboard',
          'Kabel speaker',
        ],
        'answer': 'Program atau proses yang sedang berjalan',
      },
      {
        'topic': 'Sistem Operasi',
        'question':
            'Jika sistem operasi tidak dapat mengelola file dengan baik, pengguna akan mengalami masalah pada...',
        'options': [
          'Penyimpanan dan pengelolaan file',
          'Warna layar',
          'Bentuk keyboard',
          'Ukuran CPU',
        ],
        'answer': 'Penyimpanan dan pengelolaan file',
      },
      {
        'topic': 'Hardware + Sistem Operasi',
        'question':
            'Ketika sebuah perangkat baru dipasang ke komputer, sistem operasi perlu mengenali perangkat tersebut agar dapat digunakan. Hal ini berkaitan dengan...',
        'options': [
          'Driver perangkat',
          'Microsoft Word',
          'Monitor',
          'Keyboard',
        ],
        'answer': 'Driver perangkat',
      },
      {
        'topic': 'Software + Sistem Operasi',
        'question':
            'Sebuah aplikasi tidak dapat berjalan karena sistem operasi tidak mendukung kebutuhan aplikasi tersebut. Masalah ini menunjukkan adanya hubungan antara...',
        'options': [
          'Software dan sistem operasi',
          'Keyboard dan speaker',
          'Monitor dan mouse',
          'Printer dan scanner',
        ],
        'answer': 'Software dan sistem operasi',
      },
    ],

    // ==========================================================
    // LEVEL 5 - CHALLENGE
    // ==========================================================

    [
      {
        'topic': 'Hardware + Software + Sistem Operasi',
        'question':
            'Seorang siswa ingin membuat dokumen menggunakan komputer. Agar pekerjaan dapat dilakukan, kombinasi yang tepat adalah...',
        'options': [
          'Hardware, software, dan sistem operasi',
          'Hardware saja',
          'Software saja',
          'Sistem operasi saja',
        ],
        'answer': 'Hardware, software, dan sistem operasi',
      },
      {
        'topic': 'Hardware + Sistem Operasi',
        'question':
            'Saat komputer dinyalakan, sistem operasi mengatur penggunaan RAM dan processor agar program dapat berjalan. Hal ini menunjukkan fungsi sistem operasi dalam...',
        'options': [
          'Mengelola sumber daya hardware',
          'Membuat aplikasi',
          'Mengedit gambar',
          'Mencetak dokumen',
        ],
        'answer': 'Mengelola sumber daya hardware',
      },
      {
        'topic': 'Software + Hardware',
        'question':
            'Aplikasi pengolah video menggunakan processor, RAM, dan media penyimpanan selama proses editing. Kondisi ini menunjukkan bahwa software...',
        'options': [
          'Menggunakan sumber daya hardware',
          'Tidak membutuhkan hardware',
          'Merupakan hardware',
          'Menggantikan sistem operasi',
        ],
        'answer': 'Menggunakan sumber daya hardware',
      },
      {
        'topic': 'Sistem Operasi + Software',
        'question':
            'Pengguna membuka aplikasi melalui antarmuka sistem operasi. Dalam kondisi ini sistem operasi berperan sebagai...',
        'options': [
          'Penghubung antara pengguna dan aplikasi',
          'Perangkat input',
          'Media penyimpanan',
          'Processor',
        ],
        'answer': 'Penghubung antara pengguna dan aplikasi',
      },
      {
        'topic': 'Hardware + Software + Sistem Operasi',
        'question':
            'Sebuah komputer dapat digunakan untuk belajar ketika hardware tersedia, sistem operasi berjalan, dan aplikasi pembelajaran dapat dijalankan. Kesimpulan yang tepat adalah...',
        'options': [
          'Ketiganya saling berkaitan dalam sistem komputer',
          'Hardware dapat bekerja tanpa software',
          'Software tidak membutuhkan sistem operasi',
          'Sistem operasi merupakan perangkat keras',
        ],
        'answer':
            'Ketiganya saling berkaitan dalam sistem komputer',
      },
    ],
  ];

  // ============================================================
  // NAMA LEVEL
  // ============================================================

  final List<String> levelNames = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
    'Challenge',
  ];

  final List<String> levelDescriptions = [
    'Mengenali konsep dasar sistem komputer',
    'Memahami hubungan antar konsep',
    'Menerapkan konsep dalam situasi sederhana',
    'Menganalisis masalah sistem komputer',
    'Mengintegrasikan Hardware, Software, dan Sistem Operasi',
  ];

  final List<Color> levelColors = [
    const Color(0xFF4F46E5),
    const Color(0xFF6366F1),
    const Color(0xFF7C3AED),
    const Color(0xFF8B5CF6),
    const Color(0xFF312E81),
  ];

  // ============================================================
  // CEK LEVEL TERBUKA
  // ============================================================

  bool isLevelUnlocked(int level) {
    if (level == 0) {
      return true;
    }

    return completedLevels[level - 1];
  }

  // ============================================================
  // BUKA LEVEL
  // ============================================================

  void openLevel(int level) {
    if (!isLevelUnlocked(level)) {
      return;
    }

    setState(() {
      selectedLevel = level;
      currentBox = 0;

      // Reset status kotak ketika level dimulai kembali
      for (int i = 0; i < 5; i++) {
        completedBoxes[i] = false;
        wrongBoxes[i] = false;
      }
    });
  }

  // ============================================================
  // KELUAR DARI LEVEL
  // ============================================================

  void exitLevel() {
    setState(() {
      selectedLevel = -1;
      currentBox = 0;
    });
  }

  // ============================================================
  // JAWAB SOAL
  // ============================================================

  void answerQuestion(String selectedAnswer) {
    final question =
        levelQuestions[selectedLevel][currentBox];

    final String correctAnswer =
        question['answer'].toString();

    // ==========================================================
    // JAWABAN BENAR
    // ==========================================================

    if (selectedAnswer == correctAnswer) {
      setState(() {
        completedBoxes[currentBox] = true;
        wrongBoxes[currentBox] = false;
      });

      _showCorrectAnswerDialog();
    }

    // ==========================================================
    // JAWABAN SALAH
    // ==========================================================

    else {
      setState(() {
        wrongBoxes[currentBox] = true;
      });

      _showWrongAnswerDialog();
    }
  }

  // ============================================================
  // DIALOG JAWABAN BENAR
  // ============================================================

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Jawaban Benar! 🎉',
          ),
          content: const Text(
            'Bagus! Kotak ini sudah selesai. Kamu bisa lanjut ke kotak berikutnya.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _moveToNextBox();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Lanjut'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DIALOG JAWABAN SALAH
  // ============================================================

  void _showWrongAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Jawaban Salah',
          ),
          content: const Text(
            'Jawaban kamu belum tepat. Kotak ini tetap merah. Coba lagi sampai jawabanmu benar.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PINDAH KE KOTAK BERIKUTNYA
  // ============================================================

  void _moveToNextBox() {
    final isLastBox =
        currentBox ==
        levelQuestions[selectedLevel].length - 1;

    // ==========================================================
    // JIKA KOTAK TERAKHIR
    // ==========================================================

    if (isLastBox) {
      setState(() {
        completedLevels[selectedLevel] = true;
      });

      _showLevelComplete();
    }

    // ==========================================================
    // MASIH ADA KOTAK BERIKUTNYA
    // ==========================================================

    else {
      setState(() {
        currentBox++;
      });
    }
  }

  // ============================================================
  // LEVEL SELESAI
  // ============================================================

  void _showLevelComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final bool lastLevel =
            selectedLevel == levelNames.length - 1;

        return AlertDialog(
          title: const Text(
            'Level Selesai! 🎉',
          ),
          content: Text(
            lastLevel
                ? 'Selamat! Kamu telah menyelesaikan semua level Computer Challenge.'
                : 'Kamu telah menyelesaikan ${levelNames[selectedLevel]}.\n\nLevel berikutnya sekarang sudah terbuka.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                exitLevel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kembali'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (selectedLevel != -1) {
      return _buildLevelPage();
    }

    return _buildChallengeHome();
  }

  // ============================================================
  // HALAMAN UTAMA CHALLENGE
  // ============================================================

  Widget _buildChallengeHome() {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Computer Challenge',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildChallengeHeader(),

              const SizedBox(height: 24),

              const Text(
                'Pilih Level',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Selesaikan setiap papan engklek untuk membuka level berikutnya.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 16),

              ...List.generate(
                levelNames.length,
                (index) => _buildLevelCard(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER CHALLENGE
  // ============================================================

  Widget _buildChallengeHeader() {
    final completedCount =
        completedLevels.where(
          (item) => item,
        ).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF111827),
            Color(0xFF312E81),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(15),
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
            'Lewati setiap langkah engklek dan uji pemahamanmu tentang sistem komputer.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '$completedCount dari 5 level selesai',
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

  // ============================================================
  // LEVEL CARD
  // ============================================================

  Widget _buildLevelCard(int index) {
    final bool unlocked =
        isLevelUnlocked(index);

    final bool completed =
        completedLevels[index];

    return InkWell(
      onTap: unlocked
          ? () {
              openLevel(index);
            }
          : null,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        margin:
            const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: unlocked
              ? Colors.white
              : const Color(0xFFE5E7EB),
          borderRadius:
              BorderRadius.circular(18),
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
                    ? levelColors[index]
                    : const Color(0xFFD1D5DB),
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Icon(
                completed
                    ? Icons.check_rounded
                    : unlocked
                        ? Icons
                            .sports_esports_rounded
                        : Icons.lock_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${index + 1} • ${levelNames[index]}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      color: unlocked
                          ? const Color(
                              0xFF1F2937,
                            )
                          : const Color(
                              0xFF9CA3AF,
                            ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    levelDescriptions[index],
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: unlocked
                          ? const Color(
                              0xFF6B7280,
                            )
                          : const Color(
                              0xFF9CA3AF,
                            ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '5 kotak • 5 tantangan',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                      color: unlocked
                          ? const Color(
                              0xFF4F46E5,
                            )
                          : const Color(
                              0xFF9CA3AF,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              completed
                  ? Icons
                      .check_circle_rounded
                  : unlocked
                      ? Icons
                          .arrow_forward_ios_rounded
                      : Icons
                          .lock_outline_rounded,
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

  // ============================================================
  // HALAMAN LEVEL
  // ============================================================

  Widget _buildLevelPage() {
    final question =
        levelQuestions[selectedLevel][currentBox];

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF111827),
          ),
          onPressed: () {
            exitLevel();
          },
        ),

        title: Text(
          'Level ${selectedLevel + 1}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
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
            children: [
              _buildLevelTitle(),

              const SizedBox(height: 20),

              _buildHopscotchMap(),

              const SizedBox(height: 24),

              _buildCurrentQuestion(
                question,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // JUDUL LEVEL
  // ============================================================

  Widget _buildLevelTitle() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            levelColors[selectedLevel],
            levelColors[selectedLevel]
                .withOpacity(0.75),
          ],
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Level ${selectedLevel + 1}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            levelNames[selectedLevel],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            levelDescriptions[selectedLevel],
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

  // ============================================================
  // PAPAN ENGKLEK
  //
  //             [ 5 ]
  //
  //       [ 3 ]   [ 4 ]
  //
  //             [ 2 ]
  //
  //             [ 1 ]
  //
  // ============================================================

  Widget _buildHopscotchMap() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
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

          // -----------------------------
          // KOTAK 5
          // -----------------------------

          _buildHopscotchBox(4),

          const SizedBox(height: 8),

          // -----------------------------
          // KOTAK 3 & 4
          // -----------------------------

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              _buildHopscotchBox(2),

              const SizedBox(width: 8),

              _buildHopscotchBox(3),
            ],
          ),

          const SizedBox(height: 8),

          // -----------------------------
          // KOTAK 2
          // -----------------------------

          _buildHopscotchBox(1),

          const SizedBox(height: 8),

          // -----------------------------
          // KOTAK 1
          // -----------------------------

          _buildHopscotchBox(0),
        ],
      ),
    );
  }

  // ============================================================
  // KOTAK ENGKLEK
  // ============================================================

  Widget _buildHopscotchBox(
    int boxIndex,
  ) {
    final bool active =
        boxIndex == currentBox;

    final bool completed =
        completedBoxes[boxIndex];

    final bool wrong =
        wrongBoxes[boxIndex];

    late Color backgroundColor;
    late Color borderColor;
    late Color textColor;
    late IconData icon;

    // ==========================================================
    // SUDAH BENAR
    // ==========================================================

    if (completed) {
      backgroundColor =
          const Color(0xFFDCFCE7);

      borderColor =
          const Color(0xFF22C55E);

      textColor =
          const Color(0xFF166534);

      icon =
          Icons.check_circle_rounded;
    }

    // ==========================================================
    // SALAH
    // ==========================================================

    else if (wrong) {
      backgroundColor =
          const Color(0xFFFEE2E2);

      borderColor =
          const Color(0xFFDC2626);

      textColor =
          const Color(0xFFB91C1C);

      icon = Icons.close_rounded;
    }

    // ==========================================================
    // KOTAK AKTIF
    // ==========================================================

    else if (active) {
      backgroundColor =
          levelColors[selectedLevel];

      borderColor =
          levelColors[selectedLevel];

      textColor = Colors.white;

      icon =
          Icons.location_on_rounded;
    }

    // ==========================================================
    // KOTAK BELUM DIMAINKAN
    // ==========================================================

    else {
      backgroundColor =
          const Color(0xFFF3F4F6);

      borderColor =
          const Color(0xFFD1D5DB);

      textColor =
          const Color(0xFF9CA3AF);

      icon =
          Icons.circle_outlined;
    }

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 200),
      width: 130,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width:
              active || wrong || completed
                  ? 2
                  : 1,
        ),
        boxShadow:
            active && !wrong && !completed
                ? [
                    BoxShadow(
                      color:
                          levelColors[
                                  selectedLevel]
                              .withOpacity(
                        0.20,
                      ),
                      blurRadius: 10,
                      offset:
                          const Offset(0, 4),
                    ),
                  ]
                : null,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 21,
          ),

          const SizedBox(width: 8),

          Text(
            'Kotak ${boxIndex + 1}',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERTANYAAN
  // ============================================================

  Widget _buildCurrentQuestion(
    Map<String, dynamic> question,
  ) {
    final List<String> options =
        List<String>.from(
      question['options'],
    );

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEEF2FF),
                  borderRadius:
                      BorderRadius.circular(9),
                ),
                child: Text(
                  question['topic']
                      .toString(),
                  style:
                      const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF4F46E5),
                  ),
                ),
              ),

              const Spacer(),

              Text(
                'Kotak ${currentBox + 1}/5',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            question['question']
                .toString(),
            style: const TextStyle(
              fontSize: 19,
              height: 1.4,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 22),

          ...options.map(
            (option) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child:
                  _buildAnswerButton(
                option,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PILIHAN JAWABAN
  // ============================================================

  Widget _buildAnswerButton(
    String option,
  ) {
    return InkWell(
      onTap: () {
        answerQuestion(option);
      },
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              const Color(0xFFF9FAFB),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color:
                const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment:
                  Alignment.center,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .arrow_forward_rounded,
                color:
                    Color(0xFF4F46E5),
                size: 17,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                option,
                style:
                    const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight:
                      FontWeight.w500,
                  color:
                      Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}