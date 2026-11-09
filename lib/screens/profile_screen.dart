import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = DatabaseService.progress;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                  child: Text(
                    progress.displayName.isNotEmpty
                        ? progress.displayName[0].toUpperCase()
                        : 'L',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  progress.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                const Text('Spanish · A1'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Stats grid
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Streak', value: '${progress.currentStreak} days', icon: '🔥')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Lessons', value: '${progress.totalLessonsCompleted}', icon: '📚')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Words', value: '${progress.totalWordsLearned}', icon: '💬')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Minutes', value: '${progress.totalStudyMinutes}', icon: '⏱️')),
            ],
          ),
          const SizedBox(height: 32),

          // Skills
          Text(
            'Skills',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...progress.skillScores.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key[0].toUpperCase() + e.key.substring(1)),
                      Text('${(e.value * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: e.value.clamp(0.0, 1.0),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: Colors.grey.shade200,
                    color: AppTheme.primaryBlue,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.offline_bolt, color: AppTheme.accentGreen),
              title: const Text('Offline Mode'),
              subtitle: const Text('All content available offline'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Ready',
                  style: TextStyle(
                    color: AppTheme.accentGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
