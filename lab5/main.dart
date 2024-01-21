import 'src/lr0/lr0Parser.dart';

import 'src/utils/conjunctiveGrammar.dart';
import 'dart:io';

// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  // dart main .dart -w"input your word" -c

  String word = '';
  print('Input word');

  word = stdin.readLineSync() ?? 'null';
  bool conj = false;
  int step_num = 0;
  print(arguments);
  print(conj);
  print(step_num);
  for (var argument in arguments) {
    var match_conj = RegExp(r'-c').firstMatch(argument);
    var match_step = RegExp(r'-p(\w+)').firstMatch(argument);

    if (match_conj != null) {
      conj = true;
    }

    if (match_step != null) {
      step_num = int.parse(match_step.group(1)!);
    }
  }
  var cg = conjunctiveGrammar.fromFile('input.txt');
  print(word);

  var p = LR0Parser(cg.possible_grammars[0]);
  print(p.parse(word.split('')));
  /** List<bool> results = [];
  for (var grammar in cg.possible_grammars) {
    LR0Parser curr_parser = LR0Parser(grammar);

    curr_parser.Log(cg.possible_grammars.indexOf(grammar) + 1);
    results.add(curr_parser.Parse(word));
  }
  print(results);
  if (conj == true) {
    if (results.any((element) => element == true)) {
      print('Существует хотя бы один корректный разбор ');
    } else {
      print('слово не принадлежит языку введеёной грамматики');
    }
  } else {
    if (results[0] == true) {
      print('Слово распознано');
    } else {
      print('Слово не распознаётся');
    }
  }
  print(step_num); */
}
