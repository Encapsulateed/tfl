import 'lab2.dart';
import 'dart:io';
import 'functions.dart';

class FMS {
  Set<String> alphabet = {};
  Set<State> States = {};
  Set<State> StartStates = {};
  Set<State> FinalStates = {};
  List<Transaction> Transactions = [];

  FMS(String regex) {
    var firstState = State();
    alphabet = getRegexAlf(regex);

    firstState.regex = regex;
    firstState.name = 'q0';

    this.StartStates.add(firstState);
    this.States.add(firstState);

    if (isEpsilonInRegex(regex)) {
      this.FinalStates.add(firstState);
    }
  }

  bool isRegexAlreadyExits(String regex) {
    return this.States.any((state) =>
        state.regex == regex ||
        regex == '(${state.regex})' ||
        state.regex == '(${regex})' ||
        state.regex == prepareRegex(regex));
  }

  String getCurrentStateTitle() {
    return 'q' + States.length.toString();
  }

  int getStateNumber(String s) {
    return int.parse(s.substring(1));
  }

  State getStateByRegex(String regex) {
    return States.where((state) =>
        state.regex == regex ||
        regex == '(${state.regex})' ||
        state.regex == '(${regex})' ||
        state.regex == prepareRegex(regex)).first;
  }

  void build(String prevRegex) {
    Set<String> alf = getRegexAlf(prevRegex);

    for (var term in alf) {
      //  print('Take ${prevRegex} by ${term}');
      var simpeleDerivative = MainSymplify(derivative(prevRegex, term));

      var stateTitle = getCurrentStateTitle();
      var prevState = getStateByRegex(prevRegex);
      var newState = State();

      newState.name = stateTitle;
      newState.regex = simpeleDerivative;
      var transaction = Transaction();

      transaction.from = prevState;
      transaction.to = newState;
      transaction.letter = term;

      //  print('Derivative is $simpeleDerivative');

      if (simpeleDerivative == '∅') {
      } else {
        ;
        if (isRegexAlreadyExits(simpeleDerivative)) {
          transaction.from = prevState;
          transaction.to = getStateByRegex(simpeleDerivative);
          transaction.letter = term;
          this.Transactions.add(transaction);
        } else {
          this.States.add(newState);

          if (isEpsilonInRegex(simpeleDerivative)) {
            FinalStates.add(newState);
          }

          transaction.from = prevState;
          transaction.to = newState;
          transaction.letter = term;
          this.Transactions.add(transaction);

          build(simpeleDerivative);
        }
      }
    }
  }

  void Print() {
    for (var transaction in this.Transactions) {
      print(
          '(${transaction.from.name}->${transaction.to.name}) by character ${transaction.letter} [${transaction.from.regex}]->[${transaction.to.regex}]');
    }
    for (var state in this.StartStates) {
      print('start state ${state.name} [${state.regex}]');
    }

    for (var state in this.FinalStates) {
      print('final state ${state.name} [${state.regex}]');
    }
  }

  void DumpDotToFile() {
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

  String DumpDot() {
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

    return res;
  }

  Map<String, List<Transaction>> transitionsTo = {};
  Map<String, List<Transaction>> transitionsFrom = {};
  Map<String, String> loops = {};

  String DumpRegex() {
    for (var state in States) {
      transitionsFrom[state.name] = [];
      transitionsTo[state.name] = [];
      loops[state.name] = "";
    }

    for (var transition in Transactions) {
      if (transition.to.name == transition.from.name) {
        if (loops[transition.to.name] == "") {
          loops[transition.to.name] = transition.letter + "*";
        } else {
          loops[transition.to.name] =
              "(${loops[transition.to.name]}|${transition.letter}*)";
        }
      } else {
        transitionsFrom[transition.from.name]!.add(transition);
        transitionsTo[transition.to.name]!.add(transition);
      }
    }

    for (var state in StartStates) {
      if (transitionsTo[state.name]!.length > 0) {
        State newState = State();
        newState.name = state.name + "'";
        transitionsFrom[newState.name] = [
          Transaction.fromData(state, newState, "")
        ];
        transitionsTo[state.name]!
            .add(Transaction.fromData(state, newState, ""));

        StartStates = Set();
        StartStates.add(newState);
      }
    }

    if (true) {
      State newFinalState = State();
      newFinalState.name = "finalState";
      transitionsTo[newFinalState.name] = [];

      for (var state in FinalStates) {
        transitionsTo[newFinalState.name]!
            .add(Transaction.fromData(state, newFinalState, ""));
        transitionsFrom[state.name]!
            .add(Transaction.fromData(state, newFinalState, ""));
      }

      FinalStates = Set();
      FinalStates.add(newFinalState);
    }

    Set<State> states = States;

    for (var state in states) {
      if (FinalStates.contains(state) || StartStates.contains(state)) {
        continue;
      }

      var transOut = new List.from(transitionsFrom[state.name]!);
      var transIn = new List.from(transitionsTo[state.name]!);

      for (var inTransition in transIn) {
        for (var outTransition in transOut) {
          String from = inTransition.from.name;
          String to = outTransition.to.name;
          String letter =
              inTransition.letter + loops[state.name]! + outTransition.letter;

          transitionsFrom[from]!.remove(inTransition);
          transitionsFrom[from]!.add(Transaction.fromData(
              inTransition.from, outTransition.to, letter));

          transitionsTo[to]!.remove(outTransition);
          transitionsTo[to]!.add(Transaction.fromData(
              inTransition.from, outTransition.to, letter));
        }
      }
      transitionsTo[state.name] = [];
      transitionsFrom[state.name] = [];
    }

    String res = "";
    for (var transition in transitionsFrom[StartStates.elementAt(0).name]!) {
      if (res != "" && res != "|" || transition.letter == "") {
        res += "|";
      }
      String letter = transition.letter;
      if (letter.length > 1) {
        letter = "($letter)";
      }
      res += letter;
    }
    res = "^(${res})\$";
    res = res;

    return res;
  }
}

class State {
  String name = '';
  String regex = '';

  State();

  State.fromData(this.name, this.regex);

  @override
  String toString() {
    // TODO: implement toString
    return "${name}";
  }

  @override
  bool operator ==(covariant State rhs) {
    return (rhs.name == name);
  }

  @override
  // TODO: implement hashCode
  int get hashCode => name.hashCode;
}

class Transaction {
  State from = State();
  State to = State();
  String letter = '';

  Transaction();

  Transaction.fromData(this.from, this.to, this.letter);

  @override
  String toString() {
    // TODO: implement toString
    return "${from} -> ${to} [${letter}]";
  }

  @override
  bool operator ==(covariant Transaction rhs) {
    return (rhs.letter == letter && from == rhs.from && to == rhs.to);
  }
}
