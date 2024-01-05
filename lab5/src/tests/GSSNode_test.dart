import 'package:test/test.dart';
import '../types/Comparator.dart';
import '../classes/GSSLevel.dart';

void main() {
  group('GSSNode: constructor', () {
    const value = 1;
    const level = 0;

    test('starts with empty prev', () {
      expect(GSSLevel(level).push(value, DEFAULT_COMPARATOR).degPrev(), equals(0));
    });

    test('starts with empty next', () {
      expect(GSSLevel(level).push(value, DEFAULT_COMPARATOR).degNext(), equals(0));
    });
  });

  const methods = [
    ['addPrev', 'degPrev'],
    ['addNext', 'degNext'],
  ];

  for (final method in methods) {
    test('GSSNode: ${method[0]}', () {
      final level = GSSLevel(0);
      final mainNode = level.push(5, DEFAULT_COMPARATOR);
      final otherNode = level.push(1, DEFAULT_COMPARATOR);

      mainNode.addPrev(otherNode);

      expect(mainNode.degPrev(), equals(1));
    });

    test("doesn't add if the node already exists", () {
      final level = GSSLevel(0);
      final mainNode = level.push(5, DEFAULT_COMPARATOR);
      final otherNode = level.push(0, DEFAULT_COMPARATOR);

      mainNode.addPrev(otherNode);
      mainNode.addPrev(otherNode);

      expect(mainNode.degPrev(), equals(1));
    });
  }

  test('GSSNode: hasHigherLevelNext', () {
    final node = GSSLevel(0).push(5, DEFAULT_COMPARATOR);

    expect(node.hasHigherLevelNext(), equals(false));
  });

  test('GSSNode: hasHigherLevelNext', () {
    final node = GSSLevel(0).push(1, DEFAULT_COMPARATOR);

    expect(node.hasHigherLevelNext(), equals(false));
  });
}