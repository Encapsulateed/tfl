import './src/utils/grammar.dart';
//import './src/state_machine./FSM.dart';
//import 'src/lr0/base/LR0State.dart';
import 'src/lr0/base/LR0fms.dart';

void main(List<String> arguments) {
  Grammar g = Grammar.fromFile('input.txt');
  LR0FMS fms = LR0FMS(g);
  fms.DumpToDOT();
  //fms.log();
}
