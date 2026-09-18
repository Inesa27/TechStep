import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;

import '../services/learning_analytics_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ============================================================
  // DOWNLOAD LEARNING ANALYTICS
  // ============================================================

  Future<void> _downloadLearningAnalytics(
    BuildContext context,
  ) async {
    try {
      final analytics =
          LearningAnalyticsService.instance;

      final document = pw.Document();

      final now = DateTime.now();

      final String reportDate =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year}';

      // ========================================================
      // DATA DARI LEARNING ANALYTICS
      // ========================================================

      final int overallProgress =
          analytics.overallProgress;

      final int hardware =
          analytics.hardwareMastery;

      final int software =
          analytics.softwareMastery;

      final int sistemOperasi =
          analytics.operatingSystemMastery;

      const int completedMaterials = 0;

      final int completedQuiz =
          analytics.quizCompleted ? 1 : 0;

      final int completedLevels =
          analytics.completedChallengeLevels;

      // ========================================================
      // BUAT PDF
      // ========================================================

      document.addPage(
        pw.MultiPage(
          pageFormat:
              pdf.PdfPageFormat.a4,
          margin:
              const pw.EdgeInsets.all(36),

          header: (context) {
            return pw.Container(
              margin:
                  const pw.EdgeInsets.only(
                bottom: 15,
              ),
              child: pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,
                children: [
                  pw.Text(
                    'TechStep',
                    style:
                        pw.TextStyle(
                      fontSize: 16,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Learning Analytics',
                    style:
                        const pw.TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          },

          footer: (context) {
            return pw.Container(
              margin:
                  const pw.EdgeInsets.only(
                top: 15,
              ),
              child: pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,
                children: [
                  pw.Text(
                    'TechStep - Profil Penguasaan Kompetensi',
                    style:
                        const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                  pw.Text(
                    'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                    style:
                        const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            );
          },

          build: (context) => [
            // ==================================================
            // JUDUL
            // ==================================================

            pw.SizedBox(height: 10),

            pw.Center(
              child: pw.Text(
                'PROFIL PENGUASAAN KOMPETENSI SISWA',
                textAlign:
                    pw.TextAlign.center,
                style:
                    pw.TextStyle(
                  fontSize: 19,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 6),

            pw.Center(
              child: pw.Text(
                'Hasil Learning Analytics TechStep',
                style:
                    const pw.TextStyle(
                  fontSize: 11,
                ),
              ),
            ),

            pw.SizedBox(height: 25),

            // ==================================================
            // IDENTITAS
            // ==================================================

            pw.Text(
              'A. Identitas Siswa',
              style:
                  pw.TextStyle(
                fontSize: 14,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            _pdfInfoRow(
              'Nama',
              'Siswa TechStep',
            ),

            _pdfInfoRow(
              'Kelas',
              'X TJKT',
            ),

            _pdfInfoRow(
              'Tanggal Laporan',
              reportDate,
            ),

            pw.SizedBox(height: 20),

            // ==================================================
            // PROGRESS
            // ==================================================

            pw.Text(
              'B. Progress Pembelajaran',
              style:
                  pw.TextStyle(
                fontSize: 14,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Container(
              padding:
                  const pw.EdgeInsets.all(
                15,
              ),
              decoration:
                  pw.BoxDecoration(
                border: pw.Border.all(
                  color:
                      pdf.PdfColors.grey400,
                ),
                borderRadius:
                    const pw.BorderRadius.all(
                  pw.Radius.circular(8),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment
                        .start,
                children: [
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment
                            .spaceBetween,
                    children: [
                      pw.Text(
                        'Progress Keseluruhan',
                        style:
                            pw.TextStyle(
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '$overallProgress%',
                        style:
                            pw.TextStyle(
                          fontSize: 15,
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 8),

                  pw.Container(
                    height: 8,
                    decoration:
                        pw.BoxDecoration(
                      border:
                          pw.Border.all(
                        color: pdf
                            .PdfColors
                            .grey400,
                      ),
                      borderRadius:
                          const pw.BorderRadius.all(
                        pw.Radius.circular(
                          5,
                        ),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        if (overallProgress >
                            0)
                          pw.Expanded(
                            flex:
                                overallProgress,
                            child:
                                pw.Container(
                              decoration:
                                  const pw.BoxDecoration(
                                borderRadius:
                                    pw.BorderRadius.all(
                                  pw.Radius.circular(
                                    5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (overallProgress <
                            100)
                          pw.Expanded(
                            flex:
                                100 -
                                    overallProgress,
                            child:
                                pw.Container(),
                          ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text(
                    'Status: ${analytics.learningStatus}',
                    style:
                        const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ==================================================
            // PENGUASAAN
            // ==================================================

            pw.Text(
              'C. Penguasaan Kompetensi',
              style:
                  pw.TextStyle(
                fontSize: 14,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Table(
              border:
                  pw.TableBorder.all(
                color:
                    pdf.PdfColors.grey400,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(
                    2.5),
                1: const pw.FlexColumnWidth(
                    1),
                2: const pw.FlexColumnWidth(
                    2),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(
                    color:
                        pdf.PdfColors.grey200,
                  ),
                  children: [
                    _pdfTableCell(
                      'Materi',
                      bold: true,
                    ),
                    _pdfTableCell(
                      'Nilai',
                      bold: true,
                      center: true,
                    ),
                    _pdfTableCell(
                      'Status',
                      bold: true,
                      center: true,
                    ),
                  ],
                ),

                _pdfCompetencyRow(
                  'Hardware',
                  hardware,
                ),

                _pdfCompetencyRow(
                  'Software',
                  software,
                ),

                _pdfCompetencyRow(
                  'Sistem Operasi',
                  sistemOperasi,
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ==================================================
            // AKTIVITAS
            // ==================================================

            pw.Text(
              'D. Aktivitas Pembelajaran',
              style:
                  pw.TextStyle(
                fontSize: 14,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Table(
              border:
                  pw.TableBorder.all(
                color:
                    pdf.PdfColors.grey400,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(
                    2.5),
                1: const pw.FlexColumnWidth(
                    1),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(
                    color:
                        pdf.PdfColors.grey200,
                  ),
                  children: [
                    _pdfTableCell(
                      'Aktivitas',
                      bold: true,
                    ),
                    _pdfTableCell(
                      'Jumlah',
                      bold: true,
                      center: true,
                    ),
                  ],
                ),

                _pdfActivityRow(
                  'Materi selesai',
                  completedMaterials,
                ),

                _pdfActivityRow(
                  'Quiz selesai',
                  completedQuiz,
                ),

                _pdfActivityRow(
                  'Level Challenge selesai',
                  completedLevels,
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ==================================================
            // TINDAK LANJUT
            // ==================================================

            pw.Text(
              'E. Tindak Lanjut Pembelajaran',
              style:
                  pw.TextStyle(
                fontSize: 14,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Container(
              width: double.infinity,
              padding:
                  const pw.EdgeInsets.all(
                15,
              ),
              decoration:
                  pw.BoxDecoration(
                border: pw.Border.all(
                  color:
                      pdf.PdfColors.grey400,
                ),
                borderRadius:
                    const pw.BorderRadius.all(
                  pw.Radius.circular(8),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment
                        .start,
                children: [
                  _pdfBullet(
                    _getRecommendation(
                      'Hardware',
                      hardware,
                    ),
                  ),

                  _pdfBullet(
                    _getRecommendation(
                      'Software',
                      software,
                    ),
                  ),

                  _pdfBullet(
                    _getRecommendation(
                      'Sistem Operasi',
                      sistemOperasi,
                    ),
                  ),

                  _pdfBullet(
                    analytics.quizCompleted
                        ? 'Hasil Quiz sudah tersedia dan dapat digunakan sebagai dasar pemetaan penguasaan kompetensi.'
                        : 'Kerjakan Quiz untuk memperoleh data penguasaan kompetensi.',
                  ),

                  _pdfBullet(
                    completedLevels > 0
                        ? 'Computer Challenge sudah dimainkan. Lanjutkan level berikutnya untuk memperdalam penerapan konsep.'
                        : 'Selesaikan Computer Challenge untuk menguji penerapan konsep sistem komputer.',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ==================================================
            // CATATAN
            // ==================================================

            pw.Container(
              padding:
                  const pw.EdgeInsets.all(
                12,
              ),
              decoration:
                  pw.BoxDecoration(
                border: pw.Border.all(
                  color:
                      pdf.PdfColors.grey400,
                ),
                borderRadius:
                    const pw.BorderRadius.all(
                  pw.Radius.circular(8),
                ),
              ),
              child: pw.Text(
                'Catatan: Laporan ini dihasilkan berdasarkan data Learning Analytics TechStep. '
                'Nilai dan status penguasaan diperbarui berdasarkan aktivitas pembelajaran yang tersimpan selama aplikasi berjalan.',
                style:
                    const pw.TextStyle(
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      );

      // ========================================================
      // SIMPAN PDF
      // ========================================================

      final bytes =
          await document.save();

      await FileSaver.instance.saveAs(
        name:
            'hasil_learning_analytics_techstep',
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Hasil Learning Analytics berhasil diunduh.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membuat PDF: $e',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // REKOMENDASI
  // ============================================================

  String _getRecommendation(
    String topic,
    int score,
  ) {
    if (score >= 80) {
      return '$topic sudah menunjukkan penguasaan yang baik. Pertahankan pemahaman dan lanjutkan ke penerapan konsep.';
    }

    if (score >= 60) {
      return '$topic cukup dikuasai. Perbanyak latihan dan pelajari kembali konsep yang masih belum konsisten.';
    }

    if (score > 0) {
      return '$topic masih perlu diperkuat. Pelajari kembali materi dan kerjakan evaluasi ulang.';
    }

    return 'Pelajari materi $topic terlebih dahulu sebelum melakukan evaluasi lanjutan.';
  }

  // ============================================================
  // PDF INFO ROW
  // ============================================================

  pw.Widget _pdfInfoRow(
    String label,
    String value,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.only(
        bottom: 6,
      ),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style:
                  pw.TextStyle(
                fontWeight:
                    pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          pw.Text(
            ': $value',
            style:
                const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PDF TABLE CELL
  // ============================================================

  pw.Widget _pdfTableCell(
    String text, {
    bool bold = false,
    bool center = false,
  }) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.all(8),
      alignment: center
          ? pw.Alignment.center
          : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        textAlign: center
            ? pw.TextAlign.center
            : pw.TextAlign.left,
        style:
            pw.TextStyle(
          fontSize: 9,
          fontWeight: bold
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ============================================================
  // PDF COMPETENCY ROW
  // ============================================================

  pw.TableRow _pdfCompetencyRow(
    String title,
    int score,
  ) {
    final status =
        score >= 80
            ? 'Sangat Baik'
            : score >= 60
                ? 'Baik'
                : score >= 40
                    ? 'Cukup'
                    : 'Perlu Penguatan';

    return pw.TableRow(
      children: [
        _pdfTableCell(title),

        _pdfTableCell(
          '$score%',
          center: true,
        ),

        _pdfTableCell(
          status,
          center: true,
        ),
      ],
    );
  }

  // ============================================================
  // PDF ACTIVITY ROW
  // ============================================================

  pw.TableRow _pdfActivityRow(
    String title,
    int value,
  ) {
    return pw.TableRow(
      children: [
        _pdfTableCell(title),

        _pdfTableCell(
          '$value',
          center: true,
        ),
      ],
    );
  }

  // ============================================================
  // PDF BULLET
  // ============================================================

  pw.Widget _pdfBullet(
    String text,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.only(
        bottom: 7,
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment
                .start,
        children: [
          pw.Text(
            '• ',
            style:
                pw.TextStyle(
              fontSize: 10,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),

          pw.Expanded(
            child: pw.Text(
              text,
              style:
                  const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD PROFILE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final analytics =
        LearningAnalyticsService.instance;

    return AnimatedBuilder(
      animation: analytics,
      builder: (context, child) {
        return Scaffold(
          backgroundColor:
              const Color(0xFFF6F7FB),

          appBar: AppBar(
            backgroundColor:
                Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,

            title: const Text(
              'Profil',
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==============================================
                  // HEADER PROFIL
                  // ==============================================

                  _buildProfileHeader(),

                  const SizedBox(height: 24),

                  // ==============================================
                  // RINGKASAN
                  // ==============================================

                  const Text(
                    'Ringkasan Pembelajaran',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildSummaryCard(
                    analytics,
                  ),

                  const SizedBox(height: 24),

                  // ==============================================
                  // KOMPETENSI
                  // ==============================================

                  const Text(
                    'Penguasaan Kompetensi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Ringkasan penguasaan berdasarkan hasil Quiz dan Computer Challenge.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color:
                          Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildCompetencyCard(
                    title: 'Hardware',
                    percentage:
                        analytics.hardwareMastery,
                    icon:
                        Icons.memory_rounded,
                  ),

                  const SizedBox(height: 12),

                  _buildCompetencyCard(
                    title: 'Software',
                    percentage:
                        analytics.softwareMastery,
                    icon:
                        Icons.apps_rounded,
                  ),

                  const SizedBox(height: 12),

                  _buildCompetencyCard(
                    title:
                        'Sistem Operasi',
                    percentage:
                        analytics
                            .operatingSystemMastery,
                    icon: Icons
                        .desktop_windows_rounded,
                  ),

                  const SizedBox(height: 24),

                  // ==============================================
                  // STATUS
                  // ==============================================

                  const Text(
                    'Status Pembelajaran',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildLearningStatus(
                    analytics,
                  ),

                  const SizedBox(height: 24),

                  // ==============================================
                  // DOWNLOAD REPORT
                  // ==============================================

                  _buildReportCard(
                    context,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withValues(alpha:0.16),
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color:
                  Colors.white,
              size: 35,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Siswa TechStep',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Kelas X TJKT',
                  style:
                      TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Profil Pembelajaran',
                  style:
                      TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 12,
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
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(
    LearningAnalyticsService analytics,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              icon:
                  Icons.menu_book_rounded,
              value: '0',
              label:
                  'Materi selesai',
            ),
          ),

          Expanded(
            child: _buildSummaryItem(
              icon:
                  Icons.quiz_rounded,
              value:
                  analytics.quizCompleted
                      ? '1'
                      : '0',
              label:
                  'Quiz selesai',
            ),
          ),

          Expanded(
            child: _buildSummaryItem(
              icon: Icons
                  .sports_esports_rounded,
              value:
                  '${analytics.completedChallengeLevels}',
              label:
                  'Level selesai',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration:
              BoxDecoration(
            color:
                const Color(0xFFEEF2FF),
            borderRadius:
                BorderRadius.circular(
              13,
            ),
          ),
          child: Icon(
            icon,
            color:
                const Color(0xFF4F46E5),
            size: 22,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          value,
          style:
              const TextStyle(
            fontSize: 19,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            fontSize: 10,
            color:
                Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COMPETENCY CARD
  // ============================================================

  Widget _buildCompetencyCard({
    required String title,
    required int percentage,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFFEEF2FF),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(0xFF4F46E5),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF1F2937),
                  ),
                ),
              ),

              Text(
                '$percentage%',
                style:
                    const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF4F46E5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            child:
                LinearProgressIndicator(
              value:
                  percentage / 100,
              minHeight: 8,
              backgroundColor:
                  const Color(0xFFE5E7EB),
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                Color(0xFF4F46E5),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              percentage == 0
                  ? 'Belum ada hasil evaluasi'
                  : LearningAnalyticsService
                      .instance
                      .competencyStatus(
                    percentage,
                  ),
              style:
                  const TextStyle(
                fontSize: 11,
                color:
                    Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS PEMBELAJARAN
  // ============================================================

  Widget _buildLearningStatus(
    LearningAnalyticsService analytics,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFEEF2FF),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: const Icon(
              Icons.flag_outlined,
              color:
                  Color(0xFF4F46E5),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  analytics.learningStatus,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Progress pembelajaran saat ini ${analytics.overallProgress}%. '
                  'Quiz: ${analytics.quizCompleted ? "sudah dikerjakan" : "belum dikerjakan"}. '
                  'Challenge: ${analytics.completedChallengeLevels}/5 level.',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color:
                        Color(0xFF6B7280),
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
  // REPORT CARD
  // ============================================================

  Widget _buildReportCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          const BoxDecoration(
        color:
            Color(0xFF111827),
        borderRadius:
            BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(alpha:
                    0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                    const Icon(
                  Icons.analytics_rounded,
                  color:
                      Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Learning Analytics',
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Unduh profil penguasaan kompetensi dalam format PDF.',
                      style:
                          TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child:
                ElevatedButton.icon(
              onPressed: () {
                _downloadLearningAnalytics(
                  context,
                );
              },
              icon:
                  const Icon(
                Icons.download_rounded,
                size: 20,
              ),
              label:
                  const Text(
                'Unduh Hasil Learning Analytics',
                style:
                    TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white,
                foregroundColor:
                    const Color(
                  0xFF111827,
                ),
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}