import 'dart:ffi';
import 'dart:io';

import 'package:day_desk/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:day_desk/features/tasks/data/models/task_local_model.dart';
import 'package:day_desk/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:day_desk/features/tasks/domain/entities/task.dart';
import 'package:day_desk/features/tasks/domain/entities/task_category.dart';
import 'package:day_desk/features/tasks/domain/entities/task_priority.dart';
import 'package:day_desk/features/tasks/domain/entities/task_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'TaskRepository сохраняет CRUD, completion и reschedule сценарии',
    () async {
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
      final TaskRepositoryImpl repository = TaskRepositoryImpl(
        TaskLocalDataSource(isar),
      );

      final DateTime firstDay = DateTime(2026, 3, 18);
      final DateTime secondDay = DateTime(2026, 3, 19);
      final Task firstTask = Task(
        id: 'task-a',
        title: 'Подготовить интервью',
        date: firstDay,
        startTime: DateTime(2026, 3, 18, 10),
        durationMinutes: 60,
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        category: TaskCategory.interview,
        createdAt: DateTime(2026, 3, 18, 9),
        updatedAt: DateTime(2026, 3, 18, 9),
      );
      final Task secondTask = Task(
        id: 'task-b',
        title: 'Разобрать заметки',
        date: secondDay,
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        category: TaskCategory.work,
        isAllDay: true,
        createdAt: DateTime(2026, 3, 18, 11),
        updatedAt: DateTime(2026, 3, 18, 11),
      );

      await repository.createTask(firstTask);
      await repository.createTask(secondTask);

      final List<Task> firstDayTasks = await repository.getTasksByDate(
        firstDay,
      );
      expect(firstDayTasks, hasLength(1));
      expect(firstDayTasks.single.id, 'task-a');

      await repository.markTaskCompleted('task-a', completed: true);
      final Task completed = (await repository.getAllTasks()).firstWhere(
        (Task task) => task.id == 'task-a',
      );
      expect(completed.status, TaskStatus.completed);
      expect(completed.updatedAt.isAfter(firstTask.updatedAt), isTrue);

      await repository.rescheduleTask('task-a', date: secondDay);
      expect(await repository.getTasksByDate(firstDay), isEmpty);
      expect(await repository.getTasksByDate(secondDay), hasLength(2));

      await repository.deleteTask('task-b');
      final List<Task> allTasks = await repository.getAllTasks();
      expect(allTasks, hasLength(1));
      expect(allTasks.single.id, 'task-a');

      await isar.close(deleteFromDisk: true);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    },
  );
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
