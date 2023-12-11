import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:layout_tutorial/db.dart';
import 'package:path_provider/path_provider.dart';

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

String formatDate(DateTime date) {
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
    return DateFormat('dd-MM-yyyy').format(date);
  }
}

Future<String?> exportJson() async {
  try {
    // Fetch all successes from the database
    var successes = await SuccessDatabaseService().getAllSuccesses();

    // Convert each success to a Map and then to a JSON string
    var jsonData = jsonEncode(successes.map((s) => s.toMap()).toList());

    // Get the directory to save the file
    final directory = await getApplicationDocumentsDirectory();

    // Format the current date and time
    String formattedDateTime =
        DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    // Create the file with the date and time in the name
    final file =
        File('${directory.path}/successes_export_$formattedDateTime.json');

    // Write the JSON data to the file
    await file.writeAsString(jsonData);

    // Return the file path for confirmation
    return file.path;
  } catch (e) {
    // In case of an error, return null
    return null;
  }
}
