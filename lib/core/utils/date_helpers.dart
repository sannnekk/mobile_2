import 'package:intl/intl.dart';

/// Formats a date in a relative way for display in lists.
/// Returns "Сегодня", "Вчера", day of week, or full date depending on how recent the date is.
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final workDate = DateTime(date.year, date.month, date.day);

  if (workDate == today) {
    return 'Сегодня';
  } else if (workDate == today.subtract(const Duration(days: 1))) {
    return 'Вчера';
  } else if (workDate.isAfter(today.subtract(const Duration(days: 7)))) {
    return DateFormat('EEEE', 'ru').format(date); // Day of the week
  } else if (workDate.year == today.year) {
    return DateFormat('d MMMM', 'ru').format(date); // e.g., 5 марта
  } else {
    return DateFormat('d MMMM yyyy', 'ru').format(date); // e.g., 5 марта 2022
  }
}

/// Formats a date in dd.MM.yyyy format for deadlines and specific dates.
String formatDate(DateTime date) {
  return DateFormat('dd.MM.yyyy', 'ru').format(date);
}
