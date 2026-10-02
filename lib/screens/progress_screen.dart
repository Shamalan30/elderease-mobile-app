import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_card.dart';

/// Simple motivational progress view: today's completion and this
/// week's completion. No complicated analytics per the MVP spec —
/// just two clear numbers and progress bars.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final (todayCompleted, todayTotal) = provider.todayProgress;
    final (weekCompleted, weekTotal) = provider.weekProgress;

    final hasAnyToday = todayTotal > 0;
    final hasAnyWeek = weekTotal > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: AppTextSizes.appTitle,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'A simple look at how you\'re doing.',
            style: TextStyle(
              fontSize: AppTextSizes.normalText,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          ProgressCard(
            label: 'Today',
            completed: todayCompleted,
            total: todayTotal,
          ),
          const SizedBox(height: 16),
          ProgressCard(
            label: 'This Week',
            completed: weekCompleted,
            total: weekTotal,
          ),
          const SizedBox(height: 24),

          if (hasAnyToday || hasAnyWeek)
            _EncouragementCard(
              todayCompleted: todayCompleted,
              todayTotal: todayTotal,
            ),
        ],
      ),
    );
  }
}

/// A small motivational message that changes based on today's progress.
/// Keeps things positive and simple — no complicated stats to read.
class _EncouragementCard extends StatelessWidget {
  final int todayCompleted;
  final int todayTotal;

  const _EncouragementCard({
    required this.todayCompleted,
    required this.todayTotal,
  });

  String _message() {
    if (todayTotal == 0) return "You're all caught up for today!";
    final ratio = todayCompleted / todayTotal;
    if (ratio >= 1.0) return "Great job! You've completed all your tasks today.";
    if (ratio >= 0.5) return "You're doing well — keep it up!";
    return "You still have some tasks left today. You can do it!";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: AppColors.primary, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _message(),
                style: const TextStyle(
                  fontSize: AppTextSizes.normalText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}