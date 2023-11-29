import '../regex/regex_functions.dart';

class Node {
  String c;
  Node? l;
  Node? r;
  List<String> regexes = [];
  Node(this.c, {this.l, this.r});
}

Node? postfixToTree(String postfix) {
  if (postfix.isEmpty) {
    return null;
  }

  final stack = <Node>[];
  for (int i = 0; i < postfix.length; i++) {
    final char = postfix[i];
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
  } else if (node.c == '|') {
    return nullable(node.l) || nullable(node.r);
  } else if (node.c == '·' || node.c == '#') {
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
  if (root.c == '·' || root.c == '#') {
    // Если листовая вершина содержит "ϵ"
    if (containsEps(root)) {
      if (root.l?.c == 'ϵ') {
        return root.r;
      }
      return root.l;
    }
  } else if (root.c == '|') {
    // a*|ϵ == a*
    // ϵ|a* == a*
    if (containsEps(root)) {
      if (root.l?.c == '*') {
        return root.l;
      } else if (root.r?.c == '*') {
        return root.r;
      }
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

  // Проверка листовых вершин бинарных операций "·" и "#"

  if ((root.c == '·' || root.c == '#')) {
    // Если листовая вершина содержит "∅"
    if (containsEmptyLeaf(root)) {
      return Node('∅');
    }
  } else if (root.c == '|') {
    if (containsEmptyLeaf(root)) {
      if (root.l?.c == '∅') {
        return root.r;
      }
      return root.l;
    }
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
  if (root.c == '*') {
    if (root.l == null && root.r == null) {
      // Если и левое, и правое поддеревья отсутствуют, удаляем текущую ноду
      return null;
    }
  }

  return root;
}

Node? removeSameOr(Node? root, Map<Node, List<String>> treeMap) {
  if (root == null) {
    return null;
  }
  root = removeInvalidNodes(root);
  List<Node> keys = treeMap.keys.toList();

  for (int i = 0; i < treeMap.length; i++) {
    var curr_lst = treeMap[keys[i]];
    if (curr_lst == null) {
      continue;
    }
    if (curr_lst.length != 2) {
      continue;
    }

    // В альтернативе просто 2 одинаковых значения | [a,a] -> [a]
    if (curr_lst[0] == curr_lst[1]) {
      // удаляю правое, потому что могу себе позволить
      root = removeNodeByReference(root, keys[i].r);
      //перестариваем карту после каждого удаления
      treeMap = Map<Node, List<String>>();
      makeMap(root, treeMap);
      root = removeSameOr(root, treeMap);
    }

    for (int j = i + 1; j < treeMap.length; j++) {
      var cmp_lst = treeMap[keys[j]];
      if (cmp_lst == null) {
        break;
      }
      bool rm_flag = false;

      if (curr_lst[0] == cmp_lst[0]) {
        root = removeNodeByReference(root, keys[j].l);
        rm_flag = true;
      } else if (curr_lst[0] == cmp_lst[1]) {
        root = removeNodeByReference(root, keys[j].r);
        rm_flag = true;
      } else if (curr_lst[1] == cmp_lst[0]) {
        root = removeNodeByReference(root, keys[j].l);
        rm_flag = true;
      } else if (curr_lst[1] == cmp_lst[1]) {
        root = removeNodeByReference(root, keys[j].r);
        rm_flag = true;
      }

      if (rm_flag) {
        rm_flag = false;

        treeMap = Map<Node, List<String>>();
        makeMap(root, treeMap);
        root = removeSameOr(root, treeMap);
      }
    }
  }
  return root;
}

Node? ssnf(Node? root) {
  if (root == null) {
    return null;
  }

  // Рекурсивный вызов для левого и правого поддерева
  root.l = removeNodesWithEmptyLeaf(root.l);
  root.r = removeNodesWithEmptyLeaf(root.r);

  // Проверяем условия удаления вершины
  if ((root.c == '*' && root.l?.c == '*')) {
    var t = clone(root.l?.l)!;

    root.l = t;

    return root;
  }
  if ((root.c == '*' && root.r?.c == '*')) {
    var t = clone(root.r?.l)!;
    root.r = t;

    return root;
  }

  return root;
}

Node? simplifyRegex(Node? root, Map<Node, List<String>> treeMap) {
  root = removeInvalidNodes(ssnf(root));
  root = removeInvalidNodes(processEmptyLeaves(root));

  root = removeInvalidNodes(removeNodesWithEmptyLeaf(root));
  makeMap(root, treeMap);

  root = removeInvalidNodes(removeSameOr(root, treeMap));

  return removeInvalidNodes(root);
}

void printMap(Map<Node, List<String>> treeMap) {
  treeMap.forEach((key, value) {
    print('[${inorder(key)}] <-> (${key.c}): $value');
  });
}

Node? makeMap(Node? root, Map<Node, List<String>> treeMap) {
  if (root == null) {
    return null;
  }

  if (root.c == '|') {
    treeMap[root] = [
      inorder(makeMap(root.l, treeMap)),
      inorder(makeMap(root.r, treeMap))
    ];
  }
  else if(root.c == '*'){
    Map<Node, List<String>> star_map = {};
    var t_r = root.l;

    star_map[root] = [
      inorder(makeMap(t_r?.l, star_map)),
      inorder(makeMap(t_r?.r, star_map))
    ];
    t_r = removeSameOr(t_r, star_map);
  }
  else {
    root.l = makeMap(root.l, treeMap);
    root.r = makeMap(root.r, treeMap);
  }
  return root;
}
