import '../../state_machine/FSM.dart';
import '../../utils/grammar.dart';
import 'LR0Situation.dart';

class LR0FMS extends FSM {
  Grammar LR_grammar = Grammar();

  LR0FMS(Grammar grammar) {
    Map<Production, List<LR0Situation>> states = {};
    LR_grammar = grammar;
    //дополнили грамматику
    grammar.complete();

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
  @override
  build() {}

  void log() {
    for (var item in super.states.toList()) {
      print(item.name);
    }
  }

  void make_epsilon_goto(State input_state) {
    LR0Situation stateLR = input_state.value;

    // если точка стоит перед нетерминалом N, у нас есть эпсилон переходы
    // в те состояния Слева, которых стоит этот N & точка LR0 ситуации стоит на 0 позиции

    if (LR_grammar.nonTerminals.contains(stateLR.next)) {
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
