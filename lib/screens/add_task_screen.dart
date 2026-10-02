import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

/// Used for both creating a new task and editing an existing one.
/// Pass [existingTask] to edit, or [initialDate] to pre-fill the date
/// when adding from a specific day (e.g. tapped "+ Add Task" on Tasks screen).
class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;
  final DateTime? initialDate;

  const AddTaskScreen({super.key, this.existingTask, this.initialDate});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  TaskCategory _category = TaskCategory.medication;
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  bool _reminderEnabled = true;
  int _reminderMinutesBefore = 10;

  String? _errorText;

  bool get _isEditing => widget.existingTask != null;

  final List<int> _reminderOptions = const [5, 10, 15, 30, 60];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTask;
    if (existing != null) {
      _titleController.text = existing.title;
      _notesController.text = existing.notes;
      _category = existing.category;
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
      setState(() => _errorText = 'Please enter a task.');
      return;
    }

    final provider = context.read<TaskProvider>();

    if (_isEditing) {
      final updated = widget.existingTask!.copyWith(
        title: title,
        category: _category,
        date: _date,
        time: _time,
        notes: _notesController.text.trim(),
        reminderEnabled: _reminderEnabled,
        reminderMinutesBefore: _reminderMinutesBefore,
      );
      provider.updateTask(updated);
    } else {
      final newTask = Task(
        id: provider.generateId(),
        title: title,
        category: _category,
        date: _date,
        time: _time,
        notes: _notesController.text.trim(),
        reminderEnabled: _reminderEnabled,
        reminderMinutesBefore: _reminderMinutesBefore,
      );
      provider.addTask(newTask);
    }

    Navigator.of(context).pop();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task?'),
        content: Text('Remove "${widget.existingTask!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(widget.existingTask!.id);
              Navigator.of(dialogContext).pop(); // close dialog
              Navigator.of(context).pop(); // close screen
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
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
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
              const Text('Task Name',
                  style: TextStyle(
                      fontSize: AppTextSizes.importantTask,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: AppTextSizes.normalText),
                decoration: InputDecoration(
                  hintText: 'e.g. Take Blood Pressure Medicine',
                  errorText: _errorText,
                ),
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
              ),
              const SizedBox(height: 22),

              const Text('Category',
                  style: TextStyle(
                      fontSize: AppTextSizes.importantTask,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: TaskCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  return ChoiceChip(
                    label: Text(cat.label),
                    avatar: Icon(cat.icon,
                        size: 18,
                        color: isSelected ? Colors.white : AppColors.primary),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _category = cat),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 15,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  );
                }).toList(),
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
                  children: _reminderOptions.map((minutes) {
                    final isSelected = _reminderMinutesBefore == minutes;
                    return ChoiceChip(
                      label: Text('$minutes min before'),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _reminderMinutesBefore = minutes),
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
                  hintText: 'e.g. Take after breakfast',
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save Changes' : 'Save Task'),
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