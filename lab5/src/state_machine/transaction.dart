import 'state.dart';

class Transaction {
  State from = State();
  State to = State();
  String letter = '';

  Transaction();

  Transaction.fromData(this.from, this.to, this.letter);
}
