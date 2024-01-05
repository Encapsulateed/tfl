import './src/utils/grammar.dart';
//import './src/state_machine./FSM.dart';
//import 'src/lr0/base/LR0State.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  Grammar g = Grammar.fromFile('input.txt');
  print(g.toString());
  // LR0FMS fms = LR0FMS(g);
  // fms.DumpToDOT();
  //fms.log();
}
