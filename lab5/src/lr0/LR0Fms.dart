import '../utils/grammar.dart';
import '../utils/Production.dart';
import '../state_machine/FSM.dart';
import 'LR0Situation.dart';

class LR0FMS extends FSM {
  LR0FMS.empty();
  Map<String, State> statyByLR0 = {};
  Grammar _grammar = Grammar();

  LR0FMS(Grammar CompleteGrammar) {
    this._grammar = CompleteGrammar;
    super.alphabet.addAll(_grammar.nonTerminals);
    super.alphabet.addAll(_grammar.terminals);

    buildDFA();
  }

  List<LR0Situation> closure(Production production) {
    List<LR0Situation> production_possible_LR0_situations = [];
    for (int lr_ptr = 1; lr_ptr <= production.right.length; lr_ptr++) {
      var s = LR0Situation(production.left, production.right, lr_ptr);
      production_possible_LR0_situations.add(s);
    }

    return production_possible_LR0_situations;
  }

  List<LR0Situation> zeroClosure(Production production) {
    List<LR0Situation> production_possible_LR0_situations = [];
    var s = LR0Situation(production.left, production.right, 0);
    production_possible_LR0_situations.add(s);

    return production_possible_LR0_situations;
  }

  void buildDFA() {
    // Начальное состояние соответвует G+ - пополненной грамматике
    List<LR0Situation> first_state_value = []
      ..addAll(_grammar.rules.map((P) => zeroClosure(P)[0].clone()));
    var state_name = first_state_value.join('\n');
    State first_state = State.valued(state_name, first_state_value);
    super.states.add(first_state);
    super.startStates.add(first_state);
    shift(first_state);

    while (true) {
      int p_l = super.states.length;

      for (int i = 1; i < p_l; i++) {
        shift(getStateByIndex(i));
      }
      int n_l = super.states.length;
      if (p_l == n_l) {
        break;
      }
    }
    for (var tr in super.transactions) {
      var t = tr.to;
      var f = tr.from;

      if (!super.states.contains(t)) {
        super.states.add(t);
      }
      if (!super.states.contains(f)) {
        super.states.add(f);
      }
    }
    for (var s in super.states) {
      for (var l in s.value as List<LR0Situation>) {
        if (l.getNext() == 'eps') {
          super.finalStates.add(s);
          break;
        }
      }
    }
  }

  void shift(State state, {bool need_load = true}) {
    for (var l in state.value as List<LR0Situation>) {
      try {
        var newl = l.clone();
        var beta = newl.next;

        if (beta == "eps") {
          continue;
        }

        newl.move();

        var X = newl.getNext();

        var transition_set = super
            .transactions
            .where((trans) => trans.from == state && trans.letter == beta)
            .toList();

        if (transition_set.length == 0) {
          State N0 = State();
          bool existed = false;

          if (statyByLR0[newl.toString()] != null) {
            N0 = statyByLR0[newl.toString()]!;
            existed = true;
          } else {
            N0 = State.valued(newl.toString(), [newl.clone()]);

            if (newl.getNext() == 'eps') {
              super.finalStates.add(N0);
            }

            super.states.add(N0);

            if (X != 'eps') {
              statyByLR0[newl.toString()] = N0;
            }
          }

          Transaction transaction = Transaction.ivan(state, N0, beta);
          super.transactions.add(transaction);

          if (existed == false) {
            List<State> first = [];
            First(N0, first);
            first.forEach((element) {
              load_rules(element, N0, X);
            });
          }
        } else {
          if ((transition_set[0].to.value as List<LR0Situation>)
                  .contains(newl) ==
              false) {
            transition_set[0].to.name += '\n${newl.toString()}';
            (transition_set[0].to.value as List<LR0Situation>)
                .add(newl.clone());

            if (X != 'eps') {
              statyByLR0[newl.toString()] = transition_set[0].to;
            }

            List<State> first = [];
            First(transition_set[0].to, first);
            first.forEach((element) {
              load_rules(element, transition_set[0].to, X);
            });
          }
        }
      } catch (e) {
        return;
      }
    }
  }

  void load_rules(State state, State N0, String X) {
    if (state == N0) {
      return;
    }

    if (_grammar.nonTerminals.contains(X)) {
      for (var l_0 in state.value as List<LR0Situation>) {
        if (l_0.left == X) {
          var prev_lr0 = LR0Situation(l_0.left, l_0.right, l_0.LR0_pointer - 1);
          if (prev_lr0.LR0_pointer == -1) {
            prev_lr0.LR0_pointer = 0;
          }

          if ((N0.value as List<LR0Situation>).contains(prev_lr0) == false) {
            (N0.value as List<LR0Situation>).add(prev_lr0.clone());
            N0.name += '\n${prev_lr0.toString()}';
            statyByLR0[prev_lr0.toString()] = N0;
          }

          if (_grammar.nonTerminals.contains(prev_lr0.getNext()) &&
              X != prev_lr0.getNext()) {
            load_rules(state, N0, prev_lr0.getNext());
          }
        }
      }
    }
  }

  void First(State X, List<State> first) {
    for (var tr in super.transactions.where((t) => t.to == X)) {
      if (X != tr.from) {
        first.add(tr.from);
        First(tr.from, first);
      }
    }
  }
}
