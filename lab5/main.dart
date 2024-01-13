import './src/utils/grammar.dart';
import 'src/classes/GSSNode.dart';
import 'src/classes/GSStack.dart';
import 'src/lr0/LR0Fms.dart';
import 'src/lr0/LR0Table.dart';
import 'src/lr0/lr0Parser.dart';
import 'src/state_machine/FSM.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  GSStack<List<String>> tokenStack = GSStackImpl<List<String>>();
  Map<int, GSSNode<List<String>>> Nodes = {};

  var g = Grammar.fromFile('input.txt');

  LR0Parser p = LR0Parser(g);
  // print(p.Parse('abb'));
  print(p.ParseGss('n+n', 0));
}
