import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';

/// Displays simulated health band data: heart rate, blood pressure,
/// steps, and fall detection. No real hardware is connected — this
/// screen demonstrates the concept using HealthProvider's simulated feed.
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-connect when the screen opens, similar to how a real band
    // would auto-reconnect once paired.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthProvider>();
    final data = provider.latest;

    return Scaffold(
      appBar: AppBar(title: const Text('Health Band')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _ConnectionStatusCard(
              isConnected: provider.isConnected,
              isConnecting: provider.isConnecting,
            ),
            const SizedBox(height: 16),

            if (data != null && data.fallDetected) ...[
              const _FallAlertBanner(),
              const SizedBox(height: 16),
            ],

            if (data == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _VitalCard(
                      icon: Icons.favorite_rounded,
                      label: 'Heart Rate',
                      value: '${data.heartRate}',
                      unit: 'bpm',
                      isWarning: data.heartRateHigh || data.heartRateLow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VitalCard(
                      icon: Icons.bloodtype_rounded,
                      label: 'Blood Pressure',
                      value: data.bloodPressureLabel,
                      unit: 'mmHg',
                      isWarning: data.bloodPressureHigh,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _VitalCard(
                      icon: Icons.directions_walk_rounded,
                      label: 'Steps Today',
                      value: '${data.steps}',
                      unit: 'steps',
                      isWarning: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VitalCard(
                      icon: Icons.shield_rounded,
                      label: 'Fall Detection',
                      value: data.fallDetected ? 'Alert' : 'Normal',
                      unit: '',
                      isWarning: data.fallDetected,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 28),
            const Text(
              'This is a concept preview. No physical health band is '
                  'connected — data shown here is simulated to demonstrate '
                  'how a future wearable integration would work.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            OutlinedButton.icon(
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Simulate Fall (Demo)'),
              onPressed: () => context.read<HealthProvider>().triggerFallDemo(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionStatusCard extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;

  const _ConnectionStatusCard({
    required this.isConnected,
    required this.isConnecting,
  });

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? AppColors.success : AppColors.warning;
    final label = isConnecting
        ? 'Connecting to health band...'
        : isConnected
        ? 'Health Band Connected'
        : 'Health Band Not Connected';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.watch_rounded, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: AppTextSizes.importantTask,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isConnecting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (isConnected)
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
          ],
        ),
      ),
    );
  }
}

class _FallAlertBanner extends StatelessWidget {
  const _FallAlertBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.overdue.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.overdue, size: 32),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Fall Detected! A caregiver notification has been sent.',
                style: TextStyle(
                  fontSize: AppTextSizes.normalText,
                  fontWeight: FontWeight.w700,
                  color: AppColors.overdue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool isWarning;

  const _VitalCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppColors.overdue : AppColors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}