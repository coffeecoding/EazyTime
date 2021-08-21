import 'package:flutter/material.dart';

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
  bool equalsDateOf(DateTime other) {
    return this.year == other.year &&
        this.month == other.month && this.day == other.day;
  }

  bool isAfterDayOf(DateTime other) {
    DateTime thisDayWithoutTime = DateUtils.dateOnly(this);
    DateTime otherDayWithoutTime = DateUtils.dateOnly(other);
    return thisDayWithoutTime.isAfter(otherDayWithoutTime);
  }

  bool isBeforeDayOf(DateTime other) {
    DateTime thisDayWithoutTime = DateUtils.dateOnly(this);
    DateTime otherDayWithoutTime = DateUtils.dateOnly(other);
    return thisDayWithoutTime.isBefore(otherDayWithoutTime);
  }

  String toSimpleString() => DateTimeUtils.dateToString(this);
}