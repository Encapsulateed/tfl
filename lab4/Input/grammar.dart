import 'dart:io';

Map<String, List<List<String>>> parseGrammarFromFile(String filename) {
  var grammar = <String, List<List<String>>>{};
  var lines = File(filename).readAsStringSync().split('\n');

  for (var line in lines) {
    if (line.trim().isNotEmpty) {
      var parts = line.split('->').map((part) => part.trim()).toList();
      var nonTerminal = parts[0];
      var productions = parts[1].split('|').map((prod) => prod.trim().split(' ')).toList();
      grammar[nonTerminal] = productions;
    }
  }

  return grammar;
}