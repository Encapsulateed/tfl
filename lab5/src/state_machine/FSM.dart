import 'dart:io';

// Класс представляющий собой абстрактный конечный автомат
// states - множество всех состояний автомата
// startStates и finalStates - множества начальных и конечных состояний соотвественно
// transactions - список всех переходов автомата
class FSM {
  Set<State> states = {};
  Set<State> startStates = {};
  Set<State> finalStates = {};
  List<Transaction> transactions = [];

  FSM();

  void build() {}

  FSM.fromData(
      this.states, this.startStates, this.finalStates, this.transactions);

  // тут надо сделать детерминиизацию НКА
  FSM determinize() {
    return FSM();
  }

// метод реализующий получение состояния автомата по маске его имени
  State getState(String name) {
    //print(name);
    return states.toList().where((element) => element.name == name).first;
  }

  int getStateIndex(State state) {
    return states.toList().indexOf(state);
  }

// метод представления автомата в формате DOT
  void DumpToDOT() {
    String res = "";

    for (var state in this.states) {
      String shape = "circle";
      if (finalStates.contains(state)) {
        shape = "doublecircle";
      }
      res +=
          "\"${state.name}\" [label = \"${state.name}\", shape = ${shape}]\n";
    }

    for (var state in this.startStates) {
      res += "dummy -> \"${state.name}\"\n";
    }

    for (var transaction in this.transactions) {
      res +=
          "\"${transaction.from.name}\" -> \"${transaction.to.name}\" [label = \"${transaction.letter}\"]\n";
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

// Класс описывающий состояние автомата
class State {
  // имя состояния, выступает в роли идентификатора в множестве состояний автомата
  String name = '';
  // здесь хранится смысловая часть состояния автомата
  // в случае 5ЛР - это LR0 ситуация (см. класс LR0Situation)
  dynamic value;

  State();

  State.valued(this.name, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is State && runtimeType == other.runtimeType && name == other.name;

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

  Transaction.fromData(Set<State> from, Set<State> to, this.letter) {
    this.from = from.length == 1
        ? from.first
        : State(); // Take the first state from the set
    this.to = to.length == 1
        ? to.first
        : State(); // Take the first state from the set
  }
}
