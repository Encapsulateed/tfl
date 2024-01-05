import 'dart:io';

class FSM {
  Set<State> states = {};
  Set<State> startStates = {};
  Set<State> finalStates = {};
  List<Transaction> transactions = [];

  FSM();

  void build() {}

  FSM.fromData(
      this.states, this.startStates, this.finalStates, this.transactions);

  // тут надо сделать детерминиизацию НКА
  FSM determinize() {
    return FSM();
  }

  Set<String> alphabet() {
    return transactions
        .where((t) => t.letter.isNotEmpty)
        .map((t) => t.letter)
        .toSet();
  }

  State getState(String name) {
    return states.toList().where((element) => element.name == name).first;
  }

  void DumpToDOT() {
    String res = "";

    for (var state in this.states) {
      String shape = "circle";
      if (finalStates.contains(state)) {
        shape = "doublecircle";
      }
      res +=
          "\"${state.name}\" [label = \"${state.name}\", shape = ${shape}]\n";
    }

    for (var state in this.startStates) {
      res += "dummy -> \"${state.name}\"\n";
    }

    for (var transaction in this.transactions) {
      res +=
          "\"${transaction.from.name}\" -> \"${transaction.to.name}\" [label = \"${transaction.letter}\"]\n";
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

class State {
  String name = '';
  dynamic value;

  State();

  State.valued(this.name, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is State && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class Transaction {
  State from = State();
  State to = State();
  String letter = '';

  Transaction();

  Transaction.fromData(Set<State> from, Set<State> to, this.letter) {
    this.from = from.length == 1
        ? from.first
        : State(); // Take the first state from the set
    this.to = to.length == 1
        ? to.first
        : State(); // Take the first state from the set
  }
}
