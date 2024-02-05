class Production {
  String left;
  List<String> right;

  Production(this.left, this.right);

  @override
  String toString() {
    return '\n$left -> ${right.join('')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      this.toString() == other.toString() ||
      (this.left == (other as Production).left && this.right == other.right);
}
