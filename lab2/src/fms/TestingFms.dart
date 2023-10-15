import 'dart:math';

import '../../Fms.dart';
import '../matrix/matrix.dart';

class TestingFms extends FMS {
  List<List<String>> transition = [];
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
      transition.add(List.filled(States.length, ""));
    }

    for (var transaction in Transactions) {
      int i = getStateNumber(transaction.from.name);
      int j = getStateNumber(transaction.to.name);

      transition[i][j] = transaction.letter;
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
          validity[i][transition[i][j]] = j;
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

  String Bfs(int startPos, int endPos) {
    List<bool> visited = List.filled(States.length, false);
    List<Path> queue = [];
    queue.add(Path(startPos, ""));

    while (queue.length > 0) {
      Path pos = queue.removeLast();
      // path.add(pos);
      if (pos.pos == endPos) {
        return pos.word;
      }
      visited[pos.pos] = true;

      for (var i = 0; i < States.length; i++) {
        if (adjacency.data[pos.pos][i] > 0) {
          if (!visited[i]) {
            queue.add(Path(i, pos.word + transition[pos.pos][i]));
            visited[i] = true;
          }
        }
      }
    }

    return "";
  }

  String GenerateWord(Random wheel) {
    List<int> path = ChooseRandomStateChain(wheel);
    String res = "";

    for (var i = 0; i < path.length - 1; i++) {
      String s = Bfs(path[i], path[i + 1]);
      res += s;
    }

    return res;
  }

  String MutateWord(String word) {
    // TODO: make an external word mutator
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
    return true;
  }

  
}

class Path {
  int pos = 0;
  String word = "";

  Path(this.pos, this.word);
}
