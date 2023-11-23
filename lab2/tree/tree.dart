import 'dart:io';
import '../regex/regex_functions.dart';

class Node {
  String c;
  Node? l;
  Node? r;

  Node(this.c, {this.l, this.r});
}

Node? postfixToTree(String postfix) {
  if (postfix.isEmpty) {
    return null;
  }

  final stack = <Node>[];
  for (final c in postfix.runes) {
    final char = String.fromCharCode(c);
    if (char == '|' || char == '·' || char == '#') {
      final r = stack.removeLast();
      final l = stack.removeLast();
      stack.add(Node(char, l: l, r: r));
    } else if (char == '*') {
      final l = stack.removeLast();
      stack.add(Node(char, l: l));
    } else {
      stack.add(Node(char));
    }
  }

  return stack.last;
}

Node? clone(Node? node) {
  if (node == null) {
    return null;
  }
  return Node(node.c, l: clone(node.l), r: clone(node.r));
}

bool nullable(Node? node) {
  if (node == null) {
    return false;
  } else if (node.c == 'ϵ' || node.c == '*') {
    return true;
  } else if (node.c == '·' || node.c == '|' || node.c == '#') {
    return nullable(node.l) && nullable(node.r);
  } else {
    return false;
  }
}

void printTree(Node? root, [String indent = '', bool last = true]) {
  if (root != null) {
    print(indent + (last ? '└── ' : '├── ') + root.c);
    var newIndent = indent + (last ? '    ' : '│   ');
    printTree(root.l, newIndent, false);
    printTree(root.r, newIndent, true);
  }
}

Node? deriv(Node? root, String c) {
  final stack = [root];
 
  while (stack.isNotEmpty) {
    final node = stack.removeLast();
    // print("LEFT: ${node?.l}");
    // print("RIGHT: ${node?.r}");

    if (node == null || node.c == '∅') {
      continue;
    } else if (node.c == 'ϵ') {
      node.c = '∅';
    } else if (node.c == c) {
      node.c = 'ϵ';
    } else if (node.c == '|') {
      stack.add(node.l);
      stack.add(node.r);
    } else if (node.c == '·') {
      if (nullable(node.l)) {
        node.c = '|';
        final dnode = Node('·', l: node.l, r: node.r);
        node.l = dnode;
        node.r = clone(dnode.r);
        stack.add(node.l?.l);
        stack.add(node.r);
      } else {
        stack.add(node.l);
      }
    } else if (node.c == '#') {
      node.c = '|';
      final llnode = Node('#', l: node.l, r: node.r);
      final dnode = Node('#', l: clone(node.l), r: clone(node.r));

      node.l = llnode;
      node.r = dnode;

      stack.add(node.l?.l);
      stack.add(node.r?.r);
    } else if (node.c == '*') {
      final starNode = clone(node);
      node.c = '·';
      node.r = starNode;
      stack.add(node.l);
    } else {
      node.c = '∅';
    }
  }

  return root;
}

Node? removeNodeByReference(Node? root, Node? targetNode) {
  if (root == null) {
    return null;
  }

  if (root == targetNode) {
    return null;
  }

  root.l = removeNodeByReference(root.l, targetNode);
  root.r = removeNodeByReference(root.r, targetNode);

  return root;
}

bool containsEmptyLeaf(Node? root) {
  if (root == null) {
    return false;
  }

  if (root.l == null && root.r == null) {
    // Если это листовая вершина, проверяем содержится ли "∅"
    return root.c == '∅';
  }

  // Рекурсивный вызов для левого и правого поддерева
  return containsEmptyLeaf(root.l) || containsEmptyLeaf(root.r);
}

bool containsEps(Node? root) {
  if (root == null) {
    return false;
  }

  if (root.l == null && root.r == null) {
    // Если это листовая вершина, проверяем содержится ли "ϵ"
    return root.c == 'ϵ';
  }

  // Рекурсивный вызов для левого и правого поддерева
  return containsEps(root.l) || containsEps(root.r);
}

Node? processEmptyLeaves(Node? root) {
  if (root == null) {
    return null;
  }

  // Рекурсивный вызов для левого и правого поддерева
  root.l = processEmptyLeaves(root.l);
  root.r = processEmptyLeaves(root.r);

  // Проверка листовых вершин бинарных операций "·" и "#"
  if ((root.c == '·' || root.c == '#') && root.l == null || root.r == null) {
    // Если листовая вершина содержит "ϵ"
    if (containsEps(root)) {
      if (root.l == 'ϵ') {
        return root.r;
      }
      return root.l;
    }
  }

  return root;
}

Node? removeNodesWithEmptyLeaf(Node? root) {
  if (root == null) {
    return null;
  }

  // Рекурсивный вызов для левого и правого поддерева
  root.l = removeNodesWithEmptyLeaf(root.l);
  root.r = removeNodesWithEmptyLeaf(root.r);

  // Проверяем условия удаления вершины
  if ((root.c == '·' || root.c == '#') && containsEmptyLeaf(root)) {
    // Если операция - "·" или "#", и в листовой вершине содержится "∅", удаляем вершину
    return null;
  }

  return root;
}

Node? removeInvalidNodes(Node? root) {
  if (root == null) {
    return null;
  }

  // Рекурсивный вызов для левого и правого поддерева
  root.l = removeInvalidNodes(root.l);
  root.r = removeInvalidNodes(root.r);

  // Проверка наличия поддеревьев и удаление некорректных узлов
  if (root.c == '·' || root.c == '#' || root.c == '|') {
    if (root.l == null && root.r != null) {
      // Если левое поддерево отсутствует, делаем верхнюю ноду корнем правого поддерева
      return root.r;
    } else if (root.l != null && root.r == null) {
      // Если правое поддерево отсутствует, делаем верхнюю ноду корнем левого поддерева
      return root.l;
    } else if (root.l == null && root.r == null) {
      // Если и левое, и правое поддеревья отсутствуют, удаляем текущую ноду
      return null;
    }
  }

  return root;
}

Node? removeDuplicateSubtrees(Node? root) {
  if (root == null) {
    return null;
  }

  // Рекурсивный вызов для левого и правого поддерева
  root.l = removeDuplicateSubtrees(root.l);
  root.r = removeDuplicateSubtrees(root.r);

  // Проверка операции "|"
  if (root.c == '|') {
    // Проверяем, равны ли левое и правое поддеревья
    if (areSubtreesEqual(root.l, root.r)) {
      // Если поддеревья равны, удаляем правое поддерево
      return root.l;
    }
  }

  return root;
}

// Вспомогательная функция для проверки эквивалентности поддеревьев
bool areSubtreesEqual(Node? subtree1, Node? subtree2) {
  if (subtree1 == null && subtree2 == null) {
    return true;
  }

  if (subtree1 != null && subtree2 != null) {
    return subtree1.c == subtree2.c &&
        areSubtreesEqual(subtree1.l, subtree2.l) &&
        areSubtreesEqual(subtree1.r, subtree2.r);
  }

  return false;
}

Node? leftRotate(Node? root) {
  if (root == null || root.r == null) {
    return root;
  }

  var newRoot = root.r;
  root.r = newRoot!.l;
  newRoot.l = root;
  return newRoot;
}

Node? makeLeft(Node? node) {
  if (node == null) {
    return null;
  }

  if (node.c == '|' && node.r?.c == '|') {
    node = leftRotate(node);
  }

  node?.l = makeLeft(node.l);
  node?.r = makeLeft(node.r);

  return node;
}
