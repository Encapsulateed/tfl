import 'dart:io';

class Production {
  String left;
  List<String> right;

  Production(this.left, this.right);

  @override
  String toString() {
    return '\n$left -> ${right.join('')}';
  }
}

class Grammar<T> {
  Set<String> terminals = {};
  Set<String> nonTerminals = {};
  Set<Production> rules = {};
  String start_non_terminal = '';

  Grammar();

  Grammar.fromFile(String filePath) {
    _readGrammarFromFile(filePath);
  }

  void _readGrammarFromFile(String filePath) {
    try {
      var lines = File(filePath).readAsStringSync().split('\n');

      for (var line in lines) {
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
    rules = {};

    rules.add(Production(new_non_terminal, start_non_terminal.split('')));
    rules.addAll(prev_rules);
  }
}
