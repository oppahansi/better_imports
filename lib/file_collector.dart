// Dart Imports
import 'dart:io';

// Project Imports
import 'package:better_imports/cfg.dart';
import 'package:better_imports/log.dart';

class Collector {
  final Cfg cfg;
  final _allFilePaths = <String>[];
  final _filteredFilePaths = <String>[];

  Collector({required this.cfg});

  CollectorResult collect() {
    _collectInFolders();

    _filteredFilePaths.addAll(List.from(_allFilePaths));

    _filterIgnoredFiles();
    _processOptions();

    return CollectorResult(
        allPaths: _allFilePaths, filteredPaths: _filteredFilePaths);
  }

  void _collectInFolders() {
    log.fine("┠ Collecting files in all folders..");

    for (var folder in cfg.folders) {
      var folderPath = '${cfg.sortPath}${Platform.pathSeparator}$folder';

      if (!Directory(folderPath).existsSync()) {
        continue;
      }

      var entities = Directory(folderPath).listSync(recursive: cfg.recursive);

      for (FileSystemEntity entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          _allFilePaths.add(entity.path);
        }
      }
    }
  }

  void _filterIgnoredFiles() {
    log.fine("┠ Removing ignored files..");

    for (var pattern in cfg.ignoreFilesLike) {
      log.fine("┠─ Removing ignored file like: $pattern");

      _filteredFilePaths.removeWhere(
        (filePath) => RegExp(pattern).hasMatch(filePath),
      );
    }

    for (var ignored in cfg.ignoreFiles) {
      log.fine("┠─ Removing ignored file: $ignored");

      _filteredFilePaths.removeWhere(
        (filePath) =>
            filePath.endsWith("${Platform.pathSeparator}$ignored.dart"),
      );
    }
  }

  void _processOptions() {
    if (cfg.files.isNotEmpty) {
      log.fine("┠ Files option provided.");

      _retainNamedFiles(cfg.files);
    } else if (cfg.filesLike.isNotEmpty) {
      log.fine("┠ Files-like option provided.");

      _retainFilesLike();
    }
  }

  void _retainNamedFiles(List<String> files) {
    log.fine("┠─ Retaining only named files..");

    _filteredFilePaths.retainWhere((element) {
      var fileName = element.split(Platform.pathSeparator).last;

      return files.contains(fileName) ||
          files.contains(fileName.replaceAll(".dart", ""));
    });
  }

  void _retainFilesLike() {
    log.fine("┠─ Retaining only files like: ${cfg.filesLike}");

    _filteredFilePaths.retainWhere(
        (element) => RegExp(cfg.filesLike.join("|")).hasMatch(element));
  }
}

class CollectorResult {
  final List<String> allPaths;
  final List<String> filteredPaths;

  CollectorResult({required this.allPaths, required this.filteredPaths});
}
