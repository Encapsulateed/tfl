// fuzz module

import 'dart:math';
import '../functions.dart';
import '../Fms.dart';

import '../src/fms/TestingFms.dart';
import '../src/generator/regex/gen.dart';

class Tester {
  late TestingFms fms;
  late RegExp solutionRegex;
  Random enigmaOracle = Random();

  /// Store previous generations so we don't test on same words
  Set<String> previousWords = {};

  Tester(this.fms, this.solutionRegex);

  void PrepareTestingFms() {
    fms.CalculateTransitionMatrix();
    fms.CalculateAdjacencyMatrix();
    fms.CalculateReachabilityMatrix();
    fms.BuildPossibilityMap();
    fms.BuildValidityMap();
  }

  void RunRandomTest({bool mutate = true}) {
    String word = fms.GenerateWord(enigmaOracle, mutate: mutate);
    int i = 10;
    while (previousWords.contains(word) && i > 0) {
      word = fms.GenerateWord(enigmaOracle, mutate: mutate);
      i--;
    }

    previousWords.add(word);

    RunTest(word);
  }

  void RunTest(String word) {
    print("comparing results on word: " + word);
    bool testRes = fms.ValidateWord(word);
    bool solutionRes = solutionRegex.stringMatch(word) == word;

    if (testRes != solutionRes) {
      throw "test error: unequal result: got ${testRes} from test and ${solutionRes} from solution";
    }
    print("ok");
  }
}

void TestRandomNoMutate() {
  String regex = "";
  while (regex.length < 3) {
    regex = GenerateRegexInit(7, 2, 10);
  }
  // String regex =  "e";
  print("generated regex: " + regex);

  regex = MainSymplify(regex);
  print("parsed regex: " + regex);

  // I build both fms to ensure tests quality and reliability
  FMS fms = FMS(regex);
  fms.build(regex);
  TestingFms testingFms = TestingFms(regex);
  testingFms.build(regex);
  // testingFms.Print();
  // print(testingFms.DumpDot());

  String solutionRegex = fms.DumpRegex();
  print("solution regex: " + solutionRegex);
  RegExp reg = RegExp(solutionRegex);

  Tester tester = Tester(testingFms, reg);
  tester.PrepareTestingFms();
  print("testing fms prepared");

  for (var i = 0; i < 10; i++) {
    tester.RunRandomTest();
  }
}

void TestSeedNoMutate() {}

void main(List<String> args) {
  TestRandomNoMutate();
}
