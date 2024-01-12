import '../types/Comparator.dart';
import './GSSNode.dart';

class GSSLevel<T> {
  int iota = 0;
  int numberOfNodes = 0;
  Map<int, GSSNode<T>> nodes = {};

  int number;

  GSSLevel(this.number);

  // O(n)
  GSSNode<T>? find(T value, [Comparator<T>? comparator]) {
    comparator ??= DEFAULT_COMPARATOR;

    for (final key in nodes.keys) {
      final node = nodes[key]!;

      if (comparator(node.value, value)) {
        return node;
      }
    }

    return null;
  }

  // O(n)
  GSSNode<T> push(T value, [Comparator<T>? comparator]) {
    comparator ??= DEFAULT_COMPARATOR;

    var node = this.find(value, comparator);
    if (node == null) {
      node = GSSNode<T>(this.number, value, ++this.iota);
      this.nodes[node.id] = node;
      this.numberOfNodes++;
    }

    return node;
  }

  // O(1)
  void remove(GSSNode<T> node) {
    this.nodes[node.id]?.delete();
    this.numberOfNodes--;
    this.nodes.remove(node.id);
  }

  int length() {
    return numberOfNodes;
  }

  void printLevel() {
    for (var node in nodes.values) {
      if (node.value != null) {
        print("| ${node.toString()} |");
        print("  Prev: ${node.prevSet().join(', ')}");
      }
    }
    print("-------");
  }
}
