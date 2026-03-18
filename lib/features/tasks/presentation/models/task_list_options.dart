import '../../domain/entities/task_category.dart';

enum TaskViewMode {
  matrix(label: 'Матрица'),
  list(label: 'Список');

  const TaskViewMode({required this.label});

  final String label;
}

enum TaskScopeMode {
  forDay(label: 'На дату'),
  allTasks(label: 'Все');

  const TaskScopeMode({required this.label});

  final String label;
}

enum TaskCategoryFilter {
  all(label: 'Все категории'),
  work(label: 'Работа', category: TaskCategory.work),
  personal(label: 'Личное', category: TaskCategory.personal),
  interview(label: 'Интервью', category: TaskCategory.interview),
  publication(label: 'Публикация', category: TaskCategory.publication),
  call(label: 'Звонок', category: TaskCategory.call),
  other(label: 'Другое', category: TaskCategory.other);

  const TaskCategoryFilter({required this.label, this.category});

  final String label;
  final TaskCategory? category;

  bool matches(TaskCategory value) {
    return category == null || category == value;
  }
}

enum TaskListSortOption {
  deadlineFirst(label: 'По сроку'),
  dateTime(label: 'По времени/дате'),
  recentlyUpdated(label: 'Недавно изменённые');

  const TaskListSortOption({required this.label});

  final String label;
}
