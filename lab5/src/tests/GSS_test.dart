import 'package:test/test.dart';
import '../classes/GSStack.dart';
import '../classes/GSSNode.dart';

void main() {
  group('GSStack: example', () {
    late GSStack<int> stack;
    late Map<int, GSSNode<int>> nodes;

    setUp(() {
      stack = GSStackImpl<int>();
      nodes = {};

      // {7,3,1,0}
      nodes[0] = stack.push(0);
      nodes[1] = stack.push(1, nodes[0]);
      nodes[3] = stack.push(3, nodes[1]);
      nodes[7] = stack.push(7, nodes[3]);

      // {7,4,1,0}
      nodes[4] = stack.push(4, nodes[1]);
      nodes[7] = stack.push(7, nodes[4]); // 7 isn't duplicated, as it ends up in the same layer

      // {7,5,2,0}
      nodes[2] = stack.push(2, nodes[0]);
      nodes[5] = stack.push(5, nodes[2]);
      nodes[7] = stack.push(7, nodes[5]);

      // {8,6,2,0}
      nodes[6] = stack.push(6, nodes[2]);
      nodes[8] = stack.push(8, nodes[6]);
    });

    test('has the right degrees: prev', () {
      expect(nodes[7]!.degPrev(), equals(3));
      expect(nodes[8]!.degPrev(), equals(1));
      expect(nodes[3]!.degPrev(), equals(1));
      expect(nodes[4]!.degPrev(), equals(1));
      expect(nodes[5]!.degPrev(), equals(1));
      expect(nodes[6]!.degPrev(), equals(1));
      expect(nodes[1]!.degPrev(), equals(1));
      expect(nodes[2]!.degPrev(), equals(1));
      expect(nodes[0]!.degPrev(), equals(0));
    });

    test('has the right degrees: next', () {
      expect(nodes[7]!.degNext(), equals(0));
      expect(nodes[8]!.degNext(), equals(0));
      expect(nodes[3]!.degNext(), equals(1));
      expect(nodes[4]!.degNext(), equals(1));
      expect(nodes[5]!.degNext(), equals(1));
      expect(nodes[6]!.degNext(), equals(1));
      expect(nodes[1]!.degNext(), equals(2));
      expect(nodes[2]!.degNext(), equals(2));
      expect(nodes[0]!.degNext(), equals(2));
    });

    test('has the right prevSet', () {
      expect(nodes[7]!.prevSet(), equals({'3', '4', '5'}));
      expect(nodes[8]!.prevSet(), equals({'6'}));
      expect(nodes[4]!.prevSet(), equals({'1'}));
      expect(nodes[5]!.prevSet(), equals({'2'}));
      expect(nodes[6]!.prevSet(), equals({'2'}));
      expect(nodes[2]!.prevSet(), equals({'0'}));
      expect(nodes[1]!.prevSet(), equals({'0'}));
    });
  });
}