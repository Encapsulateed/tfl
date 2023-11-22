import 'tree/tree.dart';
import 'regex/regex_functions.dart';

void main(List<String> arguments) {
  String regex = '(a|b)|(a|b)c*';
  //print(infixToPostfix(regex));
  print(augment(regex));
  final node = postfixToTree(infixToPostfix(augment(regex)));
  printTree(node);
  //print(match(regex, 'a', showInference: true));

  for (final c in regex.runes) {
    //deriv(node, String.fromCharCode(c));

    //print(inorder(node));

    if (nullable(node)) {
      break;
    }
  }
}
