import 'dart:math';

class RegexConfig {
  int alphabetSize = 0;
  int starLevel = 0;
  int maxLength = 0;
  int length = 0;

  // forbiddenRegexStates is an illegal hack in attempt to make regex result more nice
  List<int> forbiddenRegexStates = [4];

  Random fortuneWheel = new Random();

  RegexConfig(this.alphabetSize, this.starLevel, this.maxLength);
  RegexConfig.fromRegexConfig(RegexConfig conf) {
    this.alphabetSize = conf.alphabetSize;
    this.starLevel = conf.starLevel;
    this.maxLength = conf.maxLength;
    this.length = conf.length;
  }
}
