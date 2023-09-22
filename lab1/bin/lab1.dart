import 'package:lab1/lab1.dart' as lab1;
import 'dart:io';

String input() {
  print("Input TRS");
  return stdin.readLineSync() ?? 'null';
}

List<String> getFunctionSystem(String trs) {
  bool change_flag = false;
  if (trs.contains('(') || trs.contains(')')) {
    trs = trs.replaceAll(RegExp(r'[()\s]'), '');
    change_flag = true;
  }
  var lhs = trs.split('->')[0];
  var rhs = trs.split('->')[1];

  //remove any variable from trs
  if (change_flag) {
    print("$lhs $rhs");

    lhs = lhs.substring(0, lhs.length - 1);
    rhs = rhs.substring(0, rhs.length - 1);
    print("$lhs $rhs");
  }

  return <String>[lhs, rhs];
}

void main(List<String> arguments) {
  String trs = input();

  if (trs == "null") {
    throw 'Incorrect input';
  }

  var parts = getFunctionSystem(trs);
}
