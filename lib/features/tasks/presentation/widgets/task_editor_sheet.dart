import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_priority.dart';
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
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
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
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.controller.title)
      ..addListener(() {
        widget.controller.updateTitle(_titleController.text);
      });
    _descriptionController =
        TextEditingController(text: widget.controller.description)
          ..addListener(() {
            widget.controller.updateDescription(_descriptionController.text);
          });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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

  @override
  Widget build(BuildContext context) {
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
                    hintText: 'Например, подготовить интервью',
                    errorText: widget.controller.titleError,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  key: const Key('task-editor-description-field'),
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    hintText: 'Короткий контекст, ссылки или заметки',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Когда делать',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: widget.controller.dateLabel,
                  icon: Icons.event_outlined,
                  variant: AppButtonVariant.secondary,
                  isExpanded: true,
                  onPressed: _selectDate,
                ),
                const SizedBox(height: AppSpacing.lg),
                SwitchListTile(
                  key: const Key('task-editor-all-day-switch'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Весь день'),
                  subtitle: const Text(
                    'Если включено, задача не требует конкретного времени.',
                  ),
                  value: widget.controller.isAllDay,
                  onChanged: widget.controller.updateAllDaySafe,
                ),
                if (!widget.controller.isAllDay) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: AppButton(
                          label: widget.controller.startTimeLabel,
                          icon: Icons.schedule_outlined,
                          variant: AppButtonVariant.secondary,
                          isExpanded: true,
                          onPressed: _selectTime,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        key: const Key('task-editor-clear-time-button'),
                        tooltip: 'Очистить время',
                        onPressed: widget.controller.startTime == null
                            ? null
                            : () => widget.controller.updateStartTime(null),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (widget.controller.canEditDuration)
                    AppDropdownField<int?>(
                      label: 'Длительность',
                      value: widget.controller.durationMinutes,
                      fieldKey: const Key('task-editor-duration-dropdown'),
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
                      onChanged: widget.controller.updateDurationMinutes,
                      width: double.infinity,
                    )
                  else
                    Text(
                      'Сначала укажи время, и тогда появится выбор '
                      'длительности.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Контекст',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.lg),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool stackFields = constraints.maxWidth < 560;
                    final Widget priorityField = AppDropdownField<TaskPriority>(
                      label: 'Приоритет',
                      value: widget.controller.priority,
                      fieldKey: const Key('task-editor-priority-dropdown'),
                      items: TaskPriority.values
                          .map(
                            (TaskPriority value) =>
                                DropdownMenuItem<TaskPriority>(
                                  key: Key(
                                    'task-editor-priority-option-${value.name}',
                                  ),
                                  value: value,
                                  child: Text(value.label),
                                ),
                          )
                          .toList(growable: false),
                      onChanged: (TaskPriority? value) {
                        if (value != null) {
                          widget.controller.updatePriority(value);
                        }
                      },
                      width: double.infinity,
                    );
                    final Widget categoryField = AppDropdownField<TaskCategory>(
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
                      width: double.infinity,
                    );

                    if (stackFields) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          priorityField,
                          const SizedBox(height: AppSpacing.lg),
                          categoryField,
                        ],
                      );
                    }

                    return Row(
                      children: <Widget>[
                        Expanded(child: priorityField),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(child: categoryField),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on TaskEditorController {
  void updateAllDaySafe(bool value) {
    setAllDay(value);
  }
}
