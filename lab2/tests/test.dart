// fuzz module

import 'dart:math';

// import '../Fms.dart';
import '../lab2.dart';
import '../src/fms/TestingFms.dart';
// import '../src/generator/regex/gen.dart';

class Tester {
  late TestingFms fms;
  late RegExp solutionRegex;
  Random enigmaOracle = Random();

  Tester(this.fms, this.solutionRegex);

  void PrepareTestingFms() {
    fms.CalculateTransitionMatrix();
    fms.CalculateAdjacencyMatrix();
    fms.CalculateReachabilityMatrix();
    fms.BuildPossibilityMap();
    fms.BuildValidityMap();
  }

  void RunRandomTest({bool? mutate}) {
    String word = fms.GenerateWord(enigmaOracle);
    if (mutate ?? false) {
      word = fms.MutateWord(word);
    }

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
  // String regex = GenerateRegexInit(3, 2, 10);
  String regex = "(c|cb)|b|b";
  print("generated regex: " + regex);

  regex = prepareRegex(regex);
  print("parsed regex: " + regex);

  // I build both fms to ensure tests quality and reliability
  // FMS fms = FMS(regex);
  // fms.build(regex);
  TestingFms testingFms = TestingFms(regex);
  testingFms.build(regex);
  testingFms.Print();
  print(testingFms.DumpDot());

  // TODO: get regex from fms
  String solutionRegex = regex;
  print("solution regex: " + solutionRegex);
  RegExp reg = RegExp(regex);

  Tester tester = Tester(testingFms, reg);
  tester.PrepareTestingFms();

  for (var i = 0; i < 10; i++) {
    tester.RunRandomTest();
  }
}

void TestSeedNoMutate() {}

void main(List<String> args) {
  TestRandomNoMutate();
  // String regex = "abc|de";
  // RegExp reg = RegExp(regex);
  // String word = "abc";

  // print(reg.stringMatch(word) == word);
}
