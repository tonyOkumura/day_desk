enum TaskStatus {
  pending(
    label: 'В работе',
    sortOrder: 1,
    persistsInStorage: true,
    selectableInEditor: true,
  ),
  postponed(
    label: 'Отложена',
    sortOrder: 2,
    persistsInStorage: true,
    selectableInEditor: true,
  ),
  completed(
    label: 'Завершена',
    sortOrder: 3,
    persistsInStorage: true,
    selectableInEditor: true,
  ),
  overdue(
    label: 'Просрочена',
    sortOrder: 0,
    persistsInStorage: false,
    selectableInEditor: false,
  );

  const TaskStatus({
    required this.label,
    required this.sortOrder,
    required this.persistsInStorage,
    required this.selectableInEditor,
  });

  final String label;
  final int sortOrder;
  final bool persistsInStorage;
  final bool selectableInEditor;

  static List<TaskStatus> get editorValues {
    return values
        .where((TaskStatus status) => status.selectableInEditor)
        .toList(growable: false);
  }
}
