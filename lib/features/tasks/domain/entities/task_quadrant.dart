enum TaskQuadrant {
  doNow(
    label: 'Сделать сейчас',
    subtitle: 'Срочно и важно',
    isUrgent: true,
    isImportant: true,
    sortOrder: 0,
  ),
  schedule(
    label: 'Запланировать',
    subtitle: 'Не срочно, но важно',
    isUrgent: false,
    isImportant: true,
    sortOrder: 1,
  ),
  quickWins(
    label: 'Быстро закрыть',
    subtitle: 'Срочно, но не важно',
    isUrgent: true,
    isImportant: false,
    sortOrder: 2,
  ),
  later(
    label: 'Отложить',
    subtitle: 'Не срочно и не важно',
    isUrgent: false,
    isImportant: false,
    sortOrder: 3,
  );

  const TaskQuadrant({
    required this.label,
    required this.subtitle,
    required this.isUrgent,
    required this.isImportant,
    required this.sortOrder,
  });

  final String label;
  final String subtitle;
  final bool isUrgent;
  final bool isImportant;
  final int sortOrder;

  static TaskQuadrant fromFlags({
    required bool isUrgent,
    required bool isImportant,
  }) {
    for (final TaskQuadrant quadrant in values) {
      if (quadrant.isUrgent == isUrgent &&
          quadrant.isImportant == isImportant) {
        return quadrant;
      }
    }

    return schedule;
  }
}
