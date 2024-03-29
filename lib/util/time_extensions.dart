import 'package:flutter/material.dart';
import 'datetime_utils.dart';

extension TimeUtils on TimeOfDay {
  bool isAfter(TimeOfDay other) {
    int _timeValueNow = this.hour * 60 + this.minute;
    int _timeValueOther = other.hour * 60 + other.minute;
    return _timeValueNow > _timeValueOther;
  }

  bool isBefore(TimeOfDay other) {
    int _timeValueNow = this.hour * 60 + this.minute;
    int _timeValueOther = other.hour * 60 + other.minute;
    return _timeValueNow < _timeValueOther;
  }

  bool isSimultaneousTo(TimeOfDay other) {
    int _timeValueNow = this.hour * 60 + this.minute;
    int _timeValueOther = other.hour * 60 + other.minute;
    return _timeValueNow == _timeValueOther;
  }

  bool isMidnight() {
    return (this.hour == 0 || this.hour == 24) && this.minute == 0;
  }

  String display() => DateTimeUtils.timeToString(this);
}