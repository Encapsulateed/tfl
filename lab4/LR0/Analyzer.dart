import 'LR0Item.dart';
import 'LR0State.dart';

List<LR0Item> closure(List<LR0Item> items, Map<String, List<List<String>>> grammar) {
  var closureItems = Set<LR0Item>.from(items);
  var changed = true;

  while (changed) {
    changed = false;
    for (var item in List.from(closureItems)) {
      var dotPosition = item.dotPosition;
      var production = item.production;

      if (dotPosition < production.length && grammar.containsKey(production[dotPosition])) {
        var newProductions = grammar[production[dotPosition]] ?? <List<String>>[];
        for (var newProduction in newProductions) {
          var newItem = LR0Item(newProduction, 0);
          if (!closureItems.contains(newItem)) {
            closureItems.add(newItem);
            changed = true;
          }
        }
      }
    }
  }

  return List.from(closureItems);
}


List<LR0Item> goto(List<LR0Item> items, String symbol, Map<String, List<List<String>>> grammar) {
  var newItems = <LR0Item>[];

  for (var item in items) {
    var dotPosition = item.dotPosition;
    var production = item.production;

    if (dotPosition < production.length && production[dotPosition] == symbol) {
      newItems.add(LR0Item(production, dotPosition + 1));
    }
  }

  return closure(newItems, grammar);
}

List<LR0State> buildLR0States(Map<String, List<List<String>>> grammar) {
  var startSymbol = grammar.keys.first;
  var startItem = LR0Item([startSymbol] + grammar[startSymbol]!.first, 0);
  var startState = LR0State(closure([startItem], grammar));

  var states = [startState];
  var queue = [startState];

  while (queue.isNotEmpty) {
    var currentState = queue.removeAt(0);

    for (var symbol in grammar.keys) {
      var nextStateItems = goto(currentState.items, symbol, grammar);

      if (nextStateItems.isNotEmpty) {
        var nextState = LR0State(nextStateItems);

        if (!states.contains(nextState)) {
          states.add(nextState);
          queue.add(nextState);
        }
      }
    }
  }

  return states;
}


