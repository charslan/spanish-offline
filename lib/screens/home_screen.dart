import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course_models.dart';
import '../services/content_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'lesson_screen.dart';
import 'review_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await ContentService.loadContent();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      const _CourseTab(),
      const ReviewScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'Review',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _CourseTab extends StatelessWidget {
  const _CourseTab();

  @override
  Widget build(BuildContext context) {
    final course = ContentService.course!;
    final progress = DatabaseService.progress;
    final level = course.levels.first; // A1 for now

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text('${course.languageName} · ${level.cefr.shortLabel}'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '${progress.currentStreak}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Overall progress card
        // Progress Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress.overallProgress.clamp(0.0, 1.0),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                            backgroundColor: Colors.grey.shade200,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(progress.overallProgress * 100).round()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${progress.totalLessonsCompleted} lessons · ${progress.totalWordsLearned} words',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Units list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final unit = level.units[index];
                final isCompleted = progress.isUnitCompleted(unit.id);
                final completedLessons = unit.lessons.where((l) => progress.isLessonCompleted(l.id)).length;
                final progressValue = unit.lessons.isEmpty ? 0.0 : completedLessons / unit.lessons.length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _UnitCard(
                    unit: unit,
                    progress: progressValue,
                    isCompleted: isCompleted,
                    onTap: () {
                      final lesson = unit.lessons.firstWhere((l) => !progress.isLessonCompleted(l.id), orElse: () => unit.lessons.first);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson)));
                    },
                  ),
                );
              },
              childCount: level.units.length,
            ),
          ),
                  ),
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _UnitCard extends StatelessWidget {
  final Unit unit;
  final double progress;
  final bool isCompleted;
  final VoidCallback onTap;

  const _UnitCard({
    required this.unit,
    required this.progress,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.accentGreen.withOpacity(0.15)
                      : AppTheme.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.menu_book_rounded,
                  color: isCompleted ? AppTheme.accentGreen : AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                      backgroundColor: Colors.grey.shade200,
                      color: isCompleted ? AppTheme.accentGreen : AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
