import './src/utils/grammar.dart';
import 'src/lr0/LR0Fms.dart';
import 'src/state_machine/FSM.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  var g = Grammar.fromFile('input.txt');
  g.complete();
  FSM f = LR0FMS(g);
  //f = f.determinize();
  f.DumpToDOT();

  //LR0Table t = LR0Table(g);
  //t.logToFile();

//  fsm = fsm.determinize();
  // fsm.DumpToDOT();
}
