class TaskChecklistItem {
  const TaskChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.sortOrder,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final int sortOrder;

  bool get hasContent => title.trim().isNotEmpty;
  String get normalizedTitle => title.trim();

  TaskChecklistItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? sortOrder,
  }) {
    return TaskChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TaskChecklistItem &&
        other.id == id &&
        other.title == title &&
        other.isCompleted == isCompleted &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(id, title, isCompleted, sortOrder);
}
