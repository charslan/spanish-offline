class UserProgress {
  final String userId;
  final String displayName;
  final String? avatarPath;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;
  final int totalStudyMinutes;
  final int totalLessonsCompleted;
  final int totalWordsLearned;
  final Map<String, double> skillScores; // vocabulary, grammar, listening, speaking
  final Set<String> completedLessonIds;
  final Set<String> completedUnitIds;
  final String? currentLevelId;
  final String? currentUnitId;
  final int dailyGoalMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProgress({
    required this.userId,
    this.displayName = 'Learner',
    this.avatarPath,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.totalStudyMinutes = 0,
    this.totalLessonsCompleted = 0,
    this.totalWordsLearned = 0,
    this.skillScores = const {
      'vocabulary': 0.0,
      'grammar': 0.0,
      'listening': 0.0,
      'speaking': 0.0,
    },
    this.completedLessonIds = const {},
    this.completedUnitIds = const {},
    this.currentLevelId,
    this.currentUnitId,
    this.dailyGoalMinutes = 10,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProgress copyWith({
    String? displayName,
    String? avatarPath,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
    int? totalStudyMinutes,
    int? totalLessonsCompleted,
    int? totalWordsLearned,
    Map<String, double>? skillScores,
    Set<String>? completedLessonIds,
    Set<String>? completedUnitIds,
    String? currentLevelId,
    String? currentUnitId,
    int? dailyGoalMinutes,
    DateTime? updatedAt,
  }) {
    return UserProgress(
      userId: userId,
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
      skillScores: skillScores ?? this.skillScores,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      completedUnitIds: completedUnitIds ?? this.completedUnitIds,
      currentLevelId: currentLevelId ?? this.currentLevelId,
      currentUnitId: currentUnitId ?? this.currentUnitId,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  double get overallProgress {
    // Simple average of skill scores for now
    if (skillScores.isEmpty) return 0.0;
    final sum = skillScores.values.fold(0.0, (a, b) => a + b);
    return sum / skillScores.length;
  }

  bool isLessonCompleted(String lessonId) => completedLessonIds.contains(lessonId);
  bool isUnitCompleted(String unitId) => completedUnitIds.contains(unitId);
}
