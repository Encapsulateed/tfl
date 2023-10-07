import 'dart:io';
import 'dart:math';

List<String> parseRegex(String regex, Set<String> alf) {
  List<String> subRegexes = [];

  for (var i = 0; i < regex.length; i++) {
    if (regex[i] != '*' &&
        regex[i] != '|' &&
        regex[i] != '#' &&
        regex[i] != '+' &&
        regex[i] != '(' &&
        regex[i] != ')') {
      alf.add(regex[i]);
    }
  }

  for (var i = 0; i < regex.length; i++) {
    // Смотрим является ли первый символ началом регулярки в скобках
    bool in_group = regex[i] == '(' && regex[i + 1] != '(';
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
          if (regex[i] == ')') {
            group_balance--;
          }
          if (regex[i] == '(') {
            group_balance++;
          }

          if (regex[i + 1] == '*') {
            subRegex = "${subRegex}*";
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
      subRegexes.add(subRegex);
    }
  }

  subRegexes.removeWhere(
      (element) => !(alf.any((letter) => element.contains(letter))));

  var lastItem = subRegexes[subRegexes.length - 1];
  if (lastItem.endsWith('+')) {
    lastItem = lastItem.substring(0, lastItem.length - 1);
  }

  subRegexes =
      subRegexes.map((e) => e = e.replaceAll(RegExp(r'\*+'), '*')).toList();

  subRegexes[subRegexes.length - 1] = lastItem;
  return subRegexes;
}

String buildRegex(String regex, List<String> SubRegexes) {
  SubRegexes.removeAt(0);
  regex = '${regex}(';

  for (var reg in SubRegexes) {
    regex += reg;
  }
  regex += ')';
  return regex;
}

//Функция проверки регулярного выражения на содержание пустой строки
bool isEpsilonInRegex(String regex) {
  // Можно так сделать, потому что шафл - просто перестановка сиволов
  // Он не сделает из регулярки не содержащей пустую строку, регулярку ее содержающую
  // вроде...
  regex = regex.replaceAll('#', '|');
  RegExp r = RegExp(regex);

  return r.hasMatch('');
}

// Функция поиска минимальной конкатенации регулярных выражений, такой что
// пустая строка НЕ будет содержаться в данной конкатенации
int FindMinimalNonEpsilonConcatenationCount(List<String> Regexes) {
  String concat = '';
  int counter = 0;
  for (var regex in Regexes) {
    concat += regex;
    if (!isEpsilonInRegex(concat)) {
      break;
    }
    counter++;
  }

  return counter;
}

String derivative(String regex, String char) {
  print(regex);

  if (regex.isEmpty || regex == 'ES') {
    return 'ES'; // Производная символа равна ε (пустой строке)
  } else if (regex == '(${char})') {
    return 'ε'; // Производная символа равна ε (пустой строке)
  } else if (regex == '(${char}*)') {
    return char + '*';
  } else {
    var regexes = parseRegex(regex, {});
    regex = buildRegex(regexes[0], regexes);
    //  print(regex);

    String left = regex[0];
    String right = '';
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
    //print(left);

    // Значит перед нами бинарная операция, такая что регулярку можно разделить на лево и право
    if (right != '' && right.length > 1) {
      String op = right[0];
      right = right.substring(1, right.length);
      //print("$left $op $right");

      if (op == '+') {
        if (isEpsilonInRegex(regex)) {
          return "${derivative(left, char)}${right} | ${left}${derivative(right, char)}";
        } else {
          return "${derivative(left, char)}${right}";
        }
      }
      if (op == '|') {
        return '${derivative(left, char)}|${derivative(right, char)}';
      }
      if (op == '#') {
        return '${derivative(left, char)}#${right}|${left}#${derivative(right, char)}';
      }
    }
    //Значит это регулярка без бинарной операции, это возможно только если на высшем уровне вложенности расположена звезда клини
    // например, (((r1|r2)#r3)*)
    else {
      //var left_no_klini = left.split('');
      //  left_no_klini.removeAt(regex.length - 2);

      // print( left_no_klini.join());
      //return "${derivative(left.substring(0, left.length - 2), char)}+${left}";
    }
  }
  return 'ES';
}

void main() {
  String regex;
  List<String> ConcatRegexes = [];
  Set<String> alf = {};
  print('Input shuffle regex:');
  regex = stdin.readLineSync() ?? 'null';

  if (regex == 'null') {
    throw 'Incorrect input!';
  }
  if (regex != '') {
    //  var s = derivative(input_regex, 'a');
    // ConcatRegexes = parseRegex(input_regex);
  }

  var d = derivative(regex, 'a');
  print("d = ${d}");
}
