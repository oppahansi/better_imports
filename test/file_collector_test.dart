// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/lib.dart';

void main() {
  group("Collector Tests. Test amount of collected files.", () {
    test("Default config.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.isNotEmpty, true);
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

      expect(collected.isNotEmpty, true);
    });

    test("folders arg provided", () {
      var args = <String>["--folders", "lib/cmds, lib/collectors, lib/utils"];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.isNotEmpty, true);
    });

    test("ignore-files arg provided, ignore some dart files", () {
      var args = <String>[];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collectedDefault = collector.collect();

      args = <String>["--ignore-files", "parser, lib"];
      argResult = argParser.parse(args);
      cfg = Cfg(argResult);

      collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, collectedDefault.length - 2);
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
      var args = <String>[];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collectedDefault = collector.collect();

      args = <String>["--ignore-files-like", r".*sort_cmd\.dart"];
      argResult = argParser.parse(args);
      cfg = Cfg(argResult);

      collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, collectedDefault.length - 1);
    });

    test("recursive arg provided, recursive false", () {
      var args = <String>[];
      var argResult = argParser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collectedDefault = collector.collect();

      args = <String>["--no-recursive"];
      argResult = argParser.parse(args);
      cfg = Cfg(argResult);

      collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length < collectedDefault.length, true);
    });
  });
}
