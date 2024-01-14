import 'dart:io';
import 'Production.dart';

class Grammar {
  Map<String, Set<String>> firstSets = {};
  Map<String, Set<String>> followSets = {};

  Set<String> terminals = {};
  Set<String> nonTerminals = {};
  List<Production> rules = [];
  List<Production> user_rules = [];
  String start_non_terminal = '';

  Grammar();

  Grammar.make(List<Production> prd, Set<String> NT, Set<String> T) {
    this.nonTerminals = [...NT.toList()].toSet();
    this.terminals = [...T.toList()].toSet();
    this.rules = [...prd];
  }

  Grammar.fromFile(String filePath) {
    _readGrammarFromFile(filePath);
    complete();
  }

  void _readGrammarFromFile(String filePath) {
    try {
      // Читаем все строки в файле
      var lines = File(filePath).readAsStringSync().split('\n');

      // Идём по всем строкам файла
      for (var line in lines) {
        // trim - удаляет все проблы из строки, если они там есть
        if (line.trim().isNotEmpty) {
          var parts = line.split('->').map((part) => part.trim()).toList();

          var left = parts[0];
          var right = parts[1];

          nonTerminals.add(left);

          for (int i = 0; i < right.length; i++) {
            int charCode = right[i].codeUnitAt(0);
            if (charCode >= 65 && charCode <= 90) {
              this.nonTerminals.add(right[i]);
            } else {
              terminals.add(right[i]);
            }
          }

          rules.add(Production(left, right.split('')));
        }
      }

      start_non_terminal = nonTerminals.toList()[0];
    } catch (e) {
      print('Произошла ошибка при чтении файла: $e');
    }
  }

  @override
  String toString() {
    return 'TERMINALS: ${terminals.toString()}\nNON TERMINALS: ${nonTerminals.toString()}\nSTART: ${start_non_terminal}\nRULES\n${rules.toString()}';
  }

  void complete() {
    var new_non_terminal = '${start_non_terminal}0';
    nonTerminals.add(new_non_terminal);
    var prev_rules = rules;
    user_rules = prev_rules;
    rules = [];
    rules.add(Production(new_non_terminal, start_non_terminal.split('')));
    rules.addAll(prev_rules);
  }

  int getRuleIndex(Production rule) {
    String tmp_left = rule.left;
    List<String> tmp_right = [];
    tmp_right.addAll(rule.right);
    tmp_right.remove('·');

    return rules.indexOf(Production(tmp_left, tmp_right));
  }

  int getruleIndexInUser(Production rule) {
    String tmp_left = rule.left;
    List<String> tmp_right = [];
    tmp_right.addAll(rule.right);
    tmp_right.remove('·');

    return rules.indexOf(Production(tmp_left, tmp_right));
  }

  Set<String> getFirst(List<String> str, int i) {
    Set<String> first = {};

    if (i == str.length) {
      return first;
    }

    if (terminals.contains(str[i])) {
      first.add(str[i]);
      return first;
    }

    if (nonTerminals.contains(str[i])) {
      for (var key in firstSets.keys) {
        first.addAll(firstSets[key]!);
      }
    }

    return first;
  }
}
