import '../../utils/grammar.dart';
import 'LR0Situation.dart';

class LR0State {
  Map<Production, Set<LR0Situation>> states = {};
  Grammar g = Grammar();

  LR0State(Grammar grammar) {
    g = grammar;
    //дополнили грамматику
    grammar.complete();

    // тут делаем closure для всей грамматики
    for (var rule in grammar.rules) {
      Set<LR0Situation> rule_possible_situation = {};
      for (int LR0_pointer = 0;
          LR0_pointer <= rule.right.length;
          LR0_pointer++) {
        var situation = LR0Situation(rule.left, rule.right, LR0_pointer);

        rule_possible_situation.add(situation);
      }

      states[rule] = rule_possible_situation;
    }
  }

  @override
  String toString() {
    String s = '';

    for (var rule in g.rules) {
      s += '${rule.toString()} ${states[rule]}';
      s += '\n';
    }
    return s;
  }
}
