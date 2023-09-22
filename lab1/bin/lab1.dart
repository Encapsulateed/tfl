import 'package:lab1/lab1.dart' as lab1;
import 'dart:io';

List<String> getFunctionSystem(String trs) {

  if (trs == ''){
    return [];
  }

  bool change_flag = false;
  if (trs.contains('(') || trs.contains(')')) {
    trs = trs.replaceAll(RegExp(r'[()\s]'), '');
    change_flag = true;
  }
  var lhs = trs.split('->')[0];
  var rhs = trs.split('->')[1];

  //remove any variable from trs
  if (change_flag) {
    lhs = lhs.substring(0, lhs.length - 1);
    rhs = rhs.substring(0, rhs.length - 1);
  }

  return <String>[lhs, rhs];
}

void main(List<String> arguments) {
  String trs = '';
  List<String> parts = [];
  print("Input TRS");

  do {
    trs = stdin.readLineSync() ?? 'null';

    if (trs == "null") {
      throw 'Incorrect input';
    }

    parts.addAll(getFunctionSystem(trs));
  } while (trs != '');

  print(parts);
}
