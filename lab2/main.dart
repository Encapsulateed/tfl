import 'src/fms/TestingFms.dart';
import 'tree/tree.dart';
import 'regex/regex_functions.dart';

void main(List<String> arguments) {
  String regex = "c*|((abc|sy*))*|zx|a|c*"; // -> a|b

  //*
  var root = (postfixToTree(infixToPostfix(augment(regex))));
  makeMap(root);
  printMap();
  printTree(root);

  root = simplifyRegex(root);

  printTree(root);
  print(inorder(root));
//  printTree(root);

  var fms = TestingFms(regex);
  fms.build(regex);
  //fms.Print();
  fms.DumpDotToFile();
  fms.CalculateTransitionMatrix();
  fms.CalculateAdjacencyMatrix();
  fms.CalculateReachabilityMatrix();
  fms.BuildPossibilityMap();
  fms.BuildValidityMap();
  print(fms.DumpRegex());
/*
*/
}
