import 'LR0/Analyzer.dart';

import 'LR0/LR0State.dart';

import './Input/grammar.dart';

void main(List<String> arguments) {
  var grammar = parseGrammarFromFile('input.txt');

  var LR0States = buildLR0States(grammar);
  printLR0States(LR0States);
  printLR0StatesDot(LR0States, grammar);
}
