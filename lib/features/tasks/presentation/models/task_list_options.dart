enum TaskListMode {
  forDay(label: 'На дату'),
  allTasks(label: 'Все');

  const TaskListMode({required this.label});

  final String label;
}

enum TaskStatusFilter {
  all(label: 'Все'),
  pending(label: 'В работе'),
  postponed(label: 'Отложенные'),
  overdue(label: 'Просроченные'),
  completed(label: 'Завершённые');

  const TaskStatusFilter({required this.label});

  final String label;
}

enum TaskSortOption {
  chronological(label: 'По времени'),
  priorityFirst(label: 'По приоритету');

  const TaskSortOption({required this.label});

  final String label;
}
