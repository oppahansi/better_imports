// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/arg_parser.dart';
import 'package:better_imports/cfg.dart';
import 'package:better_imports/file_collector.dart';

void main() {
  group("Collector Tests. Test amount of collected files.", () {
    test("Default config.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collectorResult = collector.collect();

      expect(collectorResult.filteredPaths.isNotEmpty, true);
    });

    test("files arg provided", () {
      var args = <String>["--files", "cfg, cmds, arg_parser"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collectorResult = collector.collect();

      expect(collectorResult.filteredPaths.length, 2);
    });

    test("files-like arg provided", () {
      var args = <String>["--files-like", r".*\.dart"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collectorResult = collector.collect();

      expect(collectorResult.filteredPaths.isNotEmpty, true);
    });

    test("folders arg provided", () {
      var args = <String>["--folders", "lib"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collectorResult = collector.collect();

      expect(collectorResult.filteredPaths.isNotEmpty, true);
    });

    test("ignore-files arg provided, ignore some dart files", () {
      var args = <String>["--ignore-files", "sort_cmd"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.filteredPaths.length, collected.allPaths.length - 1);
    });

    test("ignore-files-like arg provided, ignore all dart files", () {
      var args = <String>["--ignore-files-like", r".*\.dart"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collectorResult = collector.collect();

      expect(collectorResult.filteredPaths.length, 0);
    });

    test("ignore-files-like arg provided, ignore only given files", () {
      var args = <String>["--ignore-files-like", r".*sort_cmd\.dart"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.filteredPaths.length, collected.allPaths.length - 1);
    });

    test("recursive arg provided, recursive false", () {
      var args = <String>["--no-recursive"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.filteredPaths.length == collected.allPaths.length, true);
    });
  });
}
