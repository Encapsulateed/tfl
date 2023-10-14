import 'dart:math';

import '../../Fms.dart';
import '../matrix/matrix.dart';

class TestingFms extends FMS {
  Matrix adjacency = Matrix(0, 0);
  Matrix reachability = Matrix(0, 0);
  Map<int, List<int>> possibility = Map();

  TestingFms(String regex) : super(regex) {}

  void CalculateAdjacencyMatrix() {
    adjacency = Matrix(States.length, States.length);

    for (var transaction in Transactions) {
      int i = getStateNumber(transaction.from.name);
      int j = getStateNumber(transaction.to.name);

      adjacency.data[i][j] = 1;
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

  int GetRandomWay(int pos) {
    return 0;
  }

  List<int> Bfs(int startPos, int endPos) {
    List<int> path = [];

    List<bool> visited = List.filled(States.length, false);
    List<int> queue = [];
    queue.add(startPos);

    while (queue.length > 0) {
      int pos = queue.removeLast();
      // path.add(pos);
      if (pos == endPos) {
        return path;
      }
      visited[pos] = true;
    }

    return [];
  }
}
