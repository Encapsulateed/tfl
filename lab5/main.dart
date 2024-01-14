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
  List<Grammar> grammars = [];
  var g = Grammar.fromFile('input.txt');

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
  print(grammars.length);
  for (var gg in grammars) {
    LR0Parser pp = LR0Parser(gg);
    // total.add(pp.Parse(word));

    print(gg.rules);
  }
  bool answer = true;

  for (var ans in total) {
    if (ans == false) {
      answer = false;
      break;
    }
  }
  print(answer);
/*
  Stack<String> inputStack = Stack();
  Stack<String> tokenStack = Stack();
  Stack<String> actionStack = Stack();
  LR0Parser p = LR0Parser(g);

  tokenStack.push('0');
  inputStack.push('\$');
  p.stack_screens.add(tokenStack.copyStack());

  p.Parse(word);
  List<Stack<String>> stacks = [];*/
  //p.parseLR0_params(tokenStack, actionStack, inputStack, stacks, action_stacks);
}
