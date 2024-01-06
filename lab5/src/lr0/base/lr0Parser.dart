import '../../utils/grammar.dart';
import '../../utils/stack.dart';
import 'LR0Fms.dart';
import 'LR0Table.dart';

class LR0Parser {
  Grammar grammar = Grammar();
  LR0FMS fms = LR0FMS.empty();
  LR0Table table = LR0Table.empty();
  List<String> process = [];
  LR0Parser(Grammar g) {
    grammar = g;
    fms = LR0FMS(grammar);
    table = LR0Table(grammar);
  }

  void LR0Parse(String word) {
    Stack<String> inputStack = Stack<String>();
    Stack<String> tokenStack = Stack<String>();
    Stack<String> statusStack = Stack<String>();

    statusStack.push("0");
    // $ - конечный символ
    inputStack.push("'\$\'");

    for (int i = word.length - 1; i >= 0; i--) {
      inputStack.push(word[i]);
    }

    while (true) {
      //statusStack.add
      String data = "";
      if (data == '') {
        statusStack.push('ACCESS');
        break;
      }
    }
  }

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
