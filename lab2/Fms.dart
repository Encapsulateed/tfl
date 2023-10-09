import 'lab2.dart';
import 'dart:io';

class FMS {
  Set<String> alphabet = {};
  Set<State> States = {};
    Set<State> StartStates = {};
      Set<State> FinalStates = {};
  List<Transaction> transaction= [];
}

class State {
  String name = '';
  String regex = '';
}

class Transaction{
  State from = State();
  State to = State();
  String letter = '';  
}

