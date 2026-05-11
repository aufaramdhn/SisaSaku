import 'package:intl/intl.dart';

/// Date formatter for Indonesian locale
class DateFormatter {
  static final _dateFormat = DateFormat('d MMM yyyy', 'id_ID');
  static final _timeFormat = DateFormat('HH:mm', 'id_ID');
  static final _dateTimeFormat = DateFormat('d MMM yyyy HH:mm', 'id_ID');

  /// Format DateTime to "d MMM yyyy" (e.g., "10 Mei 2026")
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format DateTime to "HH:mm" (e.g., "14:30")
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format DateTime to "d MMM yyyy HH:mm"
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Get relative date (e.g., "H-2", "H+1")
  static String getRelativeDate(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;

    if (difference == 0) return 'Hari ini';
    if (difference == 1) return 'Besok';
    if (difference == -1) return 'Kemarin';
    if (difference > 0) return 'H+$difference';
    if (difference < 0) return 'H$difference';
    return formatDate(targetDate);
  }
}
