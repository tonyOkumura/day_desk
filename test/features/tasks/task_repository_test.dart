import 'dart:ffi';
import 'dart:io';

import 'package:day_desk/core/reminders/reminder_lead_time_preset.dart';
import 'package:day_desk/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:day_desk/features/tasks/data/models/task_local_model.dart';
import 'package:day_desk/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:day_desk/features/tasks/domain/entities/task.dart';
import 'package:day_desk/features/tasks/domain/entities/task_category.dart';
import 'package:day_desk/features/tasks/domain/entities/task_checklist_item.dart';
import 'package:day_desk/features/tasks/domain/entities/task_quadrant.dart';
import 'package:day_desk/features/tasks/domain/entities/task_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaskRepository', () {
    test(
      'сохраняет CRUD, квадрант, checklist, deadline/reminder, completion и reschedule',
      () async {
        final _TaskRepoTestContext context = await _openContext(
          nowProvider: () => DateTime(2026, 3, 18, 12),
        );
        addTearDown(context.dispose);

        final DateTime firstDay = DateTime(2026, 3, 18);
        final DateTime secondDay = DateTime(2026, 3, 19);
        final Task firstTask = Task(
          id: 'task-a',
          title: 'Сходить в магазин',
          date: firstDay,
          startTime: DateTime(2026, 3, 18, 10),
          durationMinutes: 60,
          deadline: DateTime(2026, 3, 18, 18),
          reminderPreset: ReminderLeadTimePreset.hour1,
          isUrgent: true,
          isImportant: true,
          subtasks: const <TaskChecklistItem>[
            TaskChecklistItem(
              id: 'item-milk',
              title: 'Купить молоко',
              sortOrder: 0,
            ),
            TaskChecklistItem(
              id: 'item-bread',
              title: 'Купить хлеб',
              sortOrder: 1,
            ),
          ],
          status: TaskStatus.pending,
          category: TaskCategory.personal,
          createdAt: DateTime(2026, 3, 18, 9),
          updatedAt: DateTime(2026, 3, 18, 9),
        );
        final Task secondTask = Task(
          id: 'task-b',
          title: 'Разобрать заметки',
          date: secondDay,
          reminderPreset: ReminderLeadTimePreset.minutes15,
          isUrgent: false,
          isImportant: true,
          status: TaskStatus.pending,
          category: TaskCategory.work,
          isAllDay: true,
          createdAt: DateTime(2026, 3, 18, 11),
          updatedAt: DateTime(2026, 3, 18, 11),
        );

        await context.repository.createTask(firstTask);
        await context.repository.createTask(secondTask);

        final List<Task> firstDayTasks = await context.repository
            .getTasksByDate(firstDay);
        expect(firstDayTasks, hasLength(1));
        expect(firstDayTasks.single.id, 'task-a');
        expect(firstDayTasks.single.quadrant, TaskQuadrant.doNow);
        expect(firstDayTasks.single.deadline, DateTime(2026, 3, 18, 18));
        expect(firstDayTasks.single.reminderAt, DateTime(2026, 3, 18, 17));
        expect(firstDayTasks.single.totalSubtaskCount, 2);

        await context.repository.toggleSubtaskCompleted(
          'task-a',
          'item-milk',
          completed: true,
        );
        final Task afterChecklistToggle =
            (await context.repository.getAllTasks()).firstWhere(
              (Task task) => task.id == 'task-a',
            );
        expect(afterChecklistToggle.completedSubtaskCount, 1);

        await context.repository.updateTaskQuadrant(
          'task-a',
          quadrant: TaskQuadrant.later,
        );
        final Task reclassified = (await context.repository.getAllTasks())
            .firstWhere((Task task) => task.id == 'task-a');
        expect(reclassified.quadrant, TaskQuadrant.later);

        await context.repository.markTaskCompleted('task-a', completed: true);
        final Task completed = (await context.repository.getAllTasks())
            .firstWhere((Task task) => task.id == 'task-a');
        expect(completed.status, TaskStatus.completed);
        expect(completed.updatedAt.isAfter(firstTask.updatedAt), isTrue);

        await context.repository.rescheduleTask('task-a', date: secondDay);
        expect(await context.repository.getTasksByDate(firstDay), isEmpty);
        final List<Task> secondDayTasks = await context.repository
            .getTasksByDate(secondDay);
        expect(secondDayTasks, hasLength(2));
        final Task rescheduledTask = secondDayTasks.firstWhere(
          (Task item) => item.id == 'task-a',
        );
        expect(rescheduledTask.deadline, DateTime(2026, 3, 19, 18));
        expect(rescheduledTask.reminderAt, DateTime(2026, 3, 19, 17));
        final Task allDayTask = secondDayTasks.firstWhere(
          (Task item) => item.id == 'task-b',
        );
        expect(allDayTask.reminderAt, DateTime(2026, 3, 18, 23, 45));

        await context.repository.deleteTask('task-b');
        final List<Task> allTasks = await context.repository.getAllTasks();
        expect(allTasks, hasLength(1));
        expect(allTasks.single.id, 'task-a');
      },
    );

    test('materializes overdue but keeps pending in storage', () async {
      final _TaskRepoTestContext context = await _openContext(
        nowProvider: () => DateTime(2026, 3, 20, 12),
      );
      addTearDown(context.dispose);

      final Task task = Task(
        id: 'task-overdue',
        title: 'Отправить текст',
        date: DateTime(2026, 3, 18),
        deadline: DateTime(2026, 3, 19, 18),
        reminderPreset: ReminderLeadTimePreset.hour1,
        isUrgent: false,
        isImportant: true,
        status: TaskStatus.pending,
        category: TaskCategory.publication,
        createdAt: DateTime(2026, 3, 18, 10),
        updatedAt: DateTime(2026, 3, 18, 10),
      );

      await context.repository.createTask(task);

      final Task loaded = (await context.repository.getAllTasks()).single;
      expect(loaded.status, TaskStatus.pending);
      expect(loaded.isOverdue, isTrue);
      expect(loaded.reminderAt, DateTime(2026, 3, 19, 17));

      final TaskLocalModel stored =
          (await context.dataSource.readAllTasks()).single;
      expect(stored.status, 'pending');
      expect(stored.reminderPreset, ReminderLeadTimePreset.hour1);
    });

    test('completed task never materializes as overdue', () async {
      final _TaskRepoTestContext context = await _openContext(
        nowProvider: () => DateTime(2026, 3, 20, 12),
      );
      addTearDown(context.dispose);

      final Task task = Task(
        id: 'task-completed',
        title: 'Отправить договор',
        date: DateTime(2026, 3, 18),
        deadline: DateTime(2026, 3, 19, 9),
        reminderPreset: ReminderLeadTimePreset.minutes15,
        status: TaskStatus.completed,
        category: TaskCategory.call,
        createdAt: DateTime(2026, 3, 18, 8),
        updatedAt: DateTime(2026, 3, 18, 8),
      );

      await context.repository.createTask(task);

      final Task loaded = (await context.repository.getAllTasks()).single;
      expect(loaded.status, TaskStatus.completed);
      expect(loaded.isOverdue, isFalse);
      expect(loaded.reminderAt, DateTime(2026, 3, 19, 8, 45));
    });
  });
}

Future<_TaskRepoTestContext> _openContext({
  required DateTime Function() nowProvider,
}) async {
  await Isar.initializeIsarCore(
    libraries: <Abi, String>{Abi.current(): _resolveIsarCoreLibraryPath()},
  );
  final Directory directory = await Directory.systemTemp.createTemp(
    'day_desk_task_repo_test_',
  );
  final Isar isar = await Isar.open(
    <CollectionSchema<dynamic>>[TaskLocalModelSchema],
    directory: directory.path,
    name: 'task_repo_test_${DateTime.now().microsecondsSinceEpoch}',
    inspector: false,
  );
  final TaskLocalDataSource dataSource = TaskLocalDataSource(isar);

  return _TaskRepoTestContext(
    isar: isar,
    directory: directory,
    dataSource: dataSource,
    repository: TaskRepositoryImpl(dataSource, nowProvider: nowProvider),
  );
}

class _TaskRepoTestContext {
  const _TaskRepoTestContext({
    required this.isar,
    required this.directory,
    required this.dataSource,
    required this.repository,
  });

  final Isar isar;
  final Directory directory;
  final TaskLocalDataSource dataSource;
  final TaskRepositoryImpl repository;

  Future<void> dispose() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

String _resolveIsarCoreLibraryPath() {
  final String? pubCache = Platform.environment['PUB_CACHE'];
  final String? home = Platform.environment['HOME'];
  final List<String> candidateRoots = <String>[
    if (pubCache != null && pubCache.isNotEmpty) pubCache,
    if (home != null && home.isNotEmpty) '$home/.pub-cache',
  ];

  for (final String root in candidateRoots) {
    final Directory hostedDirectory = Directory('$root/hosted/pub.dev');
    if (!hostedDirectory.existsSync()) {
      continue;
    }

    final List<Directory> matches =
        hostedDirectory
            .listSync()
            .whereType<Directory>()
            .where(
              (Directory entry) => entry.path.contains('isar_flutter_libs-'),
            )
            .toList()
          ..sort(
            (Directory left, Directory right) =>
                right.path.compareTo(left.path),
          );

    for (final Directory match in matches) {
      final File libraryFile = File('${match.path}/linux/libisar.so');
      if (libraryFile.existsSync()) {
        return libraryFile.path;
      }
    }
  }

  throw StateError(
    'Не удалось найти libisar.so из isar_flutter_libs в PUB_CACHE.',
  );
}
