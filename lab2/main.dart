import 'tree/tree.dart';
import 'regex/regex_functions.dart';
void main(List<String> arguments) {
  print(match('a|b', 'a', showInference: true));
}
