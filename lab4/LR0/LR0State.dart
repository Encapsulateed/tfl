import 'LR0Item.dart';
import 'Analyzer.dart';

class LR0State {
  List<LR0Item> items;

  LR0State(this.items);

  @override
  String toString() {
    return 'State(${items.join(', ')})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LR0State &&
          runtimeType == other.runtimeType &&
          items == other.items;

  @override
  int get hashCode => items.hashCode;
}

void printLR0States(List<LR0State> states) {
  for (var i = 0; i < states.length; i++) {
    print('State $i:\n${states[i]}\n');
  }
}

void printLR0StatesDot(
    List<LR0State> states, Map<String, List<List<String>>> grammar) {
  print('digraph LR0Automaton {');

  for (var i = 0; i < states.length; i++) {
    var currentState = states[i];

    // Вершина
    print('  $i [label="${currentState.toString()}"];');

    for (var symbol in grammar.keys) {
      var nextStateItems = goto(currentState.items, symbol, grammar);

      if (nextStateItems.isNotEmpty) {
        var nextStateIndex = states.indexOf(LR0State(nextStateItems));

        // Дуга
        print('  $i -> $nextStateIndex [label="$symbol"];');
      }
    }
  }

  print('}');
}
