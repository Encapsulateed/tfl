import 'state.dart';
import 'transaction.dart';
import 'dart:io';

class FSM {
  Set<State> States = {};
  Set<State> StartStates = {};
  Set<State> FinalStates = {};
  List<Transaction> Transactions = [];

  void build() {}

  FSM determine() {
    return FSM();
  }

  void DumpToDOT() {
    String res = "";

    for (var state in this.States) {
      String shape = "circle";
      if (FinalStates.contains(state)) {
        shape = "doublecircle";
      }
      res += "${state.name} [label = \"${state.name}\", shape = ${shape}]\n";
    }

    for (var state in this.StartStates) {
      res += "dummy -> ${state.name}\n";
    }

    for (var transaction in this.Transactions) {
      res +=
          "${transaction.from.name} -> ${transaction.to.name} [label = ${transaction.letter}]\n";
    }

    res = "digraph {\n"
        "rankdir = LR\n"
        "dummy [shape=none, label=\"\", width=0, height=0]\n"
        "$res"
        "}\n";

    File file = File('solution.txt');
    file.writeAsStringSync(res);
  }
}
