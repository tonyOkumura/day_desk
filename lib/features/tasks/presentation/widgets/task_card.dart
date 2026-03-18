import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/reminders/reminder_lead_time_preset.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.dateFormatter,
    required this.onToggleCompleted,
    required this.onTogglePostponed,
    required this.onEdit,
    required this.onDelete,
    required this.onReschedule,
    super.key,
  });

  final Task task;
  final AppDateFormatter dateFormatter;
  final VoidCallback onToggleCompleted;
  final VoidCallback onTogglePostponed;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReschedule;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final bool completed = task.isCompleted;
    final bool overdue = task.isOverdue;
    final bool postponed = task.isPostponed;

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
                            : overdue
                            ? colorScheme.error
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
              if (task.deadline != null)
                _TaskMetaChip(
                  icon: Icons.flag_outlined,
                  label:
                      'Дедлайн: ${dateFormatter.formatDateTime(task.deadline!)}',
                  tone: overdue ? _TaskMetaTone.error : _TaskMetaTone.neutral,
                ),
              if (task.reminderPreset != ReminderLeadTimePreset.none)
                _TaskMetaChip(
                  icon: Icons.notifications_active_outlined,
                  label: task.reminderPreset.taskChipLabel,
                ),
              if (task.reminderPreset != ReminderLeadTimePreset.none &&
                  task.reminderAt != null)
                _TaskMetaChip(
                  icon: Icons.alarm_outlined,
                  label:
                      'Сработает: ${dateFormatter.formatDateTime(task.reminderAt!)}',
                )
              else if (task.reminderPreset != ReminderLeadTimePreset.none)
                const _TaskMetaChip(
                  icon: Icons.hourglass_bottom_rounded,
                  label: 'Ждёт дедлайн или время',
                ),
              _TaskMetaChip(
                icon: switch (task.status) {
                  TaskStatus.completed => Icons.done_all_rounded,
                  TaskStatus.postponed => Icons.pause_circle_outline_rounded,
                  TaskStatus.overdue => Icons.error_outline_rounded,
                  TaskStatus.pending => Icons.work_outline,
                },
                label: task.status.label,
                tone: switch (task.status) {
                  TaskStatus.completed => _TaskMetaTone.primary,
                  TaskStatus.postponed => _TaskMetaTone.tertiary,
                  TaskStatus.overdue => _TaskMetaTone.error,
                  TaskStatus.pending => _TaskMetaTone.neutral,
                },
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
              if (!completed)
                IconButton(
                  key: Key('task-postpone-button-${task.id}'),
                  tooltip: postponed ? 'Вернуть в работу' : 'Отложить',
                  onPressed: onTogglePostponed,
                  icon: Icon(
                    postponed
                        ? Icons.play_circle_outline_rounded
                        : Icons.pause_circle_outline_rounded,
                  ),
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
    this.tone = _TaskMetaTone.neutral,
  });

  final IconData icon;
  final String label;
  final _TaskMetaTone tone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foreground = switch (tone) {
      _TaskMetaTone.neutral => colorScheme.onSurfaceVariant,
      _TaskMetaTone.primary => colorScheme.primary,
      _TaskMetaTone.tertiary => colorScheme.tertiary,
      _TaskMetaTone.error => colorScheme.error,
    };
    final Color background = switch (tone) {
      _TaskMetaTone.neutral => colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.6,
      ),
      _TaskMetaTone.primary => colorScheme.primaryContainer.withValues(
        alpha: 0.65,
      ),
      _TaskMetaTone.tertiary => colorScheme.tertiaryContainer.withValues(
        alpha: 0.65,
      ),
      _TaskMetaTone.error => colorScheme.errorContainer.withValues(alpha: 0.72),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
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

enum _TaskMetaTone { neutral, primary, tertiary, error }
