enum TaskPriority {
  low(label: 'Низкий', sortWeight: 0),
  medium(label: 'Средний', sortWeight: 1),
  high(label: 'Высокий', sortWeight: 2);

  const TaskPriority({required this.label, required this.sortWeight});

  final String label;
  final int sortWeight;
}
