import './src/utils/grammar.dart';
import 'src/lr0/base/LR0Table.dart';
// import 'src/lr0/base/LR0fms.dart';

void main(List<String> arguments) {
  Grammar g = Grammar.fromFile('input.txt');
  // LR0FMS fms = LR0FMS(g);
  // fms.DumpToDOT();
  LR0Table t = LR0Table(g);
  //print(g.toString());
  t.log();
}
