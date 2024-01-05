import '../../state_machine/FSM.dart';
import '../../utils/Action.dart';
import '../../utils/grammar.dart';

import 'LR0fms.dart';

class LR0Table {
  LR0FMS lrfms = LR0FMS.empty();
  Grammar inputGrammar = Grammar();
  Map<State, Map<String, List<Action>>> lr0_table = {};
  LR0Table(Grammar g) {
    inputGrammar = g;
    lrfms = LR0FMS(inputGrammar);
    makeTable();
  }

  void makeTable() {
    for (var I in lrfms.states) {
      lr0_table[I] = {};
      for (var X in inputGrammar.nonTerminals) {
        if (X != inputGrammar.start_non_terminal) {
          lr0_table[I]![X] = [];
        }
      }
      for (var X in inputGrammar.terminals) {
        lr0_table[I]![X] = [];
      }
    }

    for (var tran in lrfms.transactions) {
      var I = tran.from;
      var J = tran.to;
      var X = tran.letter;

      if (inputGrammar.nonTerminals.contains(X)) {
        if (X != inputGrammar.start_non_terminal) {
          print('shift ${lrfms.getStateIndex(J)} ${X}');
          lr0_table[I]![X]!.add(Action.shift(lrfms.getStateIndex(J)));
        }
      } else if (inputGrammar.terminals.contains(X)) {
        lr0_table[I]![X]!.add(Action.goto(lrfms.getStateIndex(J)));
      }
    }

    for (var I in lrfms.finalStates) {
      if (lr0_table[I] == null) {
        // lr0_table[I] = {};
      }
      for (var terminal in inputGrammar.terminals) {
        if (lr0_table[I]![terminal] == null) {
          lr0_table[I]![terminal] = [];
        }
        lr0_table[I]![terminal]!
            .add(Action.reduce(inputGrammar.getRuleIndex(I.value)));
      }
    }
    /**/
  }

  void log() {
    for (var I in lrfms.states) {
      for (var nonTerminal in inputGrammar.nonTerminals) {
        if (nonTerminal != inputGrammar.start_non_terminal) {
          print(
              "Action at T[${lrfms.getStateIndex(I)}][${nonTerminal}] is ${lr0_table[I]![nonTerminal]}");
        }
      }
      for (var terminal in inputGrammar.terminals) {
        print(
            "Action at T[${lrfms.getStateIndex(I)}][${terminal}] is ${lr0_table[I]![terminal]}");
      }
    }
  }
}
