import 'tree/tree.dart';
import 'regex/regex_functions.dart';

void main(List<String> arguments) {
  String regex = 'a|a';
  var node = postfixToTree(infixToPostfix(augment(regex)));
  printTree(node);
  node = removeInvalidNodes(removeDuplicateSubtrees(node));

  printTree(node);
  print('==============================');

  // print(match(regex, 'a', showInference: true));
  /*
  deriv(node, 'a');
  printTree(node);
  print('==============================');
  node = removeInvalidNodes(removeNodesWithEmptyLeaf(node));
  printTree(node);
  print('==============================');

  node = removeInvalidNodes(processEmptyLeaves(node));

  printTree(node);
  print('==============================');
  print('==============================');

  node = removeInvalidNodes(removeDuplicateAlters(node));

  printTree(node);
  print('==============================');
  print(inorder(node));
  */
}
