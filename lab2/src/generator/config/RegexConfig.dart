import 'dart:math';

import '../wheel/FortuneWheel.dart';

class RegexConfig {
  int alphabetSize = 0;
  int starLevel = 0;
  int maxLength = 0;
  int length = 0;

  bool generateShuffles = true;

  // forbiddenRegexStates is an illegal hack in attempt to make regex result more nice
  List<int> forbiddenRegexStates = [4];

  // <regex> ::= <regex><binary><regex> | (<regex>) | <regex><unary> | <symbol> | eps
  //                     40                  20          20               10      10
  UnfairFortuneWheel regexUnfairFortuneWheel =
      new UnfairFortuneWheel([40, 20, 20, 10, 10]);
  Random fortuneWheel = new Random();

  RegexConfig(this.alphabetSize, this.starLevel, this.maxLength, this.generateShuffles);
  RegexConfig.fromRegexConfig(RegexConfig conf) {
    this.alphabetSize = conf.alphabetSize;
    this.starLevel = conf.starLevel;
    this.maxLength = conf.maxLength;
    this.length = conf.length;
    this.generateShuffles = conf.generateShuffles;
  }
}
