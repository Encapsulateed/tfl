import '../utils/grammar.dart';
import '../utils/Production.dart';
import '../state_machine/FSM.dart';
import 'LR0Situation.dart';

class LR0FMS extends FSM {
  LR0FMS.empty();
  Grammar _grammar = Grammar();
  LR0FMS(Grammar CompleteGrammar) {
    this._grammar = CompleteGrammar;
    super.alphabet.addAll(_grammar.nonTerminals);
    super.alphabet.addAll(_grammar.terminals);

    gaySex();

    // make_symbol_transition();
    // make_eps_transitions();
  }

  List<LR0Situation> closure(Production production) {
    List<LR0Situation> production_possible_LR0_situations = [];
    for (int lr_ptr = 0; lr_ptr <= production.right.length; lr_ptr++) {
      var s = LR0Situation(production.left, production.right, lr_ptr);
      production_possible_LR0_situations.add(s);
    }

    return production_possible_LR0_situations;
  }

  void gaySex() {
    // Начальное состояние соответвует G+ - пополненной грамматике
    List<LR0Situation> first_state_value = []
      ..addAll(_grammar.rules.map((P) => closure(P)[0]));
    var state_name = first_state_value.join('\n');
    State first_state = State.valued(state_name, first_state_value);
    super.states.add(first_state);
    super.startStates.add(first_state);

    // тута лежат все возможные LR(0)-ситуации, кроме изначальных правил грамматики
    Map<int, LR0Situation> all_lr0_items = {};
    for (var state in super.states) {
      shift(state, all_lr0_items);
    }
  }

  // Метод сдвигает точку в LR разборе и строит связи для состояний автомата
  void shift(State state, Map<int, LR0Situation> existed_situations) {
    var state_lr0 = state.value as List<LR0Situation>;

    for (var lr0 in state_lr0) {
      if (lr0.next == "eps") {
        continue;
      }
      var symbol = lr0.next;
      lr0.LR0_pointer++;

      var new_state = State.valued(lr0.toString(), lr0);
      super.states.add(new_state);

      var tran = Transaction()
        ..from = state
        ..to = new_state
        ..letter = lr0.next;

      super.transactions.add(tran);
      print(lr0.toString());
    }
  }

  void make_symbol_transition() {
    var f_state = closure(_grammar.rules[0])[0];
    super.startStates.add(State.valued(f_state.toString(), [f_state]));

    for (var prod in _grammar.rules) {
      var closure_lst = closure(prod);
      var f = closure_lst[0];
      for (var lr0s in closure_lst) {
        if (lr0s.isFinal()) {
          super.finalStates.add(State.valued(lr0s.toString(), [lr0s]));
        }
        super.states.add(State.valued(lr0s.toString(), [lr0s]));

        var next = lr0s;

        if (f != next) {
          var transaction = Transaction()
            ..from = super.getState(f.toString())
            ..to = super.getState(next.toString())
            ..letter = f.next;
          super.transactions.add(transaction);
        }
        f = next;
      }
    }
  }

  void make_eps_transitions() {
    for (var st in super.states) {
      // если точка стоит перед нетерминалом N, у нас есть эпсилон переходы
      // в те состояния Слева, которых стоит этот N & точка LR0 ситуации стоит на 0 позиции

      var lr0_s = st.value[0] as LR0Situation;

      if (_grammar.nonTerminals.contains(lr0_s.next)) {
        var N = lr0_s.next;
        for (var state in super.states.toList()) {
          var state_value = state.value[0] as LR0Situation;

          if (state_value.left == N && state_value.LR0_pointer == 0) {
            var transaction = Transaction()
              ..from = super.getState(lr0_s.toString())
              ..to = super.getState(state_value.toString())
              ..letter = 'ε';

            super.transactions.add(transaction);
          }
        }
      }
    }
  }
}
