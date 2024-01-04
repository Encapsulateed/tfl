import '../../state_machine/FSM.dart';
import '../../utils/grammar.dart';
import 'LR0State.dart';

class LR0_FMS extends FSM {
  LR0_FMS(Grammar grammar) {
    LR0State state = LR0State(grammar);

    super.startStates.add(State.named(
        state.states[grammar.rules.toList()[0]]!.toList()[0].toString()));

    //var prev = super.startStates.toList()[0];

    for (var rule in grammar.rules) {
      for (var lr0_situations in state.states[rule]!.toList()) {
        if (lr0_situations.isFinal()) {
          super.finalStates.add(State.named(lr0_situations.toString()));
        }
        super.states.add(State.named(lr0_situations.toString()));
      }
    }

    // print(grammar);
  }
  @override
  build() {}

  void log() {
    for (var item in super.states.toList()) {
      print(item.name);
    }
  }
}
