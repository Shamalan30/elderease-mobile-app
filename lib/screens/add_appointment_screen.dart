import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';

/// Used for both creating a new appointment and editing an existing one.
class AddAppointmentScreen extends StatefulWidget {
  final Appointment? existingAppointment;
  final DateTime? initialDate;

  const AddAppointmentScreen({
    super.key,
    this.existingAppointment,
    this.initialDate,
  });

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _reminderEnabled = true;
  int _reminderMinutesBefore = 1440; // 1 day before, default per spec

  String? _errorText;

  bool get _isEditing => widget.existingAppointment != null;

  // Label -> minutes mapping for the reminder picker
  final List<MapEntry<String, int>> _reminderOptions = const [
    MapEntry('30 min before', 30),
    MapEntry('1 hour before', 60),
    MapEntry('1 day before', 1440),
    MapEntry('2 days before', 2880),
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAppointment;
    if (existing != null) {
      _titleController.text = existing.title;
      _locationController.text = existing.location;
      _notesController.text = existing.notes;
      _date = existing.date;
      _time = existing.time;
      _reminderEnabled = existing.reminderEnabled;
      _reminderMinutesBefore = existing.reminderMinutesBefore;
    } else {
      _date = widget.initialDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = 'Please enter an appointment name.');
      return;
    }

    final provider = context.read<TaskProvider>();

    if (_isEditing) {
      final updated = widget.existingAppointment!.copyWith(
        title: title,
        date: _date,
        time: _time,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
        reminderEnabled: _reminderEnabled,
        reminderMinutesBefore: _reminderMinutesBefore,
      );
      provider.updateAppointment(updated);
    } else {
      final newAppointment = Appointment(
        id: provider.generateId(),
        title: title,
        date: _date,
        time: _time,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
        reminderEnabled: _reminderEnabled,
        reminderMinutesBefore: _reminderMinutesBefore,
      );
      provider.addAppointment(newAppointment);
    }

    Navigator.of(context).pop();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Appointment?'),
        content: Text('Remove "${widget.existingAppointment!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<TaskProvider>()
                  .deleteAppointment(widget.existingAppointment!.id);
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.overdue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Appointment' : 'Add Appointment'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Appointment Name',
                  style: TextStyle(
                      fontSize: AppTextSizes.importantTask,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: AppTextSizes.normalText),
                decoration: InputDecoration(
                  hintText: 'e.g. Doctor Appointment',
                  errorText: _errorText,
                ),
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: _PickerField(
                      label: 'Date',
                      value: DateFormat('d MMMM yyyy').format(_date),
                      icon: Icons.calendar_today_rounded,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerField(
                      label: 'Time',
                      value: _time.format(context),
                      icon: Icons.access_time_rounded,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              const Text('Location',
                  style: TextStyle(
                      fontSize: AppTextSizes.importantTask,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                style: const TextStyle(fontSize: AppTextSizes.normalText),
                decoration: const InputDecoration(
                  hintText: 'e.g. Klinik Kesihatan',
                ),
              ),
              const SizedBox(height: 22),

              const Text('Reminder',
                  style: TextStyle(
                      fontSize: AppTextSizes.importantTask,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable reminder',
                    style: TextStyle(fontSize: AppTextSizes.normalText)),
                value: _reminderEnabled,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _reminderEnabled = v),
              ),
              if (_reminderEnabled)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _reminderOptions.map((option) {
                    final isSelected = _reminderMinutesBefore == option.value;
                    return ChoiceChip(
                      label: Text(option.key),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _reminderMinutesBefore = option.value),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 22),

              const Text('Notes',
                  style: TextStyle(
                      fontSize: AppTextSizes.importantTask,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(fontSize: AppTextSizes.normalText),
                decoration: const InputDecoration(
                  hintText: 'Optional notes',
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save Changes' : 'Save Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: AppTextSizes.importantTask,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD0D5DD)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}