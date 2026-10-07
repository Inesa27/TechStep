import 'dart:convert';

class LearningMaterial {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String iconKey;
  final String colorHex;
  final String imageAsset;
  final int order;
  final int totalSubmaterials;
  final int completedSubmaterials;
  final int masteryScore;
  final String masteryStatus;

  const LearningMaterial({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.iconKey,
    required this.colorHex,
    required this.imageAsset,
    required this.order,
    required this.totalSubmaterials,
    required this.completedSubmaterials,
    required this.masteryScore,
    required this.masteryStatus,
  });

  double get progress {
    if (totalSubmaterials == 0) {
      return 0;
    }

    return completedSubmaterials / totalSubmaterials;
  }

  factory LearningMaterial.fromMap(Map<String, Object?> map) {
    return LearningMaterial(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconKey: map['icon_key'] as String? ?? 'book',
      colorHex: map['color_hex'] as String? ?? '#4F46E5',
      imageAsset: map['image_asset'] as String? ?? '',
      order: _asInt(map['order_index']),
      totalSubmaterials: _asInt(map['total_submaterials']),
      completedSubmaterials: _asInt(map['completed_submaterials']),
      masteryScore: _asInt(map['mastery_score']),
      masteryStatus: map['mastery_status'] as String? ?? 'Belum Dinilai',
    );
  }
}

class Submaterial {
  final String id;
  final String materialId;
  final String title;
  final String summary;
  final int order;
  final List<ContentBlock> blocks;
  final bool completed;
  final DateTime? lastViewedAt;

  const Submaterial({
    required this.id,
    required this.materialId,
    required this.title,
    required this.summary,
    required this.order,
    required this.blocks,
    required this.completed,
    required this.lastViewedAt,
  });

  factory Submaterial.fromMap(Map<String, Object?> map) {
    final rawBlocks = map['content_json'] as String? ?? '[]';
    final decoded = jsonDecode(rawBlocks) as List<dynamic>;

    return Submaterial(
      id: map['id'] as String,
      materialId: map['material_id'] as String,
      title: map['title'] as String,
      summary: map['summary'] as String? ?? '',
      order: _asInt(map['order_index']),
      blocks: decoded
          .whereType<Map<String, dynamic>>()
          .map(ContentBlock.fromJson)
          .toList(),
      completed: ((map['completed'] as int?) ?? 0) == 1,
      lastViewedAt: _parseDateTime(map['last_viewed_at']),
    );
  }
}

class ContentBlock {
  final String type;
  final String text;
  final String asset;
  final String caption;
  final List<String> headers;
  final List<List<String>> rows;

  const ContentBlock({
    required this.type,
    required this.text,
    required this.asset,
    required this.caption,
    required this.headers,
    required this.rows,
  });

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      type: json['type'] as String? ?? 'paragraph',
      text: json['text'] as String? ?? '',
      asset: json['asset'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      headers: (json['headers'] as List<dynamic>? ?? const []).map((item) {
        return item.toString();
      }).toList(),
      rows: (json['rows'] as List<dynamic>? ?? const []).map((row) {
        return (row as List<dynamic>).map((cell) => cell.toString()).toList();
      }).toList(),
    );
  }
}

class AnswerOption {
  final String key;
  final String text;

  const AnswerOption({required this.key, required this.text});

  factory AnswerOption.fromMap(Map<String, Object?> map) {
    return AnswerOption(
      key: map['option_key'] as String,
      text: map['option_text'] as String,
    );
  }
}

class LearningQuestion {
  final String id;
  final String source;
  final String? code;
  final int? levelId;
  final String materialId;
  final String materialTitle;
  final String competencyId;
  final String competencyTitle;
  final String question;
  final String correctOptionKey;
  final int order;
  final List<AnswerOption> options;

  const LearningQuestion({
    required this.id,
    required this.source,
    required this.code,
    required this.levelId,
    required this.materialId,
    required this.materialTitle,
    required this.competencyId,
    required this.competencyTitle,
    required this.question,
    required this.correctOptionKey,
    required this.order,
    required this.options,
  });

  factory LearningQuestion.fromMap(
    Map<String, Object?> map,
    List<AnswerOption> options,
  ) {
    return LearningQuestion(
      id: map['id'] as String,
      source: map['source'] as String,
      code: map['code'] as String?,
      levelId: _asNullableInt(map['level_id']),
      materialId: map['material_id'] as String,
      materialTitle: map['material_title'] as String? ?? '',
      competencyId: map['competency_id'] as String,
      competencyTitle: map['competency_title'] as String? ?? '',
      question: map['question_text'] as String,
      correctOptionKey: map['correct_option_key'] as String,
      order: _asInt(map['order_index']),
      options: options,
    );
  }
}

class ChallengeLevel {
  final int id;
  final String name;
  final String description;
  final int order;
  final bool completed;
  final int bestScore;

  const ChallengeLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.completed,
    required this.bestScore,
  });

  factory ChallengeLevel.fromMap(Map<String, Object?> map) {
    return ChallengeLevel(
      id: _asInt(map['id']),
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      order: _asInt(map['order_index']),
      completed: ((map['completed'] as int?) ?? 0) == 1,
      bestScore: _asInt(map['best_score']),
    );
  }
}

class CompetencyProgress {
  final String id;
  final String materialId;
  final String title;
  final int masteryScore;
  final String status;
  final String recommendation;

  const CompetencyProgress({
    required this.id,
    required this.materialId,
    required this.title,
    required this.masteryScore,
    required this.status,
    required this.recommendation,
  });

  factory CompetencyProgress.fromMap(Map<String, Object?> map) {
    return CompetencyProgress(
      id: map['competency_id'] as String,
      materialId: map['material_id'] as String,
      title: map['title'] as String,
      masteryScore: _asInt(map['mastery_score']),
      status: map['status'] as String? ?? 'Belum Dinilai',
      recommendation: map['message'] as String? ?? '',
    );
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
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

int? _asNullableInt(Object? value) {
  if (value == null) {
    return null;
  }

  return _asInt(value);
}