import '../utils/grammar.dart';
import 'LR0Fms.dart';
import 'LR0Table.dart';

class LR0Parser {
  LR0Table _table = LR0Table.emtpy();
  Grammar _grammar = Grammar();
  LR0FMS _fsm = LR0FMS.empty();

  LR0Parser(Grammar grammar) {
    _table = LR0Table(_grammar);
  }
}
