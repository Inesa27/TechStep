import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_content.dart';

class TechStepDatabase {
  static final TechStepDatabase instance = TechStepDatabase._internal();

  TechStepDatabase._internal();

  // Default is used only before the first authenticated user logs in.
  // AuthGate switches this to the ID of the currently authenticated account.
  int _studentId = 1;
  int get studentId => _studentId;

  Database? _database;
  Map<String, dynamic>? _webSeed;
  final Set<String> _webCompletedSubmaterials = {};
  final Map<String, String> _webSubmaterialViewedAt = {};
  final List<Map<String, Object?>> _webActivities = [];
  final List<Map<String, Object?>> _webQuizResults = [];
  final List<Map<String, Object?>> _webQuizAnswers = [];
  final List<Map<String, Object?>> _webChallengeResults = [];
  final List<Map<String, Object?>> _webChallengeAnswers = [];
  final List<Map<String, Object?>> _webCompetencyMapping = [];
  final List<Map<String, Object?>> _webRecommendations = [];
  final List<Map<String, Object?>> _webReports = [];

  // Persist Learning Analytics separately for each authenticated Web user.
  // Version 1 is retained only to migrate the original single-user data to
  // account ID 1. Other users must never inherit that legacy state.
  static const String _legacyWebStateKey = 'techstep_learning_web_state_v1';
  static const String _webStateKeyPrefix =
      'techstep_learning_web_state_v2_student_';
  String get _webStateKey => '$_webStateKeyPrefix$_studentId';
  int? _webLoadedStudentId;
  final SharedPreferencesAsync _webPreferences = SharedPreferencesAsync();

  /// Activates the learning-data partition for the logged-in account.
  /// The account's user ID is used as student_id in the learning database.
  Future<void> setCurrentStudent({
    required int id,
    required String name,
    required String className,
  }) async {
    if (id <= 0) {
      throw ArgumentError.value(id, 'id', 'Student ID must be positive.');
    }

    if (kIsWeb) {
      // Ensure the previous user's state is loaded and safely saved before
      // switching to a different account namespace.
      await _initializeWebStore();
      await _persistWebState();

      if (_studentId != id) {
        _studentId = id;
        _clearWebUserState();
        _webLoadedStudentId = null;
        await _initializeWebStore();
      }

      _refreshWebCompetencyMapping();
      return;
    }

    // Initialize while the old ID is still active. This avoids seeding the
    // database with an unauthenticated ID and preserves existing rows.
    await initialize();
    _studentId = id;

    final db = await database;
    await db.insert('students', {
      'id': id,
      'name': name,
      'class_name': className,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.update(
      'students',
      {'name': name, 'class_name': className},
      where: 'id = ?',
      whereArgs: [id],
    );

    await refreshCompetencyMapping();
  }

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not available on Flutter Web.');
    }

    if (_database != null) {
      return _database!;
    }

    await initialize();
    return _database!;
  }

  Future<void> initialize() async {
    if (kIsWeb) {
      await _initializeWebStore();
      return;
    }

    if (_database != null) {
      return;
    }

    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'techstep_learning.db');

    _database = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createTables,
    );

    await _seedIfNeeded();
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        class_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE materials (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        image_asset TEXT NOT NULL,
        order_index INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE submaterials (
        id TEXT PRIMARY KEY,
        material_id TEXT NOT NULL,
        title TEXT NOT NULL,
        summary TEXT NOT NULL,
        content_json TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (material_id) REFERENCES materials(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE competencies (
        id TEXT PRIMARY KEY,
        material_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (material_id) REFERENCES materials(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE submaterial_competencies (
        submaterial_id TEXT NOT NULL,
        competency_id TEXT NOT NULL,
        PRIMARY KEY (submaterial_id, competency_id),
        FOREIGN KEY (submaterial_id) REFERENCES submaterials(id),
        FOREIGN KEY (competency_id) REFERENCES competencies(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE challenge_levels (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        order_index INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        source TEXT NOT NULL,
        code TEXT,
        level_id INTEGER,
        material_id TEXT NOT NULL,
        competency_id TEXT NOT NULL,
        question_text TEXT NOT NULL,
        correct_option_key TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        weight INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (material_id) REFERENCES materials(id),
        FOREIGN KEY (competency_id) REFERENCES competencies(id),
        FOREIGN KEY (level_id) REFERENCES challenge_levels(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE answer_options (
        id TEXT PRIMARY KEY,
        question_id TEXT NOT NULL,
        option_key TEXT NOT NULL,
        option_text TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (question_id) REFERENCES questions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE learning_progress (
        student_id INTEGER NOT NULL,
        material_id TEXT NOT NULL,
        submaterial_id TEXT NOT NULL,
        opened_at TEXT NOT NULL,
        last_viewed_at TEXT NOT NULL,
        completed_at TEXT,
        progress_percent INTEGER NOT NULL,
        PRIMARY KEY (student_id, submaterial_id),
        FOREIGN KEY (student_id) REFERENCES students(id),
        FOREIGN KEY (material_id) REFERENCES materials(id),
        FOREIGN KEY (submaterial_id) REFERENCES submaterials(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        ref_id TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        score_percent INTEGER NOT NULL,
        total_correct INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        result_id INTEGER NOT NULL,
        question_id TEXT NOT NULL,
        selected_option_key TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        material_id TEXT NOT NULL,
        competency_id TEXT NOT NULL,
        FOREIGN KEY (result_id) REFERENCES quiz_results(id),
        FOREIGN KEY (question_id) REFERENCES questions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE challenge_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        level_id INTEGER NOT NULL,
        score_percent INTEGER NOT NULL,
        total_correct INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id),
        FOREIGN KEY (level_id) REFERENCES challenge_levels(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE challenge_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        result_id INTEGER NOT NULL,
        question_id TEXT NOT NULL,
        selected_option_key TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        material_id TEXT NOT NULL,
        competency_id TEXT NOT NULL,
        FOREIGN KEY (result_id) REFERENCES challenge_results(id),
        FOREIGN KEY (question_id) REFERENCES questions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE competency_mapping (
        student_id INTEGER NOT NULL,
        competency_id TEXT NOT NULL,
        material_id TEXT NOT NULL,
        quiz_score INTEGER,
        challenge_score INTEGER,
        activity_score INTEGER NOT NULL,
        mastery_score INTEGER NOT NULL,
        status TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        PRIMARY KEY (student_id, competency_id),
        FOREIGN KEY (student_id) REFERENCES students(id),
        FOREIGN KEY (competency_id) REFERENCES competencies(id),
        FOREIGN KEY (material_id) REFERENCES materials(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE recommendations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        competency_id TEXT,
        material_id TEXT NOT NULL,
        message TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE learning_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        report_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id)
      )
    ''');
  }

  Future<void> _seedIfNeeded() async {
    final db = await database;
    final materialCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM materials'),
    );

    if ((materialCount ?? 0) > 0) {
      return;
    }

    final seedRaw = await rootBundle.loadString(
      'assets/data/techstep_seed.json',
    );
    final seed = jsonDecode(seedRaw) as Map<String, dynamic>;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final student in seed['students'] as List<dynamic>) {
        final item = student as Map<String, dynamic>;
        batch.insert('students', {
          'id': item['id'],
          'name': item['name'],
          'class_name': item['class_name'],
        });
      }

      for (final material in seed['materials'] as List<dynamic>) {
        final item = material as Map<String, dynamic>;
        batch.insert('materials', {
          'id': item['id'],
          'title': item['title'],
          'subtitle': item['subtitle'],
          'description': item['description'],
          'icon_key': item['icon_key'],
          'color_hex': item['color_hex'],
          'image_asset': item['image_asset'] ?? '',
          'order_index': item['order'],
        });

        for (final submaterial in item['submaterials'] as List<dynamic>) {
          final sub = submaterial as Map<String, dynamic>;
          batch.insert('submaterials', {
            'id': sub['id'],
            'material_id': sub['material_id'],
            'title': sub['title'],
            'summary': sub['summary'] ?? '',
            'content_json': jsonEncode(sub['blocks']),
            'order_index': sub['order'],
          });
        }
      }

      for (final competency in seed['competencies'] as List<dynamic>) {
        final item = competency as Map<String, dynamic>;
        batch.insert('competencies', {
          'id': item['id'],
          'material_id': item['material_id'],
          'title': item['title'],
          'description': item['description'],
          'order_index': item['order'],
        });
      }

      for (final material in seed['materials'] as List<dynamic>) {
        final item = material as Map<String, dynamic>;
        for (final submaterial in item['submaterials'] as List<dynamic>) {
          final sub = submaterial as Map<String, dynamic>;
          for (final competencyId
              in sub['competency_ids'] as List<dynamic>? ?? const []) {
            batch.insert('submaterial_competencies', {
              'submaterial_id': sub['id'],
              'competency_id': competencyId,
            });
          }
        }
      }

      for (final level in seed['challenge_levels'] as List<dynamic>) {
        final item = level as Map<String, dynamic>;
        batch.insert('challenge_levels', {
          'id': item['id'],
          'name': item['name'],
          'description': item['description'],
          'order_index': item['order'],
        });
      }

      for (final question in seed['quiz_questions'] as List<dynamic>) {
        _insertQuestionBatch(
          batch,
          question as Map<String, dynamic>,
          source: 'quiz',
        );
      }

      for (final question in seed['challenge_questions'] as List<dynamic>) {
        _insertQuestionBatch(
          batch,
          question as Map<String, dynamic>,
          source: 'challenge',
        );
      }

      batch.insert('metadata', {
        'key': 'seed_schema_version',
        'value': seed['schema_version'].toString(),
      });

      await batch.commit(noResult: true);
    });

    await refreshCompetencyMapping();
  }

  void _insertQuestionBatch(
    Batch batch,
    Map<String, dynamic> item, {
    required String source,
  }) {
    batch.insert('questions', {
      'id': item['id'],
      'source': source,
      'code': item['code'],
      'level_id': item['level_id'],
      'material_id': item['material_id'],
      'competency_id': item['competency_id'],
      'question_text': item['question'],
      'correct_option_key': item['correct_option_key'],
      'order_index': item['order'],
      'weight': item['weight'] ?? 1,
    });

    var order = 0;
    for (final option in item['options'] as List<dynamic>) {
      final optionMap = option as Map<String, dynamic>;
      order++;
      batch.insert('answer_options', {
        'id': '${item['id']}_${optionMap['key']}',
        'question_id': item['id'],
        'option_key': optionMap['key'],
        'option_text': optionMap['text'],
        'order_index': order,
      });
    }
  }

  Future<List<LearningMaterial>> getMaterialsWithProgress() async {
    if (kIsWeb) {
      await _initializeWebStore();
      final mapping = await materialMasteryScores();
      final materials = _webMaterials();

      return materials.map((material) {
        final submaterials = _webSubmaterialsForMaterial(
          material['id'].toString(),
        );
        final completed = submaterials.where((submaterial) {
          return _webCompletedSubmaterials.contains(submaterial['id']);
        }).length;
        final score = mapping[material['id']] ?? 0;

        return LearningMaterial.fromMap({
          'id': material['id'],
          'title': material['title'],
          'subtitle': material['subtitle'],
          'description': material['description'],
          'icon_key': material['icon_key'],
          'color_hex': material['color_hex'],
          'image_asset': material['image_asset'] ?? '',
          'order_index': material['order'],
          'total_submaterials': submaterials.length,
          'completed_submaterials': completed,
          'mastery_score': score,
          'mastery_status': competencyStatus(score),
        });
      }).toList();
    }

    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT
        m.*,
        COUNT(DISTINCT s.id) AS total_submaterials,
        COUNT(DISTINCT CASE WHEN lp.completed_at IS NOT NULL THEN s.id END)
          AS completed_submaterials,
        COALESCE(ROUND(AVG(cm.mastery_score)), 0) AS mastery_score,
        CASE
          WHEN COUNT(cm.competency_id) = 0 THEN 'Belum Dinilai'
          WHEN ROUND(AVG(cm.mastery_score)) >= 80 THEN 'Dikuasai'
          WHEN ROUND(AVG(cm.mastery_score)) >= 60 THEN 'Cukup'
          ELSE 'Perlu Diperkuat'
        END AS mastery_status
      FROM materials m
      LEFT JOIN submaterials s ON s.material_id = m.id
      LEFT JOIN learning_progress lp
        ON lp.submaterial_id = s.id AND lp.student_id = ?
      LEFT JOIN competency_mapping cm
        ON cm.material_id = m.id AND cm.student_id = ?
      GROUP BY m.id
      ORDER BY m.order_index ASC
    ''',
      [studentId, studentId],
    );

    return rows.map(LearningMaterial.fromMap).toList();
  }

  Future<List<Submaterial>> getSubmaterials(String materialId) async {
    if (kIsWeb) {
      await _initializeWebStore();

      return _webSubmaterialsForMaterial(materialId).map((submaterial) {
        final id = submaterial['id'].toString();

        return Submaterial.fromMap({
          'id': id,
          'material_id': submaterial['material_id'],
          'title': submaterial['title'],
          'summary': submaterial['summary'] ?? '',
          'content_json': jsonEncode(submaterial['blocks']),
          'order_index': submaterial['order'],
          'completed': _webCompletedSubmaterials.contains(id) ? 1 : 0,
          'last_viewed_at': _webSubmaterialViewedAt[id],
        });
      }).toList();
    }

    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT
        s.*,
        CASE WHEN lp.completed_at IS NULL THEN 0 ELSE 1 END AS completed,
        lp.last_viewed_at
      FROM submaterials s
      LEFT JOIN learning_progress lp
        ON lp.submaterial_id = s.id AND lp.student_id = ?
      WHERE s.material_id = ?
      ORDER BY s.order_index ASC
    ''',
      [studentId, materialId],
    );

    return rows.map(Submaterial.fromMap).toList();
  }

  Future<Submaterial?> getSubmaterial(String submaterialId) async {
    if (kIsWeb) {
      await _initializeWebStore();

      for (final material in _webMaterials()) {
        for (final submaterial
            in material['submaterials'] as List<dynamic>? ?? const []) {
          final item = submaterial as Map<String, dynamic>;
          if (item['id'] == submaterialId) {
            return Submaterial.fromMap({
              'id': item['id'],
              'material_id': item['material_id'],
              'title': item['title'],
              'summary': item['summary'] ?? '',
              'content_json': jsonEncode(item['blocks']),
              'order_index': item['order'],
              'completed': _webCompletedSubmaterials.contains(submaterialId)
                  ? 1
                  : 0,
              'last_viewed_at': _webSubmaterialViewedAt[submaterialId],
            });
          }
        }
      }

      return null;
    }

    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT
        s.*,
        CASE WHEN lp.completed_at IS NULL THEN 0 ELSE 1 END AS completed,
        lp.last_viewed_at
      FROM submaterials s
      LEFT JOIN learning_progress lp
        ON lp.submaterial_id = s.id AND lp.student_id = ?
      WHERE s.id = ?
      LIMIT 1
    ''',
      [studentId, submaterialId],
    );

    if (rows.isEmpty) {
      return null;
    }

    return Submaterial.fromMap(rows.first);
  }

  Future<void> recordSubmaterialOpened(Submaterial submaterial) async {
    if (kIsWeb) {
      await _initializeWebStore();
      final now = DateTime.now().toIso8601String();
      _webCompletedSubmaterials.add(submaterial.id);
      _webSubmaterialViewedAt[submaterial.id] = now;
      await addActivity(
        type: 'learn',
        refId: submaterial.id,
        title: 'Materi dibuka',
        description: submaterial.title,
      );
      await refreshCompetencyMapping();
      return;
    }

    final db = await database;
    final now = DateTime.now().toIso8601String();
    final existing = await db.query(
      'learning_progress',
      columns: ['opened_at'],
      where: 'student_id = ? AND submaterial_id = ?',
      whereArgs: [studentId, submaterial.id],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('learning_progress', {
        'student_id': studentId,
        'material_id': submaterial.materialId,
        'submaterial_id': submaterial.id,
        'opened_at': now,
        'last_viewed_at': now,
        'completed_at': now,
        'progress_percent': 100,
      });
    } else {
      await db.update(
        'learning_progress',
        {'last_viewed_at': now, 'completed_at': now, 'progress_percent': 100},
        where: 'student_id = ? AND submaterial_id = ?',
        whereArgs: [studentId, submaterial.id],
      );
    }

    await addActivity(
      type: 'learn',
      refId: submaterial.id,
      title: 'Materi dibuka',
      description: submaterial.title,
    );
    await refreshCompetencyMapping();
  }

  Future<List<LearningQuestion>> getQuizQuestions() async {
    if (kIsWeb) {
      await _initializeWebStore();
      return _webQuestions(source: 'quiz');
    }

    return _getQuestions(source: 'quiz');
  }

  Future<List<ChallengeLevel>> getChallengeLevels() async {
    if (kIsWeb) {
      await _initializeWebStore();
      final completedLevelIds = _webChallengeResults.map((result) {
        return _asInt(result['level_id']);
      }).toSet();

      return _webChallengeLevels().map((level) {
        final levelId = _asInt(level['id']);
        final scores = _webChallengeResults
            .where((result) => _asInt(result['level_id']) == levelId)
            .map((result) => _asInt(result['score_percent']))
            .toList();
        final bestScore = scores.isEmpty
            ? 0
            : scores.reduce((current, next) => current > next ? current : next);

        return ChallengeLevel.fromMap({
          'id': levelId,
          'name': level['name'],
          'description': level['description'],
          'order_index': level['order'],
          'completed': completedLevelIds.contains(levelId) ? 1 : 0,
          'best_score': bestScore,
        });
      }).toList();
    }

    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT
        l.*,
        CASE WHEN MAX(cr.id) IS NULL THEN 0 ELSE 1 END AS completed,
        COALESCE(MAX(cr.score_percent), 0) AS best_score
      FROM challenge_levels l
      LEFT JOIN challenge_results cr
        ON cr.level_id = l.id AND cr.student_id = ?
      GROUP BY l.id
      ORDER BY l.order_index ASC
    ''',
      [studentId],
    );

    return rows.map(ChallengeLevel.fromMap).toList();
  }

  Future<List<LearningQuestion>> getChallengeQuestions(int levelId) async {
    if (kIsWeb) {
      await _initializeWebStore();
      return _webQuestions(source: 'challenge', levelId: levelId);
    }

    return _getQuestions(source: 'challenge', levelId: levelId);
  }

  Future<List<LearningQuestion>> _getQuestions({
    required String source,
    int? levelId,
  }) async {
    final db = await database;
    final args = <Object?>[source];
    var levelFilter = '';

    if (levelId != null) {
      levelFilter = 'AND q.level_id = ?';
      args.add(levelId);
    }

    final questionRows = await db.rawQuery('''
      SELECT
        q.*,
        m.title AS material_title,
        c.title AS competency_title
      FROM questions q
      INNER JOIN materials m ON m.id = q.material_id
      INNER JOIN competencies c ON c.id = q.competency_id
      WHERE q.source = ?
      $levelFilter
      ORDER BY COALESCE(q.level_id, 0), q.order_index ASC
    ''', args);

    final questions = <LearningQuestion>[];

    for (final row in questionRows) {
      final optionRows = await db.query(
        'answer_options',
        where: 'question_id = ?',
        whereArgs: [row['id']],
        orderBy: 'order_index ASC',
      );

      questions.add(
        LearningQuestion.fromMap(
          row,
          optionRows.map(AnswerOption.fromMap).toList(),
        ),
      );
    }

    return questions;
  }

  Future<int> recordQuizResult({
    required List<LearningQuestion> questions,
    required Map<String, String> selectedOptionKeys,
  }) async {
    if (kIsWeb) {
      await _initializeWebStore();
      final resultId = _webQuizResults.length + 1;
      final totalQuestions = questions.length;
      final totalCorrect = questions.where((question) {
        return selectedOptionKeys[question.id] == question.correctOptionKey;
      }).length;
      final scorePercent = _percentage(totalCorrect, totalQuestions);
      final now = DateTime.now().toIso8601String();

      _webQuizResults.add({
        'id': resultId,
        'student_id': studentId,
        'score_percent': scorePercent,
        'total_correct': totalCorrect,
        'total_questions': totalQuestions,
        'created_at': now,
      });

      for (final question in questions) {
        final selected = selectedOptionKeys[question.id] ?? '';
        _webQuizAnswers.add({
          'result_id': resultId,
          'question_id': question.id,
          'selected_option_key': selected,
          'is_correct': selected == question.correctOptionKey ? 1 : 0,
          'material_id': question.materialId,
          'competency_id': question.competencyId,
        });
      }

      await addActivity(
        type: 'quiz',
        refId: resultId.toString(),
        title: 'Quiz selesai',
        description: 'Nilai quiz: $scorePercent',
      );
      await refreshCompetencyMapping();
      return resultId;
    }

    final db = await database;
    final totalQuestions = questions.length;
    final totalCorrect = questions.where((question) {
      return selectedOptionKeys[question.id] == question.correctOptionKey;
    }).length;
    final scorePercent = _percentage(totalCorrect, totalQuestions);
    final now = DateTime.now().toIso8601String();

    final resultId = await db.transaction<int>((txn) async {
      final id = await txn.insert('quiz_results', {
        'student_id': studentId,
        'score_percent': scorePercent,
        'total_correct': totalCorrect,
        'total_questions': totalQuestions,
        'created_at': now,
      });

      final batch = txn.batch();
      for (final question in questions) {
        final selected = selectedOptionKeys[question.id] ?? '';
        batch.insert('quiz_answers', {
          'result_id': id,
          'question_id': question.id,
          'selected_option_key': selected,
          'is_correct': selected == question.correctOptionKey ? 1 : 0,
          'material_id': question.materialId,
          'competency_id': question.competencyId,
        });
      }

      await batch.commit(noResult: true);
      return id;
    });

    await addActivity(
      type: 'quiz',
      refId: resultId.toString(),
      title: 'Quiz selesai',
      description: 'Nilai quiz: $scorePercent',
    );
    await refreshCompetencyMapping();
    return resultId;
  }

  Future<int> recordChallengeResult({
    required int levelId,
    required List<LearningQuestion> questions,
    required Map<String, String> firstSelectedOptionKeys,
  }) async {
    if (kIsWeb) {
      await _initializeWebStore();
      final resultId = _webChallengeResults.length + 1;
      final totalQuestions = questions.length;
      final totalCorrect = questions.where((question) {
        return firstSelectedOptionKeys[question.id] ==
            question.correctOptionKey;
      }).length;
      final scorePercent = _percentage(totalCorrect, totalQuestions);
      final now = DateTime.now().toIso8601String();

      _webChallengeResults.add({
        'id': resultId,
        'student_id': studentId,
        'level_id': levelId,
        'score_percent': scorePercent,
        'total_correct': totalCorrect,
        'total_questions': totalQuestions,
        'completed_at': now,
      });

      for (final question in questions) {
        final selected = firstSelectedOptionKeys[question.id] ?? '';
        _webChallengeAnswers.add({
          'result_id': resultId,
          'question_id': question.id,
          'selected_option_key': selected,
          'is_correct': selected == question.correctOptionKey ? 1 : 0,
          'material_id': question.materialId,
          'competency_id': question.competencyId,
        });
      }

      await addActivity(
        type: 'challenge',
        refId: resultId.toString(),
        title: 'Challenge selesai',
        description: 'Level $levelId selesai dengan nilai $scorePercent',
      );
      await refreshCompetencyMapping();
      return resultId;
    }

    final db = await database;
    final totalQuestions = questions.length;
    final totalCorrect = questions.where((question) {
      return firstSelectedOptionKeys[question.id] == question.correctOptionKey;
    }).length;
    final scorePercent = _percentage(totalCorrect, totalQuestions);
    final now = DateTime.now().toIso8601String();

    final resultId = await db.transaction<int>((txn) async {
      final id = await txn.insert('challenge_results', {
        'student_id': studentId,
        'level_id': levelId,
        'score_percent': scorePercent,
        'total_correct': totalCorrect,
        'total_questions': totalQuestions,
        'completed_at': now,
      });

      final batch = txn.batch();
      for (final question in questions) {
        final selected = firstSelectedOptionKeys[question.id] ?? '';
        batch.insert('challenge_answers', {
          'result_id': id,
          'question_id': question.id,
          'selected_option_key': selected,
          'is_correct': selected == question.correctOptionKey ? 1 : 0,
          'material_id': question.materialId,
          'competency_id': question.competencyId,
        });
      }

      await batch.commit(noResult: true);
      return id;
    });

    await addActivity(
      type: 'challenge',
      refId: resultId.toString(),
      title: 'Challenge selesai',
      description: 'Level $levelId selesai dengan nilai $scorePercent',
    );
    await refreshCompetencyMapping();
    return resultId;
  }

  Future<void> refreshCompetencyMapping() async {
    if (kIsWeb) {
      await _initializeWebStore();
      _refreshWebCompetencyMapping();
      return;
    }

    final db = await database;
    final competencies = await db.query(
      'competencies',
      orderBy: 'material_id ASC, order_index ASC',
    );
    final latestQuizRows = await db.rawQuery(
      '''
      SELECT qa.material_id, MAX(qr.id) AS result_id
      FROM quiz_answers qa
      INNER JOIN quiz_results qr ON qr.id = qa.result_id
      WHERE qr.student_id = ?
      GROUP BY qa.material_id
      ''',
      [studentId],
    );
    final latestQuizIdsByMaterial = <String, int>{
      for (final row in latestQuizRows)
        row['material_id'].toString(): _asInt(row['result_id']),
    };
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.delete(
        'competency_mapping',
        where: 'student_id = ?',
        whereArgs: [studentId],
      );
      await txn.delete(
        'recommendations',
        where: 'student_id = ?',
        whereArgs: [studentId],
      );

      for (final competency in competencies) {
        final competencyId = competency['id'] as String;
        final materialId = competency['material_id'] as String;
        final title = competency['title'] as String;
        final latestQuizId = latestQuizIdsByMaterial[materialId];

        final quizScore = latestQuizId == null
            ? null
            : await _scoreForRows(
                txn,
                table: 'quiz_answers',
                where: 'result_id = ? AND competency_id = ?',
                args: [latestQuizId, competencyId],
              );

        final challengeScore = await _scoreForRows(
          txn,
          table: 'challenge_answers',
          where: 'competency_id = ?',
          args: [competencyId],
        );

        final activityScore = await _activityScore(txn, materialId);
        final masteryScore = _masteryScore(
          quizScore: quizScore,
          challengeScore: challengeScore,
          activityScore: activityScore,
        );
        final status = competencyStatus(masteryScore);
        final recommendation = _recommendation(
          title: title,
          status: status,
          score: masteryScore,
        );

        await txn.insert('competency_mapping', {
          'student_id': studentId,
          'competency_id': competencyId,
          'material_id': materialId,
          'quiz_score': quizScore,
          'challenge_score': challengeScore,
          'activity_score': activityScore,
          'mastery_score': masteryScore,
          'status': status,
          'updated_at': now,
        });

        if (masteryScore < 80) {
          await txn.insert('recommendations', {
            'student_id': studentId,
            'competency_id': competencyId,
            'material_id': materialId,
            'message': recommendation,
            'status': status,
            'created_at': now,
          });
        }
      }
    });
  }

  Future<int?> _scoreForRows(
    DatabaseExecutor db, {
    required String table,
    required String where,
    required List<Object?> args,
  }) async {
    final rows = await db.query(
      table,
      columns: ['is_correct'],
      where: where,
      whereArgs: args,
    );

    if (rows.isEmpty) {
      return null;
    }

    final correct = rows.where((row) => row['is_correct'] == 1).length;
    return _percentage(correct, rows.length);
  }

  Future<int> _activityScore(DatabaseExecutor db, String materialId) async {
    final total =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM submaterials WHERE material_id = ?',
            [materialId],
          ),
        ) ??
        0;

    if (total == 0) {
      return 0;
    }

    final completed =
        Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(*)
            FROM learning_progress lp
            INNER JOIN submaterials s ON s.id = lp.submaterial_id
            WHERE lp.student_id = ?
              AND s.material_id = ?
              AND lp.completed_at IS NOT NULL
          ''',
            [studentId, materialId],
          ),
        ) ??
        0;

    return _percentage(completed, total);
  }

  int _masteryScore({
    required int? quizScore,
    required int? challengeScore,
    required int activityScore,
  }) {
    var weightedScore = 0.0;
    var totalWeight = 0.0;

    if (quizScore != null) {
      weightedScore += quizScore * 0.60;
      totalWeight += 0.60;
    }

    if (challengeScore != null) {
      weightedScore += challengeScore * 0.30;
      totalWeight += 0.30;
    }

    if (activityScore > 0) {
      weightedScore += activityScore * 0.10;
      totalWeight += 0.10;
    }

    if (totalWeight == 0) {
      return 0;
    }

    return (weightedScore / totalWeight).round().clamp(0, 100);
  }

  String competencyStatus(int score) {
    if (score >= 80) {
      return 'Dikuasai';
    }

    if (score >= 60) {
      return 'Cukup';
    }

    return 'Perlu Diperkuat';
  }

  String _recommendation({
    required String title,
    required String status,
    required int score,
  }) {
    if (status == 'Dikuasai') {
      return '$title sudah dikuasai. Pertahankan dengan latihan kasus yang lebih kompleks.';
    }

    if (status == 'Cukup') {
      return '$title cukup dikuasai. Ulangi submateri terkait dan kerjakan latihan sampai lebih konsisten.';
    }

    if (score == 0) {
      return 'Mulai pelajari kompetensi $title dari menu Learn sebelum mengerjakan evaluasi lanjutan.';
    }

    return '$title perlu diperkuat. Baca ulang materi, ulangi quiz, dan coba challenge yang relevan.';
  }

  Future<List<CompetencyProgress>> getCompetencyProgress() async {
    if (kIsWeb) {
      await _initializeWebStore();
      if (_webCompetencyMapping.isEmpty) {
        _refreshWebCompetencyMapping();
      }

      return _webCompetencyMapping.map(CompetencyProgress.fromMap).toList();
    }

    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT
        cm.competency_id,
        cm.material_id,
        c.title,
        cm.mastery_score,
        cm.status,
        COALESCE(r.message, '') AS message
      FROM competency_mapping cm
      INNER JOIN competencies c ON c.id = cm.competency_id
      LEFT JOIN recommendations r
        ON r.competency_id = cm.competency_id AND r.student_id = cm.student_id
      WHERE cm.student_id = ?
      ORDER BY cm.material_id ASC, c.order_index ASC
    ''',
      [studentId],
    );

    return rows.map(CompetencyProgress.fromMap).toList();
  }

  Future<List<Map<String, Object?>>> getActivities({int limit = 20}) async {
    if (kIsWeb) {
      await _initializeWebStore();
      return _webActivities.reversed.take(limit).toList();
    }

    final db = await database;
    return db.query(
      'activities',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'created_at DESC, id DESC',
      limit: limit,
    );
  }

  /// Returns the latest score for each material independently.
  /// Each material can now be completed in its own 10-question quiz.
  Future<Map<String, int>> latestQuizScoresByMaterial() async {
    if (kIsWeb) {
      await _initializeWebStore();
      final latestResultByMaterial = <String, int>{};
      final validResultIds = _webQuizResults
          .where((result) => _asInt(result['student_id']) == studentId)
          .map((result) => _asInt(result['id']))
          .toSet();

      for (final answer in _webQuizAnswers) {
        final resultId = _asInt(answer['result_id']);
        if (!validResultIds.contains(resultId)) {
          continue;
        }
        final materialId = answer['material_id'].toString();
        final previousId = latestResultByMaterial[materialId] ?? 0;
        if (resultId > previousId) {
          latestResultByMaterial[materialId] = resultId;
        }
      }

      final scores = <String, int>{};
      for (final entry in latestResultByMaterial.entries) {
        final rows = _webQuizAnswers.where((answer) {
          return _asInt(answer['result_id']) == entry.value &&
              answer['material_id'].toString() == entry.key;
        }).toList();
        final correct = rows.where((row) => row['is_correct'] == 1).length;
        scores[entry.key] = _percentage(correct, rows.length);
      }
      return scores;
    }

    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT qa.material_id, qa.is_correct
      FROM quiz_answers qa
      INNER JOIN (
        SELECT qa2.material_id, MAX(qr2.id) AS latest_result_id
        FROM quiz_answers qa2
        INNER JOIN quiz_results qr2 ON qr2.id = qa2.result_id
        WHERE qr2.student_id = ?
        GROUP BY qa2.material_id
      ) latest
        ON latest.material_id = qa.material_id
       AND latest.latest_result_id = qa.result_id
      ''',
      [studentId],
    );

    final totals = <String, int>{};
    final correct = <String, int>{};
    for (final row in rows) {
      final materialId = row['material_id'].toString();
      totals[materialId] = (totals[materialId] ?? 0) + 1;
      if (_asInt(row['is_correct']) == 1) {
        correct[materialId] = (correct[materialId] ?? 0) + 1;
      }
    }

    return {
      for (final entry in totals.entries)
        entry.key: _percentage(correct[entry.key] ?? 0, entry.value),
    };
  }

  /// Returns quiz attempts grouped by material, newest first.
  /// Older combined attempts are separated by material in the history view.
  Future<List<Map<String, Object?>>> getQuizHistory({int limit = 30}) async {
    if (kIsWeb) {
      await _initializeWebStore();
      final rows = <Map<String, Object?>>[];
      final results = _webQuizResults
          .where((result) => _asInt(result['student_id']) == studentId)
          .toList();

      for (final result in results) {
        final resultId = _asInt(result['id']);
        final answersByMaterial = <String, List<Map<String, Object?>>>{};
        for (final answer in _webQuizAnswers) {
          if (_asInt(answer['result_id']) != resultId) {
            continue;
          }
          final materialId = answer['material_id'].toString();
          answersByMaterial.putIfAbsent(materialId, () => []);
          answersByMaterial[materialId]!.add(answer);
        }

        for (final entry in answersByMaterial.entries) {
          final material = _webMaterials().firstWhere(
            (item) => item['id'].toString() == entry.key,
            orElse: () => const <String, dynamic>{},
          );
          final answers = entry.value;
          final correct = answers.where((row) => row['is_correct'] == 1).length;
          rows.add({
            'id': resultId,
            'material_id': entry.key,
            'material_title': material['title']?.toString() ?? entry.key,
            'score_percent': _percentage(correct, answers.length),
            'total_correct': correct,
            'total_questions': answers.length,
            'created_at': result['created_at']?.toString() ?? '',
          });
        }
      }

      rows.sort((a, b) {
        final dateCompare = (b['created_at']?.toString() ?? '').compareTo(
          a['created_at']?.toString() ?? '',
        );
        if (dateCompare != 0) return dateCompare;
        return _asInt(b['id']).compareTo(_asInt(a['id']));
      });
      return rows.take(limit < 0 ? 0 : limit).toList();
    }

    final db = await database;
    return db.rawQuery(
      '''
      SELECT
        qr.id,
        qa.material_id,
        m.title AS material_title,
        COUNT(qa.id) AS total_questions,
        SUM(CASE WHEN qa.is_correct = 1 THEN 1 ELSE 0 END) AS total_correct,
        CAST(ROUND(
          100.0 * SUM(CASE WHEN qa.is_correct = 1 THEN 1 ELSE 0 END)
          / COUNT(qa.id)
        ) AS INTEGER) AS score_percent,
        qr.created_at
      FROM quiz_results qr
      INNER JOIN quiz_answers qa ON qa.result_id = qr.id
      INNER JOIN materials m ON m.id = qa.material_id
      WHERE qr.student_id = ?
      GROUP BY qr.id, qa.material_id, m.title
      ORDER BY qr.created_at DESC, qr.id DESC
      LIMIT ?
      ''',
      [studentId, limit < 0 ? 0 : limit],
    );
  }

  /// Materials for which at least one quiz attempt has been saved.
  Future<Set<String>> completedQuizMaterialIds() async {
    if (kIsWeb) {
      await _initializeWebStore();
      final resultIds = _webQuizResults
          .where((result) => _asInt(result['student_id']) == studentId)
          .map((result) => _asInt(result['id']))
          .toSet();
      return _webQuizAnswers
          .where((answer) => resultIds.contains(_asInt(answer['result_id'])))
          .map((answer) => answer['material_id'].toString())
          .toSet();
    }

    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT qa.material_id
      FROM quiz_answers qa
      INNER JOIN quiz_results qr ON qr.id = qa.result_id
      WHERE qr.student_id = ?
      ''',
      [studentId],
    );
    return rows.map((row) => row['material_id'].toString()).toSet();
  }

  Future<Map<String, int>> materialMasteryScores() async {
    if (kIsWeb) {
      await _initializeWebStore();
      if (_webCompetencyMapping.isEmpty) {
        _refreshWebCompetencyMapping();
      }

      final totals = <String, List<int>>{};
      for (final row in _webCompetencyMapping) {
        final materialId = row['material_id'].toString();
        totals.putIfAbsent(materialId, () => []);
        totals[materialId]!.add(_asInt(row['mastery_score']));
      }

      return {
        for (final entry in totals.entries)
          entry.key: (entry.value.reduce((a, b) => a + b) / entry.value.length)
              .round(),
      };
    }

    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT material_id, ROUND(AVG(mastery_score)) AS score
      FROM competency_mapping
      WHERE student_id = ?
      GROUP BY material_id
    ''',
      [studentId],
    );

    return {
      for (final row in rows)
        row['material_id'] as String: _asInt(row['score']),
    };
  }

  Future<int> completedChallengeLevels() async {
    if (kIsWeb) {
      await _initializeWebStore();
      return _webChallengeResults
          .map((result) {
            return _asInt(result['level_id']);
          })
          .toSet()
          .length;
    }

    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(DISTINCT level_id)
            FROM challenge_results
            WHERE student_id = ?
          ''',
            [studentId],
          ),
        ) ??
        0;
  }

  Future<int> completedSubmaterials() async {
    if (kIsWeb) {
      await _initializeWebStore();
      return _webCompletedSubmaterials.length;
    }

    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(DISTINCT submaterial_id)
            FROM learning_progress
            WHERE student_id = ? AND completed_at IS NOT NULL
          ''',
            [studentId],
          ),
        ) ??
        0;
  }

  Future<int> totalSubmaterials() async {
    if (kIsWeb) {
      await _initializeWebStore();
      return _webMaterials().fold<int>(0, (total, material) {
        return total +
            ((material['submaterials'] as List<dynamic>?) ?? const []).length;
      });
    }

    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM submaterials'),
        ) ??
        0;
  }

  Future<int> latestQuizScore() async {
    if (kIsWeb) {
      await _initializeWebStore();
      if (_webQuizResults.isEmpty) {
        return 0;
      }

      return _asInt(_webQuizResults.last['score_percent']);
    }

    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT score_percent
            FROM quiz_results
            WHERE student_id = ?
            ORDER BY created_at DESC, id DESC
            LIMIT 1
          ''',
            [studentId],
          ),
        ) ??
        0;
  }

  Future<bool> hasQuizResult() async {
    if (kIsWeb) {
      await _initializeWebStore();
      return _webQuizResults.isNotEmpty;
    }

    final db = await database;
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM quiz_results WHERE student_id = ?',
            [studentId],
          ),
        ) ??
        0;

    return count > 0;
  }

  Future<void> addActivity({
    required String type,
    required String? refId,
    required String title,
    required String description,
  }) async {
    if (kIsWeb) {
      await _initializeWebStore();
      _webActivities.add({
        'id': _webActivities.length + 1,
        'student_id': studentId,
        'type': type,
        'ref_id': refId,
        'title': title,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      });
      // Results/progress are appended before addActivity is called, so saving
      // here persists the complete event and its associated learning data.
      await _persistWebState();
      return;
    }

    final db = await database;
    await db.insert('activities', {
      'student_id': studentId,
      'type': type,
      'ref_id': refId,
      'title': title,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveLearningReport(Map<String, Object?> report) async {
    if (kIsWeb) {
      await _initializeWebStore();
      _webReports.add({
        'id': _webReports.length + 1,
        'student_id': studentId,
        'report_json': jsonEncode(report),
        'created_at': DateTime.now().toIso8601String(),
      });
      await _persistWebState();
      return;
    }

    final db = await database;
    await db.insert('learning_reports', {
      'student_id': studentId,
      'report_json': jsonEncode(report),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _initializeWebStore() async {
    if (_webSeed == null) {
      final seedRaw = await rootBundle.loadString(
        'assets/data/techstep_seed.json',
      );
      _webSeed = jsonDecode(seedRaw) as Map<String, dynamic>;
    }

    // The seed content is shared; learning results are not. Avoid restoring
    // another account's state when the active authenticated user changes.
    if (_webLoadedStudentId == _studentId) {
      return;
    }

    _clearWebUserState();

    var savedState = await _webPreferences.getString(_webStateKey);

    // Migrate the old single-user Web data to the first registered account
    // only. Never copy that legacy state into a newly registered account.
    if ((savedState == null || savedState.isEmpty) && _studentId == 1) {
      savedState = await _webPreferences.getString(_legacyWebStateKey);
      if (savedState != null && savedState.isNotEmpty) {
        await _webPreferences.setString(_webStateKey, savedState);
      }
    }

    if (savedState != null && savedState.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedState);
        if (decoded is Map) {
          _restoreWebState(decoded);
        }
      } catch (_) {
        // Keep the app usable if the saved browser state is malformed.
      }
    }

    _webLoadedStudentId = _studentId;
    _refreshWebCompetencyMapping();
  }

  void _clearWebUserState() {
    _webCompletedSubmaterials.clear();
    _webSubmaterialViewedAt.clear();
    _webActivities.clear();
    _webQuizResults.clear();
    _webQuizAnswers.clear();
    _webChallengeResults.clear();
    _webChallengeAnswers.clear();
    _webCompetencyMapping.clear();
    _webRecommendations.clear();
    _webReports.clear();
  }

  void _restoreWebState(Map decoded) {
    _webCompletedSubmaterials.clear();
    _webSubmaterialViewedAt.clear();
    _webActivities.clear();
    _webQuizResults.clear();
    _webQuizAnswers.clear();
    _webChallengeResults.clear();
    _webChallengeAnswers.clear();
    _webReports.clear();

    final completed = decoded['completed_submaterials'];
    if (completed is List) {
      _webCompletedSubmaterials.addAll(
        completed.map((item) => item.toString()),
      );
    }

    final viewedAt = decoded['submaterial_viewed_at'];
    if (viewedAt is Map) {
      for (final entry in viewedAt.entries) {
        _webSubmaterialViewedAt[entry.key.toString()] = entry.value.toString();
      }
    }

    _webActivities.addAll(_decodeWebMapList(decoded['activities']));
    _webQuizResults.addAll(_decodeWebMapList(decoded['quiz_results']));
    _webQuizAnswers.addAll(_decodeWebMapList(decoded['quiz_answers']));
    _webChallengeResults.addAll(
      _decodeWebMapList(decoded['challenge_results']),
    );
    _webChallengeAnswers.addAll(
      _decodeWebMapList(decoded['challenge_answers']),
    );
    _webReports.addAll(_decodeWebMapList(decoded['reports']));
  }

  List<Map<String, Object?>> _decodeWebMapList(Object? value) {
    if (value is! List) {
      return <Map<String, Object?>>[];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => item.map<String, Object?>(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList();
  }

  Future<void> _persistWebState() async {
    final state = <String, Object?>{
      'completed_submaterials': _webCompletedSubmaterials.toList(),
      'submaterial_viewed_at': _webSubmaterialViewedAt,
      'activities': _webActivities,
      'quiz_results': _webQuizResults,
      'quiz_answers': _webQuizAnswers,
      'challenge_results': _webChallengeResults,
      'challenge_answers': _webChallengeAnswers,
      'reports': _webReports,
    };

    await _webPreferences.setString(_webStateKey, jsonEncode(state));
  }

  List<Map<String, dynamic>> _webMaterials() {
    return ((_webSeed?['materials'] as List<dynamic>?) ?? const [])
        .cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> _webCompetencies() {
    return ((_webSeed?['competencies'] as List<dynamic>?) ?? const [])
        .cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> _webChallengeLevels() {
    return ((_webSeed?['challenge_levels'] as List<dynamic>?) ?? const [])
        .cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> _webSubmaterialsForMaterial(String materialId) {
    final material = _webMaterials().firstWhere(
      (item) => item['id'] == materialId,
      orElse: () => const {},
    );

    return ((material['submaterials'] as List<dynamic>?) ?? const [])
        .cast<Map<String, dynamic>>();
  }

  List<LearningQuestion> _webQuestions({required String source, int? levelId}) {
    final key = source == 'quiz' ? 'quiz_questions' : 'challenge_questions';
    final rawQuestions = ((_webSeed?[key] as List<dynamic>?) ?? const [])
        .cast<Map<String, dynamic>>();
    final filtered =
        rawQuestions.where((question) {
          if (levelId == null) {
            return true;
          }

          return _asInt(question['level_id']) == levelId;
        }).toList()..sort((a, b) {
          final levelCompare = _asInt(a['level_id'])
              .compareTo(_asInt(b['level_id']));
          if (levelCompare != 0) {
            return levelCompare;
          }

          return _asInt(a['order']).compareTo(_asInt(b['order']));
        });

    return filtered.map((question) {
      final materialId = question['material_id'].toString();
      final competencyId = question['competency_id'].toString();
      final material = _webMaterials().firstWhere(
        (item) => item['id'] == materialId,
        orElse: () => const {},
      );
      final competency = _webCompetencies().firstWhere(
        (item) => item['id'] == competencyId,
        orElse: () => const {},
      );
      final options = ((question['options'] as List<dynamic>?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map((option) {
            return AnswerOption(
              key: option['key'].toString(),
              text: option['text'].toString(),
            );
          })
          .toList();

      return LearningQuestion.fromMap({
        'id': question['id'],
        'source': source,
        'code': question['code'],
        'level_id': question['level_id'],
        'material_id': materialId,
        'material_title': material['title'] ?? '',
        'competency_id': competencyId,
        'competency_title': competency['title'] ?? '',
        'question_text': question['question'],
        'correct_option_key': question['correct_option_key'],
        'order_index': question['order'],
      }, options);
    }).toList();
  }

  void _refreshWebCompetencyMapping() {
    _webCompetencyMapping.clear();
    _webRecommendations.clear();

    final latestQuizIdByMaterial = <String, int>{};
    final validResultIds = _webQuizResults
        .where((result) => _asInt(result['student_id']) == studentId)
        .map((result) => _asInt(result['id']))
        .toSet();
    for (final answer in _webQuizAnswers) {
      final resultId = _asInt(answer['result_id']);
      if (!validResultIds.contains(resultId)) {
        continue;
      }
      final materialId = answer['material_id'].toString();
      final previousId = latestQuizIdByMaterial[materialId] ?? 0;
      if (resultId > previousId) {
        latestQuizIdByMaterial[materialId] = resultId;
      }
    }

    for (final competency in _webCompetencies()) {
      final competencyId = competency['id'].toString();
      final materialId = competency['material_id'].toString();
      final title = competency['title'].toString();
      final latestQuizId = latestQuizIdByMaterial[materialId];
      final quizScore = latestQuizId == null
          ? null
          : _webScoreForRows(
              _webQuizAnswers.where((answer) {
                return _asInt(answer['result_id']) == latestQuizId &&
                    answer['competency_id'].toString() == competencyId;
              }).toList(),
            );
      final challengeScore = _webScoreForRows(
        _webChallengeAnswers.where((answer) {
          return answer['competency_id'].toString() == competencyId;
        }).toList(),
      );
      final activityScore = _webActivityScore(materialId);
      final masteryScore = _masteryScore(
        quizScore: quizScore,
        challengeScore: challengeScore,
        activityScore: activityScore,
      );
      final status = competencyStatus(masteryScore);
      final recommendation = _recommendation(
        title: title,
        status: status,
        score: masteryScore,
      );

      _webCompetencyMapping.add({
        'competency_id': competencyId,
        'material_id': materialId,
        'title': title,
        'mastery_score': masteryScore,
        'status': status,
        'message': masteryScore < 80 ? recommendation : '',
      });

      if (masteryScore < 80) {
        _webRecommendations.add({
          'id': _webRecommendations.length + 1,
          'student_id': studentId,
          'competency_id': competencyId,
          'material_id': materialId,
          'message': recommendation,
          'status': status,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  int? _webScoreForRows(List<Map<String, Object?>> rows) {
    if (rows.isEmpty) {
      return null;
    }

    final correct = rows.where((row) => row['is_correct'] == 1).length;
    return _percentage(correct, rows.length);
  }

  int _webActivityScore(String materialId) {
    final submaterials = _webSubmaterialsForMaterial(materialId);
    if (submaterials.isEmpty) {
      return 0;
    }

    final completed = submaterials.where((submaterial) {
      return _webCompletedSubmaterials.contains(submaterial['id']);
    }).length;

    return _percentage(completed, submaterials.length);
  }

  int _percentage(int correct, int total) {
    if (total == 0) {
      return 0;
    }

    return ((correct / total) * 100).round();
  }

  int _asInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}
