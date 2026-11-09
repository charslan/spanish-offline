import 'package:flutter/material.dart';

import '../models/course_models.dart';
import '../services/content_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _sectionIndex = 0;
  bool _completed = false;

  LessonSection get currentSection => widget.lesson.sections[_sectionIndex];
  bool get isLast => _sectionIndex >= widget.lesson.sections.length - 1;

  void _next() {
    if (isLast) {
      _finishLesson();
    } else {
      setState(() => _sectionIndex++);
    }
  }

  Future<void> _finishLesson() async {
    await DatabaseService.markLessonCompleted(
      widget.lesson.id,
      minutesSpent: widget.lesson.estimatedMinutes,
    );
    setState(() => _completed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson Complete')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration, size: 80, color: AppTheme.accentGreen),
                const SizedBox(height: 24),
                Text(
                  '¡Bien hecho!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You completed “${widget.lesson.title}”',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Course'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_sectionIndex + 1) / widget.lesson.sections.length,
            backgroundColor: Colors.grey.shade200,
            color: AppTheme.primaryBlue,
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildSection(currentSection),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(isLast ? 'Finish Lesson' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(LessonSection section) {
    switch (section.type) {
      case 'vocab':
        return _VocabSection(section: section);
      case 'dialogue':
        return _DialogueSection(section: section);
      case 'exercise':
        return _ExerciseSection(section: section, onAnswered: () {});
      case 'speaking':
        return _SpeakingSection(section: section);
      default:
        return Text('Section type “${section.type}” not yet implemented');
    }
  }
}

class _VocabSection extends StatelessWidget {
  final LessonSection section;
  const _VocabSection({required this.section});

  @override
  Widget build(BuildContext context) {
    final ids = (section.content['items'] as List?)?.cast<String>() ?? [];
    final items = ids.map((id) => ContentService.getVocab(id)).whereType<VocabularyItem>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null)
          Text(
            section.title!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 16),
        ...items.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  item.word,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.translation),
                    if (item.exampleSentence != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.exampleSentence!,
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up_rounded),
                  onPressed: () {
                    // TODO: play audio if available
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Audio: ${item.word}')),
                    );
                  },
                ),
              ),
            )),
      ],
    );
  }
}

class _DialogueSection extends StatelessWidget {
  final LessonSection section;
  const _DialogueSection({required this.section});

  @override
  Widget build(BuildContext context) {
    final lines = (section.content['lines'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null)
          Text(
            section.title!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 16),
        ...lines.map((line) {
          final map = Map<String, dynamic>.from(line as Map);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  map['speaker'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        map['text'] ?? '',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      if (map['translation'] != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          map['translation'],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ExerciseSection extends StatefulWidget {
  final LessonSection section;
  final VoidCallback onAnswered;
  const _ExerciseSection({required this.section, required this.onAnswered});

  @override
  State<_ExerciseSection> createState() => _ExerciseSectionState();
}

class _ExerciseSectionState extends State<_ExerciseSection> {
  int? _selected;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final type = widget.section.content['type'] as String? ?? 'multipleChoice';

    if (type == 'multipleChoice') {
      final question = widget.section.content['question'] as String? ?? '';
      final options = (widget.section.content['options'] as List?)?.cast<String>() ?? [];
      final correct = widget.section.content['correctIndex'] as int? ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.section.title ?? 'Practice',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(question, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ...List.generate(options.length, (i) {
            final isCorrect = i == correct;
            final isSelected = _selected == i;
            Color? bg;
            if (_revealed) {
              if (isCorrect) bg = AppTheme.accentGreen.withOpacity(0.2);
              else if (isSelected) bg = AppTheme.accentRed.withOpacity(0.2);
            } else if (isSelected) {
              bg = AppTheme.primaryBlue.withOpacity(0.15);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: bg ?? Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _revealed
                      ? null
                      : () {
                          setState(() {
                            _selected = i;
                            _revealed = true;
                          });
                          widget.onAnswered();
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Text(options[i], style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }

    // fillBlank fallback
    return const Text('Exercise type coming soon');
  }
}

class _SpeakingSection extends StatelessWidget {
  final LessonSection section;
  const _SpeakingSection({required this.section});

  @override
  Widget build(BuildContext context) {
    final prompt = section.content['prompt'] as String? ?? '';
    final translation = section.content['translation'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title ?? 'Speaking Practice',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  prompt,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  translation,
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Icon(Icons.mic, size: 64, color: AppTheme.primaryBlue),
                const SizedBox(height: 12),
                const Text('Tap to record (coming soon)'),
                const SizedBox(height: 8),
                Text(
                  'Compare your pronunciation with the model audio',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
