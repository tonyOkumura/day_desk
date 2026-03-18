import '../entities/task.dart';
import '../entities/task_quadrant.dart';

abstract interface class TaskRepository {
  Future<void> createTask(Task task);

  Future<void> updateTask(Task task);

  Future<void> deleteTask(String taskId);

  Future<List<Task>> getTasksByDate(DateTime date);

  Future<List<Task>> getAllTasks();

  Stream<List<Task>> watchTasksByDate(DateTime date);

  Stream<List<Task>> watchAllTasks();

  Future<void> markTaskCompleted(String taskId, {required bool completed});

  Future<void> updateTaskQuadrant(
    String taskId, {
    required TaskQuadrant quadrant,
  });

  Future<void> toggleSubtaskCompleted(
    String taskId,
    String subtaskId, {
    required bool completed,
  });

  Future<void> rescheduleTask(
    String taskId, {
    required DateTime date,
    DateTime? startTime,
  });
}
