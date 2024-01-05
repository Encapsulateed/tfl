import 'package:test/test.dart';
import '../types/Comparator.dart';
import '../classes/GSSLevel.dart';
import '../classes/GSSNode.dart';

void main() {
  group('GSSLevel: constructor', () {
    const EMPTY_MAP = <int, GSSNode<int>>{};

    // Initial conditions
    test('starts with empty nodes', () {
      expect(GSSLevel<int>(0).nodes, equals(EMPTY_MAP));
    });

    test('starts with iota = 0', () {
      expect(GSSLevel<int>(0).iota, equals(0));
    });
  });

  group('GSS: push', () {
    test('adds node', () {
      final level = GSSLevel<int>(0);
      final node = level.push(5, DEFAULT_COMPARATOR);

      expect(level.nodes.values.length, equals(1));
      expect(level.nodes[node.id], equals(node));
    });
  });

  group('GSS: find', () {
    test('returns null when empty', () {
      final level = GSSLevel<int>(0);

      expect(level.find(0, DEFAULT_COMPARATOR), isNull);
    });

    test("returns null when the value doesn't exist", () {
      const valueA = 5;
      const valueB = 0;
      final level = GSSLevel<int>(0);
      level.push(valueA);

      expect(level.find(valueB, DEFAULT_COMPARATOR), isNull);
    });

    test('returns node reference if the value exists', () {
      const value = 50;
      final level = GSSLevel<int>(0);
      final node = level.push(value);

      // testing reference validity, not just structural equality
      expect(level.find(value), equals(node));
    });
  });

  group('GSS: remove', () {
    test("doesn't fail if the node doesn't exist", () {
      final level = GSSLevel<int>(0);
      final node = level.push(0);

      try {
        expect(() => level.remove(node), returnsNormally);
      } catch (e) {
        fail('Exception should not be thrown');
      }
    });

    test('removes existing node', () {
      final level = GSSLevel<int>(0);
      const value = 0;
      final node = level.push(value);

      level.remove(node);

      expect(level.find(value), isNull);
      expect(level.nodes.values.length, equals(0));
    });

    test("fixes others' next, and prev", () {
    final level0 = GSSLevel<int>(0);
    final level1 = GSSLevel<int>(1);
    final nodeA = level0.push(0);
    final nodeB = level1.push(1);

    // create a 2-cycle
    nodeB.addPrev(nodeA);
    nodeB.addNext(nodeA);

    level1.remove(nodeB);

    expect(nodeA.degNext(), equals(0));
    expect(nodeA.degPrev(), equals(0));
    });
  });
}
