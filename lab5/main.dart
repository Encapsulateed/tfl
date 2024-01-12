import './src/utils/grammar.dart';
import 'src/classes/GSSNode.dart';
import 'src/classes/GSStack.dart';
import 'src/lr0/LR0Fms.dart';
import 'src/lr0/LR0Table.dart';
import 'src/lr0/lr0Parser.dart';
import 'src/state_machine/FSM.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  GSStack<String> statusStack = GSStackImpl<String>();
  Map<String, GSSNode<String>> StatusNodes = {};

  StatusNodes["0"] = statusStack.push("0");
  StatusNodes["1"] = statusStack.push("1", StatusNodes["0"]);
  StatusNodes["2"] = statusStack.push("2", StatusNodes["1"]);
  StatusNodes["3"] = statusStack.push("3", StatusNodes["1"]);
  StatusNodes["4"] = statusStack.push("4", StatusNodes["2"]);
  StatusNodes["4"] = statusStack.push("4", StatusNodes["3"]);

  // print(StatusNodes["2"]!.degPrev());
  var g = Grammar.fromFile('input.txt');

  LR0Parser p = LR0Parser(g);
  print(p.Parse('(n+n)'));
}
