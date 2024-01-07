import './src/utils/grammar.dart';
import 'src/lr0/base/LR0Table.dart';
import 'src/lr0/base/lr0Parser.dart';
import 'src/state_machine/FSM.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  var g = Grammar.fromFile('input.txt');
  // LR0Parser parser = LR0Parser(g);
  // print(parser.parse('()'));
  var t = LR0Table(g);
  t.logToFile();
}
