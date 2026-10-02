import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/progress_card.dart';
import 'add_task_screen.dart';
import 'tasks_screen.dart';
import 'calendar_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import 'health_screen.dart';

/// The main shell of the app: bottom navigation bar controlling
/// Home / Tasks / Calendar / Health / Progress, plus a Settings entry point.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<Widget> _pages = const [
    _HomeDashboard(),
    TasksScreen(),
    CalendarScreen(),
    HealthScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_navIndex]),
      floatingActionButton: _navIndex == 0 || _navIndex == 1
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Task',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_rounded),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final today = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM').format(today);
    final (completed, total) = provider.todayProgress;
    final nextTask = provider.nextTask;
    final todayTasks = provider.todayTasks;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: logo + greeting + settings shortcut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/remindly_logo.png',
                width: 44,
                height: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: const TextStyle(
                        fontSize: AppTextSizes.appTitle,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: AppTextSizes.normalText,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded, size: 30),
                color: AppColors.textSecondary,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Today's progress
          ProgressCard(
            label: "Today's Progress",
            completed: completed,
            total: total,
          ),
          const SizedBox(height: 20),

          // Health snapshot (only shows once Health tab has connected at
          // least once during this session — simulated wearable data)
          Consumer<HealthProvider>(
            builder: (context, healthProvider, _) {
              final data = healthProvider.latest;
              if (data == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite_rounded,
                            color: AppColors.overdue, size: 28),
                        const SizedBox(width: 10),
                        Text('${data.heartRate} bpm',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 20),
                        const Icon(Icons.directions_walk_rounded,
                            color: AppColors.primary, size: 28),
                        const SizedBox(width: 10),
                        Text('${data.steps} steps',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Next task
          if (nextTask != null) ...[
            const Text(
              'NEXT TASK',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            TaskCard(
              task: nextTask,
              onToggleComplete: () =>
                  provider.toggleTaskCompleted(nextTask.id),
            ),
            const SizedBox(height: 24),
          ],

          // Today's tasks list
          const Text(
            "TODAY'S TASKS",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          if (todayTasks.isEmpty)
            _EmptyToday(context: context)
          else
            ...todayTasks.map(
                  (task) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TaskCard(
                  task: task,
                  onToggleComplete: () =>
                      provider.toggleTaskCompleted(task.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyToday extends StatelessWidget {
  final BuildContext context;
  const _EmptyToday({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          children: [
            const Icon(Icons.wb_sunny_rounded,
                size: 44, color: AppColors.secondary),
            const SizedBox(height: 14),
            const Text(
              'No tasks for today.',
              style: TextStyle(
                fontSize: AppTextSizes.importantTask,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your day is clear!',
              style: TextStyle(
                fontSize: AppTextSizes.normalText,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                );
              },
              child: const Text('+ Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}