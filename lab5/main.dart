import './src/utils/grammar.dart';

void main(List<String> arguments) {
  String filePath = 'input.txt';
  Grammar grammar = Grammar.fromFile(filePath);

  // Выводим информацию о считанной грамматике
  print(grammar.toString());
  // grammar.rules.forEach((production) => print(production));
}
