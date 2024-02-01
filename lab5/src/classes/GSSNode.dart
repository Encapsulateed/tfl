import '../types/Comparator.dart';

class _GSSNode<T> {
  T value;
  int level;
  int id;
  int my_id = -1;
  Map<int, _GSSNode<T>> prev = {};
  Map<int, _GSSNode<T>> next = {};
  int prevLength = 0;
  int nextLength = 0;

  _GSSNode(this.level, this.value, this.id);

  @override
  String toString() {
    return '$value';
  }

  void addPrev(_GSSNode<T> node) {
    if (this.prev.containsKey(node.id)) {
      return;
    }

    this.prevLength++;
    this.prev[node.id] = node;
    node.addNext(this);
  }

  void addPrevByValue(_GSSNode<T> node) {
    if (!this.prev.values.any((existingNode) => DEFAULT_COMPARATOR(existingNode.value, node.value))) {
      final newId = this.prev.values.length + 1;
      this.prev[newId] = node;
      node.addNext(this);
    }
  }

  void addNext(_GSSNode<T> node) {
    if (this.next.containsKey(node.id)) {
      return;
    }

    this.nextLength++;
    this.next[node.id] = node;
    node.addPrev(this);
  }

  void removePrev(_GSSNode<T> node) {
    if (!prev.containsKey(node.id)) {
      return;
    }

    this.prevLength--;
    this.prev.remove(node.id);
    node.removeNext(this);
  }

  void removeNext(_GSSNode<T> node) {
    if (!next.containsKey(node.id)) {
      return;
    }

    this.nextLength--;
    this.next.remove(node.id);
    node.removePrev(this);
  }

  int degPrev() {
    return prevLength;
  }

  int degNext() {
    return nextLength;
  }

  void delete() {
    final nextNodeKeys = List.from(this.next.keys);
    final prevNodeKeys = List.from(this.prev.keys);

    for (final nextNodeKey in nextNodeKeys) {
      this.next[nextNodeKey]?.removePrev(this);
    }

    for (final prevNodeKey in prevNodeKeys) {
      this.prev[prevNodeKey]?.removeNext(this);
    }
  }

  bool hasHigherLevelNext() {
    for (final nextNodeId in next.keys) {
      if (next[nextNodeId]!.level > level) {
        return true;
      }
    }

    return false;
  }

  Set<String> prevSet() {
    //return this.prev.values.toSet();
    return this.prev.values.map((node) => node.toString()).toSet();
  }

  Set<GSSNode<T>> prevSetValued() {
    //return this.prev.values.toSet();
    return this.prev.values.toSet().map((e) => e as GSSNode<T>).toSet();
  }

  Set<_GSSNode<T>> ancestors(int k) {
    Set<_GSSNode<T>> result = {};
    _getAncestorsRecursive(this, k, result);
    result.remove(this);
    return result;
  }

  void _getAncestorsRecursive(
      _GSSNode<T> currentNode, int k, Set<_GSSNode<T>> result) {
    if (k < 0) {
      return;
    }

    result.add(currentNode);

    if (currentNode.level == 0) {
      return;
    }

    for (final prevNode in currentNode.prev.values) {
      _getAncestorsRecursive(prevNode, k - 1, result);
    }
  }
}

class GSSNode<T> extends _GSSNode<T> {
  GSSNode(int level, T value, int id) : super(level, value, id);
}
