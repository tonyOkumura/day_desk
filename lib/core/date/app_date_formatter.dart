import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class AppDateFormatter {
  AppDateFormatter();

  static const Locale appLocale = Locale('ru', 'RU');
  static const String localeName = 'ru_RU';

  final DateFormat _compactDateFormat = DateFormat('d MMMM', localeName);
  final DateFormat _fullDateFormat = DateFormat('EEEE, d MMMM y', localeName);
  final DateFormat _timeFormat = DateFormat('HH:mm', localeName);
  final DateFormat _dateTimeFormat = DateFormat('d MMMM y, HH:mm', localeName);

  String formatDate(DateTime date) {
    return _compactDateFormat.format(date);
  }

  String formatFullDate(DateTime date) {
    return _capitalize(_fullDateFormat.format(date));
  }

  String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  String formatDateTime(DateTime dateTime) {
    return _capitalize(_dateTimeFormat.format(dateTime));
  }

  String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  String formatRelativeDay(DateTime date, {DateTime? reference}) {
    final DateTime resolvedReference = reference ?? DateTime.now();

    if (isToday(date, reference: resolvedReference)) {
      return 'Сегодня';
    }
    if (isTomorrow(date, reference: resolvedReference)) {
      return 'Завтра';
    }
    if (isYesterday(date, reference: resolvedReference)) {
      return 'Вчера';
    }

    return formatDate(date);
  }

  String formatDeadline(DateTime date, {DateTime? reference}) {
    return '${formatRelativeDay(date, reference: reference)}, '
        '${formatTime(date)}';
  }

  String formatHourOfDay(int hour) {
    final DateTime date = DateTime(2000, 1, 1, hour);
    return formatTime(date);
  }

  bool isToday(DateTime date, {DateTime? reference}) {
    final DateTime resolvedReference = reference ?? DateTime.now();
    return isSameDay(date, resolvedReference);
  }

  bool isTomorrow(DateTime date, {DateTime? reference}) {
    final DateTime resolvedReference = startOfDay(reference ?? DateTime.now());
    return isSameDay(date, resolvedReference.add(const Duration(days: 1)));
  }

  bool isYesterday(DateTime date, {DateTime? reference}) {
    final DateTime resolvedReference = startOfDay(reference ?? DateTime.now());
    return isSameDay(date, resolvedReference.subtract(const Duration(days: 1)));
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}
