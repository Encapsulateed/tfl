import '../../utils/Action.dart';
import '../../utils/grammar.dart';
import '../../utils/stack.dart';
import 'LR0Fms.dart';
import 'LR0Table.dart';
import 'dart:collection';

class LR0Parser {
  Grammar grammar = Grammar();
  LR0FMS fms = LR0FMS.empty();
  LR0Table table = LR0Table.empty();

  LR0Parser(Grammar g) {
    grammar = g;
    fms = LR0FMS(grammar);
    table = LR0Table(grammar);
  }

  void parse(String input) {}

  void LROParseGss(String word, int n) {}

  String getStrFromStack(Stack<String> inputStack, {bool reverse = true}) {
    StringBuffer sb = StringBuffer();
    List<String> tokens = inputStack.toList();

    if (reverse) {
      for (int i = tokens.length - 1; i >= 0; i--) {
        sb.write("${tokens[i]} ");
      }
    } else {
      for (int i = 0; i < tokens.length; i++) {
        sb.write("${tokens[i]} ");
      }
    }

    return sb.toString();
  }
}
