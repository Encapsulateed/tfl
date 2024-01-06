import 'package:test/test.dart';
import '../state_machine/FSM.dart';

void main() {
  test('Example FSM Determinization Test', () {
    var st1 = State.valued('q1', 'значение состояния 1, сейчас оно не нужно');
    var st2 = State.valued('q2', '');
    var st3 = State.valued('q3', '');
    var st4 = State.valued('q4', '');

    FSM fsm = FSM();
    fsm.states.addAll([st1, st2, st3, st4]);
    fsm.startStates.add(st1);
    fsm.finalStates.add(st4);
    fsm.alphabet = ['a', 'c'];

    var tr1 = Transaction()
      ..from = st1
      ..to = st2
      ..letter = 'a';

    var tr2 = Transaction()
      ..from = st1
      ..to = st2
      ..letter = 'ε';

    var tr3 = Transaction()
      ..from = st1
      ..to = st3
      ..letter = 'c';

    var tr4 = Transaction()
      ..from = st2
      ..to = st3
      ..letter = 'ε';

    var tr5 = Transaction()
      ..from = st3
      ..to = st4
      ..letter = 'ε';

    fsm.transactions.addAll([tr1, tr2, tr3, tr4, tr5]);

    // Детерминизация автомата
    FSM determinizedFSM = fsm.determinize();
    determinizedFSM.DumpToDOT();

    expect(determinizedFSM.states.length, greaterThan(0));
    print(determinizedFSM.states.length);
    expect(determinizedFSM.startStates.length, greaterThan(0));
    print(determinizedFSM.startStates.length);
    expect(determinizedFSM.finalStates.length, greaterThan(0));
    print(determinizedFSM.finalStates.length);
    expect(determinizedFSM.transactions.length, greaterThan(0));
    print(determinizedFSM.transactions.length);

  });
}