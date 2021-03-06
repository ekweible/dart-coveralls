library dart_coveralls.calc;

import 'dart:io';

import 'package:dart_coveralls/dart_coveralls.dart';

import 'command_line.dart';

class CalcPart extends CommandLinePart {
  final ArgParser parser;

  CalcPart() : parser = _initializeParser();

  static ArgParser _initializeParser() {
    return new ArgParser(allowTrailingOptions: true)
      ..addFlag("help", help: "Prints this help", negatable: false)
      ..addOption("workers",
          help: "Number of workers for parsing", defaultsTo: "1")
      ..addOption("output", help: "Output file path")
      ..addOption("package-root",
          help: "Root of the analyzed package", defaultsTo: ".");
  }

  execute(ArgResults res) {
    if (res.rest.length != 1) return print("Please specify a test file to run");

    var pRoot = new Directory(res["package-root"]);
    var file = new File(res.rest.single);
    var workers = int.parse(res["workers"]);

    if (!pRoot.existsSync()) return print("Root directory does not exist");
    if (!file.existsSync()) return print("Dart file does not exist");

    var collector = new LcovCollector(pRoot, file);

    return collector.getLcovInformation(workers: workers).then((r) {
      print(r.processResult.stdout);
      if (res["output"] != null) {
        return new File(res["output"]).writeAsStringSync(r.result);
      }
      return print(r.result);
    });
  }
}
