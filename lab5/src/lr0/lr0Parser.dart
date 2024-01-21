import '../classes/GSSNode.dart';
import '../utils/Action.dart';
import '../utils/grammar.dart';
import '../utils/stack.dart';
import 'LR0Table.dart';

class LR0Parser {
  LR0Table _table = LR0Table.emtpy();
  Grammar _grammar = Grammar();
  int nodes_id_sequense = 0;

  List<Stack<String>> stack_screens = [];
  Map<int, GSSNode<List<String>>> Nodes = {};

  LR0Parser(Grammar grammar) {
    _grammar = grammar;
    _table = LR0Table(_grammar);

    _table.logToFile();
  }

  void parseLR0_params(
      Stack<String> tokenStack,
      Stack<String> actionStack,
      Stack<String> inputStack,
      List<Stack<String>> stacks,
      List<Stack<String>> action_stacks) {
    while (true) {
      int state_id = int.parse(tokenStack.peek());

      List<Action> action = [];
      try {
        action =
            _table.lr0_table[state_id]![inputStack.peek()]!.toSet().toList();
        if (action.length == 0) {
          throw Exception();
        }
      } catch (e) {
        print('Ошибка');
        actionStack.push('[ERR because of ${inputStack.peek()}]');
        stacks.add(tokenStack);
        stack_screens.add(tokenStack.copyStack());
        action_stacks.add(actionStack);
        return;
      }

      if (action.length > 1) {
        for (var act in action) {
          var new_stack = tokenStack.copyStack();
          var new_input_stack = inputStack.copyStack();
          var new_action_stack = actionStack.copyStack();

          if (act.actionTitle.startsWith('s')) {
            shift(new_stack, new_input_stack, act);
            new_action_stack
                .push('[${act.actionTitle} sym: ${inputStack.peek()}]');
            stack_screens.add(new_stack.copyStack());

            parseLR0_params(new_stack, new_action_stack, new_input_stack,
                stacks, action_stacks);
          } else if (act.actionTitle.startsWith('r')) {
            reduce(new_stack, act);
            stack_screens.add(new_stack.copyStack());

            actionStack.push(
                '[${act.actionTitle} (${_grammar.rules[act.ruleNumber!].toString().replaceAll('\n', '')}) sym: ${inputStack.peek()} ]');

            parseLR0_params(new_stack, new_action_stack, new_input_stack,
                stacks, action_stacks);
          }
        }
        return;
      }
      var a = action[0];

      if (a.actionTitle.startsWith('ACC')) {
        print('WORD ACCEPTED!');
        actionStack.push('[ACC]');

        //print('${getStrFromStack(actionStack, reverse: false)} [${inputStack.peek()}]');
        stacks.add(tokenStack);
        stack_screens.add(tokenStack.copyStack());
        action_stacks.add(actionStack);

        return;
      } else if (a.actionTitle.startsWith('s')) {
        shift(tokenStack, inputStack, a);
        actionStack.push(
            '[${a.actionTitle} sym: ${inputStack.peek()}]'); // stack_screens.add(tokenStack.copyStack());
      } else if (a.actionTitle.startsWith('r')) {
        reduce(tokenStack, a);

        actionStack.push(
            '[${a.actionTitle} (${_grammar.rules[a.ruleNumber!].toString().replaceAll('\n', '')}) sym: ${inputStack.peek()}]');
      }
      stack_screens.add(tokenStack.copyStack());
    }
  }

  void shift(
      Stack<String> tokenStack, Stack<String> inputStack, Action action) {
    tokenStack.push(inputStack.peek());
    tokenStack.push(action.stateNumber!.toString());
    inputStack.pop();
  }

  void reduce(Stack<String> tokenStack, Action action) {
    var rule = _grammar.rules.toList()[action.ruleNumber!];

    for (int i = rule.right.length - 1; i >= 0; i--) {
      tokenStack.pop();
      tokenStack.pop();
    }

    int state_id = int.parse(tokenStack.peek());
    tokenStack.push(rule.left);

    tokenStack.push(_table.lr0_table[state_id]![rule.left]![0].toString());
  }

  bool Parse(String word) {
    Stack<String> inputStack = Stack();
    Stack<String> tokenStack = Stack();

    tokenStack.push('0');
    inputStack.push('\$');

    for (int i = word.length - 1; i >= 0; i--) {
      inputStack.push(word[i]);
    }

    while (true) {
      int state_id = int.parse(tokenStack.peek());

      List<Action> action = [];
      try {
        action = _table.lr0_table[state_id]![inputStack.peek()]!;
        if (action.length == 0) {
          throw Exception();
        }
      } catch (e) {
        print('Ошибка');
        return false;
      }

      if (action.length > 1) {
        print('КОНФЛИКТ!');
        return false;
      }

      var a = action[0];
      print(
          '${getStrFromStack(tokenStack, reverse: false)} [${inputStack.peek()}]');

      if (a.actionTitle.startsWith('ACC')) {
        print('WORD ACCEP TED!');
        return true;
      } else if (a.actionTitle.startsWith('s')) {
        tokenStack.push(inputStack.peek());
        tokenStack.push(a.stateNumber!.toString());

        inputStack.pop();
      } else if (a.actionTitle.startsWith('r')) {
        var rule = _grammar.rules.toList()[a.ruleNumber!];

        for (int i = rule.right.length - 1; i >= 0; i--) {
          tokenStack.pop();
          tokenStack.pop();
        }

        print('After reduce: ${tokenStack.peek()}');

        state_id = int.parse(tokenStack.peek());
        tokenStack.push(rule.left);

        tokenStack.push(_table.lr0_table[state_id]![rule.left]![0].toString());
      }
    }
  }

  int node_id_next() {
    return nodes_id_sequense++;
  }

  int node_id_curr() {
    return nodes_id_sequense;
  }

  int node_id_roll_back() {
    return nodes_id_sequense--;
  }

  void print_stack(Map<int, GSSNode<List<String>>> Nodes) {
    print('STACK END\n===========================');
    for (var node in Nodes.values) {
      if (node.value[0] != 'null') print('${node.value} ${node.prev}');
    }
    print('STACK START\n===========================');
  }

  bool ParseGss(String word, int n) {
    List<Stack<String>> tokenStacks = [];

    return false;
  }

  void getPrevSets(
      GSSNode<List<String>> node, Set<GSSNode<List<String>>> all_prev) {
    if (node.my_id == 0) {
      return;
    }
    all_prev.addAll(node.prevSetValued());

    all_prev.map((e) => getPrevSets(e, all_prev));
  }
}

List<int> getNotNull(Map<int, GSSNode<List<String>>> nodes) {
  var for_out = <int>[];

  for (var key in nodes.keys) {
    if (nodes[key]!.value[0] != 'null') {
      for_out.add(key);
    }
  }
  return for_out;
}

String getStrFromStack(Stack<String> inputStack, {bool reverse = true}) {
  StringBuffer sb = StringBuffer();
  List<String> tokens = inputStack.toList();

  if (reverse) {
    for (int i = tokens.length - 1; i >= 0; i--) {
      sb.write('${tokens[i]} ');
    }
  } else {
    for (int i = 0; i < tokens.length; i++) {
      sb.write('${tokens[i]} ');
    }
  }

  return sb.toString();
}
