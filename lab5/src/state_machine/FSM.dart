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

  Set<State> epsilonClosure(State state) {
    var closure = Set<State>.from([state]);
    var stack = [state];

    while (stack.isNotEmpty) {
      var currentState = stack.removeLast();

      var epsilonTransitions = transactions
          .where((t) => t.from == currentState && t.letter.isEmpty)
          .map((t) => t.to);

      for (var nextState in epsilonTransitions) {
        if (!closure.contains(nextState)) {
          closure.add(nextState);
          stack.add(nextState);
        }
      }
    }

    return closure;
  }

  Set<State> epsilonClosureSet(Set<State> states) {
    var result = Set<State>();

    for (var state in states) {
      result.addAll(epsilonClosure(state));
    }

    return result;
  }

  Set<State> move(Set<State> states, String symbol) {
    var result = Set<State>();

    for (var state in states) {
      var symbolTransitions = transactions
          .where((t) => t.from == state && t.letter == symbol)
          .map((t) => t.to);
      result.addAll(symbolTransitions);
    }

    return result;
  }

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

  void DumpToDOT() {
    String res = "";

    for (var state in this.states) {
      String shape = "circle";
      if (finalStates.contains(state)) {
        shape = "doublecircle";
      }
      res += "${state.name} [label = \"${state.name}\", shape = ${shape}]\n";
    }

    for (var state in this.startStates) {
      res += "dummy -> ${state.name}\n";
    }

    for (var transaction in this.transactions) {
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

class State {
  String name = '';
  dynamic value;

  State();

  State.named(this.name);

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
