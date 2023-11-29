String SanitizeString(String word) {
  if (word.length < 2) {
    return word;
  }
  return "(${word})";
}

String SanitizeStarString(String word) {
  if (word.length == 0) {
    return word;
  }
  if (word.length == 1) {
    return "${word}*";
  }
  return "(${word})*";
}
