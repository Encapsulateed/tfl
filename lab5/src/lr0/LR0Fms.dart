import '../utils/grammar.dart';
import '../utils/Production.dart';
import '../state_machine/FSM.dart';
import 'LR0Situation.dart';

class LR0FMS extends FSM {
  LR0FMS.empty();
  // State : X: {moved by X LR0 - items}
  Map<int, Map<String, Set<LR0Situation>>> moved = {};
  Map<String, State> statyByLR0 = {};

  Grammar _grammar = Grammar();

  LR0FMS(Grammar CompleteGrammar) {
    this._grammar = CompleteGrammar;
    super.alphabet.addAll(_grammar.nonTerminals);
    super.alphabet.addAll(_grammar.terminals);

    buildDFA();

    // super.transactions.remove(super.transactions.where(
    //   (t) => t.from == getStateByIndex(0) && t.to == getStateByIndex(1)));
    // super.states.remove(getStateByIndex(0));
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

  void create_super_zero_state() {
    List<LR0Situation> first_state_value = []
      ..addAll(_grammar.user_rules.map((P) => zeroClosure(P)[0].clone()));
    var state_name = first_state_value.join('\n');
    State zero = State.valued(state_name, first_state_value);
    super.states.add(zero);
  }

  void create_first_state() {
    LR0Situation lr0 = LR0Situation.fromProduction(_grammar.rules[0]);
    var state_name = lr0.toString();
    State first = State.valued(state_name, [lr0.clone()]);
    super.states.add(first);
    super.startStates.add(first);

    super.transactions.add(
        Transaction.ivan(getStateByIndex(0), first, _grammar.startNonTerminal));
    load_rules(first, _grammar.startNonTerminal);
  }

  void buildDFA() {
    // Начальное состояние соответвует G+ - пополненной грамматике
    create_super_zero_state();
    create_first_state();

    while (true) {
      int p_l = super.states.length;

      for (int i = 1; i < p_l; i++) {
        try {
          shift(getStateByIndex(i));
        } catch (e) {
          print(e);
        }
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
      for (var l in s.value) {
        if (l.getNext() == 'eps') {
          super.finalStates.add(s);
          break;
        }
      }
    }
  }

  Set<LR0Situation> getDstSet(State s, String X) {
    Set<LR0Situation> dst_move_set = {};
    for (var lr0 in s.value) {
      var copy = lr0.clone();
      if (copy.getNext() == X) {
        copy.move();
        dst_move_set.add(copy);
      }
    }

    return dst_move_set;
  }

  State? getDst(State from, String X) {
    var dst_move_set = getDstSet(from, X);
    for (var state in super.states) {
      if (super.getStateIndex(state) == 0) {
        continue;
      }

      if (state.moved[X] != null) {
        bool contains_all = true;

        for (var item in dst_move_set) {
          if (!state.moved[X]!.any((element) => element == item)) {
            contains_all = false;
          }
        }
        if (contains_all) {
          return state;
        }
      }
    }

    return null;
  }

  void shift(State state, {bool need_load = true}) {
    for (var l in state.value) {
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
            .where((trans) =>
                trans.from == state &&
                trans.letter == beta &&
                trans.to != getStateByIndex(1))
            .toList();

        if (transition_set.length == 0) {
          State N0 = State();
          bool existed = false;

          if (statyByLR0[newl.toString()] != null) {
            if (getDst(state, beta) != null) {
              N0 = getDst(state, beta)!;
            } else {
              //   N0 = statyByLR0[newl.toString()]!;
            }
          }

          if (N0.name == '') {
            N0 = State.valued('[${newl.toString()}]', [newl.clone()]);
            N0.moved[beta] = [];
            N0.moved[beta]!.add(newl);

            if (newl.getNext() == 'eps') {
              super.finalStates.add(N0);
            }

            super.states.add(N0);

            if (X != 'eps') {
              statyByLR0[newl.toString()] = N0;
            }
          }

          super.transactions.add(Transaction.ivan(state, N0, beta));
          load_rules(N0, X);
          if (existed == false) {
            List<State> first = [];
            First(N0, first);
            first.forEach((element) {});
          }
        } else {
          if ((transition_set[0].to.value).contains(newl) == false) {
            transition_set[0].to.name += '\n[${newl.toString()}]';
            if (transition_set[0].to.moved[transition_set[0].letter] != null) {
              transition_set[0].to.moved[transition_set[0].letter]!.add(newl);
            }

            (transition_set[0].to.value).add(newl.clone());

            //addMove(state, transition_set[0].to, l);
            var temp = newl.clone();
            temp.move();

            if (X != 'eps') {
              statyByLR0[newl.toString()] = transition_set[0].to;
            }
            load_rules(transition_set[0].to, X);
          }
        }
      } catch (e, s) {
        print(s);
        return;
        // continue;
      }
    }
  }

  void load_rules(State to, String X) {
    if (_grammar.nonTerminals.contains(X)) {
      for (var p in _grammar.rules.where((r) => r.left == X)) {
        var new_lr0 = LR0Situation.fromProduction(p);
        if (!to.value.any((e) =>
            e.left == new_lr0.left &&
            e.right == new_lr0.right &&
            new_lr0.LR0_pointer == e.LR0_pointer)) {
          to.name += '\n${new_lr0.toString()}';
          to.value.add(new_lr0);

          if (_grammar.nonTerminals.contains(new_lr0.getNext()) &&
              X != new_lr0.getNext()) {
            load_rules(to, new_lr0.getNext());
          }
        }
      }
    }
  }

  void First(State X, List<State> first) {
    for (var tr in super.transactions.where((t) => t.to == X)) {
      if (X != tr.from && !first.contains(tr.from)) {
        first.add(tr.from);
        First(tr.from, first);
      }
    }
  }
}
