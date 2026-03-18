import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/reminders/reminder_lead_time_preset.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_checklist_item.dart';
import '../../domain/entities/task_quadrant.dart';
import '../controllers/task_editor_controller.dart';

class TaskEditorDialog extends StatefulWidget {
  const TaskEditorDialog({required this.controller, super.key});

  final TaskEditorController controller;

  @override
  State<TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<TaskEditorDialog> {
  Future<void> _handleCloseRequest() async {
    if (widget.controller.isSaving) {
      return;
    }
    if (!widget.controller.hasUnsavedChanges ||
        await _confirmDiscardChanges()) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool> _confirmDiscardChanges() {
    return AppConfirmDialog.show(
      context,
      title: 'Закрыть редактор?',
      message: 'Несохранённые изменения будут потеряны.',
      confirmLabel: 'Закрыть без сохранения',
      isDestructive: true,
    );
  }

  Future<void> _handleSave() async {
    final Task? task = await widget.controller.save();
    if (task != null && mounted) {
      Navigator.of(context).pop(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop:
            !widget.controller.hasUnsavedChanges && !widget.controller.isSaving,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (!didPop) {
            unawaited(_handleCloseRequest());
          }
        },
        child: Dialog(
          key: const Key('task-editor-dialog'),
          insetPadding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860, maxHeight: 860),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.controller.titleText,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Закрыть',
                          onPressed: _handleCloseRequest,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: _TaskEditorFormBody(controller: widget.controller),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        AppButton(
                          label: 'Отмена',
                          variant: AppButtonVariant.secondary,
                          onPressed: _handleCloseRequest,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AppButton(
                          label: widget.controller.saveLabel,
                          isLoading: widget.controller.isSaving,
                          onPressed: _handleSave,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TaskEditorPage extends StatefulWidget {
  const TaskEditorPage({required this.controller, super.key});

  final TaskEditorController controller;

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  Future<void> _handleCloseRequest() async {
    if (widget.controller.isSaving) {
      return;
    }

    if (!widget.controller.hasUnsavedChanges ||
        await AppConfirmDialog.show(
          context,
          title: 'Выйти из редактора?',
          message: 'Несохранённые изменения будут потеряны.',
          confirmLabel: 'Выйти без сохранения',
          isDestructive: true,
        )) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleSave() async {
    final Task? task = await widget.controller.save();
    if (task != null && mounted) {
      Navigator.of(context).pop(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop:
            !widget.controller.hasUnsavedChanges && !widget.controller.isSaving,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (!didPop) {
            unawaited(_handleCloseRequest());
          }
        },
        child: Scaffold(
          key: const Key('task-editor-fullscreen'),
          appBar: AppBar(
            title: Text(widget.controller.titleText),
            leading: IconButton(
              onPressed: _handleCloseRequest,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _TaskEditorFormBody(controller: widget.controller),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: widget.controller.saveLabel,
                isExpanded: true,
                isLoading: widget.controller.isSaving,
                onPressed: _handleSave,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskEditorFormBody extends StatefulWidget {
  const _TaskEditorFormBody({required this.controller});

  final TaskEditorController controller;

  @override
  State<_TaskEditorFormBody> createState() => _TaskEditorFormBodyState();
}

class _TaskEditorFormBodyState extends State<_TaskEditorFormBody> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.controller.title)
      ..addListener(() {
        widget.controller.updateTitle(_titleController.text);
      });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.controller.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: AppDateFormatter.appLocale,
    );
    if (picked != null) {
      widget.controller.updateDate(picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay initial = widget.controller.startTime != null
        ? TimeOfDay.fromDateTime(widget.controller.startTime!)
        : const TimeOfDay(hour: 9, minute: 0);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) {
      return;
    }

    widget.controller.updateStartTime(
      DateTime(
        widget.controller.date.year,
        widget.controller.date.month,
        widget.controller.date.day,
        picked.hour,
        picked.minute,
      ),
    );
  }

  Future<DateTime?> _pickDateTime({
    required DateTime initialDate,
    required TimeOfDay initialTime,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: AppDateFormatter.appLocale,
    );
    if (pickedDate == null) {
      return null;
    }
    if (!mounted) {
      return null;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime == null) {
      return null;
    }

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  Future<void> _selectDeadline() async {
    final DateTime selectedDate = widget.controller.date;
    final DateTime? currentDeadline = widget.controller.deadline;
    final DateTime? picked = await _pickDateTime(
      initialDate: currentDeadline ?? selectedDate,
      initialTime: currentDeadline != null
          ? TimeOfDay.fromDateTime(currentDeadline)
          : const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) {
      widget.controller.updateDeadline(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 760;

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  key: const Key('task-editor-title-field'),
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Название',
                    hintText: 'Например, пойти в магазин',
                    errorText: widget.controller.titleError,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Квадрант Эйзенхауэра',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  key: const Key('task-editor-quadrant-selector'),
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: widget.controller.quadrantOptions
                      .map((TaskQuadrant quadrant) {
                        final bool selected =
                            widget.controller.quadrant == quadrant;
                        return ChoiceChip(
                          key: Key(
                            'task-editor-quadrant-option-${quadrant.name}',
                          ),
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(quadrant.label),
                              Text(
                                quadrant.subtitle,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          selected: selected,
                          onSelected: (_) =>
                              widget.controller.updateQuadrant(quadrant),
                        );
                      })
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Подпункты',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Разбей задачу на короткие actionable-шаги.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      key: const Key('task-editor-add-subtask-button'),
                      label: 'Добавить',
                      icon: Icons.add_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => widget.controller.addSubtask(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (widget.controller.subtasks.isEmpty)
                  Text(
                    'Подпунктов пока нет. Добавь, чтобы превратить задачу в понятный план.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ReorderableListView.builder(
                    key: const Key('task-editor-subtask-list'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: widget.controller.subtasks.length,
                    onReorder: widget.controller.reorderSubtasks,
                    itemBuilder: (BuildContext context, int index) {
                      final TaskChecklistItem item =
                          widget.controller.subtasks[index];
                      return _ChecklistEditorRow(
                        key: ValueKey<String>('task-editor-subtask-${item.id}'),
                        item: item,
                        onChanged: (String value) => widget.controller
                            .updateSubtaskTitle(item.id, value),
                        onSubmitted: (_) => widget.controller.addSubtask(),
                        onDelete: () =>
                            widget.controller.removeSubtask(item.id),
                        onToggleCompleted: (bool? value) => widget.controller
                            .toggleSubtaskCompletion(item.id, value ?? false),
                        dragHandle: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_indicator_rounded),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: <Widget>[
                    AppButton(
                      key: const Key('task-editor-date-button'),
                      label: widget.controller.dateLabel,
                      icon: Icons.event_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: _selectDate,
                    ),
                    AppButton(
                      key: const Key('task-editor-start-time-button'),
                      label: widget.controller.startTimeLabel,
                      icon: Icons.schedule_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: widget.controller.isAllDay
                          ? null
                          : _selectTime,
                    ),
                    AppButton(
                      key: const Key('task-editor-deadline-button'),
                      label: widget.controller.deadlineLabel,
                      icon: Icons.flag_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: _selectDeadline,
                    ),
                    if (widget.controller.deadline != null)
                      AppButton(
                        key: const Key('task-editor-clear-deadline-button'),
                        label: 'Очистить дедлайн',
                        variant: AppButtonVariant.tonal,
                        onPressed: () => widget.controller.updateDeadline(null),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SwitchListTile.adaptive(
                  key: const Key('task-editor-all-day-switch'),
                  value: widget.controller.isAllDay,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('На весь день'),
                  subtitle: const Text(
                    'Отключает точное время и длительность для задачи.',
                  ),
                  onChanged: widget.controller.setAllDay,
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: <Widget>[
                    SizedBox(
                      width: compact ? double.infinity : 220,
                      child: DropdownButtonFormField<int?>(
                        key: const Key('task-editor-duration-dropdown'),
                        initialValue: widget.controller.canEditDuration
                            ? widget.controller.durationMinutes
                            : null,
                        isExpanded: true,
                        items: <DropdownMenuItem<int?>>[
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Без длительности'),
                          ),
                          ...TaskEditorController.durationOptions.map(
                            (int value) => DropdownMenuItem<int?>(
                              key: Key('task-editor-duration-option-$value'),
                              value: value,
                              child: Text('$value минут'),
                            ),
                          ),
                        ],
                        onChanged: widget.controller.canEditDuration
                            ? widget.controller.updateDurationMinutes
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Длительность',
                        ),
                      ),
                    ),
                    AppDropdownField<ReminderLeadTimePreset>(
                      label: 'Напоминание',
                      value: widget.controller.reminderPreset,
                      fieldKey: const Key(
                        'task-editor-reminder-preset-dropdown',
                      ),
                      items: ReminderLeadTimePreset.values
                          .map(
                            (ReminderLeadTimePreset value) =>
                                DropdownMenuItem<ReminderLeadTimePreset>(
                                  key: Key(
                                    'task-editor-reminder-option-${value.name}',
                                  ),
                                  value: value,
                                  child: Text(value.label),
                                ),
                          )
                          .toList(growable: false),
                      onChanged: (ReminderLeadTimePreset? value) {
                        if (value != null) {
                          widget.controller.updateReminderPreset(value);
                        }
                      },
                      width: compact ? double.infinity : 240,
                    ),
                    AppDropdownField<TaskCategory>(
                      label: 'Категория',
                      value: widget.controller.category,
                      fieldKey: const Key('task-editor-category-dropdown'),
                      items: TaskCategory.values
                          .map(
                            (TaskCategory value) =>
                                DropdownMenuItem<TaskCategory>(
                                  key: Key(
                                    'task-editor-category-option-${value.name}',
                                  ),
                                  value: value,
                                  child: Text(value.label),
                                ),
                          )
                          .toList(growable: false),
                      onChanged: (TaskCategory? value) {
                        if (value != null) {
                          widget.controller.updateCategory(value);
                        }
                      },
                      width: compact ? double.infinity : 220,
                    ),
                  ],
                ),
                if (widget.controller.reminderHelperText != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    widget.controller.reminderHelperText!,
                    key: const Key('task-editor-reminder-helper'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistEditorRow extends StatelessWidget {
  const _ChecklistEditorRow({
    required this.item,
    required this.onChanged,
    required this.onSubmitted,
    required this.onDelete,
    required this.onToggleCompleted,
    required this.dragHandle,
    super.key,
  });

  final TaskChecklistItem item;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggleCompleted;
  final Widget dragHandle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: <Widget>[
          dragHandle,
          Checkbox(value: item.isCompleted, onChanged: onToggleCompleted),
          Expanded(
            child: TextFormField(
              key: Key('task-editor-subtask-field-${item.id}'),
              initialValue: item.title,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Например, купить молоко',
              ),
              onChanged: onChanged,
              onFieldSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            key: Key('task-editor-subtask-delete-${item.id}'),
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}
