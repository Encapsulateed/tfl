import 'dart:developer';

import 'lab2.dart';
import 'dart:io';

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
    return this.States.any((state) => state.regex == regex);
  }

  String getCurrentStateTitle() {
    return 'q' + States.length.toString();
  }

  State getStateByRegex(String regex) {
    return States.where((element) => element.regex == regex).first;
  }

  void build(String prevRegex) {
    Set<String> alf = getRegexAlf(prevRegex);

    for (var term in alf) {
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

      //   print('Derivative is $simpeleDerivative');

      if (simpeleDerivative == '∅') {
      } else {
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
  }
}

class State {
  String name = '';
  String regex = '';
}

class Transaction {
  State from = State();
  State to = State();
  String letter = '';
}
