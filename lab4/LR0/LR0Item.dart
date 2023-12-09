class LR0Item {
  List<String> production;
  int dotPosition;

  LR0Item(this.production, this.dotPosition);

  @override
  String toString() {
    return '${production.sublist(0, dotPosition).join(' ')} . ${production.sublist(dotPosition).join(' ')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LR0Item &&
          runtimeType == other.runtimeType &&
          production == other.production &&
          dotPosition == other.dotPosition;

  @override
  int get hashCode => production.hashCode ^ dotPosition.hashCode;
}
