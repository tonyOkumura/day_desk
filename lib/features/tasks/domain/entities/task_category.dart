enum TaskCategory {
  work(label: 'Работа'),
  personal(label: 'Личное'),
  interview(label: 'Интервью'),
  publication(label: 'Публикация'),
  call(label: 'Звонок'),
  other(label: 'Другое');

  const TaskCategory({required this.label});

  final String label;
}
