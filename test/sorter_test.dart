// Dart Imports
import 'dart:io';

// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/src/arg_parser.dart';
import 'package:better_imports/src/cfg.dart';
import 'package:better_imports/src/file_path_collector.dart';
import 'package:better_imports/src/import_sorter.dart';

// Relative Project Imports
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

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(
        collected.filteredPaths.length,
        sorted.length,
      );
    });

    test("Sorting file. With comments.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filteredPaths.length);
      expect(sorted.first.sortedContent, sortedFileWithComments);
    });

    test("Sorting file. With comments. No Dart Fmt", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.dartFmt = false;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filteredPaths.length);
      expect(sorted.first.sortedContent, sortedFileWithCommentsNoDartFmt);
    });

    test("Sorting file. No comments.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.comments = false;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filteredPaths.length);

      expect(sorted.first.sortedContent, sortedFileNoComments);
    });

    test("Sorting file. No comments. No Dart Fmt", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.comments = false;
      cfg.dartFmt = false;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filteredPaths.length);

      expect(sorted.first.sortedContent, sortedFileNoCommentsNoDartFmt);
    });

    test("Sorting file. Relative Imports.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.relative = true;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filteredPaths.length);

      expect(sorted.first.sortedContent, sortedFileWithCommentsRelative);
    });

    test("Sorting file. Relative Imports. No Dart Fmt", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.relative = true;
      cfg.dartFmt = false;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filteredPaths.length);

      expect(
          sorted.first.sortedContent, sortedFileWithCommentsRelativeNoDartFmt);
    });
  });
}
