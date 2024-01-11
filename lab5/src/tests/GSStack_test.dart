import 'package:test/test.dart';
import '../types/Comparator.dart';
import '../classes/GSStack.dart';
import '../classes/GSSNode.dart';

void main() {
  group('GSStack: constructor', () {
    test('succeeds without a comparator', () {
      expect(GSStackImpl<int>(), isNotNull);
    });

    test('sets DEFAULT_COMPARATOR as the default comparator', () {
      expect(GSStackImpl<int>().comparator, equals(DEFAULT_COMPARATOR));
    });

    test('starts with no layers', () {
      expect(GSStackImpl<int>().levels.length, equals(0));
    });
  });

  group('GSStack: push', () {
    test('pushes to level = 0 when prev = null', () {
      final value = 5;
      final stack = GSStackImpl<int>();
      final node = stack.push(value);

      expect(node, isNotNull);
      expect(node.level, equals(0));
      expect(stack.levels[0].find(value, stack.comparator), equals(node));
    });

    test('pushes above prev when prev != null', () {
      final stack = GSStackImpl<int>();
      final prev = stack.push(1);
      final node = stack.push(2, prev);

      expect(node, isNotNull);
      expect(node.level, equals(1));
      expect(node.degPrev(), equals(1));
      expect(prev.hasHigherLevelNext(), isTrue);
    });
  });

  group('GSStack: pop', () {
    test('successfully removes a 1-cycle', () {
      final stack = GSStackImpl<int>();
      final node = stack.push(5);

      expect(stack.pop(node), isTrue);
    });

    test('fails to remove a bottom node', () {
      final stack = GSStackImpl<int>();
      final prevNode = stack.push(0);
      final nextNode = stack.push(1, prevNode);

      expect(stack.pop(prevNode), isFalse);
      expect(nextNode.degPrev(), equals(1));
      expect(prevNode.degNext(), equals(1));
    });
  });

  group('GSStack: integration', () {
    late GSStack<int> stack;

    setUp(() {
      stack = GSStackImpl<int>();
    });

    test('mimics a stack: pushing', () {
      final N = 500;
      final native = <int>[];
      GSSNode<int>? prev;

      for (final value in List<int>.generate(N, (i) => i)) {
        prev = stack.push(value, prev);
        native.add(value);

        expect(native.last, equals(value));
        expect(prev.value, equals(value));
      }
    });

    test('mimics a stack: push, and remove', () {
      final N = 5;
      final values = List<int>.generate(N, (i) => i);
      final native = <int>[];
      GSSNode<int>? prev;

      for (final value in values) {
        prev = stack.push(value, prev);
        native.add(value);
      }

      while (!stack.empty() && native.isNotEmpty) {
        final value = native.removeLast();
        final nextPrev = (prev?.prev.values ?? const <GSSNode<int>>[])
            .firstOrNull as GSSNode<int>?;
        stack.pop(prev!);

        expect(prev.value, equals(value));
        prev = nextPrev;
      }

      expect(stack.empty(), isTrue);
      expect(native.length, equals(0));
    });
  });
}
