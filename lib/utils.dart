import 'dart:math';
import 'package:intl/intl.dart';

List<String> adjectives = [
  "Peaceful",
  "Adventurous",
  "Serene",
  "Beautiful",
  "Mystical"
];
List<String> nouns = ["Mountain", "Lake", "Forest", "River", "Beach"];

String getRandomTitle(List<String> adjectives, List<String> nouns) {
  final random = Random();
  return "${adjectives[random.nextInt(adjectives.length)]} ${nouns[random.nextInt(nouns.length)]}";
}

String formatDateTime(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Date not available';
  }
  final DateFormat formatter = DateFormat('HH:mm d/M/yyyy');
  return formatter.format(dateTime);
}

String formatDate(DateTime date, String locale) {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(const Duration(days: 1));
  DateTime tomorrow = today.add(const Duration(days: 1));
  DateTime justDate =
      DateTime(date.year, date.month, date.day); // Extract just the date part

  if (justDate == today) {
    return 'Today'; // or use a localized string
  } else if (justDate == yesterday) {
    return 'Yesterday'; // or use a localized string
  } else if (justDate == tomorrow) {
    return 'Tomorrow'; // or use a localized string
  } else {
    return DateFormat('dd-MM-yyyy', locale).format(date);
  }
}
