import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress.dart';
import '../models/course_models.dart';

/// Lightweight local persistence layer.
/// In a full implementation this would use Drift / SQLite.
/// For the initial scaffold we use SharedPreferences + in-memory maps
/// so the app can run and demonstrate flow without code generation.
class DatabaseService {
  static SharedPreferences? _prefs;
  static UserProgress? _cachedProgress;
  static final Map<String, ReviewCard> _reviewCards = {};

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProgress();
    await _loadReviewCards();
  }

  // ---------- User Progress ----------

  static Future<void> _loadProgress() async {
    final prefs = _prefs!;
    final userId = prefs.getString('user_id') ?? 'local_user_1';
    final now = DateTime.now();

    _cachedProgress = UserProgress(
      userId: userId,
      displayName: prefs.getString('display_name') ?? 'Learner',
      currentStreak: prefs.getInt('current_streak') ?? 0,
      longestStreak: prefs.getInt('longest_streak') ?? 0,
      lastStudyDate: prefs.containsKey('last_study_date')
          ? DateTime.tryParse(prefs.getString('last_study_date')!)
          : null,
      totalStudyMinutes: prefs.getInt('total_study_minutes') ?? 0,
      totalLessonsCompleted: prefs.getInt('total_lessons_completed') ?? 0,
      totalWordsLearned: prefs.getInt('total_words_learned') ?? 0,
      dailyGoalMinutes: prefs.getInt('daily_goal_minutes') ?? 10,
      completedLessonIds: (prefs.getStringList('completed_lessons') ?? []).toSet(),
      completedUnitIds: (prefs.getStringList('completed_units') ?? []).toSet(),
      currentLevelId: prefs.getString('current_level_id'),
      currentUnitId: prefs.getString('current_unit_id'),
      createdAt: prefs.containsKey('created_at')
          ? DateTime.tryParse(prefs.getString('created_at')!) ?? now
          : now,
      updatedAt: now,
    );
  }

  static UserProgress get progress => _cachedProgress!;

  static Future<void> saveProgress(UserProgress progress) async {
    _cachedProgress = progress;
    final prefs = _prefs!;
    await prefs.setString('user_id', progress.userId);
    await prefs.setString('display_name', progress.displayName);
    await prefs.setInt('current_streak', progress.currentStreak);
    await prefs.setInt('longest_streak', progress.longestStreak);
    if (progress.lastStudyDate != null) {
      await prefs.setString('last_study_date', progress.lastStudyDate!.toIso8601String());
    }
    await prefs.setInt('total_study_minutes', progress.totalStudyMinutes);
    await prefs.setInt('total_lessons_completed', progress.totalLessonsCompleted);
    await prefs.setInt('total_words_learned', progress.totalWordsLearned);
    await prefs.setInt('daily_goal_minutes', progress.dailyGoalMinutes);
    await prefs.setStringList('completed_lessons', progress.completedLessonIds.toList());
    await prefs.setStringList('completed_units', progress.completedUnitIds.toList());
    if (progress.currentLevelId != null) {
      await prefs.setString('current_level_id', progress.currentLevelId!);
    }
    if (progress.currentUnitId != null) {
      await prefs.setString('current_unit_id', progress.currentUnitId!);
    }
    await prefs.setString('updated_at', progress.updatedAt.toIso8601String());
  }

  static Future<void> markLessonCompleted(String lessonId, {int minutesSpent = 5}) async {
    final p = progress;
    final newCompleted = {...p.completedLessonIds, lessonId};
    final today = DateTime.now();
    int newStreak = p.currentStreak;

    if (p.lastStudyDate == null) {
      newStreak = 1;
    } else {
      final last = DateTime(p.lastStudyDate!.year, p.lastStudyDate!.month, p.lastStudyDate!.day);
      final current = DateTime(today.year, today.month, today.day);
      final diff = current.difference(last).inDays;
      if (diff == 1) {
        newStreak = p.currentStreak + 1;
      } else if (diff > 1) {
        newStreak = 1;
      }
      // same day → keep streak
    }

    final updated = p.copyWith(
      completedLessonIds: newCompleted,
      totalLessonsCompleted: newCompleted.length,
      totalStudyMinutes: p.totalStudyMinutes + minutesSpent,
      currentStreak: newStreak,
      longestStreak: newStreak > p.longestStreak ? newStreak : p.longestStreak,
      lastStudyDate: today,
      updatedAt: today,
    );
    await saveProgress(updated);
  }

  // ---------- Review Cards (SRS) ----------

  static Future<void> _loadReviewCards() async {
    // In production this would come from SQLite.
    // For scaffold we keep an in-memory map that is re-created on demand.
    _reviewCards.clear();
  }

  static ReviewCard? getReviewCard(String vocabularyId) => _reviewCards[vocabularyId];

  static Future<void> saveReviewCard(ReviewCard card) async {
    _reviewCards[card.vocabularyId] = card;
    // Persist would go here
  }

  static List<ReviewCard> getDueCards({DateTime? now}) {
    final current = now ?? DateTime.now();
    return _reviewCards.values.where((c) => SrsService.isDue(c, now: current)).toList();
  }

  static Future<void> ensureCardExists(String vocabularyId) async {
    if (!_reviewCards.containsKey(vocabularyId)) {
      final card = SrsService.createNewCard(vocabularyId);
      await saveReviewCard(card);
    }
  }

  // Helper for future Drift migration
  static Future<String> getDatabasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'lingua_offline.db');
  }
}
