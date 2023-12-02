import 'src/fms/TestingFms.dart';
import 'tree/tree.dart';
import 'regex/regex_functions.dart';
import 'dart:io';

void main(List<String> arguments) {
  String regex = "";

  print('Input regex');
  regex = stdin.readLineSync() ?? 'null';
  var root = (postfixToTree(infixToPostfix(augment(regex))));

  root = simplifyRegex(root);
  regex = inorder(root);

  var fms = TestingFms(regex);
  fms.build(regex);
  // fms.Print();

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
