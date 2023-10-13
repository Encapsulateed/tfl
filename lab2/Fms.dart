import 'dart:developer';

import 'lab2.dart';
import 'dart:io';

class FMS {
  Set<String> alphabet = {};
  Set<State> States = {};
  Set<State> StartStates = {};
  Set<State> FinalStates = {};
  List<Transaction> transaction = [];

  bool isRegexAlreadyExits(String regex) {
    return this.States.any((state) => state.regex == regex);
  }

  String getCurrentStateTitle() {
    return 'q' + States.length.toString();
  }

  State getStateByRegex(String regex) {
    return States.where((element) => element.regex == regex).first;
  }

  void buildFMS(String prevRegex) {
    Set<String> alf = getRegexAlf(prevRegex);

    for (var term in alf) {
      var simpeleDerivative = MainSymplify(derivative(prevRegex, term));

      if (simpeleDerivative == '∅') {
      } else if (simpeleDerivative == 'ε') {
      } else {
        var stateTitle = getCurrentStateTitle();
        var prevState = getStateByRegex(prevRegex);
        var newState = State();
        var transaction = Transaction();

        transaction.from = prevState;
        transaction.to = newState;
        transaction.letter = term;
        this.transaction.add(transaction);

        if (isEpsilonInRegex(simpeleDerivative)) {
          newState.name = stateTitle;
          newState.regex = simpeleDerivative;
          FinalStates.add(newState);
        } else {
          if (prevRegex == simpeleDerivative) {
          } else {}
        }
      }
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
