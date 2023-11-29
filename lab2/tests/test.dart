// fuzz module

import 'dart:math';
import '../Fms.dart';

import '../src/fms/TestingFms.dart';
import '../src/generator/regex/RegexGenerator.dart';
import '../tree/tree.dart';
import '../regex/regex_functions.dart';

class Tester {
  late TestingFms fms;
  late RegExp solutionRegex;
  late RegExp? initialRegex;
  bool useInitialRegexForTest = false;
  Random enigmaOracle = Random();

  /// Store previous generations so we don't test on same words
  Set<String> previousWords = {};

  Tester(this.fms, this.solutionRegex,
      {this.useInitialRegexForTest = false, this.initialRegex = null});

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
    bool testRes = false;
    if (useInitialRegexForTest) {
      print("using initial regex for testing");
      testRes = initialRegex!.stringMatch(word) == word;
    } else {
      testRes = fms.ValidateWord(word);
    }
    bool solutionRes = solutionRegex.stringMatch(word) == word;

    if (testRes != solutionRes) {
      throw "test error: unequal result: got ${testRes} from test and ${solutionRes} from solution";
    }
    print("ok (${testRes})");
  }
}

void TestRandomMutate(
    {Random? destinyWeb = null,
    bool mutate = false,
    String regex = "",
    bool dumpDot = false,
    bool generateShuffles = true,
    bool useInitialRegexForTest = false}) {
  if (regex == "") {
    regex = GenerateRegexInit(3, 2, 5, generateShuffles: generateShuffles);
  }

  print("generated regex: " + regex);
  var root = (postfixToTree(infixToPostfix(augment(regex))));

  Map<Node, List<String>> treeMap = {};
  makeMap(root, treeMap);

  root = simplifyRegex(root, treeMap);
  regex = inorder(root);

  print("parsed regex: " + regex);

  // I build both fms to ensure tests quality and reliability
  FSM fms = FSM(regex);
  fms.build(regex);
  TestingFms testingFms = TestingFms(regex);
  testingFms.build(regex);
  if (dumpDot) {
    print(testingFms.DumpDot());
  }

  // return;

  String solutionRegex = fms.DumpRegex();
  print("solution regex: " + solutionRegex);
  RegExp reg = RegExp(solutionRegex);

  Tester tester = Tester(testingFms, reg,
      useInitialRegexForTest: useInitialRegexForTest,
      initialRegex: RegExp("^(${regex})\$"));
  if (destinyWeb != null) {
    tester.enigmaOracle = destinyWeb;
  }

  tester.PrepareTestingFms();
  print("testing fms has been prepared");

  for (var i = 0; i < 50; i++) {
    tester.RunRandomTest(mutate: mutate);
  }
}

void TestSeedMutate(int seed,
    {bool mutate = false, String regex = "", bool dumpDot = false}) {
  Random prophetOfTheNewDawn = Random(seed);

  TestRandomMutate(
      destinyWeb: prophetOfTheNewDawn,
      mutate: mutate,
      regex: regex,
      dumpDot: dumpDot);
}

void main(List<String> args) {
  TestRandomMutate(
      mutate: true,
      dumpDot: true,
      generateShuffles: false,
      useInitialRegexForTest: false);
}
