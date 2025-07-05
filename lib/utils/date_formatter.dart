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
}
