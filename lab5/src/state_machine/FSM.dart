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

  FSM determinize() {
    Set<Set<State>> dStates = {}; // Множество состояний для ДКА
    Map<Set<State>, Map<String, Set<State>>> dTransitions =
        {}; // Таблица переходов для ДКА
    Set<Set<State>> dFinalStates = {}; // Множество конечных состояний для ДКА
    Set<Set<State>> dStartStates = {}; // Множество начальных состояний для ДКА

    //Строим замыкание по стартовым состояниям
    Set<State> startStateSet = eClosure(startStates);
    dStates.add(startStateSet);
    //Помещаем в очередь множество, состоящее из стартовой вершины
    Queue<Set<State>> unprocessedStates = Queue()..add(startStateSet);

    while (unprocessedStates.isNotEmpty || unprocessedStates.length != 0) {
      //Достаем множество из очереди
      Set<State> currentStateSet = unprocessedStates.removeFirst();
      // Посмотрим в какое состояние ведет переход по символу из каждого состояния
      Map<String, Set<State>> transitions = {};

      for (String symbol in alphabet) {
        //Строим замыкание по состояниям, в которые можем перейти по символу

        // Set<State> newStateSet = eClosure(move(currentStateSet, symbol));
        Set<State> newStateSet = eClosure(move(currentStateSet, symbol));
        bool equal_flag = true;

        if (newStateSet.length == currentStateSet.length) {
          for (int i = 0; i < newStateSet.length; i++) {
            if (newStateSet.toList()[i].name !=
                currentStateSet.toList()[i].name) {
              equal_flag = false;
            }
          }
        }

        if (newStateSet.isNotEmpty && newStateSet.length != 0) {
          transitions[symbol] = newStateSet;

          //Кладем в очередь только, если оно не лежало уже там раньше
          if (unprocessedStates.contains(newStateSet) == false) {
            // Если в множестве newStateSet хотя бы одно из вершин терминально в НКА, то само терминально
            if (equal_flag == false) {
              dStates.add(newStateSet);

              unprocessedStates.add(newStateSet);
            }
          }
        }
      }

      dTransitions[currentStateSet] = transitions;

      //Проверка, содержит ли текущий набор состояний какое-либо конечное состояние
      setPrint(finalStates);
      for (State t in finalStates) {
        dFinalStates.add({t});
      }

      //Проверка, содержит ли текущий набор состояний какое-либо стартовое состояние
      for (State t in startStates) {
        if (currentStateSet.contains(t) &&
            (!dStartStates.contains(currentStateSet))) {
          dStartStates.add(currentStateSet);
        }
      }
    }

    // Создание нового ДКА
    FSM determinizedFSM = FSM();

// Map для хранения объединенных состояний

    for (Set<State> stateSet in dStates) {
      State combinedState = State();
      for (State state in stateSet) {
        combinedState.name += "${state.name} ";
        combinedState.value = <dynamic>[];
        if (state.value != null) {
          (combinedState.value as List<dynamic>).add(state.value);
        }
        //value объединяем здесь
      }

      determinizedFSM.states.add(combinedState);

      if (dStartStates.contains(stateSet)) {
        determinizedFSM.startStates.add(combinedState);
      }

      if (dFinalStates.contains(stateSet)) {
        determinizedFSM.finalStates.add(combinedState);
      }

      for (String symbol in alphabet) {
        if (dTransitions[stateSet] != null &&
            dTransitions[stateSet]![symbol] != null) {
          State toState = State();

          for (State s in dTransitions[stateSet]![symbol]!) {
            toState.name += "${s.name} ";
            //тут же собираем value
          }
          // print('BY $symbol');
          determinizedFSM.transactions.add(
            Transaction.ivan(
              combinedState,
              toState,
              symbol,
            ),
          );
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
        if (transaction.from == currentState && transaction.letter == 'ε') {
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

  void setPrint(Set<State>? set) {
    String res = "Set print is working: ";

    if (set != null) {
      for (State state in set) {
        res += "${state.name}\n";
      }

      print(res);
    } else {
      res += "set is null";
    }
  }

// метод реализующий получение состояния автомата по маске его имени
  State getState(String name) {
    return states.toList().where((element) => element.name == name).first;
  }

  int getStateIndex(State state) {
    return states.toList().indexOf(state);
  }

  State getStateByIndex(int index) {
    return states.toList()[index];
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
      other is State &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value;

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
