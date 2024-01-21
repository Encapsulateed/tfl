import 'Production.dart';
import 'conjunctiveProduction.dart';
import 'grammar.dart';
import 'dart:io';

class conjunctiveGrammar {
  List<Grammar> possible_grammars = [];
  List<conjunctiveProdutcion> rules = [];

  conjunctiveGrammar.fromFile(String filePath) {
    _alternativsPreWork(filePath);
    _readGrammarFromFile(filePath);
    _makeCFGs();
  }

  void _alternativsPreWork(String filePath) {
    var lines = File(filePath).readAsStringSync().split('\n');
    List<String> updated_rules = [];
    for (var line in lines) {
      if (line.trim().isNotEmpty) {
        List<String> parts =
            line.split('->').map((part) => part.trim()).toList();

        var left = parts[0];
        var right = parts[1].split('|').toList();
        rules.add(conjunctiveProdutcion(
            left, (right.map((e) => e.split('')).toList())));

        for (var item in right) {
          updated_rules.add('$left->$item');
        }
      }
    }

    var file = File(filePath);

    // Открываем поток для записи в файл
    var sink = file.openWrite();

    try {
      // Записываем каждую строку из списка в файл
      for (var rule in updated_rules) {
        sink.writeln(rule);
      }
    } finally {
      // Закрываем поток и сохраняем изменения в файле
      sink.close();
    }
  }

  void _readGrammarFromFile(String filePath) {
    var lines = File(filePath).readAsStringSync().split('\n');

    for (var line in lines) {
      if (line.trim().isNotEmpty) {
        List<String> parts =
            line.split('->').map((part) => part.trim()).toList();

        var left = parts[0];
        var right = parts[1].split('&').toList();
        rules.add(conjunctiveProdutcion(
            left, (right.map((e) => e.split('')).toList())));
      }
    }
  }

  void PrintCG() {
    rules.forEach((element) {
      print(element.toString());
    });
  }

  void _makeCFGs() {
    var permutations = _allPermutations();

    num rules_count = rules.length;

    for (int i = 0; i < permutations.length; i++) {
      var p = permutations[i];
      List<Production> prod = [];
      for (int j = 0; j < rules_count; j++) {
        var classicProduction = Production(rules[j].left, p[j].split(''));

        prod.add(classicProduction);
      }
      possible_grammars.add(Grammar.fromProductionList(prod));
    }
  }

  List<List<String>> _generatePermutations(
      List<List<String>> lists, int index, List<String> current) {
    if (index == lists.length) {
      return [List<String>.from(current)];
    }

    List<List<String>> permutations = [];
    for (String item in lists[index]) {
      current.add(item);
      permutations.addAll(_generatePermutations(lists, index + 1, current));
      current.removeLast();
    }

    return permutations;
  }

  List<List<String>> _allPermutations() {
    List<List<String>> possibleRightList = this
        .rules
        .map((rule) => rule.possible_right.map((lst) => lst.join()).toList())
        .toList();
    return _generatePermutations(possibleRightList, 0, []);
  }
}
