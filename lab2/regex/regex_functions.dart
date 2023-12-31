import '../tree/tree.dart';

final Map<String, int> prec = {'(': 0, '|': 1, '#': 2, '·': 3, '*': 4};

String inorder(Node? root) {
  if (root == null) {
    return '';
  }
  final out = inorder(root.l) + root.c + inorder(root.r);
  if (root.c == '|' || root.c == '·' || root.c == '*' || root.c == '#') {
    return '(${out})'.replaceAll('·', '');
  }
  return out.replaceAll('·', '');
}

String augment(String src) {
  if (src.isEmpty) {
    return 'ϵ';
  }
  src = src.replaceAll(RegExp(r'\*+'), '*');
  final dst = <String>[];
  for (int i = 0; i < src.length; i++) {
    if (i > 0 &&
        !(src[i] == '|' ||
            src[i] == '*' ||
            src[i] == '#' ||
            src[i] == ')' ||
            src[i - 1] == '(' ||
            src[i - 1] == '|' ||
            src[i - 1] == '#')) {
      dst.add('·');
    }
    dst.add(src[i]);
  }

  return dst.join();
}

String infixToPostfix(String exp) {
  final stack = <String>[];
  final output = <String>[];

  for (final c in exp.runes) {
    final char = String.fromCharCode(c);
    if (RegExp(r'[a-zA-Z]|ϵ|∅').hasMatch(char) ||
        RegExp(r'[а-яА-Я]|ϵ|∅').hasMatch(char)) {
      output.add(char);
    } else if (char == '(') {
      stack.add(char);
    } else if (char == ')') {
      while (stack.isNotEmpty && stack.last != '(') {
        output.add(stack.removeLast());
      }
      stack.removeLast();
    } else {
      while (stack.isNotEmpty && prec[stack.last]! >= prec[char]!) {
        output.add(stack.removeLast());
      }
      stack.add(char);
    }
  }

  while (stack.isNotEmpty) {
    output.add(stack.removeLast());
  }

  return output.join();
}

Set<String> getRegexAlf(String regex) {
  Set<String> alf = {};
  for (var i = 0; i < regex.length; i++) {
    if (regex[i] != '*' &&
        regex[i] != '|' &&
        regex[i] != '#' &&
        regex[i] != '+' &&
        regex[i] != '(' &&
        regex[i] != ')' &&
        regex[i] != 'ϵ' &&
        regex[i] != '∅') {
      alf.add(regex[i]);
    }
  }
  return alf;
}
