import './src/utils/grammar.dart';
import 'src/lr0/LR0Fms.dart';
import 'src/lr0/LR0Table.dart';
import 'src/lr0/lr0Parser.dart';
import 'src/state_machine/FSM.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  var g = Grammar.fromFile('input.txt');

  LR0FMS f = LR0FMS(g);
  f.DumpToDOT();
  //LR0Parser p = LR0Parser(g);
  // print(p.Parse('n+n'));
}
