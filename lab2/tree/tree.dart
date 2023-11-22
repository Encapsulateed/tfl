import 'dart:io';
import '../regex/regex_functions.dart';
class Node {
  String c;
  Node ?l;
  Node ?r;

  Node(this.c, {this.l, this.r});
}

Node? postfixToTree(String postfix) {
  if (postfix.isEmpty) {
    return null;
  }

  final stack = <Node>[];
  for (final c in postfix.runes) {
    final char = String.fromCharCode(c);
    if (char == '|' || char == '·') {
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
  } else if (node.c == '·') {
    return nullable(node.l) && nullable(node.r);
  } else if (node.c == '|') {
    return nullable(node.l) || nullable(node.r);
  } else {
    return false;
  }
}

Node? deriv(Node? root, String c) {
  final stack = [root];
  while (stack.isNotEmpty) {
    final node = stack.removeLast();
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

bool match(String regex, String string, {bool showInference = false}) {
  final node = postfixToTree(infixToPostfix(augment(regex)));

  if (showInference) {
    print(inorder(node));
  }
  for (final c in string.runes) {
    deriv(node, String.fromCharCode(c));
    if (showInference) {
      print(inorder(node));
    }
  }
  return nullable(node);
}

String inorder(Node? root) {
  if (root == null) {
    return '';
  }
  final out = inorder(root.l) + root.c + inorder(root.r);
  if (root.c == '|' || root.c == '·' || root.c == '*') {
    return '(${out})';
  }
  return out;
}
