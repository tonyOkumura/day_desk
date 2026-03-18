import 'dart:async';

import 'package:isar/isar.dart';

import '../models/task_local_model.dart';

class TaskLocalDataSource {
  TaskLocalDataSource(this._isar);

  final Isar _isar;

  Future<void> createTask(TaskLocalModel task) async {
    await _isar.writeTxn(() async {
      await _isar.taskLocalModels.put(task);
    });
  }

  Future<void> updateTask(TaskLocalModel task) async {
    await _isar.writeTxn(() async {
      await _isar.taskLocalModels.put(task);
    });
  }

  Future<void> deleteTask(String taskId) async {
    final TaskLocalModel? existing = await readTaskByTaskId(taskId);
    if (existing == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.taskLocalModels.delete(existing.isarId);
    });
  }

  Future<TaskLocalModel?> readTaskByTaskId(String taskId) async {
    final List<TaskLocalModel> tasks = await readAllTasks();
    for (final TaskLocalModel task in tasks) {
      if (task.taskId == taskId) {
        return task;
      }
    }

    return null;
  }

  Future<List<TaskLocalModel>> readAllTasks() {
    return _isar.taskLocalModels.where().findAll();
  }

  Stream<List<TaskLocalModel>> watchAllTasks() async* {
    yield await readAllTasks();
    yield* _isar.taskLocalModels.watchLazy().asyncMap((_) => readAllTasks());
  }
}
