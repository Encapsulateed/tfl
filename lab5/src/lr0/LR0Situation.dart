import '../utils/Production.dart';

class LR0Situation extends Production {
  int LR0_pointer = 0;
  String next = '';
  LR0Situation(String left, List<String> right, LR0_pointer)
      : super(left, right) {
    this.LR0_pointer = LR0_pointer;

    try {
      next = super.right[LR0_pointer];
    } catch (e) {
      next = 'eps';
    }
  }

  LR0Situation.fromProduction(Production p) : super(p.left, p.right) {
    LR0_pointer = 0;
  }

  @override
  String toString() {
    var tmp = [];
    tmp.addAll(super.right);
    tmp.insert(LR0_pointer, '·');
    return '$left -> ${tmp.join('')}';
  }

  bool isFinal() {
    return LR0_pointer == super.right.length;
  }

  bool isStart() {
    return LR0_pointer == 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (this.toString() == (other as LR0Situation).toString() &&
          LR0_pointer == other.LR0_pointer);

  void move() {
    LR0_pointer++;
    try {
      next = super.right[LR0_pointer];
    } catch (e) {
      next = 'eps';
    }
  }

  String getNext() {
    try {
      return super.right[LR0_pointer];
    } catch (e) {
      return 'eps';
    }
  }

  LR0Situation clone() {
    return LR0Situation(left, right, LR0_pointer);
  }
}
