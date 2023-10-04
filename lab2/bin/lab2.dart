import 'dart:io';

const List<String> op = ['|', '#', '*'];

parseRegex(String regex) {
  // R = r1r2...rn
  var map = <String, String>{};
  List<String> subRegexes = [];
  List<String> operands = [];

  for (var i = 0; i < regex.length; i++) {
    // Смотрим является ли первый символ началом регулярки в скобках
    bool in_group = regex[i] == '(';
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
        if (regex[i + 1] == '|' || regex[i + 1] == '#') {
          operands.add(regex[i + 1]);

          i++;
        }
      } else {
        subRegex = regex[i];

        if (regex[i + 1] == '*') {
          subRegex += '*';
          i++;
        }

        if (regex[i + 1] == '|' || regex[i + 1] == '#') {
          operands.add(regex[i + 1]);
          i++;
        } else {
          //Плюсом обозначаем конкатенацию
          operands.add('+');
        }
      }
    } catch (Exeption) {
      // Здесь значит, что мы вышли за пределы строки
      // Так легче всего отслеживать
    }
    subRegexes.add(subRegex);
  }

  for (var i = 0; i < operands.length; i++) {
    String subConcat = '';
    while (operands[i] == '+') {
      subConcat += subRegexes[i] + subRegexes[i + 1];
      i++;
    }
  }
  print(subRegexes);
  print(operands);
  return map;
}

void main(List<String> arguments) {
  print('Input shuffle regex:');
  String input_regex = stdin.readLineSync() ?? 'null';

  if (input_regex == 'null') {
    throw 'Incorrect input!';
  }

  parseRegex(input_regex);
}
