import 'dart:io';
import 'dart:math';

List<String> parseRegex(String regex) {
  List<String> subRegexes = [];
  Set<String> alf = {};
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
  subRegexes[subRegexes.length - 1] = lastItem;

  subRegexes =
      subRegexes.map((e) => e = e.replaceAll(RegExp(r'\*+'), '*')).toList();

  subRegexes = subRegexes
      .map((e) => e = (e[e.length - 1] == '*' ? "(${e})" : e))
      .toList();

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
  }
  // print(regex);
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

String simplifyRegex(String regex) {
  regex = regex.replaceAll(RegExp(r'\(+'), '(');
  regex = regex.replaceAll(RegExp(r'\)+'), ')');
  regex = regex.replaceAll(RegExp(r'\*+'), '*');

  // print(regex);

  return regex;
}

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
  // regex = simplifyRegex(regex);

  var regexes = parseRegex(regex);
  regex = buildRegex(regexes[0], regexes);

  if (regex.isEmpty || regex == '∅') {
    return '∅'; // Производная символа равна ε (пустой строке)
  } else if (regex == '($char)') {
    return 'ε'; // Производная символа равна ε (пустой строке)
  } else if (regex == '(${char}*)') {
    return char + '*';
    // Производная символа равна ε (пустой строке)
  } else if (regex.length == 3) {
    var char_in_case = regex[1];
    if (char_in_case != '#' &&
        char_in_case != '|' &&
        char_in_case != '+' &&
        char_in_case != '(' &&
        char_in_case != ')' &&
        char_in_case != char) {
      //Это обработка случая a^(-1)b
      return '∅';
    }
  } else {
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
    // print('LEFT ' + left);
    // print('RIGHT ' + right);
    // Значит перед нами бинарная операция, такая что регулярку можно разделить на лево и право
    if (right != '') {
      String op = right[0];
      right = right.substring(1, right.length);

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
    //Значит это регулярка без бинарной операции
    else {
      //Если есть скобки на верхнем уровне - удаляем их

      if (left.startsWith('(') && left.endsWith(')')) {
        var tmp_left = left.split('');

        tmp_left.removeAt(0);
        tmp_left.removeAt(tmp_left.length - 1);
        left = tmp_left.join();
        print('LEFT ' + left);
        if (!left.startsWith('(')) {
          return derivative(left, char);
        }
      }
      if (left.endsWith('*')) {
        var no_klini = left.substring(0, left.length - 1);
        print('NO KL ' + left);
        return "${derivative(no_klini, char)}${left}";
      } else {
        print('LEFT 2' + left);
        return derivative(left, char);
      }
    }
  }
  return '∅';
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
  if (regex != '') {}

  var d = derivative(regex, 'a');
  print("d = ${d}");
}
