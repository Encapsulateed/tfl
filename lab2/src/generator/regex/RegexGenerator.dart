// some empty lines at the start of file for it to look more nice

import '../config/RegexConfig.dart';

/// <init> ::= <regex>
/// <regex> ::= <regex><binary><regex> | (<regex>) | <regex><unary> | <symbol> | eps
/// <binary> ::= | | # | eps
/// <unary> ::= *

String GenerateRegexInit(int alphabetSize, int starLevel, int maxLength,
    {bool generateShuffles = true}) {
  return GenerateRegex(
      RegexConfig(alphabetSize, starLevel, maxLength, generateShuffles));
}

String GenerateRegex(RegexConfig config) {
  if (config.length == config.maxLength) {
    return "";
  }
  if (config.maxLength - config.length < 2) {
    config.forbiddenRegexStates.add(0);
  }

  int round = config.regexUnfairFortuneWheel.spin();
  if (config.forbiddenRegexStates.contains(round) ||
      (round == 2 && config.starLevel == 0)) {
    return GenerateRegex(config);
  }

  switch (round) {
    case 0:
      RegexConfig newConf = RegexConfig.fromRegexConfig(config);
      String binary = GenerateBinary(newConf);
      if (binary == "|") {
        newConf.forbiddenRegexStates = [4];
      }

      newConf.maxLength--;
      String half1 = GenerateRegex(newConf);
      newConf.maxLength++;
      String half2 = GenerateRegex(newConf);

      config.length = newConf.length;
      return "${half1}${binary}${half2}";
    case 1:
      RegexConfig newConf = RegexConfig.fromRegexConfig(config);
      newConf.forbiddenRegexStates = config.forbiddenRegexStates;
      newConf.forbiddenRegexStates.add(1);

      String reg = GenerateRegex(newConf);

      config.length = newConf.length;
      return "(${reg})";
    case 2:
      RegexConfig newConf = RegexConfig.fromRegexConfig(config);
      newConf.starLevel--;
      newConf.forbiddenRegexStates = [2, 4];

      String reg = GenerateRegex(newConf);
      String unary = GenerateUnary(newConf);

      config.length = newConf.length;
      return reg + unary;
    case 3:
      String symb = GenerateSymbol(config);
      return symb;
    default:
      throw "Universe order error: generated number out of range";
  }
}

String GenerateBinary(RegexConfig config) {
  if (!config.generateShuffles) {
    return GenerateBinaryNoShuffle(config);
  }
  if (config.length == config.maxLength) {
    return "";
  }
  int round = config.fortuneWheel.nextInt(3);
  switch (round) {
    case 0:
      return "|";
    case 1:
      return "#";
    case 2:
      return "";
    default:
      throw "Universe order error: generated number out of range";
  }
}

String GenerateBinaryNoShuffle(RegexConfig config) {
  if (config.length == config.maxLength) {
    return "";
  }
  int round = config.fortuneWheel.nextInt(2);
  switch (round) {
    case 0:
      return "|";
    case 1:
      return "";
    default:
      throw "Universe order error: generated number out of range";
  }
}

String GenerateUnary(RegexConfig config) {
  return "*";
}

String GenerateSymbol(RegexConfig config) {
  int round = config.fortuneWheel.nextInt(config.alphabetSize);
  config.length++;
  return String.fromCharCode(97 + round);
}

void main(List<String> args) {
  for (var i = 0; i < 10; i++) {
    print(GenerateRegexInit(3, 2, 10));
    print("");
  }
}
