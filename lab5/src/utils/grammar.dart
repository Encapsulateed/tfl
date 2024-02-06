import 'dart:io';
import 'Production.dart';
import 'dart:collection';

class Grammar {
  Set<String> terminals = {};
  Set<String> nonTerminals = {};
  List<Production> rules = [];
  List<Production> user_rules = [];
  String startNonTerminal = '';

  Map<String, List<String>> productions = {};

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

  Grammar.fromProductionList(List<Production> prd) {
    for (var p in prd) {
      if (nonTerminals.length == 0) {
        startNonTerminal = p.left;
      }
      nonTerminals.add(p.left);
      for (var t in p.right) {
        int charCode = t.codeUnitAt(0);
        if (charCode >= 65 && charCode <= 90) {
          this.nonTerminals.add(t);

          if (nonTerminals.length == 0) {
            startNonTerminal = t;
          }
        } else {
          terminals.add(t);
        }
      }
    }
    this.rules = [...prd];
   // to_cnf();
      complete();
    //  update_grammar();
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

      startNonTerminal = nonTerminals.toList()[0];
    } catch (e) {
      print('Произошла ошибка при чтении файла: $e');
    }
  }

  @override
  String toString() {
    return 'TERMINALS: ${terminals.toString()}\nNON TERMINALS: ${nonTerminals.toString()}\nSTART: ${startNonTerminal}\nRULES\n${rules.toString()}';
  }

  void complete() {
    var new_non_terminal = '${startNonTerminal}0';
    nonTerminals.add(new_non_terminal);
    var prev_rules = rules;
    user_rules = prev_rules;
    rules = [];
    rules.add(Production(new_non_terminal, startNonTerminal.split('')));
    rules.addAll(prev_rules);
    //  startNonTerminal = new_non_terminal;
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

  void to_cnf() {
    //  eliminate_long_rules();
    var prev_start = startNonTerminal;
    // complete();
    remove_chain_rules();
    eliminate_long_rules();
    // startNonTerminal = prev_start;
    // eliminate_unproductive_rules();
    replace_terminals_with_non_terminals();
    sort_grammar();
    update_grammar();
    complete();
  }

  void eliminate_unproductive_rules() {
    var productive_non_terminals = find_productive_non_terminals();
    print(productive_non_terminals);
    rules.removeWhere((p) => p.right.every(
        (s) => terminals.contains(s) || productive_non_terminals.contains(s)));
  }

  SplayTreeSet<String> find_productive_non_terminals() {
    SplayTreeSet<String> productive = SplayTreeSet<String>();
    bool changed = true;

    while (changed) {
      changed = false;
      for (var nt in nonTerminals) {
        for (var production in rules.where((element) => element.left == nt)) {
          if (!productive.contains(production.left)) {
            if (production.right.every(
                (s) => terminals.contains(s) || productive.contains(s))) {
              productive.add(production.left);
              changed = true;
              break;
            }
          }
        }
      }
    }
    return productive;
  }

  void update_grammar() {
    startNonTerminal = rules.toList()[0].left;
    nonTerminals = {};
    terminals = {};

    for (var rule in rules) {
      nonTerminals.add(rule.left);
    }
    for (var rule in rules) {
      for (var item in rule.right) {
        if (!nonTerminals.contains(item)) {
          terminals.add(item);
        }
      }
    }
  }

  void sort_grammar() {
    rules.sort((a, b) {
      // Проверка приоритетности символа
      if (a.left == startNonTerminal) {
        return -1; // 'a' приоритетнее
      } else if (b.left == startNonTerminal) {
        return 1; // 'b' приоритетнее
      } else {
        return a.left
            .compareTo(b.left); // Сравнение в лексикографическом порядке
      }
    });
  }

  void eliminate_long_rules() {
    Set<Production> new_productions = {};
    for (var prod in rules) {
      List<Production> transformed = [];
      var r = prod.right;
      if (r.length > 2) {
        var elements = List<String>.from(r);
        var curr_nt = prod.left;

        while (elements.length > 2) {
          var first_elem = elements[0];
          elements.removeAt(0);
          var new_nt = gener_new_nt();

          var new_prod_leftover = List<String>.from(elements);

          var new_prd = Production(curr_nt, '${first_elem}${new_nt}'.split(''));
          new_productions.add(new_prd);

          curr_nt = new_nt;
          elements = new_prod_leftover;
        }
        new_productions.add(Production(curr_nt, elements));
      } else {
        transformed.add(Production(prod.left, List<String>.from(prod.right)));
      }
      new_productions.addAll(transformed);
    }
    this.rules = new_productions.toList();
  }

  void remove_chain_rules() {
    Set<Production> new_productions = {};
    Map<String, List<String>> chain_rules = {};

    for (var prod in rules) {
      var production_symbols = List<String>.from(prod.right.where((element) =>
          element.length == 1 && nonTerminals.contains(element[0])));
      if (chain_rules[prod.left] == null) {
        chain_rules[prod.left] = [];
      }
      chain_rules[prod.left]!.addAll(production_symbols);
    }

    for (var nt in nonTerminals) {
      var closure = List<String>.from(chain_rules[nt]!);
      var index = 0;

      while (index < closure.length) {
        List<String>? next_rules = chain_rules[closure[index]];
        if (next_rules != null) {
          for (var next_rule in next_rules) {
            if (!closure.contains(next_rule)) {
              closure.add(next_rule);
            }
          }
        }
        index++;
      }
      if (chain_rules[nt] == null && closure.length != 0) {
        chain_rules[nt] = [];
      }
      if (closure.length != 0) {
        chain_rules[nt]!.addAll(closure);
      }
    }

    for (var prod in rules) {
      Set<Production> prod_set = {};
      if (prod.right.length != 1 || !nonTerminals.contains(prod.right[0])) {
        prod_set.add(Production(prod.left, prod.right));
      }

      var closure = chain_rules[prod.left];
      if (closure != null) {
        if (closure.length != 0) {
          // print(closure.toSet().toList());
          for (var closure_nt in closure) {
            for (var closure_prod in rules.where((r) => r.left == closure_nt)) {
              if (closure_prod.right.length != 1 ||
                  !nonTerminals.contains(closure_prod.right[0])) {
                prod_set.add(Production(closure_prod.left, closure_prod.right));
              }
            }
          }
        }
      }

      new_productions.addAll(prod_set);
    }
    rules = [];

    for (var r in new_productions) {
      if (!rules.any((rule) => rule.left == r.left && rule.right == r.right)) {
        rules.add(r);
      }
    }
  }

  void replace_terminals_with_non_terminals() {
    Map<String, List<Production>> new_productions = {};
    Map<String, String> visited_terminals = {};
    for (var p in rules) {
      Production new_prod = Production(p.left, []);
      for (var symbol in p.right) {
        if (terminals.contains(symbol) && p.right.length > 1) {
          String new_nt = '';
          if (visited_terminals[symbol] == null) {
            new_nt = gener_new_nt();
            visited_terminals[symbol] = new_nt;
          } else {
            new_nt = visited_terminals[symbol]!;
          }
          var new_rule = Production(new_nt, symbol.split(''));
          if (new_productions[new_nt] == null) {
            new_productions[new_nt] = [];
          }

          if (!new_productions[new_nt]!.contains(new_rule)) {
            new_productions[new_nt]!.add(new_rule);
          }

          new_prod.right.add(new_nt);
        } else {
          new_prod.right.add(symbol);
        }
      }
      if (new_productions[p.left] == null) {
        new_productions[p.left] = [];
      }
      if (new_prod.right.length != 0) {
        new_productions[p.left]!.add(new_prod);
      }
    }

    rules = [];
    for (var pro in new_productions.values) {
      rules.addAll(pro);
    }
  }

  String gener_new_nt() {
    int start_code = 'A'.codeUnits[0];
    String new_nt = String.fromCharCode(start_code);
    while (nonTerminals.contains(new_nt) == true) {
      new_nt = String.fromCharCode(start_code++);
    }
    nonTerminals.add(new_nt);
    return new_nt;
  }
}
