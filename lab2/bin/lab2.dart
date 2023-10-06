import 'dart:io';

const List<String> op = ['|', '#', '*'];

String sliceString(String input, int startIndex, int endIndex) {
  if (startIndex >= 0 && endIndex >= 0 && startIndex < endIndex) {
    return input.substring(startIndex, endIndex);
  }
  return '';
}

List<String> parseRegex(String regex) {
  List<String> subRegexes = [];
  List<String> operands = [];
  List<String> subConcatRegexes = [];

  for (var i = 0; i < regex.length; i++) {
    // Смотрим является ли первый символ началом регулярки в скобках
    bool in_group = regex[i] == '(' && regex[i + 1] != '(';
    String subRegex = '';
    try {
      if (in_group) {
        subRegex = '(';

        //Бежим по группе пока не дойдём до ее конца
        while (in_group) {
          i++;
          subRegex += regex[i];

          // Любая скобка, очевидно, должна закрыться.
          if (regex[i] == ')') {
            in_group = false;
          }
          if (regex[i + 1] == '*') {
            subRegex += '*';
            i++;
          }
        }
        if (subRegex != '(' &&
            subRegex != ')' &&
            subRegex != '*' &&
            subRegex != '**') {
          if (regex[i + 1] == '|' || regex[i + 1] == '#') {
            operands.add(regex[i + 1]);

            i++;
          } else {
            operands.add('+');
          }
        }
      } else {
        subRegex = regex[i];

        if (regex[i + 1] == '*') {
          subRegex += '*';
          i++;
        }

        if (subRegex != '(' &&
            subRegex != ')' &&
            subRegex != '*' &&
            subRegex != '**') {
          if (regex[i + 1] == '|' || regex[i + 1] == '#') {
            operands.add(regex[i + 1]);

            i++;
          } else {
            // + == конкатенация
            operands.add('+');
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

  //print(subRegexes);
  // print(operands);

  // Представим входную регулярку в виде
  // R = r1+...+rn
  // так проще всего брать производную Брозозовски
  // + - конкатенация

  var subConcatRegex = '';

  if (operands.length == 0) {
    subConcatRegex = subRegexes[0];
  }

  for (var i = 0; i < operands.length; i++) {
    var suff = i + 1 < subRegexes.length ? subRegexes[i + 1] : '';
    var perf = i == 0 ? subRegexes[i] : '';

    if (suff == '' && perf == '') {
      operands[i] = '';
    }
    subConcatRegex += perf + operands[i] + suff;
  }
  return subConcatRegex.split('+');
}

//Функция проверки регулярного выражения на содержание пустой строки
bool isEpsilonInRegex(String regex) {
  // Можно так сделать, потому что шафл - просто перестановка сиволов
  // Она не сделает из регулярки не содержащей пустую строку, регулярку ее содержающую
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
    if (isEpsilonInRegex(concat)) {
      break;
    }
    counter++;
  }

  return counter;
}

//Взятие производной Брозозовски
void derivative(String regex, String char) {}

void main(List<String> arguments) {
  String input_regex;
  List<String> ConcatRegexes = [];

  print('Input shuffle regex:');
  input_regex = stdin.readLineSync() ?? 'null';

  if (input_regex == 'null') {
    throw 'Incorrect input!';
  }
  if (input_regex != '') {
    ConcatRegexes = parseRegex(input_regex);
  }
  print(FindMinimalNonEpsilonConcatenationCount(ConcatRegexes));
}
