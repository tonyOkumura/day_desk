import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.dateFormatter,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
    required this.onReschedule,
    super.key,
  });

  final Task task;
  final AppDateFormatter dateFormatter;
  final VoidCallback onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReschedule;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final bool completed = task.isCompleted;

    return AppSurfaceCard(
      key: Key('task-card-${task.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: completed
                            ? colorScheme.onSurfaceVariant
                            : textTheme.titleLarge?.color,
                      ),
                    ),
                    if (task.description != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        task.description!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton.filledTonal(
                key: Key('task-completion-button-${task.id}'),
                tooltip: completed
                    ? 'Вернуть в активные'
                    : 'Отметить выполненной',
                onPressed: onToggleCompleted,
                icon: Icon(
                  completed
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _TaskMetaChip(
                icon: Icons.today_outlined,
                label: dateFormatter.formatRelativeDay(task.date),
              ),
              _TaskMetaChip(
                icon: task.isAllDay
                    ? Icons.calendar_today_rounded
                    : Icons.schedule_rounded,
                label: _timeLabel,
              ),
              _TaskMetaChip(
                icon: _priorityIcon(task.priority),
                label: task.priority.label,
              ),
              _TaskMetaChip(
                icon: Icons.sell_outlined,
                label: task.category.label,
              ),
              _TaskMetaChip(
                icon: completed ? Icons.done_all_rounded : Icons.work_outline,
                label: task.status.label,
                highlighted: completed,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                key: Key('task-edit-button-${task.id}'),
                tooltip: 'Редактировать',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                key: Key('task-reschedule-button-${task.id}'),
                tooltip: 'Перенести',
                onPressed: onReschedule,
                icon: const Icon(Icons.event_repeat_outlined),
              ),
              IconButton(
                key: Key('task-delete-button-${task.id}'),
                tooltip: 'Удалить',
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _timeLabel {
    if (task.isAllDay) {
      return 'Весь день';
    }

    final DateTime? start = task.startTime;
    final DateTime? end = task.endTime;
    if (start != null && end != null) {
      return dateFormatter.formatTimeRange(start, end);
    }
    if (start != null) {
      return dateFormatter.formatTime(start);
    }

    return 'Без времени';
  }

  IconData _priorityIcon(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => Icons.keyboard_arrow_down_rounded,
      TaskPriority.medium => Icons.drag_handle_rounded,
      TaskPriority.high => Icons.priority_high_rounded,
    };
  }
}

class _TaskMetaChip extends StatelessWidget {
  const _TaskMetaChip({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foreground = highlighted
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primaryContainer.withValues(alpha: 0.65)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.mono(
                context,
              ).copyWith(color: foreground, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
