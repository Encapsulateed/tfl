import 'Fms.dart';
import 'lab2.dart';

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

String InitRegex(String regex) {
  var r = SimpifyRepetedKlini(regex);

  if (r.length != 0) {
    regex = buildRegex(r[0], r);
  }

  return regex.replaceAll('+', '');
}

List<String> SimpifyRepetedKlini(String regex) {
  var r = parseRegex(regex);
  List<String> newR = [];

  for (var i = 0; i < r.length; i++) {
    var item = r[i];

    if (item.endsWith('+') || item.endsWith('|') || item.endsWith('#')) {
      item = item.substring(0, item.length - 1);
    }
    if (item.endsWith('*') || getRegexinBrakets(item).endsWith('*')) {
      for (int j = i + 1; j < r.length; j++) {
        var anotherItem = r[j];

        if (anotherItem.endsWith('+') ||
            anotherItem.endsWith('|') ||
            anotherItem.endsWith('#')) {
          anotherItem = anotherItem.substring(0, anotherItem.length - 1);
        }
        if (item == anotherItem) {
          r[j] = '';
        } else {
          break;
        }
      }
    }
  }
  for (var i = 0; i < r.length; i++) {
    if (r[i] != '') {
      newR.add(r[i]);
    }
  }
  if (newR.length != 0) {
    if (newR[newR.length - 1].endsWith('+') ||
        newR[newR.length - 1].endsWith('#') ||
        newR[newR.length - 1].endsWith('|')) {
      newR[newR.length - 1] =
          newR[newR.length - 1].substring(0, newR[newR.length - 1].length - 1);
    }
  }
  return newR;
}

int countCharacters(String input, String characterToCount) {
  int count = 0;
  for (int i = 0; i < input.length; i++) {
    if (input[i] == characterToCount) {
      count++;
    }
  }
  return count;
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

  //print('$i $back_couter');
  if (i == 1 && back_couter == 1) {
    return regex;
  }

  if (i == 0 && back_couter == 0) {
    return regex;
  }

  return regex.substring(i, regex.length - back_couter);
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

String getRegexinBrakets(String regex) {
  if (regex.endsWith('*')) {
    var noKlini = regex.substring(0, regex.length - 1);
    if (!(noKlini.startsWith('(') && noKlini.endsWith(')'))) {
      return regex;
    }
    return getRegexinBrakets(noKlini);
  }
  if (regex.startsWith('(') && regex.endsWith(')')) {
    return getRegexinBrakets(regex.substring(1, regex.length - 1));
  }
  return regex;
}

String SimplifyKlini(String regex) {
  String simplify = '';

  //regex = regex.replaceFirst('*)*', '*)');
  int i = regex.indexOf('*)*');
  if (i == -1) {
    return regex;
  }

  simplify = regex.substring(0, i + 2);

  if (regex.endsWith('*')) {
    regex = regex.substring(0, regex.length - 1);
  }

  var regexSub = regex.substring(i + 2, regex.length);
  regexSub = regexSub.replaceAll('*)', ')');
  return simplify + regexSub;
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
bool areListsEqual(List<dynamic> list1, List<dynamic> list2) {
  if (list1.length != list2.length) {
    return false; // Если списки разной длины, они точно не равны.
  }

  // Создаем множества (Set) из элементов списков, что уберет дубликаты.
  Set<dynamic> set1 = Set.from(list1);
  Set<dynamic> set2 = Set.from(list2);

  // Сравниваем множества, они равны только если элементы одинаковы.
  return set1.containsAll(set2);
}