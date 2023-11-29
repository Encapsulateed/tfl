String SanitizeString(String word) {
  if (word.length < 2) {
    return word;
  }
  if (word.length > 1 && word.startsWith("(")) {
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

void main(List<String> args) {
  print(SanitizeStarString("word"));
  print(SanitizeStarString(""));
  print(SanitizeStarString("a"));
  print(SanitizeStarString("(word)"));
  print(SanitizeStarString("(word)*"));
}