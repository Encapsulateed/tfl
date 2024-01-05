import './src/utils/grammar.dart';
//import './src/state_machine./FSM.dart';
//import 'src/lr0/base/LR0State.dart';
import 'src/lr0/base/LR0fms.dart';

void main(List<String> arguments) {
  Grammar g = Grammar.fromFile('input.txt');
  LR0_FMS fms = LR0_FMS(g);
  fms.DumpToDOT();
  //fms.log();
}
