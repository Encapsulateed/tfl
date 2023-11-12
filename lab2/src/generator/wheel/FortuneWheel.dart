import 'dart:math';

class OddsPair {
  int res;
  int weight;

  OddsPair(this.res, this.weight);
}

class UnfairFortuneWheel {
  Random fairWheel = new Random();
  List<int> unfairOdds = [];

  // for 10 10 20 we need 10 20 40

  UnfairFortuneWheel(List<int> weights) {
    int prev = 0;
    for (var weight in weights) {
      prev = weight + prev;
      unfairOdds.add(prev);
    }
  }

  int spin() {
    int res = fairWheel.nextInt(unfairOdds.last);
    for (var i = 0; i < unfairOdds.length; i++) {
      if (res < unfairOdds[i]) {
        return i;
      }
    }
    return unfairOdds.length;
  }
}
