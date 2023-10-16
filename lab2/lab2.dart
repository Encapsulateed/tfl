import 'dart:io';
// import 'Fms.dart';
import 'src/fms/TestingFms.dart';
import 'functions.dart';

List<String> parseRegex(String regex) {
  List<String> subRegexes = [];

  regex = regex.replaceAll(RegExp(r'\*+'), '*');
  regex = regex.replaceAll(RegExp(r'\|+'), '|');
  regex = regex.replaceAll(RegExp(r'\++'), '');
  //regex = regex.replaceAll('*)*', ')*');
  regex = regex.replaceAll('*))*', '))*');

  for (var i = 0; i < regex.length; i++) {
    // Смотрим является ли первый символ началом регулярки в скобках
    bool in_group = regex[i] == '(';
    String subRegex = '';
    try {
      if (in_group) {
        subRegex = '(';
        int group_balance = 1;
        //Бежим по группе пока не дойдём до ее конца
        while (group_balance != 0) {
          i++;
          subRegex += regex[i];

          // Любая скобка, очевидно, должна закрыться.
          if (regex[i] == '(') {
            group_balance++;
          }
          if (regex[i] == ')') {
            group_balance--;
          }

          if (regex[i + 1] == '*') {
            subRegex = "$subRegex*";
            i++;
          }
        }
        var srCopy = '';

        if (getRegexinBrakets(subRegex).length != 2) {
          for (var i = 0; i < subRegex.length; i++) {
            if (getRegexAlf(subRegex).contains(subRegex[i])) {
              if (i + 1 < subRegex.length && subRegex[i + 1] == '*') {
                srCopy += '(${subRegex[i]}*)';
                i++;
              } else {
                srCopy += '(${subRegex[i]})';
              }
            } else {
              if (i + 1 < subRegex.length && subRegex[i + 1] == '*') {
                srCopy += '${subRegex[i]}*';
                i++;
              } else {
                srCopy += subRegex[i];
              }
            }
          }
          subRegex = srCopy;
        }
        if (subRegex != '(' &&
            subRegex != ')' &&
            subRegex != '*' &&
            subRegex != '**') {
          if (regex[i + 1] == '|' || regex[i + 1] == '#') {
            subRegex = '$subRegex';

            subRegex += regex[i + 1];
            i++;
          } else {
            subRegex = '$subRegex';

            subRegex += '+';
          }
        }
      } else {
        subRegex = "(${regex[i]})";

        if (regex[i + 1] == '*') {
          subRegex = "(${regex[i]}*)";
          i++;
        }

        if (subRegex != '(' &&
            subRegex != ')' &&
            subRegex != '*' &&
            subRegex != '**') {
          if (regex[i + 1] == '|' || regex[i + 1] == '#') {
            subRegex = '$subRegex';
            subRegex += regex[i + 1];

            i++;
          } else {
            // + == конкатенация
            subRegex = '$subRegex';
            subRegex += '+';
          }
        }
      }
    } catch (Exeption) {
      // Здесь значит, что мы вышли за пределы строки
      // Так легче всего отслеживать
    }
    if (subRegex != '(' &&
        subRegex != ')' &&
        subRegex != '*' &&
        subRegex != '**') {
      subRegexes.add(SimplifyKlini(subRegex));
    }
  }
  if (subRegexes.length != 0) {
    var lastItem = subRegexes[subRegexes.length - 1];
    if (lastItem.endsWith('+')) {
      lastItem = lastItem.substring(0, lastItem.length - 1);
    }
    subRegexes[subRegexes.length - 1] = lastItem;
  }
  subRegexes =
      subRegexes.map((e) => e = e.replaceAll(RegExp(r'\*+'), '*')).toList();
  subRegexes =
      subRegexes.map((e) => e = e.replaceAll(RegExp(r'\|+'), '|')).toList();
  subRegexes = subRegexes
      .map((e) => e = (e[e.length - 1] == '*' ? "(${e})" : e))
      .toList();

  // subRegexes = subRegexes.map((e) => e = e.replaceAll('*))*', '*))')).toList();

  return subRegexes;
}

// Функция поиска минимальной конкатенации регулярных выражений, такой что
// пустая строка НЕ будет содержаться в данной конкатенации
String MainSymplify(String regex) {
  var prev = '';
  var curr = regex;

  while (prev != curr) {
    prev = curr;
    curr = BaseSymplify(curr);
    //print(curr);
  }
  return curr;
}

String BaseSymplify(String regex) {
 

  regex = regex.replaceAll('(', '');
  regex = regex.replaceAll(')', '');

  regex = regex.replaceAll('[', '(');
  regex = regex.replaceAll(']*', ')*');

  var items = parseRegex(regex);
  var prevItems = [];
   regex = regex.replaceAllMapped(RegExp( r'\((.)\)\*'), (match) {
    String x = match.group(1) ?? ''; // Захваченный символ x
    return '($x*)';
  });
  print(regex);
  // 1) Конкатенации
  // 2) Шафлы
  // 3) Альтернативы
  while (!areListsEqual(items, prevItems)) {
    print(items);

    for (int i = 0; i < items.length - 1; i++) {
      var item = items[i];
      if (item.endsWith('+')) {
        var rightOperand = '';
        item = item.substring(0, item.length - 1);

        var nextItem = items[i + 1];
        if (nextItem.endsWith('+') ||
            nextItem.endsWith('|') ||
            nextItem.endsWith('#')) {
          rightOperand = nextItem[nextItem.length - 1];
          nextItem = nextItem.substring(0, nextItem.length - 1);
        }

        var itemIn = getRegexinBrakets(item);
        nextItem = getRegexinBrakets(nextItem);
        if (itemIn == 'ε') {
          items[i] = '';
        }
        if (itemIn == '∅') {
          items[i + 1] = '';
          items[i] = items[i]
              .replaceRange(items[i].length - 1, items[i].length, rightOperand);
          i++;
        }
        if (nextItem == 'ε') {
          items[i + 1] = '';
          items[i] = items[i]
              .replaceRange(items[i].length - 1, items[i].length, rightOperand);
          i++;
        }
        if (nextItem == '∅') {
          items[i] = '';
        }
      }
    }

    for (int i = 0; i < items.length - 1; i++) {
      var item = items[i];
      if (item.endsWith('#')) {
        var rightOperand = '';
        item = item.substring(0, item.length - 1);
        var nextItem = items[i + 1];
        if (nextItem.endsWith('+') ||
            nextItem.endsWith('|') ||
            nextItem.endsWith('#')) {
          rightOperand = nextItem[nextItem.length - 1];
          nextItem = nextItem.substring(0, nextItem.length - 1);
        }

        var itemIn = getRegexinBrakets(item);
        nextItem = getRegexinBrakets(nextItem);

        if (itemIn == 'ε') {
          items[i] = '';
        }
        if (itemIn == '∅') {
          items[i + 1] = '';
          items[i] = items[i]
              .replaceRange(items[i].length - 1, items[i].length, rightOperand);
          i++;
        }
        if (nextItem == 'ε') {
          items[i + 1] = '';
          items[i] = items[i]
              .replaceRange(items[i].length - 1, items[i].length, rightOperand);
          i++;
        }
        if (nextItem == '∅') {
          items[i] = '';
        }
      }
    }

    for (int i = 0; i < items.length - 1; i++) {
      var item = items[i];
      if (item.endsWith('|')) {
        var rightOperand = '';
        item = item.substring(0, item.length - 1);
        var nextItem = items[i + 1];
        if (nextItem.endsWith('+') ||
            nextItem.endsWith('|') ||
            nextItem.endsWith('#')) {
          rightOperand = nextItem[nextItem.length - 1];
          nextItem = nextItem.substring(0, nextItem.length - 1);
        }

        var itemIn = getRegexinBrakets(item);
        nextItem = getRegexinBrakets(nextItem);

        if (itemIn == '∅') {
          items[i] = '';
        }

        if (nextItem == '∅') {
          items[i + 1] = '';
          items[i] = items[i]
              .replaceRange(items[i].length - 1, items[i].length, rightOperand);
          i++;
        }
        print('CMP $itemIn $nextItem');
        if (itemIn == nextItem) {
          items[i + 1] = '';
          items[i] = items[i]
              .replaceRange(items[i].length - 1, items[i].length, rightOperand);
          i++;
        }
      }
    }
    prevItems = items.toList();
    items.removeWhere((element) => element == '');
    stdin.readLineSync();
  }
  items = items.map((e) => e.replaceAll('+', '')).toList();

  return items.join();
}

String derivative(String regex, String char) {
  var regexes = parseRegex(regex);
  regex = buildRegex(regexes[0], regexes);

  if (regexes.length == 0) {
    regexes = parseRegex(regex);
    regex = buildRegex(regexes[0], regexes);
  }

  if (regex.isEmpty) {
    return 'ε';
  }
  if (regex.length == 1) {
    if (regex == char) {
      return 'ε';
    } else {
      return '∅';
    }
  } else if (regex[0] == char && regex[1] != '*') {
    return 'ε' + regex.substring(1, regex.length);
  } else {
    String left = '';
    String right = '';

    bool in_group = regex[0] == '(';
    if (in_group) {
      left = regex[0];
      int balance = 1;
      int i = 1;

      // Находим первую группу регулярок (левую)
      // Вторая определиться как исходная регулярка без первой группы

      while (balance != 0) {
        if (regex[i] == '(') {
          balance++;
        }
        if (regex[i] == ')') {
          balance--;
        }

        left += regex[i];
        i++;
      }
      // print('$left');
      if (i < regex.length && regex[i] == '*') {
        left = '$left*';
        i++;
      }
      // print('$left');

      right = regex.substring(i, regex.length);
    } else {
      left = regex;
    }

    //  print('LEFT ' + left);
    // print('RIGHT ' + right);

    if (right != '' && right != '*') {
      String op = right[0];
      right = right.substring(1, right.length);

      //print('EXPRESSION $left $op $right');

      //   stdin.readLineSync();
      //print('EXPRESSION $left $op $right');

      if (op == '+' || op == '#' || op == '|') {
        if (op == '+') {
          if (isEpsilonInRegex(left)) {
            return "(((${derivative(left, char)})((${right}))|(${derivative(right, char)})))";
          } else {
            return "((${derivative(left, char)})(${right}))";
          }
        }
        if (op == '|') {
          return '((${derivative(left, char)})|(${derivative(right, char)}))';
        }
        if (op == '#') {
          return '(((${derivative(left, char)})#(${right}))|((${left})#(${derivative(right, char)})))';
        }
      }
    }
    //Значит это регулярка без бинарной операции
    else {
      if (left.startsWith('(') && left.endsWith(')')) {
        left = left.substring(1, left.length - 1);
        return derivative(left, char);
      } else if (left.endsWith('*')) {
        var no_klini = left.substring(0, left.length - 1);
        //print('LEFT ' + left);
        if (no_klini.length == 1) {
          // return '${no_klini}*';
        }
        return "(${derivative(no_klini, char)})[${no_klini}]*";
      }
    }
  }
  return derivative(regex, char);
}

void main() {
  
  // Регулярное выражение в виде строки для поиска и замены

  // Заменяем строки


  // String regex = '(a*#a)|a*|a*|a*';
  String regex = '((a))*#(a)|(a*)';
  // print(parseRegex(regex));
  regex = InitRegex(regex);
  print(regex);
  var da = derivative(regex, 'a');
  print(da);
  // var db = derivative(regex, 'b');
  // print('DERIVATIVE ' + da);
  // print('DERIVATIVE ' + db);
  // var s = BaseSymplify(da);
  //print(s);
  var s = BaseSymplify(da);
  print(s);
  //print('SIMPILIFY ' + s);
  //s = BaseSymplify(db);
  //print('SIMPILIFY ' + s);

  /*
  print('Input shuffle regex:');
  regex = stdin.readLineSync() ?? 'null';

  if (regex == 'null') {
    throw 'Incorrect input!';
    
  }
  if (regex != '') {}
  //SimpifyRepetedKlini(regex);
  
  regex=MainSymplify(regex);
  // var s = MainSymplify(regex);
  print("распознано: " + regex);

  var da = derivative(regex, 'a');
  var db = derivative(regex, 'b');
  var dc = derivative(regex, 'c');

  print('a: $da');
  print('s:' + MainSymplify(da));

   print('b: $db');
   print('s:' + MainSymplify(db));



  var fms = TestingFms(regex);
  fms.build(regex);
  fms.Print();
  fms.DumpDotToFile();
  fms.CalculateTransitionMatrix();
  fms.CalculateAdjacencyMatrix();
  fms.CalculateReachabilityMatrix();
  fms.BuildPossibilityMap();
  fms.BuildValidityMap();
  //print(fms.validity);
*/
}
