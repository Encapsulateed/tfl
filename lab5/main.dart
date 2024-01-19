import './src/utils/grammar.dart';
import 'src/classes/GSSNode.dart';
import 'src/classes/GSStack.dart';
import 'src/lr0/LR0Fms.dart';
import 'src/lr0/LR0Table.dart';
import 'src/lr0/lr0Parser.dart';
import 'src/state_machine/FSM.dart';
import 'src/utils/Production.dart';
import 'src/utils/stack.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {

  if (arguments[1] == 'd') {
    List<Grammar> grammars = [];
    var g = Grammar.fromFile('input.txt');

    print("Searching for Conjunctive grammar");

    var rules_lst = [];
    for (var rule in g.rules) {
      if (rule.right.contains('&')) {
        var curr_left = rule.left;
        var rule_parts = rule.right.join('').toString().split('&');
        for (var part in rule_parts) {
          Production N = Production(curr_left, part.split(''));
          List<Production> curr_rules_copy = [...rules_lst];
          curr_rules_copy.add(N);
          grammars
              .add(Grammar.make(curr_rules_copy, g.nonTerminals, g.terminals));
        }
        continue;
      }
      rules_lst.add(rule);

      for (var gg in grammars) {
        gg.rules.add(rule);
      }
    }

    String word = arguments[0];
    List<bool> total = [];
    print("Total amount of grammars after separating the rules: ${grammars.length}\n");
    for (var gg in grammars) {
      LR0Parser pp = LR0Parser(gg);
      total.add(pp.Parse(word));
      print("${gg.rules}\n");
    }

    bool answer = true;

    for (var ans in total) {
      if (ans == false) {
        answer = false;
        break;
      }
    }

    print("\nResult: ");
    print(answer);
  } else {
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

    if (arguments.length == 3) {
      int n = int.parse(arguments[2]);
      print('STACK AT STEP ${n}\n=========================');

      print(getStrFromStack(p.stack_screens[n]));
      print('=========================');
    }

    // stack.GSStoDot('merged');
    stack1.GSStoDot('actions');
    stack2.GSStoDot('final');
  }
}
