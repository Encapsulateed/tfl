import 'dart:ffi';
import 'dart:io';

import '../classes/GSSNode.dart';
import '../classes/GSStack.dart';
import '../utils/Action.dart';
import '../utils/grammar.dart';
import '../utils/stack.dart';
import 'LR0Table.dart';

class LR0Parser {
  LR0Table _table = LR0Table.emtpy();
  Grammar _grammar = Grammar();
  int nodes_id_sequense = 0;
  List<String> ActionProcess = [];
  List<String> TokenProcess = [];
  List<String> inputProcess = [];
  List<String> statusProcess = [];

  LR0Parser(Grammar grammar) {
    _grammar = grammar;
    _table = LR0Table(_grammar);

    _table.logToFile();
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

  void print_stack(Map<int, GSSNode<List<String>>> Nodes) {
    print('STACK END\n===========================');
    for (var node in Nodes.values) {
      if (node.value[0] != 'null') print('${node.value} ${node.prev}');
    }
    print('STACK START\n===========================');
  }

  bool ParseGss(String word, int n) {
    Stack<String> inputStack = Stack();
    GSStack<List<String>> tokenStack = GSStackImpl<List<String>>();
    Map<int, GSSNode<List<String>>> Nodes = {};

    // В вершинах лежит пара <Value; позиция разбора>
    Nodes[0] = tokenStack.push(["0", "0"])..my_id = 0;
    node_id_next();
    inputStack.push('\$');

    for (int i = word.length - 1; i >= 0; i--) {
      inputStack.push(word[i]);
    }

    while (true) {
      //for (var nodeId in getNotNull(Nodes)) {

      int nodeId = node_id_curr() - 1;
      var curr_node = Nodes[nodeId]!;
      if (curr_node.value[0] == 'null') {
        return false;
        break;
      }
      int curr_state = int.parse(curr_node.value[0]);
      int curr_pos = int.parse(curr_node.value[1]);
      print(curr_node.value);
      String curr_input_token = inputStack.toList().reversed.toList()[curr_pos];

      List<Action> action = [];
      print(curr_input_token);
      print_stack(Nodes);
      try {
        action = _table.lr0_table[curr_state]![curr_input_token]!;
        if (action.length == 0) {
          throw Exception();
        }
      } catch (e) {
        curr_node.value[0] = "null";

        continue;
      }

      // Если в ячейке таблицы больше 1 действия => начинаем ветвление
      if (action.length > 1) {
      } else {
        var curr_action = action[0];
        if (curr_action.actionTitle.startsWith('ACC')) {
          print('WORD ACCEPTED!');
          return true;
        } else if (curr_action.actionTitle.startsWith('s')) {
          int f_id = node_id_next();
          int s_id = node_id_next();

          List<String> pair = ["${curr_input_token}", "${curr_pos++}"];
          Nodes[f_id] = tokenStack.push([...pair], curr_node)..my_id = f_id;

          pair = ["${curr_action.stateNumber!}", "${curr_pos++}"];
          Nodes[s_id] = tokenStack.push([...pair], Nodes[f_id])..my_id = s_id;
        } else if (curr_action.actionTitle.startsWith('r')) {
          var rule = _grammar.rules.toList()[curr_action.ruleNumber!];
          var nodeForPop = Nodes[node_id_curr() - 1]!;

          for (int i = (rule.right.length - 1); i >= 0; i--) {
            var prev =
                nodeForPop.prev.values.toList()[0] as GSSNode<List<String>>;
            nodeForPop.value[0] = 'null';

            tokenStack.pop(nodeForPop);

            nodeForPop = prev.prev.values.toList()[0] as GSSNode<List<String>>;
            prev.value[0] = 'null';
            tokenStack.pop(prev);
          }
          int f_id = node_id_next();
          int s_id = node_id_next();

          int state_id = int.parse(nodeForPop.value[0]);

          List<String> pair = ["${rule.left}", "${curr_pos}"];
          Nodes[f_id] = tokenStack.push([...pair], Nodes[nodeForPop.my_id])
            ..my_id = f_id;

          pair = [
            "${_table.lr0_table[state_id]![rule.left]![0].toString()}",
            "${curr_pos}"
          ];
          Nodes[s_id] = tokenStack.push(pair, Nodes[f_id])..my_id = s_id;
        }
      }
      //}
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
}
