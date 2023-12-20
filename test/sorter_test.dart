// Dart Imports
import 'dart:io';

// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/lib.dart';

import '../res/sorter_fixtures.dart';

void main() {
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
      var collected = collector.collect();

      var sorter = Sorter(paths: collected, cfg: cfg);
      var sorted = sorter.sort();

      expect(
        collected.length,
        sorted.length,
      );
    });

    test("Sorting file. With comments.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["res"];

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      var sorter = Sorter(paths: collected, cfg: cfg);
      var sorted = sorter.sort();

      expect(sorted.length, collected.length);
      expect(sorted.first.formattedContent, sortedFileWithComments);
    });
  });
}
