import 'src/lr0/lr0Parser.dart';

import 'src/utils/conjunctiveGrammar.dart';
import 'dart:io';

// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  // dart main .dart -w"input your word" -c

  String word = '';
  print('Input word');

  word = stdin.readLineSync() ?? 'null';
  word = word.trim().replaceAll(' ', '');

  int step_num = -1;

  for (var argument in arguments) {
    var match_step = RegExp(r'-p(\w+)').firstMatch(argument);

    if (match_step != null) {
      step_num = int.parse(match_step.group(1)!);
    }
  }

  var cg = conjunctiveGrammar.fromFile('input.txt');

  List<bool> results = [];
  for (var grammar in cg.possible_grammars) {
    // print(grammar);
    LR0Parser curr_parser = LR0Parser(grammar);

    curr_parser.Log(cg.possible_grammars.indexOf(grammar) + 1);
    bool res = curr_parser.parse(word.split(''), step_num);
    results.add(res);
    //  results.add(curr_parser.parse(word.split(''), step_num));
  }
  print(results);
  if (results.every((element) => element == true)) {
    print('Существует хотя бы один корректный разбор ');
  } else {
    print('слово не принадлежит языку введеёной грамматики');
  }
  /**
   *  */
}
