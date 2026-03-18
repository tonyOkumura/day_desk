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
import '../../domain/entities/task.dart';
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
    final bool useCompactLayout =
        MediaQuery.sizeOf(context).width < AppBreakpoints.compactNavigation;

    return PageContentFrame(
      storageKey: AppDestination.tasks.pageStorageKey,
      child: Obx(() {
        final List<Task> tasks = controller.visibleTasks;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSectionCard(
              title: 'Список задач',
              description:
                  'Первый рабочий модуль Day Desk. Здесь живут '
                  'текущие задачи на дату и общий список без перехода в '
                  'отдельный продуктовый поток.',
              trailing: useCompactLayout
                  ? null
                  : AppButton(
                      key: const Key('tasks-add-button'),
                      label: 'Новая задача',
                      icon: Icons.add_rounded,
                      onPressed: () => _openTaskEditor(context),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: <Widget>[
                      _ModeButton(
                        key: const Key('task-list-mode-for-day'),
                        label: TaskListMode.forDay.label,
                        selected: controller.listMode == TaskListMode.forDay,
                        onPressed: () =>
                            controller.selectListMode(TaskListMode.forDay),
                      ),
                      _ModeButton(
                        key: const Key('task-list-mode-all'),
                        label: TaskListMode.allTasks.label,
                        selected: controller.listMode == TaskListMode.allTasks,
                        onPressed: () =>
                            controller.selectListMode(TaskListMode.allTasks),
                      ),
                      if (controller.listMode == TaskListMode.forDay)
                        AppButton(
                          key: const Key('tasks-date-picker-button'),
                          label: controller.selectedDateLabel,
                          icon: Icons.event_outlined,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => _pickTasksDate(context),
                        ),
                      AppDropdownField<TaskStatusFilter>(
                        label: 'Фильтр',
                        value: controller.statusFilter,
                        fieldKey: const Key('task-status-filter-dropdown'),
                        items: controller.statusFilters
                            .map(
                              (
                                TaskStatusFilter filter,
                              ) => DropdownMenuItem<TaskStatusFilter>(
                                key: Key(
                                  'task-status-filter-option-${filter.name}',
                                ),
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
                      AppDropdownField<TaskSortOption>(
                        label: 'Сортировка',
                        value: controller.sortOption,
                        fieldKey: const Key('task-sort-dropdown'),
                        items: controller.sortOptions
                            .map(
                              (TaskSortOption option) =>
                                  DropdownMenuItem<TaskSortOption>(
                                    key: Key('task-sort-option-${option.name}'),
                                    value: option,
                                    child: Text(option.label),
                                  ),
                            )
                            .toList(growable: false),
                        onChanged: (TaskSortOption? option) {
                          if (option != null) {
                            controller.selectSortOption(option);
                          }
                        },
                        width: 240,
                      ),
                    ],
                  ),
                  if (useCompactLayout) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      key: const Key('tasks-add-button'),
                      label: 'Новая задача',
                      icon: Icons.add_rounded,
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
                    title: 'Загружаем задачи',
                    message: 'Поднимаем локальный список и готовим состояние.',
                  ),
                ),
              )
            else if (controller.hasError)
              Center(
                key: const Key('tasks-state-error'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: AppErrorState(
                    title: 'Список задач недоступен',
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
                        : 'Пока нет ни одной задачи',
                    message: controller.hasSourceTasks
                        ? 'Смени фильтр или сортировку, чтобы увидеть другие '
                              'задачи.'
                        : 'Создай первую задачу и начни собирать рабочий день '
                              'прямо из этой вкладки.',
                    actionLabel: 'Новая задача',
                    onAction: () => _openTaskEditor(context),
                  ),
                ),
              )
            else ...<Widget>[
              Text(
                _resultsLabel(tasks.length),
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
                        child: TaskCard(
                          task: task,
                          dateFormatter: Get.find<AppDateFormatter>(),
                          onToggleCompleted: () =>
                              controller.toggleTaskCompletion(task),
                          onEdit: () => _openTaskEditor(context, task: task),
                          onDelete: () => _confirmDeleteTask(context, task),
                          onReschedule: () =>
                              _pickRescheduleDate(context, task),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        );
      }),
    );
  }

  String _resultsLabel(int count) {
    if (controller.listMode == TaskListMode.forDay) {
      return 'На выбранную дату: $count';
    }

    return 'Всего задач: $count';
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
    final TaskEditorController editor = TaskEditorController(
      repository: Get.find<TaskRepository>(),
      dateFormatter: Get.find<AppDateFormatter>(),
      logger: Get.find<AppLogger>(),
      notificationService: Get.find<AppNotificationService>(),
      initialTask: task,
      initialDate: controller.listMode == TaskListMode.forDay
          ? controller.selectedDate
          : DateTime.now(),
    );

    final bool useCompactLayout =
        MediaQuery.sizeOf(context).width < AppBreakpoints.compactNavigation;

    if (useCompactLayout) {
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

class _ModeButton extends StatelessWidget {
  const _ModeButton({
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
    return AppButton(
      label: label,
      variant: selected ? AppButtonVariant.primary : AppButtonVariant.tonal,
      onPressed: onPressed,
    );
  }
}
