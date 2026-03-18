import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/config/app_breakpoints.dart';
import '../../../../core/date/app_date_formatter.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_checklist_item.dart';
import '../../domain/entities/task_quadrant.dart';

enum TaskCardDensity { comfortable, compact }

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.density,
    required this.dateFormatter,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.enableDoubleTapEdit,
    required this.onDelete,
    required this.onReschedule,
    required this.onReclassify,
    required this.onToggleSubtaskCompleted,
    super.key,
  });

  final Task task;
  final TaskCardDensity density;
  final AppDateFormatter dateFormatter;
  final VoidCallback onToggleCompleted;
  final VoidCallback onEdit;
  final bool enableDoubleTapEdit;
  final VoidCallback onDelete;
  final VoidCallback onReschedule;
  final ValueChanged<TaskQuadrant> onReclassify;
  final ValueChanged<TaskChecklistItem> onToggleSubtaskCompleted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final bool completed = task.isCompleted;
    final bool overdue = task.isOverdue;
    final List<TaskChecklistItem> previewItems = task.subtasks
        .take(3)
        .toList(growable: false);
    final int hiddenItemsCount = task.subtasks.length - previewItems.length;

    final Widget content = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        if (completed)
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double iconSize = (constraints.maxHeight * 0.9).clamp(
                    density == TaskCardDensity.compact ? 72.0 : 88.0,
                    density == TaskCardDensity.compact ? 132.0 : 176.0,
                  );

                  return Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      key: Key('task-completed-overlay-${task.id}'),
                      size: iconSize,
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  );
                },
              ),
            ),
          ),
        density == TaskCardDensity.compact
            ? _buildCompactContent(
                context: context,
                textTheme: textTheme,
                colorScheme: colorScheme,
                completed: completed,
                overdue: overdue,
              )
            : _buildComfortableContent(
                context: context,
                textTheme: textTheme,
                colorScheme: colorScheme,
                completed: completed,
                overdue: overdue,
                previewItems: previewItems,
                hiddenItemsCount: hiddenItemsCount,
              ),
      ],
    );

    return Opacity(
      opacity: completed ? 0.74 : 1,
      child: _TaskInteractiveShell(
        key: Key('task-card-${task.id}'),
        tileKey: Key('task-card-tile-${task.id}'),
        onTap: onToggleCompleted,
        onDoubleTap: enableDoubleTapEdit ? onEdit : null,
        child: Container(
          key: Key('task-card-density-${density.name}-${task.id}'),
          child: content,
        ),
      ),
    );
  }

  Widget _buildComfortableContent({
    required BuildContext context,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required bool completed,
    required bool overdue,
    required List<TaskChecklistItem> previewItems,
    required int hiddenItemsCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TaskCardHeader(
          title: task.title,
          titleStyle: _titleStyle(
            textStyle: textTheme.titleLarge,
            colorScheme: colorScheme,
            completed: completed,
            overdue: overdue,
          ),
          titleMaxLines: 3,
          titleBottomSpacing: AppSpacing.md,
          overflowButton: _buildOverflowButton(
            compact: false,
            colorScheme: colorScheme,
          ),
          metaContent: _buildPrimaryMetaRow(compact: false),
        ),
        const SizedBox(height: AppSpacing.lg),
        _TaskCardPriorityBlock(
          dueLabel: _dueSummaryLabel,
          dueIcon: _dueIcon,
          dueTone: overdue ? _TaskMetaTone.error : _dueTone,
          reminderLabel: _reminderSummaryLabel(compact: false),
          reminderIcon: _reminderIcon,
          reminderTone: _reminderTone,
          compact: false,
        ),
        const SizedBox(height: AppSpacing.md),
        _TaskTertiaryMeta(
          categoryLabel: task.category.label,
          scheduleLabel: task.deadline != null ? _timeLabel : null,
          compact: false,
        ),
        if (previewItems.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...previewItems.map(
                (TaskChecklistItem item) => _TaskSubtaskPreviewRow(
                  key: Key('task-subtask-${task.id}-${item.id}'),
                  item: item,
                  onTap: () => onToggleSubtaskCompleted(item),
                ),
              ),
              if (hiddenItemsCount > 0) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Ещё $hiddenItemsCount',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCompactContent({
    required BuildContext context,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required bool completed,
    required bool overdue,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool showCategory = constraints.maxWidth >= 260;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _TaskCardHeader(
              title: task.title,
              titleStyle: _titleStyle(
                textStyle: textTheme.titleMedium,
                colorScheme: colorScheme,
                completed: completed,
                overdue: overdue,
                lineHeight: 1.2,
              ),
              titleMaxLines: 2,
              titleBottomSpacing: AppSpacing.sm,
              overflowButton: _buildOverflowButton(
                compact: true,
                colorScheme: colorScheme,
              ),
              metaContent: _buildPrimaryMetaRow(compact: true),
            ),
            const SizedBox(height: AppSpacing.md),
            _TaskCardPriorityBlock(
              dueLabel: _dueSummaryLabel,
              dueIcon: _dueIcon,
              dueTone: overdue ? _TaskMetaTone.error : _dueTone,
              reminderLabel: _reminderSummaryLabel(compact: true),
              reminderIcon: _reminderIcon,
              reminderTone: _reminderTone,
              compact: true,
            ),
            if (showCategory) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              _TaskTertiaryMeta(
                categoryLabel: task.category.label,
                scheduleLabel: task.deadline != null ? _timeLabel : null,
                compact: true,
              ),
            ],
          ],
        );
      },
    );
  }

  TextStyle? _titleStyle({
    required TextStyle? textStyle,
    required ColorScheme colorScheme,
    required bool completed,
    required bool overdue,
    double? lineHeight,
  }) {
    return textStyle?.copyWith(
      fontWeight: FontWeight.w700,
      height: lineHeight,
      decoration: completed ? TextDecoration.lineThrough : null,
      color: completed
          ? colorScheme.onSurfaceVariant
          : overdue
          ? colorScheme.error
          : textStyle.color,
    );
  }

  Widget _buildPrimaryMetaRow({required bool compact}) {
    final List<Widget> chips = <Widget>[
      Builder(
        builder: (BuildContext chipContext) {
          return InkWell(
            key: Key('task-quadrant-button-${task.id}'),
            borderRadius: BorderRadius.circular(999),
            onTap: () => _showQuadrantPicker(chipContext),
            child: _TaskMetaChip(
              icon: _quadrantIcon(task.quadrant),
              label: task.quadrant.label,
              tone: _quadrantTone(task.quadrant),
              compact: compact,
            ),
          );
        },
      ),
    ];

    if (task.totalSubtaskCount > 0) {
      chips.add(
        _TaskMetaChip(
          icon: Icons.checklist_rounded,
          label: '${task.completedSubtaskCount}/${task.totalSubtaskCount}',
          compact: compact,
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: chips,
    );
  }

  Widget _buildOverflowButton({
    required bool compact,
    required ColorScheme colorScheme,
  }) {
    return PopupMenuButton<_TaskCardOverflowAction>(
      key: Key('task-overflow-button-${task.id}'),
      tooltip: 'Действия',
      padding: EdgeInsets.zero,
      onSelected: (_TaskCardOverflowAction action) {
        switch (action) {
          case _TaskCardOverflowAction.edit:
            onEdit();
          case _TaskCardOverflowAction.reschedule:
            onReschedule();
          case _TaskCardOverflowAction.delete:
            onDelete();
        }
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<_TaskCardOverflowAction>>[
          const PopupMenuItem<_TaskCardOverflowAction>(
            value: _TaskCardOverflowAction.edit,
            child: _TaskOverflowMenuItem(
              icon: Icons.edit_outlined,
              label: 'Редактировать',
            ),
          ),
          const PopupMenuItem<_TaskCardOverflowAction>(
            value: _TaskCardOverflowAction.reschedule,
            child: _TaskOverflowMenuItem(
              icon: Icons.event_repeat_outlined,
              label: 'Перенести',
            ),
          ),
          PopupMenuItem<_TaskCardOverflowAction>(
            value: _TaskCardOverflowAction.delete,
            child: _TaskOverflowMenuItem(
              icon: Icons.delete_outline_rounded,
              label: 'Удалить',
              color: colorScheme.error,
            ),
          ),
        ];
      },
      icon: Icon(compact ? Icons.more_horiz_rounded : Icons.more_vert_rounded),
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

  String get _dueSummaryLabel {
    if (task.deadline != null) {
      final String deadlineLabel = dateFormatter.formatDeadline(task.deadline!);
      return task.isOverdue
          ? 'Просрочено до $deadlineLabel'
          : 'Дедлайн $deadlineLabel';
    }

    final String dayLabel = dateFormatter.formatRelativeDay(task.date);
    if (_timeLabel == 'Без времени') {
      return task.isOverdue ? 'Просрочено · $dayLabel' : dayLabel;
    }

    final String scheduleLabel = '$dayLabel · $_timeLabel';
    return task.isOverdue ? 'Просрочено · $scheduleLabel' : scheduleLabel;
  }

  IconData get _dueIcon {
    if (task.isOverdue) {
      return Icons.warning_amber_rounded;
    }
    if (task.deadline != null) {
      return Icons.flag_outlined;
    }

    return task.isAllDay
        ? Icons.calendar_today_rounded
        : Icons.schedule_rounded;
  }

  _TaskMetaTone get _dueTone {
    return task.deadline != null
        ? _TaskMetaTone.primary
        : _TaskMetaTone.neutral;
  }

  String? _reminderSummaryLabel({required bool compact}) {
    if (!task.hasReminderPreset) {
      return null;
    }

    final String presetLabel = compact
        ? task.reminderPreset.label
        : task.reminderPreset.taskChipLabel;
    if (task.reminderAt != null) {
      final String reminderMoment = compact
          ? dateFormatter.formatDeadline(task.reminderAt!)
          : dateFormatter.formatDateTime(task.reminderAt!);
      return '$presetLabel · $reminderMoment';
    }

    return compact
        ? '$presetLabel · ждёт время'
        : '$presetLabel · активируется после дедлайна или времени';
  }

  IconData get _reminderIcon {
    return task.reminderAt != null
        ? Icons.notifications_active_outlined
        : Icons.hourglass_bottom_rounded;
  }

  _TaskMetaTone get _reminderTone {
    return task.reminderAt != null
        ? _TaskMetaTone.primary
        : _TaskMetaTone.neutral;
  }

  IconData _quadrantIcon(TaskQuadrant quadrant) {
    return switch (quadrant) {
      TaskQuadrant.doNow => Icons.bolt_rounded,
      TaskQuadrant.schedule => Icons.event_note_rounded,
      TaskQuadrant.quickWins => Icons.flash_on_rounded,
      TaskQuadrant.later => Icons.hourglass_top_rounded,
    };
  }

  _TaskMetaTone _quadrantTone(TaskQuadrant quadrant) {
    return switch (quadrant) {
      TaskQuadrant.doNow => _TaskMetaTone.error,
      TaskQuadrant.schedule => _TaskMetaTone.primary,
      TaskQuadrant.quickWins => _TaskMetaTone.tertiary,
      TaskQuadrant.later => _TaskMetaTone.neutral,
    };
  }

  Future<void> _showQuadrantPicker(BuildContext chipContext) async {
    final bool compact =
        MediaQuery.sizeOf(chipContext).width < AppBreakpoints.compactNavigation;

    if (compact) {
      final TaskQuadrant? selected = await showModalBottomSheet<TaskQuadrant>(
        context: chipContext,
        useSafeArea: true,
        showDragHandle: true,
        builder: (BuildContext context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Изменить квадрант',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...TaskQuadrant.values.map(
                    (TaskQuadrant value) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(_quadrantIcon(value)),
                      title: Text(value.label),
                      subtitle: Text(value.subtitle),
                      trailing: task.quadrant == value
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () => Navigator.of(context).pop(value),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (selected != null) {
        onReclassify(selected);
      }
      return;
    }

    final RenderBox button = chipContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(chipContext).context.findRenderObject() as RenderBox;
    final Offset topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Offset bottomRight = button.localToGlobal(
      button.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );

    final TaskQuadrant? selected = await showMenu<TaskQuadrant>(
      context: chipContext,
      position: RelativeRect.fromRect(
        Rect.fromPoints(topLeft, bottomRight),
        Offset.zero & overlay.size,
      ),
      items: TaskQuadrant.values
          .map(
            (TaskQuadrant value) => PopupMenuItem<TaskQuadrant>(
              value: value,
              child: Text(value.label),
            ),
          )
          .toList(growable: false),
    );
    if (selected != null) {
      onReclassify(selected);
    }
  }
}

class _TaskInteractiveShell extends StatefulWidget {
  const _TaskInteractiveShell({
    required this.child,
    required this.onTap,
    required this.onDoubleTap,
    required this.tileKey,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final Key tileKey;

  @override
  State<_TaskInteractiveShell> createState() => _TaskInteractiveShellState();
}

class _TaskInteractiveShellState extends State<_TaskInteractiveShell> {
  static const Duration _desktopDoubleTapWindow = Duration(milliseconds: 220);

  bool _hovered = false;
  bool _pressed = false;
  Timer? _pendingTapTimer;

  @override
  void dispose() {
    _pendingTapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final bool active = _hovered || _pressed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: active
              ? AppTheme.surfaceColor(context).withValues(alpha: 0.98)
              : AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: active
                ? colorScheme.primary.withValues(alpha: isDark ? 0.55 : 0.42)
                : colorScheme.outlineVariant.withValues(alpha: 0.35),
            width: active ? 1.35 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: active ? (isDark ? 0.18 : 0.08) : (isDark ? 0.14 : 0.06),
              ),
              blurRadius: active ? 18 : 14,
              offset: Offset(0, active ? 8 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: widget.tileKey,
            borderRadius: BorderRadius.circular(AppRadii.card),
            onTap: _handleTap,
            onHighlightChanged: (bool value) {
              if (_pressed != value && mounted) {
                setState(() => _pressed = value);
              }
            },
            splashColor: colorScheme.primary.withValues(alpha: 0.06),
            highlightColor: colorScheme.primary.withValues(alpha: 0.03),
            hoverColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    final VoidCallback? onDoubleTap = widget.onDoubleTap;
    if (onDoubleTap == null) {
      widget.onTap();
      return;
    }

    if (_pendingTapTimer?.isActive ?? false) {
      _pendingTapTimer?.cancel();
      _pendingTapTimer = null;
      onDoubleTap();
      return;
    }

    _pendingTapTimer = Timer(_desktopDoubleTapWindow, () {
      _pendingTapTimer = null;
      if (!mounted) {
        return;
      }
      widget.onTap();
    });
  }
}

class _TaskCardHeader extends StatelessWidget {
  const _TaskCardHeader({
    required this.title,
    required this.titleStyle,
    required this.titleMaxLines,
    required this.titleBottomSpacing,
    required this.overflowButton,
    required this.metaContent,
  });

  final String title;
  final TextStyle? titleStyle;
  final int titleMaxLines;
  final double titleBottomSpacing;
  final Widget overflowButton;
  final Widget metaContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            overflowButton,
          ],
        ),
        SizedBox(height: titleBottomSpacing),
        metaContent,
      ],
    );
  }
}

class _TaskCardPriorityBlock extends StatelessWidget {
  const _TaskCardPriorityBlock({
    required this.dueLabel,
    required this.dueIcon,
    required this.dueTone,
    required this.reminderLabel,
    required this.reminderIcon,
    required this.reminderTone,
    required this.compact,
  });

  final String dueLabel;
  final IconData dueIcon;
  final _TaskMetaTone dueTone;
  final String? reminderLabel;
  final IconData reminderIcon;
  final _TaskMetaTone reminderTone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TaskInlineInfo(
          icon: dueIcon,
          label: dueLabel,
          tone: dueTone,
          compact: compact,
        ),
        if (reminderLabel != null) ...<Widget>[
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          _TaskInlineInfo(
            icon: reminderIcon,
            label: reminderLabel!,
            tone: reminderTone,
            compact: compact,
          ),
        ],
      ],
    );
  }
}

class _TaskTertiaryMeta extends StatelessWidget {
  const _TaskTertiaryMeta({
    required this.categoryLabel,
    required this.scheduleLabel,
    required this.compact,
  });

  final String categoryLabel;
  final String? scheduleLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? AppSpacing.md : AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        _TaskInlineInfo(
          icon: Icons.sell_outlined,
          label: categoryLabel,
          tone: _TaskMetaTone.neutral,
          compact: compact,
          textOpacity: compact ? 0.86 : 0.92,
          iconOpacity: 0.78,
        ),
        if (scheduleLabel != null && scheduleLabel!.isNotEmpty)
          _TaskInlineInfo(
            icon: Icons.schedule_rounded,
            label: scheduleLabel!,
            tone: _TaskMetaTone.neutral,
            compact: compact,
            textOpacity: compact ? 0.82 : 0.88,
            iconOpacity: 0.72,
          ),
      ],
    );
  }
}

class _TaskInlineInfo extends StatelessWidget {
  const _TaskInlineInfo({
    required this.icon,
    required this.label,
    required this.tone,
    required this.compact,
    this.textOpacity = 1,
    this.iconOpacity = 1,
  });

  final IconData icon;
  final String label;
  final _TaskMetaTone tone;
  final bool compact;
  final double textOpacity;
  final double iconOpacity;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color baseColor = switch (tone) {
      _TaskMetaTone.neutral => colorScheme.onSurfaceVariant,
      _TaskMetaTone.primary => colorScheme.primary,
      _TaskMetaTone.tertiary => colorScheme.tertiary,
      _TaskMetaTone.error => colorScheme.error,
    };

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 240 : 420),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: compact ? 14 : 16,
            color: baseColor.withValues(alpha: iconOpacity),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.meta(context).copyWith(
                color: baseColor.withValues(alpha: textOpacity),
                fontSize: compact ? 12 : 13,
                fontWeight: tone == _TaskMetaTone.error
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskSubtaskPreviewRow extends StatelessWidget {
  const _TaskSubtaskPreviewRow({
    required this.item,
    required this.onTap,
    super.key,
  });

  final TaskChecklistItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: <Widget>[
            Checkbox(value: item.isCompleted, onChanged: (_) => onTap()),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: item.isCompleted ? colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskMetaChip extends StatelessWidget {
  const _TaskMetaChip({
    required this.icon,
    required this.label,
    this.tone = _TaskMetaTone.neutral,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final _TaskMetaTone tone;
  final bool compact;

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
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : AppSpacing.md,
          vertical: compact ? AppSpacing.xs : AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: compact ? 14 : 16, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.mono(
                context,
              ).copyWith(color: foreground, fontSize: compact ? 11 : 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskOverflowMenuItem extends StatelessWidget {
  const _TaskOverflowMenuItem({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: color == null ? null : TextStyle(color: color)),
      ],
    );
  }
}

enum _TaskMetaTone { neutral, primary, tertiary, error }

enum _TaskCardOverflowAction { edit, reschedule, delete }
