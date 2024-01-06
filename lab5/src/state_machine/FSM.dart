import 'dart:io';
import 'dart:collection';

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

  // тут надо сделать детерминиизацию НКА
  FSM determinize() {
    Set<Set<State>> dStates = {}; // Множество состояний для ДКА
    Map<Set<State>, Map<String, Set<State>>> dTransitions =
        {}; // Таблица переходов для ДКА
    Set<Set<State>> dFinalStates = {}; // Множество конечных состояний для ДКА

    // Начальная настройка
    Set<State> startStateSet = eClosure(startStates);
    dStates.add(startStateSet);
    Queue<Set<State>> unprocessedStates = Queue()..add(startStateSet);

    while (unprocessedStates.isNotEmpty) {
      Set<State> currentStateSet = unprocessedStates.removeFirst();

      // Вычисление переходов для каждого символа в алфавите
      Map<String, Set<State>> transitions = {};
      for (String symbol in alphabet) {
        Set<State> newStateSet = eClosure(move(currentStateSet, symbol));

        if (newStateSet.isNotEmpty) {
          transitions[symbol] = newStateSet;

          if (!dStates.contains(newStateSet)) {
            dStates.add(newStateSet);
            unprocessedStates.add(newStateSet);
          }
        }
      }

      dTransitions[currentStateSet] = transitions;

      // Проверка, содержит ли текущий набор состояний какое-либо конечное состояние
      if (currentStateSet.any((state) => finalStates.contains(state))) {
        dFinalStates.add(currentStateSet);
      }
    }

    // Создание нового ДКА
    FSM determinizedFSM = FSM();

    for (Set<State> stateSet in dStates) {
      for (State state in stateSet) {
        determinizedFSM.states.add(state);

        if (stateSet.containsAll(startStates)) {
          determinizedFSM.startStates.add(state);
        }

        if (stateSet.any((state) => finalStates.contains(state))) {
          determinizedFSM.finalStates.add(state);
        }

        for (String symbol in alphabet) {
          if (dTransitions[stateSet] != null &&
              dTransitions[stateSet]![symbol] != null) {
           /* determinizedFSM.transactions.add(
              Transaction.fromData(
                stateSet,
                dTransitions[stateSet]![symbol]!,
                symbol,
              ),
            ); */
          }
        }
      }
    }

    return determinizedFSM;
  }

  // Вычисление эпсилон-замыкания для набора состояний
  Set<State> eClosure(Set<State> states) {
    Set<State> closure = {};
    Queue<State> queue = Queue.from(states);

    while (queue.isNotEmpty) {
      State currentState = queue.removeFirst();
      closure.add(currentState);

      for (Transaction transaction in transactions) {
        if (transaction.from == currentState && transaction.letter == 'e') {
          State toState = transaction.to;
          if (!closure.contains(toState)) {
            queue.add(toState);
          }
        }
      }
    }

    return closure;
  }

  // Вычисление перехода для набора состояний по символу
  Set<State> move(Set<State> states, String symbol) {
    Set<State> result = {};

    for (State currentState in states) {
      for (Transaction transaction in transactions) {
        if (transaction.from == currentState && transaction.letter == symbol) {
          result.add(transaction.to);
        }
      }
    }

    return result;
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

  Transaction.ivan(this.from, this.to, this.letter);


  }
}
