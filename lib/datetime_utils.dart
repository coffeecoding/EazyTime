import 'package:flutter/src/material/time.dart';

class DateTimeUtils {

  static String timeToString(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour}:${timeOfDay.minute}';
  }

  static TimeOfDay parseTime(String time) {
    List<String> parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String dateToString(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

}