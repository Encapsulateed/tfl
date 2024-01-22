import '../classes/GSSNode.dart';
import '../classes/GSStack.dart';
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

  // Новый шифт

  //Что делает state_id?
  void Shift(GSSNode<List<String>> v, int state_id) {
    nodes[node_id_next()] = stack.push([(int.parse(v.value[0]) + 1).toString(), state_id.toString()], v);
  }

  // Новый редьюс

  void Reduce(GSSNode<List<String>> v, int rule_id, String x, List<GSSNode<List<String>>> P) {
    var rule = _grammar.rules[rule_id];
    print("RULE");
    print(rule);
    for (var v1_s in v.ancestors(rule.right.length)) {
      var act = _table.lr0_table[int.parse(v1_s.value[1]) + 1]?[rule.left]!;
      //print(v1_s.value[1]);
      //print(rule.left);
      var s_ss = act?[0].stateNumber;
      var i = int.parse(v.value[0]);
      var v_ss_value = [(i - 1).toString(), s_ss.toString()];
      var v_ss = stack.levels[i - 1].find(v_ss_value);

      if (v_ss != null) {
        if (v_ss.prev.values.contains(v1_s)) {
          continue;
        } // ?? Вроде как без элза, но мб книжка не сделала отступ
        for (final l in v_ss.prev.values) {
          if (l.value == v1_s.value && l.prev.values != v1_s.prev.values) {
            //Надо ли пушить? Ну вроде надо
            nodes[node_id_next()] =
                stack.push(v_ss_value, v1_s as GSSNode<List<String>>?); //vc_ss
            var act =
                _table.lr0_table[int.parse(nodes[node_id_curr()]!.value[0])]
                    ?[x]!; //Точно ли x посылаем?
            for (var obj in act!) {
              if (obj.actionTitle.startsWith("r")) {
                Reduce(nodes[node_id_curr()]!, obj.ruleNumber!, x, P);
              }
            }
          } else {
            v_ss = stack.push(v_ss_value, v1_s as GSSNode<List<String>>?);
            if (P.contains(v_ss)) {
              nodes[node_id_next()] = stack.push(
                  v_ss_value, v1_s as GSSNode<List<String>>?); //vc_ss
              var act =
                  _table.lr0_table[int.parse(nodes[node_id_curr()]!.value[0])]
                      ?[x]!; //Точно ли x посылаем?
              for (var obj in act!) {
                if (obj.actionTitle.startsWith("r")) {
                  Reduce(nodes[node_id_curr()]!, obj.ruleNumber!, x, P);
                }
              }
            }
          }
        }
      } else {
        nodes[node_id_next()] = stack.push(v_ss_value, v1_s as GSSNode<List<String>>?);
      }
    }
  }

  bool parse(List<String> word_tokens) {
    word_tokens.add("\$");
    nodes[node_id_curr()] = stack.push(["0", "0"]);
    _table.logToFile("aboba");

    for (int i = 1; i < word_tokens.length + 1; i++) {
      List<GSSNode<List<String>>> P = []; // БУКВА ПЭ
      List<GSSNode<List<String>>> levelCopy = List.from(stack.levels[i - 1].nodes.values);

      for (GSSNode<List<String>> v in levelCopy) {
        P.add(v);
        final act = _table.lr0_table[int.parse(v.value[0])]?[word_tokens[i - 1]]!;
        print("act below");
        print(int.parse(v.value[0]));
        print(word_tokens[i - 1]);
        print(act);
        print("---");
        for (var obj in act!) {
          print("obj info");
          print(obj.actionTitle);
          print("---");
          if (obj.actionTitle == 'ACC') {
            return true;
          }

          if (obj.actionTitle.startsWith("s")) {
            Shift(v, obj.stateNumber!);
          }

          if (obj.actionTitle.startsWith("r")) {
            Reduce(v, obj.ruleNumber!, word_tokens[i], P);
          }
        }
      }

      if (i > stack.levels.length - 1) {
        stack.printStack(nodes[0]!);
        return false;
      }
    }

    return false;
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

  void Log(int index) {
    String path = 'values/grammar_$index/';
    var directory = Directory(path);

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    this._table.logToFile('${path}table.txt');
    this._table.get().DumpToDOT('${path}fsm.txt');
  }
}
