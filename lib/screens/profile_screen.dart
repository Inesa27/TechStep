
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../services/learning_analytics_service.dart';
import '../services/techstep_database.dart';
import '../theme/techstep_theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? user;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    this.user,
    required this.onLogout,
  });

  // ============================================================
  // DATA SISWA
  // ============================================================

  String get _studentName {
    final value = user?['name']?.toString().trim();
    return value == null || value.isEmpty
        ? 'Siswa TechStep'
        : value;
  }

  String get _studentNis {
    final value = user?['nis']?.toString().trim();
    return value == null || value.isEmpty ? '-' : value;
  }

  String get _studentClass {
    final value = user?['class_name']?.toString().trim();
    return value == null || value.isEmpty
        ? 'X TJKT'
        : value;
  }

  // ============================================================
  // WARNA AKSEN
  // ============================================================

  static const Color _primary = Color(0xFF5547E8);
  static const Color _success = Color(0xFF159A78);
  static const Color _warning = Color(0xFFE59A32);

  // ============================================================
  // MEMBUAT LAPORAN LEARNING ANALYTICS PDF
  // ============================================================

  Future<Uint8List> _buildLearningAnalyticsPdf() async {
    final analytics = LearningAnalyticsService.instance;
    await analytics.refresh();
    final database = TechStepDatabase.instance;
    final materials = await database.getMaterialsWithProgress();
    final challengeLevels = await database.getChallengeLevels();
    final activities = await database.getActivities(limit: 8);
    final document = pw.Document();
    final now = DateTime.now();

    final reportDate =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year} ${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    final overallProgress = analytics.overallProgress.clamp(0, 100);
    final quizScores = <String, int>{
      'hardware': analytics.hardwareQuizScore,
      'software': analytics.softwareQuizScore,
      'sistem_operasi': analytics.operatingSystemQuizScore,
    };
    final completedQuizIds = analytics.completedQuizMaterialIds;
    final completedLevelCount =
        challengeLevels.where((level) => level.completed).length;
    final studentName = user?['name']?.toString().trim();
    final studentNis = user?['nis']?.toString().trim();
    final studentClass = user?['class_name']?.toString().trim();

    document.addPage(
      pw.MultiPage(
        pageFormat: pdf.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 44, 42, 42),

        header: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 18),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TechStep',
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'LAPORAN PEMBELAJARAN',
                  style: const pw.TextStyle(
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          );
        },

        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 14),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TechStep - Learning Report',
                  style: const pw.TextStyle(
                    fontSize: 9,
                  ),
                ),
                pw.Text(
                  'Halaman ${context.pageNumber} '
                  'dari ${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          );
        },

        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Laporan Perkembangan Belajar',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 21,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 5),

          pw.Center(
            child: pw.Text(
              'Learning Analytics TechStep - Dibuat $reportDate',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),

          pw.SizedBox(height: 20),

          _pdfSectionTitle('1. Identitas Siswa'),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: _pdfBoxDecoration(),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _pdfInfoRow('Nama', _reportValue(studentName)),
                _pdfInfoRow('NIS / Username', _reportValue(studentNis)),
                _pdfInfoRow('Kelas', _reportValue(studentClass)),
              ],
            ),
          ),

          pw.SizedBox(height: 18),

          _pdfSectionTitle('2. Ringkasan Progres'),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: _pdfBoxDecoration(),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Progres keseluruhan',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '$overallProgress%',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: pdf.PdfColors.deepPurple,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.ClipRRect(
                  horizontalRadius: 4,
                  verticalRadius: 4,
                  child: pw.LinearProgressIndicator(
                    value: overallProgress / 100,
                    backgroundColor: pdf.PdfColors.grey300,
                    valueColor: pdf.PdfColors.deepPurple,
                    minHeight: 8,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Status: ${analytics.learningStatus}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Materi: ${analytics.completedMaterials}/'
                  '${analytics.totalMaterials} submateri selesai'
                  '    |    Quiz: ${completedQuizIds.length}/'
                  '${LearningAnalyticsService.totalQuizMaterials} materi'
                  '    |    Challenge: $completedLevelCount/'
                  '${challengeLevels.length} level',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 18),

          _pdfSectionTitle('3. Penguasaan Materi'),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: pdf.PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.2),
              1: const pw.FlexColumnWidth(1.3),
              2: const pw.FlexColumnWidth(1.1),
              3: const pw.FlexColumnWidth(1.7),
            },
            children: [
              _pdfTableHeader(['Materi', 'Submateri', 'Nilai', 'Status']),
              for (final material in materials)
                _pdfTableRow([
                  material.title,
                  '${material.completedSubmaterials}/'
                      '${material.totalSubmaterials}',
                  '${material.masteryScore}%',
                  material.masteryScore == 0
                      ? 'Belum ada hasil evaluasi'
                      : material.masteryStatus,
                ]),
            ],
          ),

          pw.SizedBox(height: 18),

          _pdfSectionTitle('4. Hasil Quiz Terakhir'),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: pdf.PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1.6),
            },
            children: [
              _pdfTableHeader(['Materi', 'Nilai', 'Status']),
              for (final material in materials)
                _pdfTableRow([
                  material.title,
                  completedQuizIds.contains(material.id)
                      ? '${quizScores[material.id] ?? 0}%'
                      : '-',
                  completedQuizIds.contains(material.id)
                      ? 'Sudah dikerjakan'
                      : 'Belum dikerjakan',
                ]),
            ],
          ),

          pw.SizedBox(height: 18),

          _pdfSectionTitle('5. Computer Challenge'),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: pdf.PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1.5),
            },
            children: [
              _pdfTableHeader(['Level', 'Nilai terbaik', 'Status']),
              for (var index = 0; index < challengeLevels.length; index++)
                _pdfTableRow([
                  challengeLevels[index].name,
                  challengeLevels[index].completed
                      ? '${challengeLevels[index].bestScore}%'
                      : '-',
                  challengeLevels[index].completed
                      ? 'Selesai'
                      : 'Belum selesai',
                ]),
            ],
          ),

          pw.SizedBox(height: 18),

          _pdfSectionTitle('6. Aktivitas Terbaru'),
          pw.SizedBox(height: 8),
          if (activities.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: _pdfBoxDecoration(),
              child: pw.Text(
                'Belum ada aktivitas belajar yang tercatat.',
                style: const pw.TextStyle(fontSize: 10),
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: pdf.PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(3.2),
                2: const pw.FlexColumnWidth(1.6),
              },
              children: [
                _pdfTableHeader(['Aktivitas', 'Keterangan', 'Waktu']),
                for (final activity in activities)
                  _pdfTableRow([
                    activity['title']?.toString() ?? '-',
                    activity['description']?.toString() ?? '-',
                    _formatReportDate(activity['created_at']),
                  ]),
              ],
            ),

          pw.SizedBox(height: 18),

          _pdfSectionTitle('7. Rekomendasi Belajar'),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: _pdfBoxDecoration(),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (analytics.recommendations.isEmpty)
                  pw.Text(
                    'Belum ada rekomendasi tambahan berdasarkan data '
                    'kompetensi yang tersimpan.',
                    style: const pw.TextStyle(fontSize: 10),
                  )
                else
                  for (final recommendation in analytics.recommendations)
                    _pdfBullet(recommendation),
              ],
            ),
          ),

          pw.SizedBox(height: 14),
          pw.Text(
            'Sumber: progres, nilai quiz, challenge, dan aktivitas yang '
            'tersimpan pada akun TechStep ini. Nilai penguasaan mengikuti '
            'hasil evaluasi dan progres materi yang tercatat.',
            style: const pw.TextStyle(
              fontSize: 8,
              color: pdf.PdfColors.grey700,
            ),
          ),
        ],
      ),
    );

    final bytes = await document.save();
    await database.saveLearningReport({
      'student_name': _reportValue(studentName),
      'student_nis': _reportValue(studentNis),
      'student_class': _reportValue(studentClass),
      'created_at': now.toIso8601String(),
      'overall_progress': overallProgress,
      'completed_submaterials': analytics.completedMaterials,
      'total_submaterials': analytics.totalMaterials,
      'completed_quiz_material_ids': completedQuizIds.toList(),
      'quiz_scores': quizScores,
      'completed_challenge_levels': completedLevelCount,
      'total_challenge_levels': challengeLevels.length,
      'materials': [
        for (final material in materials)
          {
            'id': material.id,
            'title': material.title,
            'completed_submaterials': material.completedSubmaterials,
            'total_submaterials': material.totalSubmaterials,
            'mastery_score': material.masteryScore,
            'mastery_status': material.masteryStatus,
          },
      ],
      'challenge_levels': [
        for (final level in challengeLevels)
          {
            'id': level.id,
            'name': level.name,
            'completed': level.completed,
            'best_score': level.bestScore,
          },
      ],
      'recent_activities': activities,
      'pdf_base64': base64Encode(bytes),
    });

    return bytes;
  }

  // ============================================================
  // UNDUH LAPORAN PDF
  // ============================================================

  Future<void> _downloadLearningAnalytics(
    BuildContext context,
  ) async {
    try {
      final bytes = await _buildLearningAnalyticsPdf();

      final savedPath = await FileSaver.instance.saveToDownloads(
        name: 'hasil_learning_analytics_techstep',
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
        subfolder: 'TechStep',
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath == null || savedPath.isEmpty
                ? 'PDF berhasil dibuat dan dikirim ke lokasi unduhan.'
                : 'PDF berhasil disimpan: $savedPath',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan PDF: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // PRATINJAU LAPORAN PDF
  // ============================================================

  Future<void> _previewLearningAnalytics(
    BuildContext context,
  ) async {
    try {
      final bytes = await _buildLearningAnalyticsPdf();

      if (!context.mounted) return;

      await _showLearningReport(context, bytes);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka PDF: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openSavedLearningAnalytics(
    BuildContext context,
  ) async {
    try {
      final report =
          await TechStepDatabase.instance.getLatestLearningReport();
      final encodedPdf = report?['pdf_base64']?.toString();
      if (encodedPdf == null || encodedPdf.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Belum ada Learning Report yang tersimpan.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final bytes = Uint8List.fromList(base64Decode(encodedPdf));
      if (bytes.length < 5 ||
          bytes[0] != 0x25 ||
          bytes[1] != 0x50 ||
          bytes[2] != 0x44 ||
          bytes[3] != 0x46 ||
          bytes[4] != 0x2D) {
        throw const FormatException('File PDF tersimpan tidak valid.');
      }

      if (!context.mounted) return;
      await _showLearningReport(context, bytes);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka Learning Report tersimpan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showLearningReport(
    BuildContext context,
    Uint8List bytes,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (previewContext) {
          final colors = Theme.of(previewContext).colorScheme;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Learning Report'),
            ),
            body: PdfPreview(
              canChangeOrientation: false,
              canChangePageFormat: false,
              allowPrinting: true,
              allowSharing: true,
              build: (_) async => bytes,
            ),
            backgroundColor: colors.surface,
          );
        },
      ),
    );
  }

  // ============================================================
  // KOMPONEN PDF
  // ============================================================

  String _reportValue(String? value) {
    if (value == null || value.isEmpty) {
      return '-';
    }
    return value;
  }

  String _formatReportDate(Object? value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) {
      return '-';
    }
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.BoxDecoration _pdfBoxDecoration() {
    return pw.BoxDecoration(
      border: pw.Border.all(color: pdf.PdfColors.grey400, width: 0.7),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
    );
  }

  pw.TableRow _pdfTableHeader(List<String> labels) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: pdf.PdfColors.grey200),
      children: [
        for (final label in labels) _pdfTableCell(label, bold: true),
      ],
    );
  }

  pw.TableRow _pdfTableRow(List<String> values) {
    return pw.TableRow(
      children: [for (final value in values) _pdfTableCell(value)],
    );
  }

  pw.Widget _pdfInfoRow(
    String label,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              ': $value',
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTableCell(
    String text, {
    bool bold = false,
    bool center = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: center
          ? pw.Alignment.center
          : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        textAlign:
            center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight:
              bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _pdfBullet(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '- ',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(
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
    final analytics = LearningAnalyticsService.instance;

    return AnimatedBuilder(
      animation: analytics,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'Profil',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _buildProfileHeader(context),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    context,
                    'Ringkasan Pembelajaran',
                    'Aktivitas belajarmu sejauh ini.',
                  ),

                  const SizedBox(height: 14),

                  _buildSummaryCard(context, analytics),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    context,
                    'Penguasaan Kompetensi',
                    'Hasil evaluasi untuk setiap materi.',
                  ),

                  const SizedBox(height: 15),

                  _buildCompetencyCard(
                    context: context,
                    title: 'Hardware',
                    percentage: analytics.hardwareMastery,
                    icon: Icons.memory_rounded,
                  ),

                  const SizedBox(height: 13),

                  _buildCompetencyCard(
                    context: context,
                    title: 'Software',
                    percentage: analytics.softwareMastery,
                    icon: Icons.apps_rounded,
                  ),

                  const SizedBox(height: 13),

                  _buildCompetencyCard(
                    context: context,
                    title: 'Sistem Operasi',
                    percentage: analytics.operatingSystemMastery,
                    icon: Icons.desktop_windows_rounded,
                  ),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    context,
                    'Status Pembelajaran',
                    'Pantau perkembangan belajarmu.',
                  ),

                  const SizedBox(height: 14),

                  _buildLearningStatus(context, analytics),

                  const SizedBox(height: 28),

                  // PENGATURAN LIGHT MODE / DARK MODE

                  _buildSectionTitle(
                    context,
                    'Pengaturan Tampilan',
                    'Sesuaikan tampilan TechStep dengan preferensimu.',
                  ),

                  const SizedBox(height: 14),

                  _buildAppearanceCard(context),

                  const SizedBox(height: 28),

                  // LAPORAN PDF

                  _buildReportCard(context),

                  const SizedBox(height: 20),

                  // LOGOUT

                  _buildLogoutButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // JUDUL BAGIAN
  // ============================================================

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // KARTU PROFIL SISWA
  // ============================================================

  Widget _buildProfileHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF5547E8),
                    Color(0xFF9A8CFF),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.badge_outlined,
                          color: colors.primary,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profil Siswa',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Informasi akun siswa',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nama Lengkap',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _studentName,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    color: colors.outlineVariant,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildIdentityInfo(
                          context,
                          label: 'Username / NIS',
                          value: _studentNis,
                          icon: Icons.person_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildIdentityInfo(
                          context,
                          label: 'Kelas',
                          value: _studentClass,
                          icon: Icons.menu_book_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityInfo(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: colors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU RINGKASAN PEMBELAJARAN
  // ============================================================

  Widget _buildSummaryCard(
    BuildContext context,
    LearningAnalyticsService analytics,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildSummaryItem(
            context: context,
            icon: Icons.menu_book_rounded,
            value: '${analytics.completedMaterials}',
            label: 'Materi selesai',
            accent: _primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryItem(
            context: context,
            icon: Icons.quiz_rounded,
            value: '${analytics.completedQuizMaterialIds.length}/'
                '${LearningAnalyticsService.totalQuizMaterials}',
            label: 'Quiz selesai',
            accent: _success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryItem(
            context: context,
            icon: Icons.sports_esports_rounded,
            value: '${analytics.completedChallengeLevels}',
            label: 'Level selesai',
            accent: _warning,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color accent,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 142),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU PENGUASAAN KOMPETENSI
  // ============================================================

  Widget _buildCompetencyCard({
    required BuildContext context,
    required String title,
    required int percentage,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    final score = percentage.clamp(0, 100);

    final Color accent = score >= 80
        ? _success
        : score >= 60
            ? _primary
            : _warning;

    final String status = percentage == 0
        ? 'Belum ada hasil evaluasi'
        : LearningAnalyticsService.instance
            .competencyStatus(percentage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: colors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Penguasaan materi',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 9,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                percentage == 0
                    ? Icons.info_outline_rounded
                    : Icons.check_circle_outline_rounded,
                size: 16,
                color: accent,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS PEMBELAJARAN
  // ============================================================

  Widget _buildLearningStatus(
    BuildContext context,
    LearningAnalyticsService analytics,
  ) {
    final colors = Theme.of(context).colorScheme;
    final progress = analytics.overallProgress.clamp(0, 100);

    final Color accent = progress >= 80
        ? _success
        : progress >= 40
            ? _primary
            : _warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.12),
            colors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perjalanan Belajar',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      analytics.learningStatus,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$progress%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 9,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            'Quiz: ${analytics.completedQuizMaterialIds.length}/'
            '${LearningAnalyticsService.totalQuizMaterials} materi selesai'
            ' • Challenge: ${analytics.completedChallengeLevels}/5 level',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PENGATURAN LIGHT MODE / DARK MODE
  // ============================================================

  Widget _buildAppearanceCard(BuildContext context) {
    final controller = TechStepThemeController.instance;
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final isLightMode = controller.mode == ThemeMode.light;
        final isDarkMode = controller.mode == ThemeMode.dark;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: colors.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tampilan Aplikasi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pilih tema yang kamu sukai.',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildThemeOption(
                      context: context,
                      title: 'Mode Siang',
                      subtitle: 'Light Mode',
                      icon: Icons.light_mode_rounded,
                      selected: isLightMode,
                      onTap: () {
                        controller.setMode(ThemeMode.light);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildThemeOption(
                      context: context,
                      title: 'Mode Malam',
                      subtitle: 'Dark Mode',
                      icon: Icons.dark_mode_rounded,
                      selected: isDarkMode,
                      onTap: () {
                        controller.setMode(ThemeMode.dark);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.primaryContainer
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 25,
              color: selected
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
            const SizedBox(height: 9),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: colors.onSurfaceVariant,
              ),
            ),
            if (selected) ...[
              const SizedBox(height: 7),
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: colors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // KARTU LAPORAN LEARNING ANALYTICS
  // ============================================================

  Widget _buildReportCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF29205E),
            Color(0xFF5547C9),
            Color(0xFF7567EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laporan Belajarmu',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Learning Analytics TechStep',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE0DCFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          const Text(
            'Lihat perkembangan belajar, penguasaan kompetensi, '
            'dan rekomendasi pembelajaran dalam laporan PDF.',
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: Color(0xFFE5E1FF),
            ),
          ),
          const SizedBox(height: 21),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                _previewLearningAnalytics(context);
              },
              icon: const Icon(
                Icons.picture_as_pdf_rounded,
                size: 20,
              ),
              label: const Text(
                'Lihat Laporan PDF',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5547C9),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                _downloadLearningAnalytics(context);
              },
              icon: const Icon(
                Icons.download_rounded,
                size: 20,
              ),
              label: const Text(
                'Unduh Hasil Learning Analytics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.55),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                _openSavedLearningAnalytics(context);
              },
              icon: const Icon(
                Icons.history_rounded,
                size: 20,
              ),
              label: const Text(
                'Buka PDF Tersimpan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.55),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KONFIRMASI LOGOUT
  // ============================================================

  Future<void> _confirmLogout(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogColors =
            Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          backgroundColor: dialogColors.surface,
          icon: Icon(
            Icons.logout_rounded,
            color: dialogColors.error,
            size: 30,
          ),
          title: Text(
            'Keluar dari akun?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: dialogColors.onSurface,
            ),
          ),
          content: Text(
            'Kamu akan kembali ke halaman login. Progres belajar '
            'yang sudah tersimpan tidak akan dihapus.',
            style: TextStyle(
              height: 1.5,
              color: dialogColors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogColors.error,
                foregroundColor: dialogColors.onError,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      onLogout();
    }

    // Referensi theme diambil dari context halaman yang memanggil dialog.
    assert(colors.surface != Colors.transparent);
  }

  // ============================================================
  // TOMBOL LOGOUT
  // ============================================================

  Widget _buildLogoutButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 53,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
        ),
        label: const Text(
          'Keluar dari Akun',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          backgroundColor: colors.errorContainer,
          side: BorderSide(
            color: colors.error.withValues(alpha: 0.25),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}
