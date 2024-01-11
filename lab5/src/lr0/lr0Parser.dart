import '../classes/GSStack.dart';
import '../utils/Action.dart';
import '../utils/grammar.dart';
import '../utils/stack.dart';
import 'LR0Table.dart';

class LR0Parser {
  LR0Table _table = LR0Table.emtpy();
  Grammar _grammar = Grammar();
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
    Stack<String> statusStack = Stack();

    statusStack.push('0');
    inputStack.push('\$');

    for (int i = word.length - 1; i >= 0; i--) {
      inputStack.push(word[i]);
    }

    while (true) {
      int state_id = int.parse(statusStack.peek());
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

      if (a.actionTitle.startsWith('ACC')) {
        print('WORD ACCEPTED!');
        return true;
      } else if (a.actionTitle.startsWith('s')) {
        statusStack.push(a.stateNumber!.toString());
        tokenStack.push(inputStack.peek());
        inputStack.pop();
      } else if (a.actionTitle.startsWith('r')) {
        var rule = _grammar.rules.toList()[a.ruleNumber!];

        for (int i = rule.right.length - 1; i >= 0; i--) {
          if (rule.right[i] != tokenStack.peek()) {
            break;
          }
          tokenStack.pop();
          statusStack.pop();
        }
        tokenStack.push(rule.left);

        statusStack.push(_table
            .lr0_table[int.parse(statusStack.peek())]![tokenStack.peek()]![0]
            .toString());
      }
    }
  }

  bool ParseGss(String word, int n) {
    GSStack<String> inputStack = GSStackImpl<String>();
    GSStack<String> tokenStack = GSStackImpl<String>();
    GSStack<String> statusStack = GSStackImpl<String>();

    statusStack.push('0');
    inputStack.push('\$');

    for (int i = word.length - 1; i >= 0; i--) {
      inputStack.push(word[i]);
    }
    print(inputStack);
    return false;
  }
}
