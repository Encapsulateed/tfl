import './src/utils/grammar.dart';
import 'src/lr0/base/LR0Table.dart';
import 'src/state_machine/FSM.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  var st1 = State.valued('q1', 'значение состояния 1, сейчас оно не нужно');
  var st2 = State.valued('q2', '');
  var st3 = State.valued('q3', '');
  var st4 = State.valued('q4', '');

  FSM fms = FSM();
  fms.states.addAll([st1, st2, st3, st4]);
  fms.startStates.add(st1);
  fms.finalStates.add(st4);

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

  fms.transactions.addAll([tr1, tr2, tr3, tr4, tr5]);

  fms.DumpToDOT();
}
