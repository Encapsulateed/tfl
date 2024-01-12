import '../classes/GSSNode.dart';
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

  Set<String> calculatePossibleParsingSets(String token_peek,
      String status_peek, String word, Action selectedAction) {
    return {};
  }

  bool Parse(String word) {
    Stack<String> inputStack = Stack();
    Stack<String> tokenStack = Stack();
    //Stack<String> statusStack = Stack();

    tokenStack.push('0');
    inputStack.push('\$');

    for (int i = word.length - 1; i >= 0; i--) {
      inputStack.push(word[i]);
    }

    while (true) {
      //    print(tokenStack.peek());
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

      if (a.actionTitle.startsWith('ACC')) {
        print('WORD ACCEPTED!');
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

  bool ParseGss(String word, int n) {
    return false;
  }

  /*  Stack<String> inputStack = Stack<String>();
    GSStack<String> tokenStack = GSStackImpl<String>();
    GSStack<String> statusStack = GSStackImpl<String>();

    Map<String, GSSNode<String>> tokenNodes = {};
    Map<String, GSSNode<String>> StatusNodes = {};

    StatusNodes["0"] = statusStack.push("0");

    inputStack.push('\$');

    for (int i = word.length - 1; i >= 0; i--) {
      inputStack.push(word[i]);
    }

    while (true) {
      for (var key in StatusNodes.keys) {
        var curr_node = StatusNodes[key];
        // Берём верхнее значение со стека Состояний
        int state_id = int.parse(StatusNodes["0"]);

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
          // Здесь надо ветвить стек
          print('КОНФЛИКТ!');
          //return false;
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
    }*/
}
