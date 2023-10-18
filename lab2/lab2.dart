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

    if (in_group) {
      subRegex = '(';
      int group_balance = 1;
      //Бежим по группе пока не дойдём до ее конца
      while (group_balance != 0) {
        i++;
        if (i == regex.length) {
          break;
        }
        subRegex += regex[i];

        // Любая скобка, очевидно, должна закрыться.
        if (regex[i] == '(') {
          group_balance++;
        }
        if (regex[i] == ')') {
          group_balance--;
        }

        if (i + 1 < regex.length && regex[i + 1] == '*') {
          // subRegex = simplifyBrackets(subRegex);
          subRegex = "$subRegex*";
          i++;
        }
      }
      if (subRegex != '(' &&
          subRegex != ')' &&
          subRegex != '*' &&
          subRegex != '**') {
        subRegexes.add(subRegex);
        if (i + 1 < regex.length &&
            (regex[i + 1] == '|' ||
                regex[i + 1] == '#' ||
                regex[i + 1] == '+')) {
          subRegexes.add(regex[i + 1]);

          i++;
        } else {
          if (i + 1 < regex.length) {
            subRegexes.add('+');
          }
        }
      }
    } else {
      subRegex = "${regex[i]}";

      if (i + 1 < regex.length && regex[i + 1] == '*') {
        subRegex = "${regex[i]}*";
        i++;
      }

      if (subRegex != '(' &&
          subRegex != ')' &&
          subRegex != '*' &&
          subRegex != '**') {
        subRegexes.add(subRegex);

        if (i + 1 < regex.length &&
            (regex[i + 1] == '|' ||
                regex[i + 1] == '#' ||
                regex[i + 1] == '+')) {
          subRegexes.add(regex[i + 1]);

          i++;
        } else {
          if (i + 1 < regex.length) {
            subRegexes.add('+');
          }
        }
      }
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

  // subRegexes = subRegexes.map((e) => e = e.replaceAll('*))*', '*))')).toList();

  return subRegexes;
}

// Функция поиска минимальной конкатенации регулярных выражений, такой что
// пустая строка НЕ будет содержаться в данной конкатенации

String d(String regex, c) {
  if (regex == 'ε') {
    return 'ε';
  }
  if (regex == '∅') {
    return '∅';
  }

  if (regex.length == 2) {
    if (regex == c + '*') {
      return c + '*';
    } else if (regex != c && regex.endsWith('*')) {
      return '∅';
    }
  }
  if (regex.length == 1) {
    if (regex == c) {
      return 'ε';
    }
    return '∅';
  }

  var parsedItems = parseRegex(regex);

  // Минимальное число операндов для существования бинарной операвции
  if (parsedItems.length >= 3) {
    if (parsedItems.length > 3) {
      var assambyRegex = AssemblyString(parsedItems);
      parsedItems = parseRegex(assambyRegex);
    }

    var l = parsedItems[0];
    var operand = parsedItems[1];
    var r = parsedItems[2];

    var dl = d(l, c);
    var dr = d(r, c);
    // print('my regex == $regex');
    // print('will $operand `$l -> $dl` `$r -> $dr`');

    if (operand == '+' || operand == '#') {
      if (operand == '+') {
        if (isEpsilonInRegex(l)) {
          if (dl == '∅') {
            return '(${d(r, c)})';
          }
          if (dr == '∅') {
            return '(${d(l, c)}+$r)';
          }
          return '((${d(l, c)}+$r)|(${d(r, c)}))';
        }

        if (dl == '∅') {
          //return '∅';
        }
        return '(${d(l, c)}+$r)';
      }
      if (operand == '#') {
        if (dl == '∅' || dr == '∅') {
          // return '∅';
        }

        return '(((${d(l, c)}#$r)|($l#${d(r, c)})))';
      }
    } else if (operand == '|') {
      if (l == r) {
        return '(${d(l, c)})';
      }
      if (dl == dr) {
        return '(${d(l, c)})';
      }

      if (dl == '∅') {
        return '(${d(r, c)})';
      }
      if (dr == '∅') {
        return '(${d(l, c)})';
      }

      return '((${d(l, c)})|(${d(r, c)}))';
    }
  } else if (parsedItems.length == 1) {
    // Если элемент всего 1, всё либо тривиально, либо это звёзда клини

    if (parsedItems[0].endsWith('*')) {
      var noStar = parsedItems[0].substring(0, parsedItems[0].length - 1);
      return '(${(d(noStar, c))})' + '+' + '${parsedItems[0]}';
    } else {
      // Если нет перед нами группа
      // спускаемся ниже
      if (parsedItems[0].endsWith(')') && parsedItems[0].startsWith('(')) {
        if (countCharacters(parsedItems[0], '(') != 1 &&
            countCharacters(parsedItems[0], ')') != 1) {
          return '(${d(parsedItems[0].substring(1, parsedItems[0].length - 1), c)})';
        }
      }
      return d(parsedItems[0].substring(1, parsedItems[0].length - 1), c);
    }
  }
  return '';
}

void main() {
  String regex = '';
  print('Input regex: ');
  regex = stdin.readLineSync() ?? '';

  regex = prepareRegex(regex);
  regex = MainSymplify(regex);

  var fms = TestingFms(regex);
  fms.build(regex);
  //fms.Print();
  fms.DumpDotToFile();
  fms.CalculateTransitionMatrix();
  fms.CalculateAdjacencyMatrix();
  fms.CalculateReachabilityMatrix();
  fms.BuildPossibilityMap();
  fms.BuildValidityMap();
  print(fms.DumpRegex());
}
