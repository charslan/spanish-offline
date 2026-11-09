import '../models/course_models.dart';

/// Simplified SM-2 spaced repetition algorithm.
/// Fully offline and deterministic.
class SrsService {
  /// Update a ReviewCard based on the user's rating.
  static ReviewCard processReview(ReviewCard card, ReviewRating rating) {
    final now = DateTime.now();
    double ease = card.easeFactor;
    int reps = card.repetitions;
    int interval = card.intervalDays;
    int lapses = card.lapses;

    switch (rating) {
      case ReviewRating.again:
        reps = 0;
        lapses += 1;
        interval = 0; // review again today / very soon
        ease = (ease - 0.2).clamp(1.3, 2.5);
        break;
      case ReviewRating.hard:
        if (reps == 0) {
          interval = 1;
        } else {
          interval = (interval * 1.2).round().clamp(1, 3650);
        }
        ease = (ease - 0.15).clamp(1.3, 2.5);
        reps += 1;
        break;
      case ReviewRating.good:
        if (reps == 0) {
          interval = 1;
        } else if (reps == 1) {
          interval = 3;
        } else {
          interval = (interval * ease).round().clamp(1, 3650);
        }
        reps += 1;
        break;
      case ReviewRating.easy:
        if (reps == 0) {
          interval = 3;
        } else if (reps == 1) {
          interval = 7;
        } else {
          interval = (interval * ease * 1.3).round().clamp(1, 3650);
        }
        ease = (ease + 0.15).clamp(1.3, 2.5);
        reps += 1;
        break;
    }

    final nextReview = now.add(Duration(days: interval == 0 ? 0 : interval));

    return card.copyWith(
      easeFactor: ease,
      intervalDays: interval,
      repetitions: reps,
      nextReview: nextReview,
      lastReviewed: now,
      lapses: lapses,
    );
  }

  /// Create a brand-new card for a vocabulary item (first time seen).
  static ReviewCard createNewCard(String vocabularyId) {
    return ReviewCard(
      vocabularyId: vocabularyId,
      easeFactor: 2.5,
      intervalDays: 0,
      repetitions: 0,
      nextReview: DateTime.now(), // due immediately
      lapses: 0,
    );
  }

  /// Returns true if the card is due for review (including today).
  static bool isDue(ReviewCard card, {DateTime? now}) {
    final current = now ?? DateTime.now();
    // Compare date only (ignore time of day for daily reviews)
    final dueDate = DateTime(card.nextReview.year, card.nextReview.month, card.nextReview.day);
    final today = DateTime(current.year, current.month, current.day);
    return !dueDate.isAfter(today);
  }
}
