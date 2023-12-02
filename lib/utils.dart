import 'dart:math';

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
