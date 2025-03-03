// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/src/arg_parser.dart';
import 'package:better_imports/src/cfg.dart';
import 'package:better_imports/src/file_paths_collector.dart';

void main() {
  group("Collector Tests. Test amount of collected files.", () {
    test("Default config.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      var collector = FilePathsCollector(cfg: cfg);
      var collectorResult = collector.collect();

      expect(collectorResult.filtered.isNotEmpty, true);
    });

    test("files arg provided", () {
      var args = <String>["--files", "cfg, cmds, arg_parser"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = FilePathsCollector(cfg: cfg);
      var collectorResult = collector.collect();

      expect(collectorResult.filtered.length, 2);
    });

    test("files-like arg provided", () {
      var args = <String>["--files-like", r".*\.dart"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = FilePathsCollector(cfg: cfg);
      var collectorResult = collector.collect();

      expect(collectorResult.filtered.isNotEmpty, true);
    });

    test("folders arg provided", () {
      var args = <String>["--folders", "lib"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = FilePathsCollector(cfg: cfg);
      var collectorResult = collector.collect();

      expect(collectorResult.filtered.isNotEmpty, true);
    });

    test(
        "ignore-files arg provided, ignore some dart files without .dart in name",
        () {
      var args = <String>["--ignore-files", "sorted_result"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.filtered.length, collected.all.length - 1);
    });

    test("ignore-files arg provided, ignore some dart files with .dart in name",
        () {
      var args = <String>["--ignore-files", "sorted_result.dart"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.filtered.length, collected.all.length - 1);
    });

    test("ignore-files-like arg provided, ignore all dart files", () {
      var args = <String>["--ignore-files-like", r".*\.dart"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = FilePathsCollector(cfg: cfg);
      var collectorResult = collector.collect();

      expect(collectorResult.filtered.length, 0);
    });

    test("ignore-files-like arg provided, ignore only given files", () {
      var args = <String>["--ignore-files-like", r".*sorted_result\.dart"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.filtered.length, collected.all.length - 1);
    });

    test("recursive arg provided, recursive false", () {
      var args = <String>["--no-recursive"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.filtered.length == collected.all.length, true);
    });
  });
}
