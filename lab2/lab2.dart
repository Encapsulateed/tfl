import 'dart:io';
// import 'Fms.dart';
import 'src/fms/TestingFms.dart';

List<String> parseRegex(String regex) {
  List<String> subRegexes = [];

  regex = regex.replaceAll(RegExp(r'\*+'), '*');
  regex = regex.replaceAll(RegExp(r'\|+'), '|');
  regex = regex.replaceAll('*)*', ')*');
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
            subRegex = "($subRegex*)";
            i++;
          }
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
          subRegex = "(${regex[i]})*";
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
      subRegexes.add(subRegex);
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

  subRegexes = subRegexes.map((e) => e = e.replaceAll('*)*', ')*')).toList();
  subRegexes = subRegexes.map((e) => e = e.replaceAll('*))*', '))*')).toList();

  return subRegexes;
}

String buildRegex(String regex, List<String> SubRegexes) {
  SubRegexes.removeAt(0);
  regex = '${regex}(';

  for (var reg in SubRegexes) {
    regex += reg;
  }
  regex += ')';
  if (SubRegexes.length == 0) {
    regex = regex.substring(0, regex.length - 2);
    regex = regex.substring(1, regex.length - 1);
  }
  return regex;
}

//Функция проверки регулярного выражения на содержание пустой строки
bool isEpsilonInRegex(String regex) {
  // Можно так сделать, потому что шафл - просто перестановка сиволов
  // Он не сделает из регулярки не содержащей пустую строку, регулярку ее содержающую
  // вроде...
  regex = regex.replaceAll('#', '|');
  regex = regex.replaceAll('+', '');
  regex = regex.replaceAll('ε', '');
  RegExp r = RegExp(regex);

  return r.hasMatch('');
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
  var regexes = parseRegex(regex);
  if (regexes.length != 0) {
    regex = buildRegex(regexes[0], regexes);
  }

  //print("REDUCTED " + regex);

  if (regex == 'ε') {
    return 'ε';
  } else if (regex == 'ε') {
    return 'ε';
  } else if (regex.length == 1) {
    return regex;
  } else {
    String left = '';
    String right = '';

    bool in_group = regex[0] == '(';
    if (in_group) {
      left = regex[0];
      int balance = 1;
      int i = 1;

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
      right = regex.substring(i, regex.length);
    } else {
      left = regex;
    }

    left = Reduction(left);
    right = Reduction(right);

    if (right != '' && right != '*') {
      String op = right[0];
      right = right.substring(1, right.length);
      // right = simplifyBrackets(right);

//      print("$left $op $right");

      if (op == '+') {
        if (left == '(∅)' ||
            right == '(∅)' ||
            left == '((∅))' ||
            right == '((∅))' ||
            left == '∅' ||
            right == '∅') {
          return '∅';
        }
        if (left == '(ε)' || left == '((ε))' || left == 'ε') {
          return right;
        }
        if (right == '(ε)' || right == '((ε))' || right == 'ε') {
          return left;
        }
        return '(${BaseSymplify(left)}${BaseSymplify(right)})';
      }
      if (op == '|') {
        if (left == '(∅)' || left == '((∅))' || left == '∅') {
          return right;
        }
        if (right == '(∅)' || right == '((∅))' || right == '∅') {
          return left;
        }
        if (simplifyBrackets(left) == simplifyBrackets(right)) {
          return right;
        }
        return '(${BaseSymplify(left)}|${BaseSymplify(right)})';
      }
      if (op == '#') {
        if (left == '(∅)' ||
            right == '(∅)' ||
            left == '((∅))' ||
            right == '((∅))' ||
            left == '∅' ||
            right == '∅') {
          return '∅';
        }

        if (left == '(ε)' || left == '((ε))' || left == 'ε') {
          return right;
        }
        if (right == '(ε)' || right == '((ε))' || right == 'ε') {
          return left;
        }

        return '(${BaseSymplify(left)}#${BaseSymplify(right)})';
      }
    } else {
      if (right == '*') {
        left += right;
      }
      // print('R_NULL $left');

      if (left == '(∅)*') {
        return '∅';
      }

      if (left == '(ε)*') {
        return 'ε';
      }

      if (left.startsWith('(') && left.endsWith(')')) {
        left = left.substring(1, left.length - 1);
        return BaseSymplify(left);
      } else if (left.endsWith('*')) {
        var no_klini = left.substring(0, left.length - 1);
        return "(${BaseSymplify(no_klini)})*";
      }
    }

    //Если есть скобки на верхнем уровне - удаляем их
  }
  return BaseSymplify(regex);
}

String Reduction(String regex) {
  if (regex.startsWith('-#') || regex.endsWith('#-')) {
    //regex = '-';
  }
  if (regex.startsWith('(-#') || regex.endsWith('#-)')) {
    // regex = '-';
  }
  return regex;
}

String simplifyBrackets(String regex) {
  int i = 0;
  int back_couter = 0;
  int j = regex.length - 1;

  if (regex.length == 0) {
    return '';
  }
  while (regex[i] == '(') {
    i++;
  }

  if (i == 0) {
    return regex;
  } else {
    while (regex[j] == ')') {
      j--;

      if (back_couter == i) {
        break;
      }
      back_couter++;
    }
  }
  if (i != back_couter) {
    i = back_couter;
  }
  if (i == 1 && back_couter == 1) {
    return regex;
  }

  return regex.substring(i - 1, regex.length - back_couter + 1);
}

String derivative(String regex, String char) {
  var regexes = parseRegex(regex);
  regex = buildRegex(regexes[0], regexes);

  if (regexes.length == 0) {
    regexes = parseRegex(regex);
    regex = buildRegex(regexes[0], regexes);
  }

  //stdin.readLineSync();

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
      right = regex.substring(i, regex.length);
    } else {
      left = regex;
    }

    // print('LEFT ' + left);

    if (right != '' && right != '*') {
      String op = right[0];
      right = right.substring(1, right.length);

      //print('EXPRESSION $left $op $right');

      if (op == '+') {
        if (isEpsilonInRegex(left)) {
          return "(((${derivative(left, char)})(${right}))|(${derivative(right, char)}))";
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
    //Значит это регулярка без бинарной операции
    else {
      if (right == '*') {
        left += right;
      }

      if (left.startsWith('(') && left.endsWith(')')) {
        left = left.substring(1, left.length - 1);

        return derivative(left, char);
      } else if (left.endsWith('*')) {
        var no_klini = left.substring(0, left.length - 1);

        return "(${derivative(no_klini, char)})${left}";
      }
    }
  }
  return derivative(regex, char);
}

Set<String> getRegexAlf(String regex) {
  Set<String> alf = {};
  for (var i = 0; i < regex.length; i++) {
    if (regex[i] != '*' &&
        regex[i] != '|' &&
        regex[i] != '#' &&
        regex[i] != '+' &&
        regex[i] != '(' &&
        regex[i] != ')' &&
        regex[i] != 'ε' &&
        regex[i] != '∅') {
      alf.add(regex[i]);
    }
  }
  return alf;
}

String prepareRegex(String regex) {
  var r = parseRegex(regex);
  if (r.length != 0) {
    regex = buildRegex(r[0], r);
  }
  return regex;
}

void main() {
  String regex;
  print('Input shuffle regex:');
  regex = stdin.readLineSync() ?? 'null';

  if (regex == 'null') {
    throw 'Incorrect input!';
  }
  if (regex != '') {}

  regex = prepareRegex(regex);
  print("распознано: " + regex);

  var fms = TestingFms(regex);
  fms.build(regex);
  // fms.Print();
  print(fms.DumpDot());
  fms.CalculateTransitionMatrix();
  fms.CalculateAdjacencyMatrix();
  fms.CalculateReachabilityMatrix();
  fms.BuildPossibilityMap();
  fms.BuildValidityMap();
  print(fms.validity);
}
