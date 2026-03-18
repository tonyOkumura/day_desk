import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/shell/widgets/app_adaptive_popover.dart';
import '../../../../app/shell/widgets/app_header_icon_button.dart';
import '../../../../app/shell/widgets/app_search_action_bar.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/date/app_date_formatter.dart';
import '../../presentation/task_editor_launcher.dart';
import '../controllers/tasks_controller.dart';
import '../models/task_list_options.dart';

class TasksPageHeader extends StatefulWidget {
  const TasksPageHeader({super.key});

  @override
  State<TasksPageHeader> createState() => _TasksPageHeaderState();
}

class _TasksPageHeaderState extends State<TasksPageHeader> {
  late final TasksController _controller;
  late final TextEditingController _searchController;
  final LayerLink _filterLink = LayerLink();
  final LayerLink _sortLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TasksController>();
    _searchController = TextEditingController(text: _controller.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddTask() {
    final DateTime initialDate = _controller.scopeMode == TaskScopeMode.forDay
        ? _controller.selectedDate
        : DateTime.now();
    return openTaskEditorFlow(context, initialDate: initialDate);
  }

  Future<void> _openFilterPanel(BuildContext targetContext) {
    return AppAdaptivePopover.show(
      context: context,
      targetContext: targetContext,
      link: _filterLink,
      title: 'Фильтры задач',
      onReset: () {
        unawaited(_controller.resetFilters());
      },
      builder: (BuildContext context) {
        return _TasksFilterPanel(controller: _controller);
      },
    );
  }

  Future<void> _openSortPanel(BuildContext targetContext) {
    return AppAdaptivePopover.show(
      context: context,
      targetContext: targetContext,
      link: _sortLink,
      title: 'Сортировка',
      onReset: _controller.resetSort,
      width: 320,
      builder: (BuildContext context) {
        return _TasksSortPanel(controller: _controller);
      },
    );
  }

  void _syncSearchField() {
    if (_searchController.text == _controller.searchQuery) {
      return;
    }

    _searchController.value = TextEditingValue(
      text: _controller.searchQuery,
      selection: TextSelection.collapsed(
        offset: _controller.searchQuery.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _syncSearchField();
      final bool listMode = _controller.viewMode == TaskViewMode.list;

      return AppSearchActionBar(
        controller: _searchController,
        onChanged: _controller.updateSearchQuery,
        hintText: 'Поиск по задачам и подпунктам',
        leadingActions: <Widget>[
          AppHeaderIconButton(
            key: const Key('tasks-add-button'),
            icon: Icons.add_rounded,
            tooltip: 'Новая задача',
            onPressed: _openAddTask,
          ),
          CompositedTransformTarget(
            link: _filterLink,
            child: Builder(
              builder: (BuildContext buttonContext) {
                return AppHeaderIconButton(
                  key: const Key('tasks-filter-button'),
                  icon: Icons.filter_list_rounded,
                  tooltip: 'Фильтры',
                  isActive: _controller.hasActiveFilters,
                  onPressed: () => _openFilterPanel(buttonContext),
                );
              },
            ),
          ),
          if (listMode)
            CompositedTransformTarget(
              link: _sortLink,
              child: Builder(
                builder: (BuildContext buttonContext) {
                  return AppHeaderIconButton(
                    key: const Key('tasks-sort-button'),
                    icon: Icons.sort_rounded,
                    tooltip: 'Сортировка',
                    isActive: _controller.hasActiveSortOverride,
                    onPressed: () => _openSortPanel(buttonContext),
                  );
                },
              ),
            ),
        ],
        trailingActions: <Widget>[
          AppHeaderIconButton(
            key: const Key('tasks-view-mode-matrix'),
            icon: Icons.grid_view_rounded,
            tooltip: 'Матрица',
            isActive: _controller.viewMode == TaskViewMode.matrix,
            onPressed: () => _controller.selectViewMode(TaskViewMode.matrix),
          ),
          AppHeaderIconButton(
            key: const Key('tasks-view-mode-list'),
            icon: Icons.view_agenda_outlined,
            tooltip: 'Список',
            isActive: listMode,
            onPressed: () => _controller.selectViewMode(TaskViewMode.list),
          ),
        ],
      );
    });
  }
}

class _TasksFilterPanel extends StatelessWidget {
  const _TasksFilterPanel({required this.controller});

  final TasksController controller;

  Future<void> _pickDate(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Период',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: controller.scopeModes
                .map(
                  (TaskScopeMode mode) => ChoiceChip(
                    key: Key('task-filter-scope-${mode.name}'),
                    label: Text(mode.label),
                    selected: controller.scopeMode == mode,
                    onSelected: (_) {
                      unawaited(controller.selectScopeMode(mode));
                    },
                  ),
                )
                .toList(growable: false),
          ),
          if (controller.scopeMode == TaskScopeMode.forDay) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              key: const Key('task-filter-date-button'),
              onPressed: () => _pickDate(context),
              icon: const Icon(Icons.event_outlined),
              label: Text(controller.selectedDateLabel),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Категория',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: controller.categoryFilters
                .map(
                  (TaskCategoryFilter filter) => ChoiceChip(
                    key: Key('task-filter-category-${filter.name}'),
                    label: Text(filter.label),
                    selected: controller.categoryFilter == filter,
                    onSelected: (_) => controller.selectCategoryFilter(filter),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _TasksSortPanel extends StatelessWidget {
  const _TasksSortPanel({required this.controller});

  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Как упорядочить список',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: controller.listSortOptions
                .map(
                  (TaskListSortOption option) => ChoiceChip(
                    key: Key('task-sort-option-${option.name}'),
                    label: Text(option.label),
                    selected: controller.listSortOption == option,
                    onSelected: (_) => controller.selectListSortOption(option),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}
