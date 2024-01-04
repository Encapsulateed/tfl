import '../../utils/grammar.dart';

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

  @override
  String toString() {
    var tmp = [];
    tmp.addAll(super.right);
    tmp.insert(LR0_pointer, '·');
    return '$left -> ${tmp.join('')}';
  }

  bool isFinal() {
    return LR0_pointer == super.right.length - 1;
  }

  bool isStart() {
    return LR0_pointer == 0;
  }
}
