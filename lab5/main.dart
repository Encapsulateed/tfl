import './src/utils/grammar.dart';
import 'src/classes/GSSNode.dart';
import 'src/classes/GSStack.dart';
import 'src/lr0/LR0Fms.dart';
import 'src/lr0/LR0Table.dart';
import 'src/lr0/lr0Parser.dart';
import 'src/state_machine/FSM.dart';
import 'src/utils/Production.dart';
import 'src/utils/conjunctiveGrammar.dart';
import 'src/utils/stack.dart';
// import 'src/lr0/base/LR0Fms.dart';

void main(List<String> arguments) {
  List<Grammar> grammars = [];

  var cg = conjunctiveGrammar.fromFile('input.txt');

  for(var grammar in cg.possible_grammars){
    print(grammar);
  } 
 
}

