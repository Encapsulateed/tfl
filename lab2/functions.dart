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

String AssemblyString(List<String> items) {
  var first = '(${items[0]}${items[1]}${items[2]})${items[3]}';
  items.removeRange(0, 4);
  var second = '(${items.join()})';

  return first + second;
}

String simp(String regex) {
  print('input regex is $regex');
  if (regex == '∅') {
    return '∅';
  }
  if (regex == 'ε') {
    return 'ε';
  }
  if (regex.length == 1) {
    return regex;
  }
  if (regex.length == 2 && regex.endsWith('*')) {
    return regex;
  }
  var parsedItems = parseRegex(regex);
  if (parsedItems.length >= 3) {
    if (parsedItems.length > 3) {
      var assambyRegex = AssemblyString(parsedItems);
      parsedItems = parseRegex(assambyRegex);
    }
    var l = parsedItems[0];
    var operand = parsedItems[1];
    var r = parsedItems[2];

    //print('TRY TO SIMPLIFY $l $r WITH $operand');
    if (operand == '|') {
      if (l == r) {
        return simp(l);
      }
      if (l == '∅' || getRegexinBrakets(l) == '∅') {
        return '${simp(r)}';
      } else if (r == '∅' || getRegexinBrakets(r) == '∅') {
        return '${simp(l)}';
      }
    } else if (operand == '+') {
      if (l == '∅' || getRegexinBrakets(l) == '∅') {
        return '∅';
      } else if (r == '∅' || getRegexinBrakets(r) == '∅') {
        return '∅';
      }
      if (l == 'ε' || getRegexinBrakets(l) == 'ε') {
        return simp(r);
      } else if (r == 'ε' || getRegexinBrakets(r) == 'ε') {
        return simp(l);
      }
      if (l.endsWith('*') && r.endsWith('*')) {
        var nkl = l.substring(0, l.length - 1);
        var nkr = r.substring(0, r.length - 1);

        if (nkl == nkr || (getRegexinBrakets(nkl) == getRegexinBrakets(nkr))) {
          return simp(l);
        }
      }
    } else if (operand == '#') {
      if (l == 'ε' || getRegexinBrakets(l) == 'ε') {
        return '${simp(r)}';
      } else if (r == 'ε' || getRegexinBrakets(r) == 'ε') {
        return '${simp(l)}';
      }
      if (l == '∅' || getRegexinBrakets(l) == '∅') {
        return '∅';
      }
      if (r == '∅' || getRegexinBrakets(r) == '∅') {
        return '∅';
      }
    }

    return '${simp(l)}$operand${simp(r)}';
  } else {
    if (parsedItems.length > 0) {
      if (parsedItems[0].endsWith('*')) {
        var noStar = parsedItems[0].substring(0, parsedItems[0].length - 1);
        return '(${simp(noStar)})*';
      }
      if (parsedItems.length == 1) {
        var parsed = parsedItems[0];
        if (parsed.endsWith(')') && parsed.startsWith('(')) {
          return simp(parsed.substring(1, parsed.length - 1));
        } else {
          return parsed;
        }
      }
    }
  }

  return '';
}

String MainSymplify(String regex) {
  var prev = '';
  var curr = regex;

  while (prev != curr) {
    curr = curr.replaceAllMapped(RegExp(r'\((.)\)\*'), (match) {
      String x = match.group(1) ?? ''; // Захваченный символ x
      return '$x*';
    });
    curr = removeSameOR(curr);

/*
    curr = parseRegex(curr)
        .map((item) => item = SimplifyKlini(item))
        .toList()
        .join();

    curr = SimplifyKlini(curr);
   
    */
    prev = curr;
    curr = simp(curr);
    //print(curr);
  }
  return curr.replaceAll('+', '');
}

String SimplifyKlini(String regex) {
  // (a*)* -> (a)* -> a*
  // (ab*)* -> (ab*)*
  // (((a)*)*)* -> (a)* ->a*
  // ((..((r)*)..)*) -> (r)*

  //print('${getRegexinBrakets(regex)} ${regex}');
  if (getRegexinBrakets(regex).length <= 2) {
    if (getRegexinBrakets(regex).endsWith('*')) {
      regex = regex.replaceFirst('*', '!');
      regex = regex.replaceAll(')*', ')');
      regex = regex.replaceFirst('!', '*)');
      return regex;
    } else {
      regex = regex.replaceFirst(')*', '!');
      regex = regex.replaceAll(')*', ')');
      regex = regex.replaceFirst('!', '*)');
      return regex;
    }
  } else {
    if (getRegexinBrakets(regex).endsWith('*')) {
      regex = regex.replaceFirst('*)*', '!');
      regex = regex.replaceAll(')*', ')');
      regex = regex.replaceFirst('!', '*)*');
      return regex;
    } else {
      regex = regex.replaceFirst(')*', '!');
      regex = regex.replaceAll(')*', ')');
      regex = regex.replaceFirst('!', ')*');
      return regex;
    }
  }
}

String removeSameOR(String regex) {
  var Regexlst = regex.split('|').toList();

  for (int i = 0; i < Regexlst.length - 1; i++) {
    if (Regexlst[i] == Regexlst[i + 1]) {
      Regexlst.removeAt(i);
      i--; // Decrement i to recheck the current index
    }
  }

  return Regexlst.join('|');
}
