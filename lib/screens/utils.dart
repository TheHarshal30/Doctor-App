// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: prefer_for_elements_to_map_fromiterable, prefer_const_constructors

import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

/// Define your custom events here.
final _kEventSource = <DateTime, List<Event>>{
  DateTime.utc(2024, 6, 10): [Event('Custom Event 1'), Event('Custom Event 2')],
  DateTime.utc(2024, 7, 15): [Event('Custom Event 3')],
  DateTime.utc(2024, 8, 20): [Event('Custom Event 4'), Event('Custom Event 5')],
  kToday: [
    Event('Today\'s Event 1'),
    Event('Today\'s Event 2'),
  ],
};

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
