// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/lib.dart';

void main() {
  final expectedFilesInProject = 20;
  final expectedFilesInProjectNoRecursive = 5;

  group("Collector Tests. Test amount of collected files.", () {
    test("Default config.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, expectedFilesInProject);
    });

    test("files arg provided", () {
      var args = <String>["--files", "cfg, cmds, arg_parser"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, 3);
    });

    test("files-like arg provided", () {
      var args = <String>["--files-like", r".*\.dart"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, expectedFilesInProject);
    });

    test("folders arg provided", () {
      var args = <String>["--folders", "lib/cmds, lib/collectors, lib/utils"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, 7);
    });

    test("ignore-files arg provided, ignore some dart files", () {
      var args = <String>["--ignore-files", "parser, lib"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, expectedFilesInProject - 2);
    });

    test("ignore-files-like arg provided, ignore all dart files", () {
      var args = <String>["--ignore-files-like", r".*\.dart"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, 0);
    });

    test("ignore-files-like arg provided, ignore only given files", () {
      var args = <String>["--ignore-files-like", r".*sort_cmd\.dart"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, expectedFilesInProject - 1);
    });

    test("recursive arg provided, recursive false", () {
      var args = <String>["--no-recursive"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, expectedFilesInProjectNoRecursive);
    });
  });
}
