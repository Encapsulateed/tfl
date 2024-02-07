import '../utils/Action.dart';
import '../utils/grammar.dart';
import 'LR0Fms.dart';
import 'dart:io';

class LR0Table {
  LR0FMS _fsm = LR0FMS.empty();
  Grammar _grammar = Grammar();
  Map<int, Map<String, List<Action>>> lr0_table = {};

  LR0Table.emtpy();

  LR0Table(Grammar input_grammar) {
    _grammar = input_grammar;
    _fsm = LR0FMS(_grammar);
    _grammar.terminals.add('\$');
    makeTable();
    _grammar.terminals.remove('\$');
  }
  LR0FMS get() {
    return _fsm;
  }

  void makeTable() {
    for (var I
        in _fsm.states.where((element) => _fsm.getStateIndex(element) != -1)) {
      int index = _fsm.getStateIndex(I);

      lr0_table[index] = {};
      for (var X in _grammar.nonTerminals) {
        if (X != _grammar.startNonTerminal + "0") {
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

      for (int i = 0; i < (I.value).length; i++) {
        var lr0_situation = I.value.toList()[i];
        if (lr0_situation.getNext() == 'eps') {
          int reduce_id = _grammar.getRuleIndex(lr0_situation);

          if (reduce_id == 0) {
            lr0_table[index_I]!['\$']!.add(Action.accept());
          } else {
            for (var terminal in _grammar.terminals) {
              lr0_table[index_I]![terminal]!.add(Action.reduce(reduce_id));
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
        if (X != _grammar.startNonTerminal + '0') {
          if (index_I != -1) {
            lr0_table[index_I]![X]!.add(Action.goto(index_J));
          }
        }
      }
    }
  }

  void logToFile(String path) {
    var file = File(path);

    // Открываем файл для записи
    var sink = file.openWrite();

    // Записываем заголовок таблицы
    sink.write('State\t\t\t\t\t\t');
    sink.writeln('${lr0_table.values.first.keys.join('\t\t\t\t\t\t')}');

    // Записываем значения таблицы
    lr0_table.forEach((state, actions) {
      sink.write('$state\t\t\t\t\t\t');
      sink.writeln(actions.values
          .map((actionList) => '[${actionList.join('\t\t\t')}]')
          .join('\t\t\t\t\t\t'));
    });

    // Закрываем файл
    sink.close();
  }
}
