enum TaskStatus {
  pending(label: 'В работе'),
  completed(label: 'Завершена');

  const TaskStatus({required this.label});

  final String label;
}
