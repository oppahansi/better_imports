// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/lib.dart';

void main() {
  group("Sorter Tests", () {
    test("Default config.", () {
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
  });
}
