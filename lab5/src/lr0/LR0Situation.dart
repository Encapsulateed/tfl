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
      identical(this, other) || this.toString() == other.toString();

  List<String> getNextTokens(List<LR0Situation> productions) {
    List<String> generatedList = [];
    for (LR0Situation production in productions) {
      String nextToken = production.next;
      if (nextToken != 'eps' && !generatedList.contains(nextToken)) {
        generatedList.add(nextToken);
      }
    }
    return generatedList;
  }
}
