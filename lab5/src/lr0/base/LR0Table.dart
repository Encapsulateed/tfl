import '../../state_machine/FSM.dart';
import '../../utils/Action.dart';
import '../../utils/grammar.dart';

import 'LR0Fms.dart';
import 'dart:io';

class LR0Table {
  LR0FMS lrfms = LR0FMS.empty();
  Grammar inputGrammar = Grammar();
  Map<State, Map<String, List<Action>>> lr0_table = {};
  Map<int, Map<String, List<Action>>> lr0_table_indexed = {};
  LR0Table.empty();

  LR0Table(Grammar g) {
    inputGrammar = g;
    lrfms = LR0FMS(inputGrammar);
    makeTable();
  }

  void makeTable() {
    for (var I in lrfms.states) {
      int index = lrfms.getStateIndex(I);

      lr0_table[I] = {};
      lr0_table_indexed[index] = {};
      for (var X in inputGrammar.nonTerminals) {
        if (X != inputGrammar.start_non_terminal + "0") {
          lr0_table[I]![X] = [];
          lr0_table_indexed[index]![X] = [];
        }
      }
      for (var X in inputGrammar.terminals) {
        lr0_table[I]![X] = [];
        lr0_table_indexed[index]![X] = [];
      }
    }

    for (var tran in lrfms.transactions) {
      var I = tran.from;
      var J = tran.to;
      var X = tran.letter;

      int index_I = lrfms.getStateIndex(I);
      int index_J = lrfms.getStateIndex(J);

      if (inputGrammar.terminals.contains(X)) {
        lr0_table[I]![X]!.add(Action.shift(index_J));
        lr0_table_indexed[index_I]![X]!.add(Action.shift(index_J));
      } else if (inputGrammar.nonTerminals.contains(X)) {
        if (X != inputGrammar.start_non_terminal + '0') {
          lr0_table[I]![X]!.add(Action.goto(index_J));
          lr0_table_indexed[index_I]![X]!.add(Action.goto(index_J));
        }
      }
    }

    for (var I in lrfms.finalStates) {
      int index_I = lrfms.getStateIndex(I);

      for (var terminal in inputGrammar.terminals) {
        print(I.value);
        print(inputGrammar.getRuleIndex(I.value));
        lr0_table[I]![terminal]!
            .add(Action.reduce(inputGrammar.getRuleIndex(I.value)));
        lr0_table_indexed[index_I]![terminal]!
            .add(Action.reduce(inputGrammar.getRuleIndex(I.value)));
      }
    }
  }

  void log() {}

  void logToFile() {
    lrfms.DumpToDOT();
    String res = "\t\t";

    for (var nonTerminal in inputGrammar.nonTerminals) {
      if (nonTerminal != inputGrammar.start_non_terminal + '0') {
        res += nonTerminal + ' | ';
      }
    }
    for (var terminal in inputGrammar.terminals) {
      res += terminal + ' | ';
    }
    res += '\n';
    for (var I in lrfms.states) {
      var state_index = lrfms.getStateIndex(I);
      res += '${state_index}';
      if (state_index < 10) {
        res += ' |';
      } else {
        res += ' | ';
      }
      var lst = lr0_table[I];
      String row_values = '';
      for (var el in lst!.keys) {
        if (lst[el] == '' || lst[el] == null || lst[el]!.length == 0) {
          row_values += ' |- ';
        } else {
          print(lst[el]!.length);
          if (lst[el]!.length > 1) {
            row_values += ' |K ';
          } else {
            row_values += ' |${lst[el]![0]} ';
          }
        }
      }
      res += row_values;
      res += '\n';
    }

    File file = File('lr0_table.txt');
    file.writeAsStringSync(res);
  }
}
