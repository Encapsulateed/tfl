import 'dart:collection';

import '../classes/GSSNode.dart';
import '../classes/GSStack.dart';
import '../utils/Action.dart';
import '../utils/grammar.dart';
import '../utils/stack.dart';
import 'LR0Table.dart';
import 'dart:io';

class LR0Parser {
  LR0Table _table = LR0Table.emtpy();
  Grammar _grammar = Grammar();
  int nodes_id_sequense = 0;

  Map<int, GSSNode<List<String>>> nodes = {};
  var stack = GSStackImpl<List<String>>();

  LR0Parser(Grammar grammar) {
    _grammar = grammar;
    _table = LR0Table(_grammar);
  }

  void Shift(GSSNode<List<String>> v, int state_id) {
    nodes[node_id_next()] = stack.push([(int.parse(v.value[0]) + 1).toString(), state_id.toString()], v);
  }

  void Reduce(GSSNode<List<String>> v, int rule_id, String x, List<GSSNode<List<String>>> P,Set<GSSNode<List<String>>> out) {
    var rule = _grammar.rules[rule_id];
    print("RULE");
    print(rule);
    print("LOOK UP");
    for (var v1_s in v.ancestors(rule.right.length)) {
      var act = _table.lr0_table[int.parse(v1_s.value[1])]?[rule.left]!;
      if (act?.length == 0) {
        continue;
      }
      print(v1_s.value);
      print(rule.left);
      var s_ss = act?[0].stateNumber;
      var i = int.parse(v.value[0]);
      var v_ss_value = [i.toString(), s_ss.toString()]; // Индексация верная
      var v_ss = stack.levels[i - 1].find(v_ss_value); // Индексация верная
      /*print("Level print");
      for (final l in stack.levels[i - 1].nodes.values) {
        print(l);
      }
      print("Level print ended");

       */
      print(i);
      print(v_ss_value);
      print(v_ss?.level);
      //stdin.readLineSync();

      if (v_ss != null) {
        if (v_ss.prev.values.contains(v1_s)) {
          //print("bro, im in do nothing");
          //stdin.readLineSync();
          continue;
        } else {
          //print("IM HERE - ITS MAIN ELSE");
          //stdin.readLineSync();
          for (final l in v_ss.prev.values) {
            if (l.value == v1_s.value && l.prev.values != v1_s.prev.values) {
              nodes[node_id_next()] = stack.push(v_ss_value, v1_s as GSSNode<List<String>>?); //vc_ss
              var act = _table.lr0_table[s_ss]?[x]!;
              for (var obj in act!) {
                if (obj.actionTitle.startsWith("r")) {
                  Reduce(nodes[node_id_curr()]!, obj.ruleNumber!, x, P, out);
                }
              }
            } else {
              //print("IM HERE, ITS ELSE UNDER MAIN");
              //stdin.readLineSync();
              v_ss = stack.push(v_ss_value, v1_s as GSSNode<List<String>>?);
              if (P.contains(v_ss)) {
                //print("IM HERE ITS UNDEREST ELSE MAIN LALALA");
                //stdin.readLineSync();
                nodes[node_id_next()] = stack.push(v_ss_value, v1_s as GSSNode<List<String>>?); //vc_ss
                var act = _table.lr0_table[s_ss]?[x]!;
                for (var obj in act!) {
                  if (obj.actionTitle.startsWith("r")) {
                    Reduce(nodes[node_id_curr()]!, obj.ruleNumber!, x, P,out);
                  }
                }
              }
            }
          }
        }
      } else {
        stack.pop(v);
        int id = node_id_next();
        nodes[id] = stack.push(v_ss_value, v1_s as GSSNode<List<String>>?, i);
        print('ЧЛЕН CБОКУ ${nodes[id]}');
        out.add(nodes[id]!);
      }
    }
  }

  bool parse(List<String> word_tokens, int n) {
    word_tokens.add("\$");
    nodes[node_id_curr()] = stack.push(["0", "0"]);
    int i = 1;
    var endcheck = 0;
    while (i < word_tokens.length + 1) {
      List<GSSNode<List<String>>> P = []; // БУКВА ПЭ
      List<GSSNode<List<String>>> levelCopy = List.from(stack.levels[i - 1].nodes.values);

      Set<GSSNode<List<String>>> reduced = {};

      for (GSSNode<List<String>> v in levelCopy) {
        var check = false;
        P.add(v);
        final act = _table.lr0_table[int.parse(v.value[1])]?[word_tokens[i - 1]]!;
        if (act?.length == 0) {
          endcheck++;
          continue;
        }
        print("act below");
        print(v.value[1]);
        print(word_tokens[i - 1]);
        print(act);
        print("---");

        if (n == i) {
          stack.printStack(nodes[0]!);
          stack.GSStoDot("Step n");
        }

        for (var obj in act!) {
          if (obj.actionTitle.startsWith("s")) {
            Shift(v, obj.stateNumber!);
            check = true;
            continue;
          }
        }

        stack.GSStoDot("TEST");

        for (var obj in act) {
          if (obj.actionTitle.startsWith("r")) {
            Reduce(v, obj.ruleNumber!, word_tokens[i - 1], P,reduced);
            print('Я СДЕЛАЛ РЕДУС И ПОЛУЧИЛ МНОЖЕСТВО:: ${reduced}');
          }
        }

        print("IM HERE");

        for (var obj in act) {
          if (obj.actionTitle == 'ACC') {
            GSSNode<List<String>> lastNode = stack.levels.last.nodes.values.last;
            nodes[node_id_next()] = stack.push(["ACC", "ACC"], lastNode);
            stack.printStack(nodes[0]!);
            stack.GSStoDot("chipichipi");
            return true;
          }
        }

        if (check) {
          i++;
        }

        stack.printStack(nodes[0]!);
      }

      if (endcheck == 2) {
        print("MISSION FAILED");
        stack.printStack(nodes[0]!);
        stack.GSStoDot("chipichipi");
        return false;
      }
    }

    return false;
  }

  bool classicParser(String word) {
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
          throw 'Пустая ячейка!';
        }

      } catch (e) {
        print('Ошибка $e');
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
  void p (int a, ){

  }
  void Log(int index) {
    String path = 'values/grammar_$index/';
    var directory = Directory(path);

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    this._table.logToFile('${path}table.txt');
    this._table.get().DumpToDOT('${path}fsm.txt');
  }

  Queue<GSSNode<List<String>>> frontier = Queue();
  Set<GSSNode<List<String>>> accepted = {};
  bool glrParser(List<String> tokens, {int n = 0 - 1}) {
    tokens.add('\$');
    nodes[0] = stack.push(["0", "0", "${tokens[0]}"]);
    frontier.add(nodes[0]!);
    var t = _table.lr0_table;
    int action_counter = 0;
    while (frontier.isEmpty == false) {
      var x = frontier.removeFirst();

      int x_index = int.parse(x.value[1]);
      int x_state = int.parse(x.value[0]);
      for (var action in t[x_state]![tokens[x_index]]!) {
        if (action.actionTitle.startsWith('s')) {
          int new_id = node_id_next();
          int goto = t[x_state]![tokens[x_index]]![0].stateNumber!;

          nodes[new_id] = stack.push([
            goto.toString(),
            (x_index + 1).toString(),
            "${tokens[x_index + 1]}"
          ], x);

          frontier.add(nodes[new_id]!);
          new_action_pass(action_counter, n);
          break;
        } else if (action.actionTitle.startsWith('r')) {
          var rule = _grammar.rules[action.ruleNumber!];
          int m = rule.right.length;
          String left = rule.left;
          var s = x.ancestors(m).toList()[m - 1];

          int new_id = node_id_next();

          int s_state = int.parse(s.value[0]);
          int goto = t[s_state]![left]![0].stateNumber!;

          nodes[new_id] = stack.push(
              [goto.toString(), x_index.toString(), "${tokens[x_index]}"],
              s as GSSNode<List<String>>);

          frontier.add(nodes[new_id]!);
          new_action_pass(action_counter, n);

          break;
        } else if (action.actionTitle.startsWith('ACC')) {
          nodes[node_id_next()] = stack.push(['acc', 'acc'], x);
          accepted.add(x);
          new_action_pass(action_counter, n);

          break;
        } else {
          print('err');
        }
      }
    }

    return accepted.length > 0;
  }

  void new_action_pass(int action_counter, int n) {
    ++action_counter;

    if (n != -1 && action_counter == n) {
      stack.GSStoDot('results/stack_dump_on_$action_counter');
    } else if (n == -1) {
      stack.GSStoDot('results/stack_dump_on_$action_counter');
    }
  }
}