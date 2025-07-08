import 'package:intl/intl.dart';

class DateFormatter {
  static String getMonthName(int month, {String locale = 'th'}) {
    final now = DateTime(2000, month);
    return DateFormat.MMMM(locale).format(now);
  }

  static String getFullDate(DateTime date, {String locale = 'th'}) {
    return DateFormat.yMMMM(locale).format(date);
  }

  static List<String> getMonthNames({String locale = 'th'}) {
    return List.generate(12, (index) => getMonthName(index + 1, locale: locale));
  }

  static String formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}
