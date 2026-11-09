import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/content_service.dart';
import '../services/database_service.dart';
import '../services/srs_service.dart';
import '../theme/app_theme.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<ReviewCard> _dueCards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDue();
  }

  Future<void> _loadDue() async {
    // Ensure some cards exist for demo
    for (final id in ContentService.vocabulary.keys) {
      await DatabaseService.ensureCardExists(id);
    }
    setState(() {
      _dueCards = DatabaseService.getDueCards();
      _loading = false;
      _currentIndex = 0;
      _showAnswer = false;
    });
  }

  ReviewCard? get currentCard =>
      _dueCards.isEmpty || _currentIndex >= _dueCards.length ? null : _dueCards[_currentIndex];

  VocabularyItem? get currentVocab {
    final card = currentCard;
    if (card == null) return null;
    return ContentService.getVocab(card.vocabularyId);
  }

  Future<void> _rate(ReviewRating rating) async {
    final card = currentCard;
    if (card == null) return;

    final updated = SrsService.processReview(card, rating);
    await DatabaseService.saveReviewCard(updated);

    setState(() {
      _showAnswer = false;
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final vocab = currentVocab;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Review'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _dueCards.isEmpty
                    ? '0 left'
                    : '${_dueCards.length - _currentIndex} left',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: vocab == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 72, color: AppTheme.accentGreen),
                  const SizedBox(height: 16),
                  Text(
                    'All caught up!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('No cards due for review right now.'),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _loadDue,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showAnswer = true),
                      child: Card(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                vocab.word,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (vocab.phonetic != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  vocab.phonetic!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              if (_showAnswer) ...[
                                const Divider(),
                                const SizedBox(height: 16),
                                Text(
                                  vocab.translation,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.primaryBlue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (vocab.exampleSentence != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    vocab.exampleSentence!,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ] else
                                Text(
                                  'Tap to reveal',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_showAnswer)
                    Row(
                      children: [
                        Expanded(
                          child: _RatingButton(
                            label: 'Again',
                            color: AppTheme.accentRed,
                            onTap: () => _rate(ReviewRating.again),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _RatingButton(
                            label: 'Hard',
                            color: AppTheme.accentOrange,
                            onTap: () => _rate(ReviewRating.hard),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _RatingButton(
                            label: 'Good',
                            color: AppTheme.primaryBlue,
                            onTap: () => _rate(ReviewRating.good),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _RatingButton(
                            label: 'Easy',
                            color: AppTheme.accentGreen,
                            onTap: () => _rate(ReviewRating.easy),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showAnswer = true),
                        child: const Text('Show Answer'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
