import '../utils/grammar.dart';
import '../utils/Production.dart';
import '../state_machine/FSM.dart';
import 'LR0Situation.dart';

class LR0FMS extends FSM {
  LR0FMS.empty();
  Map<String, State> statyByLR0 = {};
  Grammar _grammar = Grammar();

  LR0FMS.nka(Grammar grammar) {
    Map<Production, List<LR0Situation>> states = {};
    _grammar = grammar;
    // тут делаем closure для всей грамматики
    for (var rule in grammar.rules) {
      List<LR0Situation> rule_possible_situation = [];
      for (int LR0_pointer = 0;
          LR0_pointer <= rule.right.length;
          LR0_pointer++) {
        var situation = LR0Situation(rule.left, rule.right, LR0_pointer);
        rule_possible_situation.add(situation);
      }

      states[rule] = rule_possible_situation;
    }
    var first_state = states[grammar.rules.toList()[0]]!.toList()[0];
    super.startStates.add(State.valued(first_state.toString(), first_state));

    // тут строим реальные переходы в автомате
    for (var rule in grammar.rules) {
      var first = states[rule]!.toList()[0];

      for (var lr0_situations in states[rule]!.toList()) {
        if (lr0_situations.isFinal()) {
          super
              .finalStates
              .add(State.valued(lr0_situations.toString(), lr0_situations));
        }
        var next = lr0_situations;

        //
        super
            .states
            .add(State.valued(lr0_situations.toString(), lr0_situations));

        // Нужно добавить переход в автомате
        if (first != next) {
          var transaction = Transaction()
            ..from = super.getState(first.toString())
            ..to = super.getState(next.toString())
            ..letter = first.next;
          super.transactions.add(transaction);
        }
        first = next;
      }
    }

    // тут строим эпсилон переходы в автомате

    for (var state in super.states.toList()) {
      make_epsilon_goto(state);
    }
  }

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

  List<LR0Situation> closure2(List<LR0Situation> productions) {
    return [];
  }

  void gaySex() {
    // Начальное состояние соответвует G+ - пополненной грамматике
    List<LR0Situation> first_state_value = []
      ..addAll(_grammar.rules.map((P) => zeroClosure(P)[0].clone()));
    var state_name = first_state_value.join('\n');
    State first_state = State.valued(state_name, first_state_value);
    super.states.add(first_state);
    super.startStates.add(first_state);
    shift(first_state);
  }

  void shift(State state, {bool need_load = true}) {
    for (var l in state.value as List<LR0Situation>) {
      try {
        var newl = l.clone();
        var beta = newl.next;

        if (l.toString() == "E -> ·E+T") {}

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
          // тут логика, есди какое-то состояние уже содержит эту продукцию
          if (statyByLR0[newl.toString()] != null) {
            N0 = statyByLR0[newl.toString()]!;
          } else {
            N0 = State.valued(newl.toString(), [newl.clone()]);

            if (newl.getNext() == 'eps') {
              super.finalStates.add(N0);
            }
            super.states.add(N0);
            statyByLR0[newl.toString()] = N0;
          }

          Transaction transaction = Transaction.ivan(state, N0, beta);
          super.transactions.add(transaction);

          if (need_load) {
            List<State> first = [];
            First(N0, first);
            first.forEach((element) {
              load_rules(element, N0, X);
            });
          } else {
            load_rules(state, N0, X);
          }

          shift(N0);
        } else {
          print(state.name);
          if ((transition_set[0].to.value as List<LR0Situation>)
                  .contains(newl) ==
              false) {
            if (statyByLR0[newl.toString()] == null) {
              transition_set[0].to.name += '\n${newl.toString()}';
              (transition_set[0].to.value as List<LR0Situation>)
                  .add(newl.clone());
              statyByLR0[newl.toString()] = transition_set[0].to;
            }
          }
          shift(transition_set[0].to, need_load: false);
        }
      } catch (e) {
        return;
      }
    }
  }

  void load_rules(State state, State N0, String X) {
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

  void make_epsilon_goto(State input_state) {
    LR0Situation stateLR = input_state.value;

    // если точка стоит перед нетерминалом N, у нас есть эпсилон переходы
    // в те состояния Слева, которых стоит этот N & точка LR0 ситуации стоит на 0 позиции
    if (_grammar.nonTerminals.contains(stateLR.next)) {
      var N = stateLR.next;
      for (var state in super.states.toList()) {
        if ((state.value as LR0Situation).left == N &&
            (state.value as LR0Situation).LR0_pointer == 0) {
          var transaction = Transaction()
            ..from =
                super.getState((input_state.value as LR0Situation).toString())
            ..to = super.getState((state.value as LR0Situation).toString())
            ..letter = 'ε';

          super.transactions.add(transaction);
        }
      }
    }
  }
}
