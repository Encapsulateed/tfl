import 'src/lr0/lr0Parser.dart';

import 'src/utils/conjunctiveGrammar.dart';

// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  // dart main .dart -w"input your word" -c

  String word = '';
  bool conj = false;
  int step_num = 0;
  for (var argument in arguments) {
    var match_word = RegExp(r'-w(\w+)').firstMatch(argument);
    var match_conj = RegExp(r'-c').firstMatch(argument);
    var match_step = RegExp(r'-p(\w+)').firstMatch(argument);
    if (match_word != null) {
      word = match_word.group(1)!;
    }

    if (match_conj != null) {
      conj = true;
    }

    if (match_step != null) {
      step_num = int.parse(match_step.group(1)!);
    }
  }
  var cg = conjunctiveGrammar.fromFile('input.txt');

  List<bool> results = [];
  for (var grammar in cg.possible_grammars) {
    LR0Parser curr_parser = LR0Parser(grammar);

    curr_parser.Log(cg.possible_grammars.indexOf(grammar) + 1);

    results.add(curr_parser.Parse(word));
  }

  if (conj == false) {
    if (results.any((element) => element == true)) {
      print('Существует хотя бы один корректный разбор ');
    } else {
      print('слово не принадлежит языку введеёной грамматики');
    }
  } else {
    if (!results.any((element) => element == true)) {
      print('Существует хотя бы один корректный разбор ');
    } else {
      print('слово не принадлежит языку введеёной грамматики');
    }
  }
  print(step_num);
}
