import 'dart:io';

List<String> getFunctionSystem(String srs) {
  if (srs == '') {
    return [];
  }
  srs = srs.replaceAll(' ', '');
  bool change_flag = false;
  if (srs.contains('(') || srs.contains(')')) {
    srs = srs.replaceAll(RegExp(r'[()\s]'), '');
    change_flag = true;
  }
  var lhs = srs.split('->')[0];
  var rhs = srs.split('->')[1];

  //remove any variable from trs
  if (change_flag) {
    lhs = lhs.substring(0, lhs.length - 1);
    rhs = rhs.substring(0, rhs.length - 1);
  }

  return <String>[lhs, rhs];
}

List<List<String>> generateMatrix(String func) {
  List<List<String>> matrix = List.empty(growable: true);

  matrix.addAll([
    ["${func}_11", "${func}_12"],
    ["${func}_21", "${func}_22"]
  ]);

  return matrix;
}

List<List<String>> generateVector(String func) {
  List<List<String>> vector = List.empty(growable: true);

  vector.addAll([
    ["${func}_0"],
    [
      "${func}_1",
    ]
  ]);

  return vector;
}

Set<String> getUnicFunctions(List<String> terms) {
  Set<String> functions = {};

  for (var term in terms) {
    for (var fun in term.runes.map((char) => String.fromCharCode(char))) {
      functions.add(fun);
    }
  }

  return functions;
}

List<String> InputSRS() {
  String srs = '';
  List<String> parts = [];
  print("Input TRS");
  do {
    srs = stdin.readLineSync() ?? 'null';

    if (srs == "null") {
      throw 'Incorrect input';
    }

    parts.addAll(getFunctionSystem(srs));
  } while (srs != '');

  return parts;
}

List<List<List<String>>> MakeFunctionMatrix(Set<String> functions) {
  List<List<List<String>>> matrixes = List.empty(growable: true);

  for (var fun in functions) {
    matrixes.add(generateMatrix(fun));
    matrixes.add(generateVector(fun));
  }

  return matrixes;
}

Map<String, List<List<List<String>>>> getMatrixAndVector(
    Set<String> funs, List<List<List<String>>> matrixes) {
  Map<String, List<List<List<String>>>> fun_map =
      <String, List<List<List<String>>>>{};

  int index = 0;
  for (var fun in funs) {
    fun_map[fun] = [matrixes[index], matrixes[index + 1]];
    index += 2;
  }

  return fun_map;
}

void main(List<String> arguments) {
  List<String> parts = InputSRS();

  var unic_funs = getUnicFunctions(parts);
  var matrixes = MakeFunctionMatrix(unic_funs);

  var func_map = getMatrixAndVector(unic_funs, matrixes);

  for (var fun in func_map.keys) {
     print(func_map[fun]);
  }
}
