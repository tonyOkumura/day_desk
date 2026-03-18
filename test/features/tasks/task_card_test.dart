import 'package:day_desk/core/date/app_date_formatter.dart';
import 'package:day_desk/features/tasks/domain/entities/task.dart';
import 'package:day_desk/features/tasks/domain/entities/task_category.dart';
import 'package:day_desk/features/tasks/domain/entities/task_checklist_item.dart';
import 'package:day_desk/features/tasks/domain/entities/task_quadrant.dart';
import 'package:day_desk/features/tasks/domain/entities/task_status.dart';
import 'package:day_desk/features/tasks/presentation/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting(AppDateFormatter.localeName);
  });

  testWidgets(
    'TaskCard toggles completion on single tap when double tap edit is disabled',
    (WidgetTester tester) async {
      int toggleCount = 0;
      int editCount = 0;

      await _pumpTaskCard(
        tester,
        task: _task(id: 'task-1'),
        enableDoubleTapEdit: false,
        onToggleCompleted: () => toggleCount++,
        onEdit: () => editCount++,
      );

      await tester.tap(find.byKey(const Key('task-card-tile-task-1')));
      await tester.pumpAndSettle();

      expect(toggleCount, 1);
      expect(editCount, 0);
    },
  );

  testWidgets(
    'TaskCard delays desktop single tap and toggles after double click window',
    (WidgetTester tester) async {
      int toggleCount = 0;
      int editCount = 0;

      await _pumpTaskCard(
        tester,
        task: _task(id: 'task-1'),
        enableDoubleTapEdit: true,
        onToggleCompleted: () => toggleCount++,
        onEdit: () => editCount++,
      );

      await tester.tap(find.byKey(const Key('task-card-tile-task-1')));
      await tester.pump(const Duration(milliseconds: 120));

      expect(toggleCount, 0);
      expect(editCount, 0);

      await tester.pump(const Duration(milliseconds: 140));

      expect(toggleCount, 1);
      expect(editCount, 0);
    },
  );

  testWidgets(
    'TaskCard opens editor on double tap without toggling completion',
    (WidgetTester tester) async {
      int toggleCount = 0;
      int editCount = 0;

      await _pumpTaskCard(
        tester,
        task: _task(id: 'task-1'),
        enableDoubleTapEdit: true,
        onToggleCompleted: () => toggleCount++,
        onEdit: () => editCount++,
      );

      final Finder tile = find.byKey(const Key('task-card-tile-task-1'));
      await tester.tap(tile);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(toggleCount, 0);
      expect(editCount, 1);
    },
  );

  testWidgets(
    'TaskCard renders completed overlay watermark for completed task',
    (WidgetTester tester) async {
      await _pumpTaskCard(
        tester,
        task: _task(id: 'task-1', status: TaskStatus.completed),
        enableDoubleTapEdit: false,
      );

      expect(
        find.byKey(const Key('task-completed-overlay-task-1')),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpTaskCard(
  WidgetTester tester, {
  required Task task,
  required bool enableDoubleTapEdit,
  VoidCallback? onToggleCompleted,
  VoidCallback? onEdit,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 420,
            child: TaskCard(
              task: task,
              density: TaskCardDensity.comfortable,
              dateFormatter: AppDateFormatter(),
              onToggleCompleted: onToggleCompleted ?? () {},
              onEdit: onEdit ?? () {},
              enableDoubleTapEdit: enableDoubleTapEdit,
              onDelete: () {},
              onReschedule: () {},
              onReclassify: (_) {},
              onToggleSubtaskCompleted: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

Task _task({required String id, TaskStatus status = TaskStatus.pending}) {
  final DateTime now = DateTime(2026, 3, 19, 12);
  return Task(
    id: id,
    title: 'Подготовить задачу',
    date: DateTime(now.year, now.month, now.day),
    deadline: DateTime(now.year, now.month, now.day, 18),
    reminderAt: DateTime(now.year, now.month, now.day, 17, 45),
    isUrgent: TaskQuadrant.doNow.isUrgent,
    isImportant: TaskQuadrant.doNow.isImportant,
    status: status,
    category: TaskCategory.work,
    subtasks: const <TaskChecklistItem>[
      TaskChecklistItem(id: 'sub-1', title: 'Черновик', sortOrder: 0),
    ],
    createdAt: now,
    updatedAt: now,
    evaluationTime: now,
  );
}
