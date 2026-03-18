import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/page_content_frame.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/config/app_breakpoints.dart';
import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_expandable_section.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_checklist_item.dart';
import '../../domain/entities/task_quadrant.dart';
import '../controllers/tasks_controller.dart';
import '../models/task_list_options.dart';
import '../task_editor_launcher.dart';
import '../widgets/task_card.dart';

enum _TaskMatrixLayoutMode { compact, medium, wide }

class TasksContentPage extends GetView<TasksController> {
  const TasksContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool matrixMode = controller.viewMode == TaskViewMode.matrix;

      return PageContentFrame(
        storageKey: AppDestination.tasks.pageStorageKey,
        widthPolicy: matrixMode
            ? PageContentWidthPolicy.fluid
            : PageContentWidthPolicy.standard,
        builder: (BuildContext context, PageContentLayout frame) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Obx(() {
                final _TaskMatrixLayoutMode matrixLayout =
                    _matrixLayoutForWidth(constraints.maxWidth);
                final List<Task> tasks = controller.visibleTasks;
                final List<TaskQuadrantGroup> groups = controller.matrixGroups;

                if (controller.isLoading) {
                  return const Center(
                    key: Key('tasks-state-loading'),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                      child: AppLoadingState(
                        title: 'Собираем матрицу задач',
                        message:
                            'Поднимаем локальный список и готовим квадранты на день.',
                      ),
                    ),
                  );
                }

                if (controller.hasError) {
                  return Center(
                    key: const Key('tasks-state-error'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxl,
                      ),
                      child: AppErrorState(
                        title: 'Модуль задач недоступен',
                        message:
                            controller.errorMessage ??
                            'Попробуй обновить экран ещё раз.',
                        actionLabel: 'Повторить',
                        onAction: controller.retryLoading,
                      ),
                    ),
                  );
                }

                if (tasks.isEmpty) {
                  return Center(
                    key: const Key('tasks-state-empty'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxl,
                      ),
                      child: AppEmptyState(
                        title: controller.hasSourceTasks
                            ? 'Под текущий фильтр задач нет'
                            : 'Матрица пока пустая',
                        message: controller.hasSourceTasks
                            ? 'Сбрось фильтры, смени запрос или открой другой режим просмотра.'
                            : 'Создай первую задачу через кнопку плюс в верхней панели.',
                        actionLabel: 'Открыть редактор',
                        onAction: () => _openTaskEditor(context),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (matrixMode)
                      _TaskMatrixBoard(
                        controller: controller,
                        groups: groups,
                        layout: matrixLayout,
                        availableHeight: frame.contentHeight,
                        onOpenEditor: (Task task) =>
                            _openTaskEditor(context, task: task),
                        onConfirmDelete: (Task task) =>
                            _confirmDeleteTask(context, task),
                        onReschedule: (Task task) =>
                            _pickRescheduleDate(context, task),
                      )
                    else
                      _TaskListBoard(
                        controller: controller,
                        tasks: tasks,
                        onOpenEditor: (Task task) =>
                            _openTaskEditor(context, task: task),
                        onConfirmDelete: (Task task) =>
                            _confirmDeleteTask(context, task),
                        onReschedule: (Task task) =>
                            _pickRescheduleDate(context, task),
                      ),
                  ],
                );
              });
            },
          );
        },
      );
    });
  }

  _TaskMatrixLayoutMode _matrixLayoutForWidth(double width) {
    if (width < AppBreakpoints.compactNavigation) {
      return _TaskMatrixLayoutMode.compact;
    }
    if (width < AppBreakpoints.wideMatrixBoard) {
      return _TaskMatrixLayoutMode.medium;
    }
    return _TaskMatrixLayoutMode.wide;
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
    await openTaskEditorFlow(
      context,
      task: task,
      initialDate: controller.scopeMode == TaskScopeMode.forDay
          ? controller.selectedDate
          : DateTime.now(),
    );
  }
}

class _TaskMatrixBoard extends StatelessWidget {
  const _TaskMatrixBoard({
    required this.controller,
    required this.groups,
    required this.layout,
    required this.availableHeight,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TasksController controller;
  final List<TaskQuadrantGroup> groups;
  final _TaskMatrixLayoutMode layout;
  final double availableHeight;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    if (layout == _TaskMatrixLayoutMode.compact) {
      return Column(
        key: const Key('tasks-matrix-compact'),
        children: groups
            .map((TaskQuadrantGroup group) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Obx(
                  () => _CompactQuadrantSection(
                    group: group,
                    expanded: controller.isQuadrantExpanded(group.quadrant),
                    onExpandedChanged: (bool expanded) {
                      controller.setQuadrantExpanded(group.quadrant, expanded);
                    },
                    controller: controller,
                    onOpenEditor: onOpenEditor,
                    onConfirmDelete: onConfirmDelete,
                    onReschedule: onReschedule,
                  ),
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
    final double boardGap = layout == _TaskMatrixLayoutMode.medium
        ? AppSpacing.lg
        : AppSpacing.xl;
    final double boardHeight = availableHeight
        .clamp(560.0, layout == _TaskMatrixLayoutMode.medium ? 820.0 : 920.0)
        .toDouble();

    return SizedBox(
      key: Key('tasks-matrix-${layout.name}'),
      height: boardHeight,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _WideQuadrantSection(
                    group: doNow,
                    dense: layout == _TaskMatrixLayoutMode.medium,
                    controller: controller,
                    onOpenEditor: onOpenEditor,
                    onConfirmDelete: onConfirmDelete,
                    onReschedule: onReschedule,
                  ),
                ),
                SizedBox(width: boardGap),
                Expanded(
                  child: _WideQuadrantSection(
                    group: schedule,
                    dense: layout == _TaskMatrixLayoutMode.medium,
                    controller: controller,
                    onOpenEditor: onOpenEditor,
                    onConfirmDelete: onConfirmDelete,
                    onReschedule: onReschedule,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: boardGap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _WideQuadrantSection(
                    group: quickWins,
                    dense: layout == _TaskMatrixLayoutMode.medium,
                    controller: controller,
                    onOpenEditor: onOpenEditor,
                    onConfirmDelete: onConfirmDelete,
                    onReschedule: onReschedule,
                  ),
                ),
                SizedBox(width: boardGap),
                Expanded(
                  child: _WideQuadrantSection(
                    group: later,
                    dense: layout == _TaskMatrixLayoutMode.medium,
                    controller: controller,
                    onOpenEditor: onOpenEditor,
                    onConfirmDelete: onConfirmDelete,
                    onReschedule: onReschedule,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                    enableDrag: false,
                    density: TaskCardDensity.comfortable,
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
    required this.dense,
    required this.controller,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TaskQuadrantGroup group;
  final bool dense;
  final TasksController controller;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (DragTargetDetails<Task> details) {
        return details.data.quadrant != group.quadrant;
      },
      onAcceptWithDetails: (DragTargetDetails<Task> details) {
        if (details.data.quadrant == group.quadrant) {
          return;
        }
        controller.reclassifyTask(details.data, group.quadrant);
      },
      builder:
          (
            BuildContext context,
            List<Task?> candidateData,
            List<dynamic> rejectedData,
          ) {
            final bool isHighlighted = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: double.infinity,
              padding: EdgeInsets.all(isHighlighted ? AppSpacing.xs : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppRadii.card + AppSpacing.xs,
                ),
                color: isHighlighted
                    ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.24)
                    : Colors.transparent,
                border: Border.all(
                  color: isHighlighted
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.22)
                      : Colors.transparent,
                ),
              ),
              child: AppSurfaceCard(
                key: Key('task-matrix-group-${group.quadrant.name}'),
                child: _QuadrantSectionBody(
                  group: group,
                  dense: dense,
                  controller: controller,
                  enableDrag: true,
                  onOpenEditor: onOpenEditor,
                  onConfirmDelete: onConfirmDelete,
                  onReschedule: onReschedule,
                ),
              ),
            );
          },
    );
  }
}

class _CompactQuadrantSection extends StatelessWidget {
  const _CompactQuadrantSection({
    required this.group,
    required this.expanded,
    required this.onExpandedChanged,
    required this.controller,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TaskQuadrantGroup group;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final TasksController controller;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    return AppExpandableSection(
      cardKey: Key('task-matrix-group-${group.quadrant.name}'),
      key: Key('task-matrix-expansion-${group.quadrant.name}'),
      expanded: expanded,
      onExpandedChanged: onExpandedChanged,
      header: _QuadrantHeader(group: group, dense: true),
      child: _QuadrantTaskList(
        group: group,
        controller: controller,
        enableDrag: false,
        onOpenEditor: onOpenEditor,
        onConfirmDelete: onConfirmDelete,
        onReschedule: onReschedule,
      ),
    );
  }
}

class _QuadrantSectionBody extends StatelessWidget {
  const _QuadrantSectionBody({
    required this.group,
    required this.dense,
    required this.controller,
    required this.enableDrag,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TaskQuadrantGroup group;
  final bool dense;
  final TasksController controller;
  final bool enableDrag;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _QuadrantHeader(group: group, dense: dense),
        SizedBox(height: dense ? AppSpacing.md : AppSpacing.lg),
        Expanded(
          child: _QuadrantTaskViewport(
            group: group,
            controller: controller,
            enableDrag: enableDrag,
            onOpenEditor: onOpenEditor,
            onConfirmDelete: onConfirmDelete,
            onReschedule: onReschedule,
            dense: dense,
          ),
        ),
      ],
    );
  }
}

class _QuadrantHeader extends StatelessWidget {
  const _QuadrantHeader({required this.group, this.dense = false});

  final TaskQuadrantGroup group;
  final bool dense;

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
                style:
                    (dense
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.headlineSmall)
                        ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                group.quadrant.subtitle,
                style: dense
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? AppSpacing.sm : AppSpacing.md,
            vertical: dense ? AppSpacing.xs : AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          ),
          child: Text(
            '${group.tasks.length}',
            style: dense ? Theme.of(context).textTheme.bodySmall : null,
          ),
        ),
      ],
    );
  }
}

class _QuadrantTaskList extends StatelessWidget {
  const _QuadrantTaskList({
    required this.group,
    required this.controller,
    required this.enableDrag,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final TaskQuadrantGroup group;
  final TasksController controller;
  final bool enableDrag;
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
                enableDrag: enableDrag,
                density: TaskCardDensity.comfortable,
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

class _QuadrantTaskViewport extends StatefulWidget {
  const _QuadrantTaskViewport({
    required this.group,
    required this.controller,
    required this.enableDrag,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
    required this.dense,
  });

  final TaskQuadrantGroup group;
  final TasksController controller;
  final bool enableDrag;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;
  final bool dense;

  @override
  State<_QuadrantTaskViewport> createState() => _QuadrantTaskViewportState();
}

class _QuadrantTaskViewportState extends State<_QuadrantTaskViewport> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Task> tasks = widget.group.tasks;

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Здесь пока пусто. Это нормально — квадрант заполнится по мере планирования.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useCompactCards = constraints.maxWidth >= 560;
        final double spacing = widget.dense ? AppSpacing.md : AppSpacing.lg;

        if (useCompactCards) {
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: GridView.builder(
              key: Key('task-matrix-grid-${widget.group.quadrant.name}'),
              controller: _scrollController,
              primary: false,
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: widget.dense ? 232 : 244,
              ),
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                final Task task = tasks[index];
                return _TaskCardHost(
                  task: task,
                  controller: widget.controller,
                  enableDrag: widget.enableDrag,
                  density: TaskCardDensity.compact,
                  onOpenEditor: widget.onOpenEditor,
                  onConfirmDelete: widget.onConfirmDelete,
                  onReschedule: widget.onReschedule,
                );
              },
            ),
          );
        }

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: ListView.separated(
            key: Key('task-matrix-list-${widget.group.quadrant.name}'),
            controller: _scrollController,
            primary: false,
            padding: EdgeInsets.zero,
            itemCount: tasks.length,
            separatorBuilder: (_, index) => SizedBox(height: spacing),
            itemBuilder: (BuildContext context, int index) {
              final Task task = tasks[index];
              return _TaskCardHost(
                task: task,
                controller: widget.controller,
                enableDrag: widget.enableDrag,
                density: TaskCardDensity.comfortable,
                onOpenEditor: widget.onOpenEditor,
                onConfirmDelete: widget.onConfirmDelete,
                onReschedule: widget.onReschedule,
              );
            },
          ),
        );
      },
    );
  }
}

class _TaskCardHost extends StatelessWidget {
  const _TaskCardHost({
    required this.task,
    required this.controller,
    required this.enableDrag,
    required this.density,
    required this.onOpenEditor,
    required this.onConfirmDelete,
    required this.onReschedule,
  });

  final Task task;
  final TasksController controller;
  final bool enableDrag;
  final TaskCardDensity density;
  final ValueChanged<Task> onOpenEditor;
  final ValueChanged<Task> onConfirmDelete;
  final ValueChanged<Task> onReschedule;

  @override
  Widget build(BuildContext context) {
    final Widget card = TaskCard(
      task: task,
      density: density,
      dateFormatter: Get.find<AppDateFormatter>(),
      onToggleCompleted: () => controller.toggleTaskCompletion(task),
      onEdit: () => onOpenEditor(task),
      onDelete: () => onConfirmDelete(task),
      onReschedule: () => onReschedule(task),
      onReclassify: (TaskQuadrant quadrant) =>
          controller.reclassifyTask(task, quadrant),
      onToggleSubtaskCompleted: (TaskChecklistItem item) =>
          controller.toggleSubtaskCompletion(task, item),
    );

    if (!enableDrag || task.isCompleted) {
      return card;
    }

    return LongPressDraggable<Task>(
      data: task,
      delay: const Duration(milliseconds: 120),
      feedback: Material(
        color: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Opacity(opacity: 0.96, child: card),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.36,
        child: IgnorePointer(child: card),
      ),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: card),
    );
  }
}
