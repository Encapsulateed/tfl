import 'dart:math';

class StringConfig {
  int maxLength = 0;
  int length = 0;

  /// when reaching chainLengthThreshold generator will try to find its way out
  int chainLengthThreshold = 0;

  Random fortuneWheel = new Random();
}
