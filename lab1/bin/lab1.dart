import 'dart:io';

//this type can be Matrix 2x2 or vector 1x2
typedef Matrix = List<List<String>>;

class LinearMatrixFunction {
  final Matrix a;
  final Matrix b;

  LinearMatrixFunction(this.a, this.b);

  LinearMatrixFunction Compose(LinearMatrixFunction? fun) {
    if (fun == null) {
      throw 'Matrix is NULL!';
    }

    // f = Ax + B
    // g = CX + D
    // f(g(x)) = (AC)x + (AD + B)
    Matrix a_1 = ArcticMatrix_Mult(a, fun.a);
    Matrix b_1 = ArcticMatrix_Sum(ArcticMatrix_Mult(a, fun.b), b);

    return LinearMatrixFunction(a_1, b_1);
  }
}

String arctic_sum(String x, String y) => "(arctic_sum $x $y)";
String arctic_mult(String x, String y) => "arctic_mult $x $y";
//String arctic_max(String x, String y) => "(arctic_max $x $y)";

Matrix ArcticMatrix_Mult(Matrix A, Matrix B) {
  //строк в А всегда 2  вне зависимости вектор это или матрица

  // Количество столбцов в матрице А и B
  int colsA = A[0].length;
  int colsB = B[0].length;
  int rowsA = A.length;
  int rowsB = B.length;

  if (colsA != rowsB) {
    throw ArgumentError('Неподходящие размеры матриц для умножения.');
  }
  Matrix C = List.empty(growable: true);

  //result matrix init
  List<String> lst = [];
  for (int i = 0; i < colsB; i++) {
    lst.add('');
  }

  for (int j = 0; j < colsA; j++) {
    C.add(lst);
  }

  for (int i = 0; i < rowsA; i++) {
    for (int j = 0; j < colsB; j++) {
      var item = '';
      for (int k = 0; k < colsA; k++) {
        if (item != '') {
          item = arctic_sum(item, arctic_mult(A[i][k], B[k][j]));
        } else {
          item = arctic_mult(A[i][k], B[k][j]);
        }
      }
      C[i][j] = item;
    }
  }

  return C;
}

Matrix ArcticMatrix_Sum(Matrix A, Matrix B) {
  if (A[0].length != B[0].length) {
    throw 'Error in Matrix sum';
  }

  int rows = A.length;
  int cols = A[0].length;

  Matrix C = List.empty(growable: true);
  List<String> lst = [];
  for (int i = 0; i < cols; i++) {
    lst.add('');
  }
  for (int j = 0; j < rows; j++) {
    C.add(lst);
  }

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < A[0].length; j++) {
      C[i][j] = arctic_sum(A[i][j], B[i][j]);
    }
  }

  return C;
}

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

Matrix generateMatrix(String func) {
  Matrix matrix = List.empty(growable: true);

  matrix.addAll([
    ["${func}_11", "${func}_12"],
    ["${func}_21", "${func}_22"]
  ]);

  return matrix;
}

Matrix generateVector(String func) {
  Matrix vector = List.empty(growable: true);

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
  print("Input SRS");
  do {
    srs = stdin.readLineSync() ?? 'null';

    if (srs == "null") {
      throw 'Incorrect input';
    }

    parts.addAll(getFunctionSystem(srs));
  } while (srs != '');

  return parts;
}

List<Matrix> MakeFunctionMatrix(Set<String> functions) {
  List<Matrix> matrixes = List.empty(growable: true);

  for (var fun in functions) {
    matrixes.add(generateMatrix(fun));
    matrixes.add(generateVector(fun));
  }

  return matrixes;
}

Map<String, LinearMatrixFunction> generateMatrixFunction(
    Set<String> funs, List<List<List<String>>> matrixes) {
  Map<String, LinearMatrixFunction> fun_map = <String, LinearMatrixFunction>{};

  int index = 0;
  for (var fun in funs) {
    //f(x) = Ax + B
    fun_map[fun] = LinearMatrixFunction(matrixes[index], matrixes[index + 1]);
    index += 2;
  }

  return fun_map;
}

List<T> getElements<T>(List<T> inputList, bool needAdd(int i)) {
  List<T> result = [];

  for (int i = 0; i < inputList.length; i++) {
    if (needAdd(i)) {
      result.add(inputList[i]);
    }
  }

  return result;
}

List<LinearMatrixFunction> CalculateFunctionComposes(List<String> HS, funcMap) {
  List<LinearMatrixFunction> composedFunctions = List.empty(growable: true);

  for (var term in HS) {
    //f0(f1...(fn1(fn(x)))....)
    LinearMatrixFunction result = funcMap[term[0]];
    for (int i = 1; i < term.length; i++) {
         result = result.Compose(funcMap[term[i]]);
    }
    composedFunctions.add(result);
    
  }

  return composedFunctions;
}

void main(List<String> arguments) {
  List<String> parts = InputSRS();
  List<String> LHS = getElements(parts, (i) => i % 2 == 0);
  List<String> RHS = getElements(parts, (i) => i % 2 != 0);

  List<LinearMatrixFunction> leftResFunctions;
  List<LinearMatrixFunction> rightResFunctions;

  var unicFuns = getUnicFunctions(parts);
  var matrixes = MakeFunctionMatrix(unicFuns);

  var funcMap = generateMatrixFunction(unicFuns, matrixes);

  var left = CalculateFunctionComposes(LHS, funcMap);
  var right = CalculateFunctionComposes(RHS, funcMap);

  // print(ArcticMatrix_Mult(funcMap['f']!.a, funcMap['g']!.a));

  print(left[0].a);
  // print(left[0].b);1
}
