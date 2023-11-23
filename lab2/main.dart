import 'tree/tree.dart';
import 'regex/regex_functions.dart';

void main(List<String> arguments) {
  String regex = '((((a*)#a)|(a*))|(a*))';
  //              (((((a*)#a)|(a*))|(a*))|(a*))
  var node = postfixToTree(infixToPostfix(augment(regex)));
  printTree(node);
  node = makeLeft(node);
  printTree(node);
  print(inorder(node));
  print('==============================');
  //printTree(node);
   // print(inorder(node));
  // print(match(regex, 'a', showInference: true));


  deriv(node, 'a');



  node = removeInvalidNodes(removeNodesWithEmptyLeaf(node));
  node = removeInvalidNodes(processEmptyLeaves(node));
  node = removeInvalidNodes(removeDuplicateSubtrees(node));

   // printTree(node);
    print('==============================');
    print(inorder(node));

}
