import 'dart:io';
import 'dart:collection';

import '../lr0/LR0Situation.dart';

// Класс представляющий собой абстрактный конечный автомат
// states - множество всех состояний автомата
// startStates и finalStates - множества начальных и конечных состояний соотвественно
// transactions - список всех переходов автомата
class FSM {
  Set<State> states = {};
  Set<State> startStates = {};
  Set<State> finalStates = {};
  List<Transaction> transactions = [];
  List<String> alphabet = []; // Памятка для бездельника: мне нужен алфавит

  FSM();

  void build() {}

  FSM.fromData(
      this.states, this.startStates, this.finalStates, this.transactions);

// метод реализующий получение состояния автомата по маске его имени
  State getState(String name) {
    return states.toList().where((element) => element.name == name).first;
  }

  int getStateIndex(State state) {
    return states.toList().indexOf(state) -1;
  }

  State getStateByIndex(int index) {
    return states.toList()[index];
  }

// метод представления автомата в формате DOT
  void DumpToDOT(String path) {
    String res = "";

    for (var state in this.states) {
      String shape = "circle";
      if (finalStates.contains(state)) {
        shape = "doublecircle";
      }
      res +=
          "\"${getStateIndex(state)} ${state.name}\" [label = \"${getStateIndex(state)} ${state.name}\", shape = ${shape}]\n";
    }

    for (var state in this.startStates) {
      res += "dummy -> \"${getStateIndex(state)} ${state.name}\"\n";
    }

    for (var transaction in this.transactions) {
      res +=
          "\"${getStateIndex(transaction.from)} ${transaction.from.name}\" -> \"${getStateIndex(transaction.to)} ${transaction.to.name}\" [label = \"${transaction.letter}\"]\n";
    }

    res = "digraph {\n"
        "rankdir = LR\n"
        "dummy [shape=none, label=\"\", width=0, height=0]\n"
        "$res"
        "}\n";

    File file = File(path);
    file.writeAsStringSync(res);
  }
}

// Класс описывающий состояние автомата
class State {
  // имя состояния, выступает в роли идентификатора в множестве состояний автомата
  String name = '';
  // здесь хранится смысловая часть состояния автомата
  // в случае 5ЛР - это LR0 ситуация (см. класс LR0Situation)
  List<LR0Situation> value=[];
  Map<String, List<LR0Situation>> moved = {};
  State();

  State.valued(this.name, this.value);
  bool _compareLists( List<LR0Situation> list1,  List<LR0Situation> list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is State &&
          _compareLists(
              value, other.value);

  @override
  int get hashCode => name.hashCode;
}

// Класс описывающий переход из одного состояния в другое
class Transaction {
  // Состояние из которого идём
  State from = State();
  // состояние в которое идём
  State to = State();

  // Символ | строка, по которому(ой) осуществляется переход
  // Если - это эпсилон переход, в переменной letter будет содержатся символ ε
  String letter = '';

  Transaction();

  Transaction.ivan(this.from, this.to, this.letter);

  @override
  String toString() {
    return "[${from.name}] -> [${to.name}] BY ${letter} ";
  }
}
