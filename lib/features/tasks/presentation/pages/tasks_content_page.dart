import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/page_content_frame.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/config/app_breakpoints.dart';
import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/notifications/app_notification_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/repositories/app_settings_repository.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_checklist_item.dart';
import '../../domain/entities/task_quadrant.dart';
import '../../domain/repositories/task_repository.dart';
import '../controllers/task_editor_controller.dart';
import '../controllers/tasks_controller.dart';
import '../models/task_list_options.dart';
import '../widgets/task_card.dart';
import '../widgets/task_editor_sheet.dart';

class TasksContentPage extends GetView<TasksController> {
  const TasksContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool compact =
        MediaQuery.sizeOf(context).width < AppBreakpoints.compactNavigation;

    return PageContentFrame(
      storageKey: AppDestination.tasks.pageStorageKey,
      child: Obx(() {
        final List<Task> tasks = controller.visibleTasks;
        final List<TaskQuadrantGroup> groups = controller.matrixGroups;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSectionCard(
              title: 'Матрица задач',
              description:
                  'Сначала решаем, что действительно важно и срочно. '
                  'Личный трекер строится вокруг матрицы Эйзенхауэра, а не '
                  'вокруг абстрактного high priority.',
              trailing: compact
                  ? null
                  : AppButton(
                      key: const Key('tasks-add-button'),
                      label: 'Полный редактор',
                      icon: Icons.edit_note_rounded,
                      onPressed: () => _openTaskEditor(context),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _TaskQuickCaptureCard(controller: controller),
                  const SizedBox(height: AppSpacing.xl),
                  _TaskToolbar(
                    controller: controller,
                    onPickDate: () => _pickTasksDate(context),
                  ),
                  if (compact) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      key: const Key('tasks-add-button'),
                      label: 'Полный редактор',
                      icon: Icons.edit_note_rounded,
                      isExpanded: true,
                      onPressed: () => _openTaskEditor(context),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (controller.isLoading)
              const Center(
                key: Key('tasks-state-loading'),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: AppLoadingState(
                    title: 'Собираем матрицу задач',
                    message:
                        'Поднимаем локальный список и готовим квадранты на день.',
                  ),
                ),
              )
            else if (controller.hasError)
              Center(
                key: const Key('tasks-state-error'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: AppErrorState(
                    title: 'Модуль задач недоступен',
                    message:
                        controller.errorMessage ??
                        'Попробуй обновить экран ещё раз.',
                    actionLabel: 'Повторить',
                    onAction: controller.retryLoading,
                  ),
                ),
              )
            else if (tasks.isEmpty)
              Center(
                key: const Key('tasks-state-empty'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: AppEmptyState(
                    title: controller.hasSourceTasks
                        ? 'Под текущий фильтр задач нет'
                        : 'Матрица пока пустая',
                    message: controller.hasSourceTasks
                        ? 'Смени статус, категорию или режим просмотра, чтобы увидеть другие задачи.'
                        : 'Захвати первую задачу сверху и сразу отнеси её в правильный квадрант.',
                    actionLabel: 'Открыть редактор',
                    onAction: () => _openTaskEditor(context),
                  ),
                ),
              )
            else if (controller.viewMode == TaskViewMode.matrix)
              _TaskMatrixBoard(
                controller: controller,
                groups: groups,
                compact: compact,
                onOpenEditor: (Task task) =>
                    _openTaskEditor(context, task: task),
                onConfirmDelete: (Task task) =>
                    _confirmDeleteTask(context, task),
                onReschedule: (Task task) => _pickRescheduleDate(context, task),
              )
            else
              _TaskListBoard(
                controller: controller,
                tasks: tasks,
                onOpenEditor: (Task task) =>
                    _openTaskEditor(context, task: task),
                onConfirmDelete: (Task task) =>
                    _confirmDeleteTask(context, task),
                onReschedule: (Task task) => _pickRescheduleDate(context, task),
              ),
          ],
        );
      }),
    );
  }

  Future<void> _pickTasksDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: AppDateFormatter.appLocale,
    );
    if (picked != null) {
      await controller.selectDate(picked);
    }
  }

  Future<void> _pickRescheduleDate(BuildContext context, Task task) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: task.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: AppDateFormatter.appLocale,
    );
    if (picked != null) {
      await controller.rescheduleTask(task, picked);
    }
  }

  Future<void> _confirmDeleteTask(BuildContext context, Task task) async {
    final bool confirmed = await AppConfirmDialog.show(
      context,
      title: 'Удалить задачу?',
      message: 'Задача "${task.title}" будет удалена из локального списка.',
      confirmLabel: 'Удалить',
      isDestructive: true,
    );

    if (confirmed) {
      await controller.deleteTask(task);
    }
  }

  Future<void> _openTaskEditor(BuildContext context, {Task? task}) async {
    final AppSettings settings = await Get.find<AppSettingsRepository>()
        .readSettings();
    if (!context.mounted) {
      return;
    }
    final TaskEditorController editor = TaskEditorController(
      repository: Get.find<TaskRepository>(),
      dateFormatter: Get.find<AppDateFormatter>(),
      logger: Get.find<AppLogger>(),
      notificationService: Get.find<AppNotificationService>(),
      defaultReminderPreset: settings.defaultReminderPreset,
      initialTask: task,
      initialDate: controller.scopeMode == TaskScopeMode.forDay
          ? controller.selectedDate
          : DateTime.now(),
    );

    final bool compact =
        MediaQuery.sizeOf(context).width < AppBreakpoints.compactNavigation;

    if (compact) {
      await Navigator.of(context).push<Task>(
        MaterialPageRoute<Task>(
          builder: (BuildContext context) => TaskEditorPage(controller: editor),
          fullscreenDialog: true,
        ),
      );
      return;
    }

    await showDialog<Task>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskEditorDialog(controller: editor);
      },
    );
  }
}

class _TaskQuickCaptureCard extends StatefulWidget {
  const _TaskQuickCaptureCard({required this.controller});

  final TasksController controller;

  @override
  State<_TaskQuickCaptureCard> createState() => _TaskQuickCaptureCardState();
}

class _TaskQuickCaptureCardState extends State<_TaskQuickCaptureCard> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.controller.quickCaptureTitle)
          ..addListener(() {
            widget.controller.updateQuickCaptureTitle(_textController.text);
          });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await widget.controller.submitQuickCapture();
    if (!mounted) {
      return;
    }
    if (_textController.text != widget.controller.quickCaptureTitle) {
      _textController.value = TextEditingValue(
        text: widget.controller.quickCaptureTitle,
        selection: TextSelection.collapsed(
          offset: widget.controller.quickCaptureTitle.length,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_textController.text != widget.controller.quickCaptureTitle) {
        _textController.value = TextEditingValue(
          text: widget.controller.quickCaptureTitle,
          selection: TextSelection.collapsed(
            offset: widget.controller.quickCaptureTitle.length,
          ),
        );
      }

      final bool compact = MediaQuery.sizeOf(context).width < 760;
      return AppSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Быстрый захват',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Сформулируй задачу коротко и сразу положи её в правильный квадрант.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              key: const Key('task-quick-capture-field'),
              controller: _textController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                hintText: 'Например, пойти в магазин',
                labelText: 'Новая задача',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: TaskQuadrant.values
                  .map((TaskQuadrant quadrant) {
                    return ChoiceChip(
                      key: Key('quick-capture-quadrant-${quadrant.name}'),
                      label: Text(quadrant.label),
                      selected:
                          widget.controller.quickCaptureQuadrant == quadrant,
                      onSelected: (_) => widget.controller
                          .updateQuickCaptureQuadrant(quadrant),
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    key: const Key('task-quick-capture-submit'),
                    label: 'Добавить в матрицу',
                    icon: Icons.add_rounded,
                    isExpanded: compact,
                    onPressed: widget.controller.canSubmitQuickCapture
                        ? _submit
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _TaskToolbar extends StatelessWidget {
  const _TaskToolbar({required this.controller, required this.onPickDate});

  final TasksController controller;
  final Future<void> Function() onPickDate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: <Widget>[
        ...controller.viewModes.map((TaskViewMode mode) {
          return _ModeChipButton(
            key: Key('task-view-mode-${mode.name}'),
            label: mode.label,
            selected: controller.viewMode == mode,
            onPressed: () => controller.selectViewMode(mode),
          );
        }),
        ...controller.scopeModes.map((TaskScopeMode mode) {
          return _ModeChipButton(
            key: Key('task-scope-mode-${mode.name}'),
            label: mode.label,
            selected: controller.scopeMode == mode,
            onPressed: () => controller.selectScopeMode(mode),
          );
        }),
        if (controller.scopeMode == TaskScopeMode.forDay)
          AppButton(
            key: const Key('tasks-date-picker-button'),
            label: controller.selectedDateLabel,
            icon: Icons.event_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: onPickDate,
          ),
        AppDropdownField<TaskStatusFilter>(
          label: 'Статус',
          value: controller.statusFilter,
          fieldKey: const Key('task-status-filter-dropdown'),
          items: controller.statusFilters
              .map(
                (TaskStatusFilter filter) => DropdownMenuItem<TaskStatusFilter>(
                  key: Key('task-status-filter-option-${filter.name}'),
                  value: filter,
                  child: Text(filter.label),
                ),
              )
              .toList(growable: false),
          onChanged: (TaskStatusFilter? filter) {
            if (filter != null) {
              controller.selectStatusFilter(filter);
            }
          },
          width: 220,
        ),
        AppDropdownField<TaskCategoryFilter>(
          label: 'Категория',
          value: controller.categoryFilter,
          fieldKey: const Key('task-category-filter-dropdown'),
          items: controller.categoryFilters
              .map(
                (TaskCategoryFilter filter) =>
                    DropdownMenuItem<TaskCategoryFilter>(
                      key: Key('task-category-filter-option-${filter.name}'),
                      value: filter,
                      child: Text(filter.label),
                    ),
              )
              .toList(growable: false),
          onChanged: (TaskCategoryFilter? filter) {
            if (filter != null) {
              controller.selectCategoryFilter(filter);
            }
          },
          width: 220,
        ),
        if (controller.viewMode == TaskViewMode.list)
          AppDropdownField<TaskListSortOption>(
            label: 'Сортировка',
            value: controller.listSortOption,
            fieldKey: const Key('task-sort-dropdown'),
            items: controller.listSortOptions
                .map(
                  (TaskListSortOption option) =>
                      DropdownMenuItem<TaskListSortOption>(
                        key: Key('task-sort-option-${option.name}'),
                        value: option,
                        child: Text(option.label),
                      ),
                )
                .toList(growable: false),
            onChanged: (TaskListSortOption? option) {
              if (option != null) {
                controller.selectListSortOption(option);
              }
            },
            width: 240,
          ),
      ],
    );
  }
}

class _TaskMatrixBoard extends StatelessWidget {
  const _TaskMatrixBoard({
    required this.controller,
    required this.groups,
    required this.compact,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TasksController controller;
  final List<TaskQuadrantGroup> groups;
  final bool compact;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        key: const Key('tasks-matrix-compact'),
        children: groups
            .map((TaskQuadrantGroup group) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _CompactQuadrantSection(
                  group: group,
                  controller: controller,
                  onOpenEditor: onOpenEditor,
                  onConfirmDelete: onConfirmDelete,
                  onReschedule: onReschedule,
                ),
              );
            })
            .toList(growable: false),
      );
    }

    final TaskQuadrantGroup doNow = groups.firstWhere(
      (TaskQuadrantGroup group) => group.quadrant == TaskQuadrant.doNow,
    );
    final TaskQuadrantGroup schedule = groups.firstWhere(
      (TaskQuadrantGroup group) => group.quadrant == TaskQuadrant.schedule,
    );
    final TaskQuadrantGroup quickWins = groups.firstWhere(
      (TaskQuadrantGroup group) => group.quadrant == TaskQuadrant.quickWins,
    );
    final TaskQuadrantGroup later = groups.firstWhere(
      (TaskQuadrantGroup group) => group.quadrant == TaskQuadrant.later,
    );

    return Column(
      key: const Key('tasks-matrix-wide'),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _WideQuadrantSection(
                group: doNow,
                controller: controller,
                onOpenEditor: onOpenEditor,
                onConfirmDelete: onConfirmDelete,
                onReschedule: onReschedule,
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: _WideQuadrantSection(
                group: schedule,
                controller: controller,
                onOpenEditor: onOpenEditor,
                onConfirmDelete: onConfirmDelete,
                onReschedule: onReschedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _WideQuadrantSection(
                group: quickWins,
                controller: controller,
                onOpenEditor: onOpenEditor,
                onConfirmDelete: onConfirmDelete,
                onReschedule: onReschedule,
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: _WideQuadrantSection(
                group: later,
                controller: controller,
                onOpenEditor: onOpenEditor,
                onConfirmDelete: onConfirmDelete,
                onReschedule: onReschedule,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TaskListBoard extends StatelessWidget {
  const _TaskListBoard({
    required this.controller,
    required this.tasks,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TasksController controller;
  final List<Task> tasks;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Показано задач: ${tasks.length}',
          key: const Key('task-list-results-count'),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.lg),
        Column(
          key: const Key('tasks-list'),
          children: tasks
              .map(
                (Task task) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _TaskCardHost(
                    task: task,
                    controller: controller,
                    onOpenEditor: onOpenEditor,
                    onConfirmDelete: onConfirmDelete,
                    onReschedule: onReschedule,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _WideQuadrantSection extends StatelessWidget {
  const _WideQuadrantSection({
    required this.group,
    required this.controller,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TaskQuadrantGroup group;
  final TasksController controller;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      key: Key('task-matrix-group-${group.quadrant.name}'),
      child: _QuadrantSectionBody(
        group: group,
        controller: controller,
        onOpenEditor: onOpenEditor,
        onConfirmDelete: onConfirmDelete,
        onReschedule: onReschedule,
      ),
    );
  }
}

class _CompactQuadrantSection extends StatelessWidget {
  const _CompactQuadrantSection({
    required this.group,
    required this.controller,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TaskQuadrantGroup group;
  final TasksController controller;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      key: Key('task-matrix-group-${group.quadrant.name}'),
      child: ExpansionTile(
        key: Key('task-matrix-expansion-${group.quadrant.name}'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: true,
        title: _QuadrantHeader(group: group),
        children: <Widget>[
          const SizedBox(height: AppSpacing.md),
          _QuadrantTaskList(
            group: group,
            controller: controller,
            onOpenEditor: onOpenEditor,
            onConfirmDelete: onConfirmDelete,
            onReschedule: onReschedule,
          ),
        ],
      ),
    );
  }
}

class _QuadrantSectionBody extends StatelessWidget {
  const _QuadrantSectionBody({
    required this.group,
    required this.controller,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TaskQuadrantGroup group;
  final TasksController controller;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _QuadrantHeader(group: group),
        const SizedBox(height: AppSpacing.lg),
        _QuadrantTaskList(
          group: group,
          controller: controller,
          onOpenEditor: onOpenEditor,
          onConfirmDelete: onConfirmDelete,
          onReschedule: onReschedule,
        ),
      ],
    );
  }
}

class _QuadrantHeader extends StatelessWidget {
  const _QuadrantHeader({required this.group});

  final TaskQuadrantGroup group;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                group.quadrant.label,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                group.quadrant.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          ),
          child: Text('${group.tasks.length}'),
        ),
      ],
    );
  }
}

class _QuadrantTaskList extends StatelessWidget {
  const _QuadrantTaskList({
    required this.group,
    required this.controller,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TaskQuadrantGroup group;
  final TasksController controller;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    if (group.tasks.isEmpty) {
      return Text(
        'Здесь пока пусто. Это нормально — квадрант заполнится по мере планирования.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      children: group.tasks
          .map(
            (Task task) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _TaskCardHost(
                task: task,
                controller: controller,
                onOpenEditor: onOpenEditor,
                onConfirmDelete: onConfirmDelete,
                onReschedule: onReschedule,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _TaskCardHost extends StatelessWidget {
  const _TaskCardHost({
    required this.task,
    required this.controller,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final Task task;
  final TasksController controller;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    return TaskCard(
      task: task,
      dateFormatter: Get.find<AppDateFormatter>(),
      onToggleCompleted: () => controller.toggleTaskCompletion(task),
      onTogglePostponed: () => controller.toggleTaskPostponed(task),
      onEdit: () => onOpenEditor(task),
      onDelete: () => onConfirmDelete(task),
      onReschedule: () => onReschedule(task),
      onReclassify: (TaskQuadrant quadrant) =>
          controller.reclassifyTask(task, quadrant),
      onToggleSubtaskCompleted: (TaskChecklistItem item) =>
          controller.toggleSubtaskCompletion(task, item),
    );
  }
}

class _ModeChipButton extends StatelessWidget {
  const _ModeChipButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      key: key,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPressed(),
    );
  }
}
