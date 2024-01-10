import '../utils/Action.dart';
import '../utils/grammar.dart';
import 'LR0Fms.dart';
import 'dart:io';

import 'LR0Situation.dart';

class LR0Table {
  LR0FMS _fsm = LR0FMS.empty();
  Grammar _grammar = Grammar();
  Map<int, Map<String, List<Action>>> lr0_table = {};

  LR0Table.emtpy();

  LR0Table(Grammar input_grammar) {
    _grammar = input_grammar;
    _fsm = LR0FMS(_grammar);

    makeTable();
  }

  void makeTable() {
    for (var I in _fsm.states) {
      int index = _fsm.getStateIndex(I);

      lr0_table[index] = {};
      for (var X in _grammar.nonTerminals) {
        if (X != _grammar.start_non_terminal + "0") {
          lr0_table[index]![X] = [];
        }
      }
      for (var X in _grammar.terminals) {
        lr0_table[index]![X] = [];
      }
    }
    for (var I in _fsm.finalStates) {
      int index_I = _fsm.getStateIndex(I);
      if (index_I == 0) {
        continue;
      }

      for (int i = 0; i < (I.value as List<LR0Situation>).length; i++) {
        var lr0_situation = I.value[i] as LR0Situation;
        if (lr0_situation.getNext() == 'eps') {
          for (var terminal in _grammar.terminals) {
            if (lr0_situation.right.contains(terminal)) {
              lr0_table[index_I]![terminal]!
                  .add(Action.reduce(_grammar.getRuleIndex(lr0_situation)));
            }
          }
        }
      }
    }

    for (var tran in _fsm.transactions) {
      var I = tran.from;
      var J = tran.to;
      var X = tran.letter;

      int index_I = _fsm.getStateIndex(I);
      int index_J = _fsm.getStateIndex(J);

      if (_grammar.terminals.contains(X)) {
        lr0_table[index_I]![X]!.add(Action.shift(index_J));
      } else if (_grammar.nonTerminals.contains(X)) {
        if (X != _grammar.start_non_terminal + '0') {
          lr0_table[index_I]![X]!.add(Action.goto(index_J));
        }
      }
    }
  }

  void log() {
    _fsm.DumpToDOT();
    for (var stateId in lr0_table.keys) {
      for (var colId in lr0_table[stateId]!.keys) {
        print(
            'ACTION AT T[$stateId][$colId]  === ${lr0_table[stateId]![colId]}');
      }
    }
  }

  void logToFile() {
    _fsm.DumpToDOT();
    var file = File('lr0_table.txt');

    // Открываем файл для записи
    var sink = file.openWrite();

    // Записываем заголовок таблицы
    sink.write('State\t\t\t\t\t\t');
    sink.writeln('${lr0_table.values.first.keys.join('\t\t\t\t\t\t')}');

    // Записываем значения таблицы
    lr0_table.forEach((state, actions) {
      sink.write('$state\t\t\t\t\t\t');
      sink.writeln(actions.values
          .map((actionList) => actionList.join('\t\t\t'))
          .join('\t\t\t\t\t\t'));
    });

    // Закрываем файл
    sink.close();
  }
}
