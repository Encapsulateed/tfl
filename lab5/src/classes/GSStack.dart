import '../types/Comparator.dart';
import './GSSNode.dart';
import './GSSLevel.dart';
import 'dart:io';

abstract class GSStack<T> {
  GSSNode<T> push(T value, [GSSNode<T>? prev]);
  bool pop(GSSNode<T> node);
  bool empty();
  Comparator<T> get comparator;
  List<GSSLevel<T>> get levels;
  void printStack(GSSNode<T> firstNode);
  List<GSSNode<T>> getPreviousNodesFromNode(GSSNode<T> startNode);
  void GSStoDot();
}

class GSStackImpl<T> implements GSStack<T> {
  List<GSSLevel<T>> _levels = [];
  late Comparator<T> _comparator;

  GSStackImpl([Comparator<T>? comparator]) {
    _comparator = comparator ?? DEFAULT_COMPARATOR;
  }

  @override
  Comparator<T> get comparator => _comparator;

  @override
  List<GSSLevel<T>> get levels => _levels;

  @override
  GSSNode<T> push(T value, [GSSNode<T>? prev]) {
    final level = (prev?.level ?? -1) + 1;

    if (this._levels.length == level) {
      this._levels.add(GSSLevel(level));
    }

    final node = this._levels[level].find(value, _comparator) ??
        this._levels[level].push(value);

    if (prev != null) {
      node.addPrev(prev);
    }

    return node;
  }

  @override
  bool pop(GSSNode<T> node) {
    if (node.hasHigherLevelNext()) {
      return false;
    }

    this._levels[node.level].remove(node);

    final isLevelEmpty = this._levels[node.level].length() == 0;
    final isLastLevel = this._levels.length == node.level + 1;

    if (isLastLevel && isLevelEmpty) {
      this._levels.removeLast();
    }

    return true;
  }

  @override
  bool empty() {
    return this._levels.isEmpty;
  }

  @override
  List<GSSNode<T>> getPreviousNodesFromNode(GSSNode<T> startNode) {
    List<GSSNode<T>> result = [];

    var nodeLevel;
    for (int i = _levels.length - 1; i > 0; i--) {
      for (final t in _levels[i].nodes.values) {
        //print("OUR ID: ${startNode.value}, LEVELS ID: ${t.value}");
        if (t.value == startNode.value) {
          //print("IM HERE YES");
          nodeLevel = i;
          break;
        }
      }
    }

    for (int i = nodeLevel - 1; i > 0; i--) {
      var prevNodes = _levels[i].getPreviousNodesFromNode(startNode);
      result.addAll(prevNodes);
      startNode = prevNodes[1];
      //print("NEW START NODE: $startNode");
    }

    if (nodeLevel == 1) {
      return [startNode];
    } else {
      return result.toSet().toList();
    }
  }

  void printStack(GSSNode<T> firstNode) {
    print("STACK PRINT BEGIN\n"
        "-------\n"
        "Level 0");
    print("| ${firstNode.toString()} |");
    print("  Prev: First node");
    print("-------");
    for (int i = 1; i < _levels.length; i++) {
      print("Level $i:");
      _levels[i].printLevel();
    }
    print("STACK PRINT END");
  }

  void GSStoDot() {
    String res = "";

    for (int i = 0; i < _levels.length; i++) {
      res += "  subgraph cluster_$i {\n";
      res += "    label=\"Level $i\";\n";

      for (final node in _levels[i].nodes.values) {
        if (node.value != null) {
          res += "    ${node.value} [label=\"${node.value}\"];\n";
        }
      }
      res += "  }\n";
    }

    for (int i = 1; i < _levels.length; i++) {
      for (final node in _levels[i - 1].nodes.values) {
        for (final nextNode in node.next.values) {
          if (nextNode.value != null) {
            res += "  ${node.value} -> ${nextNode.value};\n";
          }
        }
      }
    }

    res = "digraph {\n"
        "rankdir = LR\n"
        "dummy [shape=none, label=\"\", width=0, height=0]\n"
        "$res"
        "}\n";

    File file = File('stack.txt');
    file.writeAsStringSync(res);

    print('Stack was dumped to stack.dot');
  }
}