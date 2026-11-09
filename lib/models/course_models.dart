/// Core content models for the offline language learning app.
/// Designed to be serializable from JSON content packs.

enum CefrLevel { a1, a2, b1, b2, c1 }

extension CefrLevelX on CefrLevel {
  String get label {
    switch (this) {
      case CefrLevel.a1:
        return 'A1 · Beginner';
      case CefrLevel.a2:
        return 'A2 · Elementary';
      case CefrLevel.b1:
        return 'B1 · Intermediate';
      case CefrLevel.b2:
        return 'B2 · Upper Intermediate';
      case CefrLevel.c1:
        return 'C1 · Advanced';
    }
  }

  String get shortLabel => name.toUpperCase();
}

enum ExerciseType {
  multipleChoice,
  fillBlank,
  matching,
  sentenceReorder,
  listenSelect,
  speakRecord,
  trueFalse,
}

class Course {
  final String id;
  final String languageCode; // e.g. "es"
  final String languageName; // e.g. "Spanish"
  final String baseLanguageCode; // e.g. "en"
  final List<Level> levels;

  const Course({
    required this.id,
    required this.languageCode,
    required this.languageName,
    required this.baseLanguageCode,
    required this.levels,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      languageCode: json['languageCode'] as String,
      languageName: json['languageName'] as String,
      baseLanguageCode: json['baseLanguageCode'] as String,
      levels: (json['levels'] as List)
          .map((e) => Level.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Level {
  final String id;
  final CefrLevel cefr;
  final String title;
  final String description;
  final List<Unit> units;

  const Level({
    required this.id,
    required this.cefr,
    required this.title,
    required this.description,
    required this.units,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
      cefr: CefrLevel.values.firstWhere(
        (e) => e.name == (json['cefr'] as String).toLowerCase(),
        orElse: () => CefrLevel.a1,
      ),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      units: (json['units'] as List)
          .map((e) => Unit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Unit {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;
  final bool isCheckpoint;

  const Unit({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
    this.isCheckpoint = false,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      lessons: (json['lessons'] as List)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      isCheckpoint: json['isCheckpoint'] as bool? ?? false,
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String? subtitle;
  final int order;
  final int estimatedMinutes;
  final List<LessonSection> sections;
  final List<String> vocabularyIds; // references to VocabularyItem ids

  const Lesson({
    required this.id,
    required this.title,
    this.subtitle,
    required this.order,
    this.estimatedMinutes = 5,
    required this.sections,
    this.vocabularyIds = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      order: json['order'] as int? ?? 0,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 5,
      sections: (json['sections'] as List)
          .map((e) => LessonSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      vocabularyIds: (json['vocabularyIds'] as List?)?.cast<String>() ?? [],
    );
  }
}

class LessonSection {
  final String id;
  final String type; // vocab, dialogue, grammar, exercise, speaking
  final String? title;
  final Map<String, dynamic> content; // flexible payload per type

  const LessonSection({
    required this.id,
    required this.type,
    this.title,
    required this.content,
  });

  factory LessonSection.fromJson(Map<String, dynamic> json) {
    return LessonSection(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String?,
      content: Map<String, dynamic>.from(json['content'] as Map),
    );
  }
}

class VocabularyItem {
  final String id;
  final String word; // target language
  final String translation; // base language
  final String? phonetic;
  final String? exampleSentence;
  final String? exampleTranslation;
  final String? audioPath;
  final String? imagePath;
  final String? partOfSpeech;
  final List<String> tags;

  const VocabularyItem({
    required this.id,
    required this.word,
    required this.translation,
    this.phonetic,
    this.exampleSentence,
    this.exampleTranslation,
    this.audioPath,
    this.imagePath,
    this.partOfSpeech,
    this.tags = const [],
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      phonetic: json['phonetic'] as String?,
      exampleSentence: json['exampleSentence'] as String?,
      exampleTranslation: json['exampleTranslation'] as String?,
      audioPath: json['audioPath'] as String?,
      imagePath: json['imagePath'] as String?,
      partOfSpeech: json['partOfSpeech'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
    );
  }
}

/// Runtime SRS state stored in local DB
class ReviewCard {
  final String vocabularyId;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime nextReview;
  final DateTime? lastReviewed;
  final int lapses;

  const ReviewCard({
    required this.vocabularyId,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    required this.nextReview,
    this.lastReviewed,
    this.lapses = 0,
  });

  ReviewCard copyWith({
    double? easeFactor,
    int? intervalDays,
    int? repetitions,
    DateTime? nextReview,
    DateTime? lastReviewed,
    int? lapses,
  }) {
    return ReviewCard(
      vocabularyId: vocabularyId,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      nextReview: nextReview ?? this.nextReview,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      lapses: lapses ?? this.lapses,
    );
  }
}

enum ReviewRating { again, hard, good, easy }
