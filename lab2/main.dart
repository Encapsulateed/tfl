import 'tree/tree.dart';
import 'regex/regex_functions.dart';

void main(List<String> arguments) {
  String regex = 'a#a*';
  //print(infixToPostfix(regex));
  print(augment(regex));
  final node = postfixToTree(infixToPostfix(augment(regex)));
  printTree(node);
 // print(match(regex, 'a', showInference: true));

  
    deriv(node, 'a');

    print(inorder(node));
    printTree(node);

  
}
