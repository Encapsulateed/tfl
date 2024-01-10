import './src/utils/grammar.dart';
import 'src/lr0/LR0Fms.dart';
import 'src/lr0/LR0Table.dart';
import 'src/state_machine/FSM.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  var g = Grammar.fromFile('input.txt');
  print(g.followSets);
  print(g.firstSets);
  // LR0Table t = LR0Table(g);
  // t.log();
//  t.logToFile();
  //LR0Table t = LR0Table(g);
  //t.logToFile();

//  fsm = fsm.determinize();
  // fsm.DumpToDOT();
}
