class conjunctiveProdutcion {
  String left;
  List<List<String>> possible_right;

  conjunctiveProdutcion(this.left, this.possible_right);

  @override
  String toString() {
    return '$left -> ${possible_right}';
  }

 
}
