// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/lib.dart';

void main() {
  final parser = Parser.setupParser();
  final filesInProject = 20;

  group("Collector Tests. Test amount of collected files.", () {
    test("Default config.", () {
      var argResult = parser.parse([]);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, filesInProject);
    });

    test("files arg provided", () {
      var args = <String>["--files", "cfg, cmds, arg_parser"];
      var argResult = parser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, 3);
    });

    test("files-like arg provided", () {
      var args = <String>["--files-like", r".*\.dart"];
      var argResult = parser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, filesInProject);
    });

    test("folders arg provided", () {
      var args = <String>["--folders", "lib/cmds, lib/collectors, lib/utils"];
      var argResult = parser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, 7);
    });

    test("ignore-files arg provided, ignore some dart files", () {
      var args = <String>["--ignore-files", "parser, lib"];
      var argResult = parser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, filesInProject - 2);
    });

    test("ignore-files-like arg provided, ignore all dart files", () {
      var args = <String>["--ignore-files-like", r".*\.dart"];
      var argResult = parser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, 0);
    });

    test("ignore-files-like arg provided, ignore only given files", () {
      var args = <String>["--ignore-files-like", r".*sort_cmd\.dart"];
      var argResult = parser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, filesInProject - 1);
    });

    test("recursive arg provided, recursive false", () {
      var args = <String>["--no-recursive"];
      var argResult = parser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, 5);
    });
  });
}
