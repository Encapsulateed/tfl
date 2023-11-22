import 'tree/tree.dart';
import 'regex/regex_functions.dart';

void main(List<String> arguments) {
  String regex = 'a|a';
  final node = postfixToTree(infixToPostfix(augment(regex)));
  print(match(regex, 'a',showInference: true));

 for (final c in regex.runes) {
    deriv(node, String.fromCharCode(c));
  
    print(inorder(node));
    
    if(nullable(node)){
      break;
    }
  }}
