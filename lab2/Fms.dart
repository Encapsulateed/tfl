import 'dart:io';
import 'src/util/util.dart';
import 'tree/tree.dart';
import 'regex/regex_functions.dart';

class FSM {
  Set<String> alphabet = {};
  Set<State> States = {};
  Set<State> StartStates = {};
  Set<State> FinalStates = {};
  List<Transaction> Transactions = [];

  FSM(String regex) {
    var root_regex = postfixToTree(infixToPostfix(augment(regex)));
    ;
    var firstState = State();
    alphabet = getRegexAlf(regex);

    firstState.regex = inorder(root_regex);
    firstState.name = 'q0';

    this.StartStates.add(firstState);
    this.States.add(firstState);

    if (nullable(root_regex)) {
      this.FinalStates.add(firstState);
    }
  }

  bool isRegexAlreadyExits(String regex) {
    return this.States.any((state) => state.regex == regex);
  }

  String getCurrentStateTitle() {
    return 'q' + States.length.toString();
  }

  int getStateNumber(String s) {
    return int.parse(s.substring(1));
  }

  State getStateByRegex(String regex) {
    return States.where((state) => state.regex == regex).first;
  }

  void build(String prevRegex) {
    var prev_regex = inorder(postfixToTree(infixToPostfix(augment(prevRegex))));
    ;

    Set<String> alf = getRegexAlf(prevRegex);
    (prevRegex);

    for (var term in alf) {
      Map<Node, List<String>> treeMap = {};
      var simpeleDerivative = inorder(simplifyRegex(
          deriv(postfixToTree(infixToPostfix(augment(prev_regex))), term),
          treeMap));

      var stateTitle = getCurrentStateTitle();
      var prevState = getStateByRegex(
          inorder(postfixToTree(infixToPostfix(augment(prev_regex)))));
      var newState = State();

      newState.name = stateTitle;
      newState.regex = simpeleDerivative;
      var transaction = Transaction();

      transaction.from = prevState;
      transaction.to = newState;
      transaction.letter = term;

      if (simpeleDerivative == '∅') {
      } else {
        if (isRegexAlreadyExits(simpeleDerivative)) {
          transaction.from = prevState;
          transaction.to = getStateByRegex(simpeleDerivative);
          transaction.letter = term;
          this.Transactions.add(transaction);
        } else {
          this.States.add(newState);

          if (nullable(
              postfixToTree(infixToPostfix(augment(simpeleDerivative))))) {
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
      transitionsFrom[transition.from.name]!.add(transition);
      transitionsTo[transition.to.name]!.add(transition);
    }

    bool startIsFinal = false;
    if (StartStates.elementAt(0) == FinalStates.elementAt(0)) {
      startIsFinal = true;
    }

    for (var state in StartStates) {
      if (true) {
        State newState = State();
        newState.name = state.name + "'";
        transitionsFrom[newState.name] = [
          Transaction.fromData(newState, state, "")
        ];
        transitionsTo[state.name]!
            .add(Transaction.fromData(newState, state, ""));

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
      States.add(newFinalState);
    }

    Set<State> states = States;

    for (var state in states) {
      if (FinalStates.contains(state) || StartStates.contains(state)) {
        continue;
      }

      var transIn = new List.from(transitionsTo[state.name]!);
      var transOut = new List.from(transitionsFrom[state.name]!);

      for (var inTransition in transIn) {
        for (var outTransition in transOut) {
          String from = inTransition.from.name;
          String to = outTransition.to.name;
          String alternative = "";
          String loop = "";
          if (inTransition.isCycle() || outTransition.isCycle()) {
            continue;
          }
          var transFromAlt = new List.from(transitionsFrom[from]!);
          for (var trans in transFromAlt) {
            if (trans.to.name == to) {
              transitionsFrom[from]!.remove(trans);
              transitionsTo[to]!.remove(trans);
              if (alternative.length == 0) {
                alternative = trans.letter;
              } else {
                alternative = "${trans.letter}|${alternative}";
              }
            }
          }
          var transFromLoop = transitionsFrom[state.name]!;
          for (var trans in transFromLoop) {
            if (trans.to.name == state.name) {
              if (loop.length == 0) {
                loop = trans.letter;
              } else {
                loop =
                    "${SanitizeStarString(trans.letter)}|${SanitizeStarString(loop)}";
              }
            }
          }
          String letter =
              "${SanitizeString(inTransition.letter)}${SanitizeStarString(loop)}${SanitizeString(outTransition.letter)}";
          if (alternative.length > 0) {
            letter = "${alternative}|${letter}";
          }

          transitionsFrom[from]!.remove(inTransition);
          transitionsFrom[state.name]!.remove(outTransition);

          transitionsTo[to]!.remove(outTransition);
          transitionsFrom[state.name]!.remove(inTransition);

          transitionsFrom[from]!.add(Transaction.fromData(
              inTransition.from, outTransition.to, letter));

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
    if (startIsFinal) {
      res = "|${res}";
    }
    res = "^(${res})\$";
    res = res;

    return res;
  }
}

class State {
  String name = '';
  String? regex = null;

  State();

  State.fromData(this.name, this.regex);

  @override
  String toString() {
    return "${name}";
  }

  @override
  bool operator ==(covariant State rhs) {
    return (rhs.name == name);
  }

  @override
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
    return "${from} -> ${to} [${letter}]";
  }

  @override
  bool operator ==(covariant Transaction rhs) {
    return (rhs.letter == letter && from == rhs.from && to == rhs.to);
  }

  bool isCycle() {
    return from == to;
  }
}
