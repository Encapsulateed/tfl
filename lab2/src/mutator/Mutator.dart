import 'dart:math';

enum MutationType { WORD_SWITCHEROO, WORD_REPETITION, WORD_DELETION }

class Mutator {
  Random prophetsEye = Random();

  Mutator(this.prophetsEye);

  String Mutate(String word) {
    if (word.length < 2) {
      return word;
    }
    int mutation = prophetsEye.nextInt(3);
    MutationType round = MutationType.values[mutation];

    switch (round) {
      case MutationType.WORD_SWITCHEROO:
        // перестановка букв
        int n = word.length;
        for (int i = 0; i < n * 2; i++) {
          int a = prophetsEye.nextInt(n);
          int b = prophetsEye.nextInt(n);

          if (a == b) {
            continue;
          }
          if (a > b) {
            int t = a;
            a = b;
            b = t;
          }

          String w1 = word.substring(0, a);
          String w2 = word.substring(a, a + 1);
          String w3 = word.substring(a + 1, b);
          String w4 = word.substring(b, b + 1);
          String w5 = word.substring(b + 1);

          word = w1 + w4 + w3 + w2 + w5;
        }

        break;

      case MutationType.WORD_REPETITION:
        // повторение букв
        for (int i = 0; i < 10; i++) {
          int n = word.length;
          int a = prophetsEye.nextInt(n);

          String w1, w2, w3;
          w1 = word.substring(0, a);
          if (a >= n - 1) {
            w2 = word.substring(a);
            w3 = "";
          } else {
            w2 = word.substring(a, a + 1);
            w3 = word.substring(a + 1);
          }

          int pumpMeAndThenJustPushMeTillICanGetMySatisfaction =
              prophetsEye.nextInt(n) + 1;

          word =
              w1 + w2 * pumpMeAndThenJustPushMeTillICanGetMySatisfaction + w3;
        }
        break;

      case MutationType.WORD_DELETION:
        // удаление букв
        for (int i = 0; i < 10; i++) {
          int n = word.length;
          if (n < 2) {
            break;
          }
          int a = prophetsEye.nextInt(n);

          String w1, w2, w3;
          w1 = word.substring(0, a);
          if (a >= n - 1) {
            w2 = word.substring(a);
            w3 = "";
          } else {
            w2 = word.substring(a, a + 1);
            w3 = word.substring(a + 1);
          }

          int pumpMeAndThenJustPushMeTillICanGetMySatisfaction = 0;

          word =
              w1 + w2 * pumpMeAndThenJustPushMeTillICanGetMySatisfaction + w3;
        }
        break;

      default:
    }

    return word;
  }
}
