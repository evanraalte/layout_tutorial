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
