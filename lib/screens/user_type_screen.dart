import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class _UserTypeOption {
  final String value;
  final String label;
  final IconData icon;

  const _UserTypeOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class UserTypeScreen extends StatefulWidget {
  const UserTypeScreen({super.key});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  final StorageService _storage = StorageService();
  String? _selected;

  final List<_UserTypeOption> _options = const [
    _UserTypeOption(
      value: 'elderly',
      label: 'Elderly Person',
      icon: Icons.elderly_rounded,
    ),
    _UserTypeOption(
      value: 'family',
      label: 'Family Member',
      icon: Icons.family_restroom_rounded,
    ),
    _UserTypeOption(
      value: 'caregiver',
      label: 'Caregiver',
      icon: Icons.medical_services_rounded,
    ),
  ];

  Future<void> _confirmSelection() async {
    if (_selected == null) return;
    await _storage.saveUserType(_selected!);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Who is using\nRemindly?',
                style: TextStyle(
                  fontSize: AppTextSizes.appTitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This helps us set up the app for you.',
                style: TextStyle(
                  fontSize: AppTextSizes.normalText,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    final isSelected = _selected == option.value;
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => setState(() => _selected = option.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 22),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE0E4E9),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              option.icon,
                              size: 36,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                option.label,
                                style: TextStyle(
                                  fontSize: AppTextSizes.importantTask,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.primary, size: 28),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selected == null ? null : _confirmSelection,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}