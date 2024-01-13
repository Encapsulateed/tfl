import './src/utils/grammar.dart';
import 'src/classes/GSSNode.dart';
import 'src/classes/GSStack.dart';
import 'src/lr0/LR0Fms.dart';
import 'src/lr0/LR0Table.dart';
import 'src/lr0/lr0Parser.dart';
import 'src/state_machine/FSM.dart';
import 'src/utils/stack.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  var g = Grammar.fromFile('input.txt');
  Stack<String> inputStack = Stack();
  Stack<String> tokenStack = Stack();
  Stack<String> actionStack = Stack();

  tokenStack.push('0');
  inputStack.push('\$');
  String word = "(n+n)*n";
  for (int i = word.length - 1; i >= 0; i--) {
    inputStack.push(word[i]);
  }

  LR0Parser p = LR0Parser(g);

  List<Stack<String>> stacks = [];
  List<Stack<String>> action_stacks = [];
  //print(p.Parse('(n+n*n)'));
  p.parseLR0_params(tokenStack, actionStack, inputStack, stacks, action_stacks);
  print(stacks.length);
  for (var i = 0; i < stacks.length; i++) {
    //print(getStrFromStack(action_stacks[i], reverse: false));
    // print(getStrFromStack(stacks[i], reverse: false));
  }
}
