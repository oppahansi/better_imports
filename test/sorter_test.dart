// Dart Imports
import 'dart:io';

// Package Imports
import 'package:dart_style/dart_style.dart';
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/lib.dart';

// Relative Project Imports
import '../res/sorter_fixtures.dart';

void main() {
  final formatter = DartFormatter();

  group("Sorter Tests.", () {
    setUp(() {
      File("res/unsorted.dart").writeAsStringSync(unsortedFile);
    });

    tearDown(() {
      File("res/unsorted.dart").delete();
    });

    test(
        "Default config. Make sure collector and sorter return the same amount.",
        () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collectedResult = collector.collect();

      var sorter = Sorter(collectorResult: collectedResult, cfg: cfg);
      var sorted = sorter.sort();

      expect(
        collectedResult.filteredPaths.length,
        sorted.length,
      );
    });

    test("Sorting file. With comments.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res"];
      cfg.files = ["unsorted.dart"];

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      var sorter = Sorter(collectorResult: collected, cfg: cfg);
      var sorted = sorter.sort();

      expect(sorted.length, collected.filteredPaths.length);

      print(sortedFileWithComments);
      print(sorted.first.formattedContent);

      expect(sorted.first.formattedContent,
          formatter.format(sortedFileWithComments));
    });
  });
}
