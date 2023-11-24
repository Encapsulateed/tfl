import 'tree/tree.dart';
import 'regex/regex_functions.dart';

void main(List<String> arguments) {
  String regex = '((((a*)#a)|(a*))|(a*))';
  // ((((a)a)|(a))|(a))
  // b|a|a
  // ((b|a)|a)
  var node = postfixToTree(infixToPostfix(augment(regex)));
  //node = makeLeft(node);
  print('==============================');
  printTree(node);
  print('==============================');
  print(inorder(node));
  node = removeInvalidNodes(removeNodesWithEmptyLeaf(node));
  node = removeInvalidNodes(processEmptyLeaves(node));
  node = removeInvalidNodes(removeSameOr(node));

  print('==============================');
  printTree(node);
  print('==============================');
  print(inorder(node));
   //printTree(node);
   // print(inorder(node));
  // print(match(regex, 'a', showInference: true));


  //deriv(node, 'a');





   // printTree(node);


}
