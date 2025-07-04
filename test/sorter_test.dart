// Dart Imports
import 'dart:io';

// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/src/arg_parser.dart';
import 'package:better_imports/src/cfg.dart';
import 'package:better_imports/src/file_paths_collector.dart';
import 'package:better_imports/src/files_sorter.dart';

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
        cfg.dryRun = true;

        var collector = FilePathsCollector(cfg: cfg);
        var collected = collector.collect();

        var sorted = sort(collected, cfg);

        expect(collected.filtered.length, sorted.length);
      },
    );

    test("Sorting file. With comments.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);
      expect(sorted.first.sorted, sortedFileWithComments);
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

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileNoComments);
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

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileWithCommentsRelative);
    });
  });

  group("Sorter Tests. Multiline with show. Issue #4", () {
    setUp(() {
      File("res/unsorted.dart").writeAsStringSync(unsortedFileIssue4);
    });

    tearDown(() {
      File("res/unsorted.dart").delete();
    });

    test("Sorting file. Multiline with show.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileIssue4);
    });
  });

  group("Sorter Tests. Multilines after directives.", () {
    setUp(() {
      File("res/unsorted.dart").writeAsStringSync(unsortedFileMultiline);
    });

    tearDown(() {
      File("res/unsorted.dart").delete();
    });

    test("Sorting file. Multiline with show.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileMultiline);
    });
  });

  group("Sorter Tests. Extra long directives.", () {
    setUp(() {
      File("res/unsorted.dart").writeAsStringSync(unsortedFileLongDirectives);
    });

    tearDown(() {
      File("res/unsorted.dart").delete();
    });

    test("Sorting file. Extra long directives.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileLongDirectives);
    });
  });
}
