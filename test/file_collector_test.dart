// Dart Imports
import 'dart:io';

// Package Imports
import 'package:path/path.dart' as path;
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
      var args = <String>[
        "--files",
        "cfg, cmds.dart, ${path.join('lib', 'src', 'arg_parser.dart')}",
      ];
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
      },
    );

    test(
      "ignore-files arg provided, ignore some dart files with .dart in name",
      () {
        var args = <String>["--ignore-files", "sorted_result.dart"];
        var argResult = argParser.parse(args);
        var cfg = Cfg(argResult);

        var collector = FilePathsCollector(cfg: cfg);
        var collected = collector.collect();

        expect(collected.filtered.length, collected.all.length - 1);
      },
    );

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

    test("symlinked dependency folders are ignored", () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'better_imports_symlink_test_',
      );
      addTearDown(() => tempRoot.deleteSync(recursive: true));

      final projectRoot = Directory(path.join(tempRoot.path, 'project'));
      projectRoot.createSync();

      final libDir = Directory(path.join(projectRoot.path, 'lib'));
      libDir.createSync();
      File(
        path.join(libDir.path, 'app.dart'),
      ).writeAsStringSync("import 'dart:io';\n");

      final depRoot = Directory(path.join(tempRoot.path, 'dependency_pkg'));
      depRoot.createSync();
      File(
        path.join(depRoot.path, 'plugin.dart'),
      ).writeAsStringSync("import 'dart:io';\n");

      final symlinkDir = Directory(
        path.join(projectRoot.path, 'ios', '.symlinks', 'plugins'),
      );
      symlinkDir.createSync(recursive: true);
      Link(
        path.join(symlinkDir.path, 'dependency_pkg'),
      ).createSync(depRoot.path, recursive: true);

      final cfg = Cfg(argParser.parse([]));
      cfg.sortPath = projectRoot.path;
      cfg.folders = <String>[];
      cfg.recursive = true;

      final collector = FilePathsCollector(cfg: cfg);
      final collected = collector.collect();

      expect(
        collected.filtered.any(
          (filePath) => filePath.contains('.symlinks/plugins'),
        ),
        isFalse,
      );
      expect(
        collected.filtered.any(
          (filePath) => filePath.endsWith(path.join('lib', 'app.dart')),
        ),
        isTrue,
      );
    });
  });
}
