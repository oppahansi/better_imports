// Dart Imports
import 'dart:io';

// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/lib.dart';

void main() {
  group("Cfg Tests.", () {
    test("default config", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      expect(cfg.sortPath, Directory.current.path);
      expect(cfg.projectName, Directory.current.name);
      expect(cfg.recursive, true);
      expect(cfg.comments, true);
      expect(cfg.silent, false);
      expect(cfg.relative, false);
      expect(cfg.folders, [
        "lib",
        "bin",
        "res",
        "example",
        "test",
        "tests",
        "integration_test",
        "integration_tests",
        "test_driver",
      ]);
      expect(cfg.files, []);
      expect(cfg.ignoreFiles, []);
      expect(cfg.filesLike, []);
      expect(cfg.ignoreFilesLike, [
        r".*generated_plugin_registrant\.dart",
        r".*\.g\.dart",
        r".*\.gr\.dart",
        r".*\.freezed\.dart",
      ]);
    });

    test("cfg arg provided. loading external", () {
      var argResult = argParser.parse(
        [
          "--cfg",
          r"D:\dev\workspace\dart\better_imports\res\external_cfg.yaml"
        ],
      );
      var cfg = Cfg(argResult);

      expect(cfg.projectName, "external_cfg");
      expect(cfg.folders, ["lib"]);
    });

    test("cli args passed in", () {
      var argResult = argParser.parse([
        "-r",
        "--no-comments",
        "--no-recursive",
        "-s",
        "--relative",
        "--project-name",
        "argsProjectName",
        "--folders",
        "lib/cmds, lib/collectors, lib/utils",
        "--files",
        "cfg, cmds, parser",
        "--ignore-files",
        "parser",
        "--files-like",
        r".*\.dart",
        "--ignore-files-like",
        r".*\.dart",
      ]);
      var cfg = Cfg(argResult);

      expect(cfg.sortPath, Directory.current.path);
      expect(cfg.projectName, "argsProjectName");
      expect(cfg.recursive, false);
      expect(cfg.comments, false);
      expect(cfg.silent, true);
      expect(cfg.relative, true);
      expect(cfg.folders, [
        "lib/cmds",
        "lib/collectors",
        "lib/utils",
      ]);
      expect(cfg.files, [
        "cfg",
        "cmds",
        "parser",
      ]);
      expect(cfg.ignoreFiles, ["parser"]);
      expect(cfg.filesLike, [r".*\.dart"]);
      expect(cfg.ignoreFilesLike, [r".*\.dart"]);
    });
  });
}
