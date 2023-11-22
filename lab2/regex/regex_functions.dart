final Map<String, int> prec = {'(': 0, '|': 1, '·': 2, '*': 3};

String augment(String src) {
  if (src.isEmpty) {
    return 'ϵ';
  }
  final List<String> dst = [];
  for (int i = 0; i < src.length; i++) {
    if (i > 0 &&
        !(src[i] == '|' ||
            src[i] == ')' ||
            src[i - 1] == '(' ||
            src[i - 1] == '|')) {
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
    if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
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
