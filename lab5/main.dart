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
  int step_num = -1;

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

  List<bool> results = [];
  for (var grammar in cg.possible_grammars) {
    LR0Parser curr_parser = LR0Parser(grammar);

    curr_parser.Log(cg.possible_grammars.indexOf(grammar) + 1);
    results.add(curr_parser.parse(word.split(''), 3));
    //results.add(curr_parser.glrParser(word.split(''), n: step_num));
  }

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
  print(step_num);
}
