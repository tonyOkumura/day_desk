enum TaskStatus {
  pending(label: 'Открыта'),
  completed(label: 'Готово');

  const TaskStatus({required this.label});

  final String label;
}
