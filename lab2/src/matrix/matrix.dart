//

class Matrix {
  List<List<int>> data = [];
  int m = 0;
  int n = 0;

  Matrix(this.m, this.n) {
    for (var i = 0; i < m; i++) {
      data.add(List.filled(n, 0));
    }
  }

  Matrix.Identity(this.m, this.n) {
    for (var i = 0; i < m; i++) {
      data.add(List.filled(n, 0));
    }

    for (var i = 0; i < m; i++) {
      data[i][i] = 1;
    }
  }

  Matrix operator +(Matrix rhs) {
    int m1 = this.m;
    int m2 = rhs.m;
    if (!(m1 > 0 && m1 == m2)) {
      throw 'Matrix Addition: bad input';
    }

    int n1 = this.n;
    int n2 = rhs.n;
    if (!(n1 > 0 && n1 == n2)) {
      throw 'Matrix Addition: bad input';
    }

    Matrix newMatrix = Matrix(m, n);

    for (var i = 0; i < m1; i++) {
      for (var j = 0; j < n1; j++) {
        newMatrix.data[i][j] = data[i][j] + rhs.data[i][j];
      }
    }

    return newMatrix;
  }

  Matrix operator *(Matrix rhs) {
    int m1 = this.m;
    int m2 = rhs.m;
    if (!(m1 > 0 && m2 > 0)) {
      throw 'Matrix Multiplication: bad input';
    }

    int n1 = this.n;
    int n2 = rhs.n;
    if (!(n1 > 0 && n2 > 0)) {
      throw 'Matrix Multiplication: bad input';
    }

    if (n1 != m2) {
      throw 'Matrix Multiplication: bad input (${n1} ${m2})';
    }

    Matrix newMatrix = Matrix(m1, n2);

    for (var i = 0; i < m1; i++) {
      for (var j = 0; j < n2; j++) {
        for (var k = 0; k < n1; k++) {
          newMatrix.data[i][j] += this.data[i][k] * rhs.data[k][j];
        }
      }
    }

    return newMatrix;
  }

  @override
  String toString() {
    String res = "";
    for (var i = 0; i < m; i++) {
      res += data[i].toString() + "\n";
    }

    return res;
  }
}
