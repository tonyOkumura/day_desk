import 'package:day_desk/core/date/app_date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AppDateFormatter formatter;

  setUpAll(() async {
    await initializeDateFormatting(AppDateFormatter.localeName);
  });

  setUp(() {
    formatter = AppDateFormatter();
  });

  test('formatTime использует 24-часовой формат', () {
    expect(formatter.formatTime(DateTime(2026, 3, 17, 9, 5)), '09:05');
  });

  test('formatRelativeDay различает сегодня завтра и вчера', () {
    final DateTime reference = DateTime(2026, 3, 17, 12);

    expect(
      formatter.formatRelativeDay(
        DateTime(2026, 3, 17, 8),
        reference: reference,
      ),
      'Сегодня',
    );
    expect(
      formatter.formatRelativeDay(
        DateTime(2026, 3, 18, 8),
        reference: reference,
      ),
      'Завтра',
    );
    expect(
      formatter.formatRelativeDay(
        DateTime(2026, 3, 16, 8),
        reference: reference,
      ),
      'Вчера',
    );
  });

  test('formatTimeRange и formatDeadline работают стабильно на ru_RU', () {
    final DateTime start = DateTime(2026, 3, 17, 9);
    final DateTime end = DateTime(2026, 3, 17, 11, 30);

    expect(formatter.formatTimeRange(start, end), '09:00 - 11:30');
    expect(
      formatter.formatDeadline(end, reference: DateTime(2026, 3, 17, 7)),
      'Сегодня, 11:30',
    );
  });

  test('day helpers и startOfDay работают корректно', () {
    final DateTime reference = DateTime(2026, 3, 17, 12, 45);

    expect(
      formatter.isToday(DateTime(2026, 3, 17, 1), reference: reference),
      isTrue,
    );
    expect(
      formatter.isTomorrow(DateTime(2026, 3, 18, 1), reference: reference),
      isTrue,
    );
    expect(
      formatter.isSameDay(
        DateTime(2026, 3, 17, 0),
        DateTime(2026, 3, 17, 23, 59),
      ),
      isTrue,
    );
    expect(formatter.startOfDay(reference), DateTime(2026, 3, 17));
  });
}
