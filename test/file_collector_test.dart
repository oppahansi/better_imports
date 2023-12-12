import 'package:better_imports/lib.dart';
import 'package:test/test.dart';

void main() {
  final parser = Parser.setupParser();
  final filesInProject = 19;

  group("Testing file collector.", () {
    test("Test amount of collected files. Default config.", () {
      var argResult = parser.parse([]);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, filesInProject);
    });

    test("Test amount of collected files. files provided.", () {
      var args = <String>["--files", "cfg, cmds, parser"];
      var argResult = parser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, args.length);
    });

    test("Test amount of collected files. files-like provided.", () {
      var args = <String>["--files-like", r".*\.dart"];
      var argResult = parser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, filesInProject);
    });

    test("Test amount of collected files. folders provided.", () {
      var args = <String>["--folders", "lib/cmds, lib/collectors, lib/utils"];
      var argResult = parser.parse(args);
      var cfg = Cfg(argResult);

      var collector = Collector(cfg: cfg);
      var collected = collector.collect();

      expect(collected.length, 7);
    });
  });
}
