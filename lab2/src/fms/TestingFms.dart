import 'dart:math';

import '../../Fms.dart';
import '../matrix/matrix.dart';

class TestingFms extends FMS {
  List<List<List<String>>> transition = [];
  Matrix adjacency = Matrix(0, 0);
  Matrix reachability = Matrix(0, 0);
  Map<int, List<int>> possibility = Map();
  List<Map<String, int>> validity = [];

  TestingFms(String regex) : super(regex) {}

  void CalculateAdjacencyMatrix() {
    adjacency = Matrix(States.length, States.length);

    for (var transaction in Transactions) {
      int i = getStateNumber(transaction.from.name);
      int j = getStateNumber(transaction.to.name);

      adjacency.data[i][j] = 1;
    }
  }

  void CalculateTransitionMatrix() {
    for (var i = 0; i < States.length; i++) {
      transition.add(List.empty(growable: true));
      for (var j = 0; j < States.length; j++) {
        transition[i].add(List.empty(growable: true));
      }
    }

    for (var transaction in Transactions) {
      int i = getStateNumber(transaction.from.name);
      int j = getStateNumber(transaction.to.name);

      transition[i][j].add(transaction.letter);
    }
  }

  void CalculateReachabilityMatrix() {
    Matrix buf = Matrix.Identity(States.length, States.length);
    reachability = buf;

    for (var i = 0; i < States.length; i++) {
      buf = buf * adjacency;
      reachability = reachability + buf;
    }

    for (var i = 0; i < States.length; i++) {
      reachability.data[i][i]--;
    }
  }

  void BuildPossibilityMap() {
    for (var i = 0; i < States.length; i++) {
      possibility[i] = [];
    }

    for (var i = 0; i < States.length; i++) {
      for (var j = 0; j < States.length; j++) {
        if (reachability.data[i][j] > 0) {
          possibility[i]!.add(j);
        }
      }
    }

    for (var state in FinalStates) {
      possibility[getStateNumber(state.name)]!.add(-1);
    }
  }

  void BuildValidityMap() {
    for (var i = 0; i < States.length; i++) {
      validity.add(Map());
    }

    for (var i = 0; i < States.length; i++) {
      for (var j = 0; j < States.length; j++) {
        if (transition[i][j] != "") {
          for (var letter in transition[i][j]) {
            validity[i][letter] = j;
          }
        }
      }
    }
  }

  List<int> ChooseRandomStateChain(Random fortuneWheel) {
    // why does @Encapsulateed leaves an opportunity that there could be more then one start state?
    // it frightens me
    int pos = getStateNumber(StartStates.elementAt(0).name);

    List<int> chain = [];

    while (pos != -1) {
      chain.add(pos);
      pos = possibility[pos]![fortuneWheel.nextInt(possibility[pos]!.length)];
    }

    return chain;
  }

  String ChooseRandomTransition(int i, int j) {
    if (transition[i][j].length == 1) {
      return transition[i][j][0];
    }
    return transition[i][j][Random().nextInt(transition[i][j].length)];
  }

  String Bfs(int startPos, int endPos) {
    if (startPos == endPos && transition[startPos][endPos].length > 0) {
      return ChooseRandomTransition(startPos, endPos); // Yup, it's a hardcode!
    }

    List<bool> visited = List.filled(States.length, false);
    List<Path> queue = [];
    queue.add(Path(startPos, ""));

    while (queue.length > 0) {
      Path pos = queue.removeLast();
      if (pos.pos == endPos) {
        return pos.word;
      }
      visited[pos.pos] = true;

      for (var i = 0; i < States.length; i++) {
        if (adjacency.data[pos.pos][i] > 0) {
          if (!visited[i]) {
            queue.add(Path(i, pos.word + ChooseRandomTransition(pos.pos, i)));
            visited[i] = true;
          }
        }
      }
    }

    return "";
  }

  String GenerateWord(Random wheel, {bool mutate = false}) {
    List<int> path = ChooseRandomStateChain(wheel);
    String res = "";

    for (var i = 0; i < path.length - 1; i++) {
      String s = Bfs(path[i], path[i + 1]);
      if (mutate) {
        s = MutateWord(wheel, s);
      }
      res += s;
    }

    return res;
  }

  String MutateWord(Random wheel, String word) {
    if (word.length < 2) {
      return word;
    }
    int mutation = wheel.nextInt(6);
    switch (mutation) {
      case 0:
        int a = wheel.nextInt(word.length - 1);
        int b = wheel.nextInt(word.length - 1);
        if (a > b) {
          int t = a;
          a = b;
          b = t;
        }
        if (a == b) {
          b++;
        }
        print(a);
        print(b);
        word = word.substring(0, a) +
            word.substring(b, b + 1) +
            word.substring(a + 1, b) +
            word.substring(a, a + 1) +
            word.substring(b + 1);
        break;
      case 1:
        int a = wheel.nextInt(word.length);
        int n = wheel.nextInt(word.length); // just because, no sense here
        word = word.substring(0, a) +
            word.substring(a, a + 1) * n +
            word.substring(a + 1);
        break;
      case 2:
        int a = wheel.nextInt(word.length);
        int b = wheel.nextInt(word.length);
        if (a > b) {
          int t = a;
          a = b;
          b = t;
        }
        int n = wheel.nextInt(word.length); // just because, no sense here
        word = word.substring(0, a) +
            word.substring(a, b + 1) * n +
            word.substring(b + 1);
        break;
      case 3:
        int a = wheel.nextInt(word.length);
        int b = wheel.nextInt(word.length);
        word = word.substring(0, a) + word.substring(a + b);
        break;
      default:
        break;
    }
    return word;
  }

  bool ValidateWord(String word) {
    int pos = getStateNumber(StartStates.elementAt(0).name);
    while (word != "") {
      String char = word.substring(0, 1);

      if (!validity[pos].containsKey(char)) {
        return false;
      }

      pos = validity[pos][char]!;
      word = word.substring(1);
    }
    return FinalStates.contains(State.fromData("q${pos}", ""));
  }
}

class Path {
  int pos = 0;
  String word = "";

  Path(this.pos, this.word);
}
