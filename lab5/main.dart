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
  LR0Parser p = LR0Parser(g);

  tokenStack.push('0');
  inputStack.push('\$');
  p.stack_screens.add(tokenStack.copyStack());

  String word = arguments[0];

  for (int i = word.length - 1; i >= 0; i--) {
    inputStack.push(word[i]);
  }

  List<Stack<String>> stacks = [];
  List<Stack<String>> action_stacks = [];
  p.parseLR0_params(tokenStack, actionStack, inputStack, stacks, action_stacks);
  print(getStrFromStack(action_stacks[0], reverse: false));
  GSStack<String> stack = GSStackImpl();
  Map<int, GSSNode<String>> Nodes = {};

  int id = 0;

  for (var stackScreen in p.stack_screens) {
    for (var s in stackScreen.toList().toList()) {
      Nodes[id] = stack.push(s, Nodes[id - 1]);
      id++;
    }
  }
  id = 0;
  GSStack<String> stack1 = GSStackImpl();
  Map<int, GSSNode<String>> Nodes1 = {};
  for (var stackScreen in action_stacks) {
    for (var s in stackScreen.toList().toList()) {
      Nodes1[id] = stack1.push(s, Nodes1[id - 1]);
      id++;
    }
  }
  id = 0;
  GSStack<String> stack2 = GSStackImpl();
  Map<int, GSSNode<String>> Nodes2 = {};
  for (var stackScreen in stacks) {
    for (var s in stackScreen.toList().toList()) {
      Nodes2[id] = stack2.push(s, Nodes2[id - 1]);
      id++;
    }
  }
  //print(getStrFromStack(stacks[0], reverse: false));

  if (arguments.length == 2) {
    int n = int.parse(arguments[1]);
    print('STACK AT STEP ${n}\n=========================');

    print(getStrFromStack(p.stack_screens[n]));
    print('=========================');
  }

  // stack.GSStoDot('merged');
  stack1.GSStoDot('actions');
  stack2.GSStoDot('final');
}
