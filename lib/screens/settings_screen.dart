import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/text_scale_provider.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'user_type_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  String? _userType;

  final Map<String, String> _userTypeLabels = const {
    'elderly': 'Elderly Person',
    'family': 'Family Member',
    'caregiver': 'Caregiver',
  };

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final type = await _storage.loadUserType();
    if (mounted) setState(() => _userType = type);
  }

  @override
  Widget build(BuildContext context) {
    final textScale = context.watch<TextScaleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            // Profile / user type
            _SectionLabel('Profile'),
            Card(
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 30),
                title: const Text('User Type',
                    style: TextStyle(fontSize: AppTextSizes.normalText)),
                subtitle: Text(
                  _userType != null
                      ? (_userTypeLabels[_userType] ?? _userType!)
                      : 'Not set',
                  style: const TextStyle(fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UserTypeScreen()),
                  );
                  _loadUserType();
                },
              ),
            ),
            const SizedBox(height: 24),

            // Text size
            _SectionLabel('Text Size'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current: ${textScale.label}',
                      style: const TextStyle(
                        fontSize: AppTextSizes.normalText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _TextSizeOption(label: 'Small', value: 0.9),
                        _TextSizeOption(label: 'Medium', value: 1.0),
                        _TextSizeOption(label: 'Large', value: 1.15),
                        _TextSizeOption(label: 'Extra Large', value: 1.3),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notifications
            _SectionLabel('Notifications'),
            Card(
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const Icon(Icons.notifications_active_rounded,
                    color: AppColors.primary, size: 30),
                title: const Text('Reminder Notifications',
                    style: TextStyle(fontSize: AppTextSizes.normalText)),
                subtitle: const Text('Tap to allow reminders on this device',
                    style: TextStyle(fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final granted =
                  await NotificationService.instance.requestPermission();
                  await NotificationService.instance
                      .requestExactAlarmPermission();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          granted
                              ? 'Notifications are enabled.'
                              : 'Please enable notifications in phone settings.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Language (placeholder — architecture ready, not implemented yet)
            _SectionLabel('Language'),
            Card(
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const Icon(Icons.language_rounded,
                    color: AppColors.primary, size: 30),
                title: const Text('English',
                    style: TextStyle(fontSize: AppTextSizes.normalText)),
                subtitle: const Text('Malay and Tamil coming soon',
                    style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(height: 24),

            // About / Help
            _SectionLabel('About'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    leading: const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 28),
                    title: const Text('About ElderEase',
                        style: TextStyle(fontSize: AppTextSizes.normalText)),
                    onTap: () => _showInfoDialog(
                      context,
                      'About ElderEase',
                      'ElderEase is a simple elderly management system that '
                          'helps you remember and manage important daily '
                          'tasks and appointments.',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    leading: const Icon(Icons.help_outline_rounded,
                        color: AppColors.primary, size: 28),
                    title: const Text('Help',
                        style: TextStyle(fontSize: AppTextSizes.normalText)),
                    onTap: () => _showInfoDialog(
                      context,
                      'Help',
                      'To add a task or appointment, tap the "+ Add Task" '
                          'button. Tap any task to edit it, or swipe it to '
                          'delete. Your progress is shown on the Progress tab.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message, style: const TextStyle(fontSize: 16, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _TextSizeOption extends StatelessWidget {
  final String label;
  final double value;

  const _TextSizeOption({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TextScaleProvider>();
    final isSelected = (provider.scale - value).abs() < 0.01;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => context.read<TextScaleProvider>().setScale(value),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}