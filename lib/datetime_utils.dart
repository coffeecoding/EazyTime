import 'package:flutter/src/material/time.dart';

class DateTimeUtils {

  static String timeToString(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay parseTime(String time) {
    List<String> parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String dateToString(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

}

extension DateExt on DateTime {
  bool isEqualTo(DateTime other) {
    return this.year == other.year &&
        this.month == other.month && this.day == other.day;
  }

  String toSimpleString() => DateTimeUtils.dateToString(this);
}