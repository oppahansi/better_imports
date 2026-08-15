// Dart Imports
import 'dart:io';

// Package Imports
import 'package:path/path.dart' as p;

// Project Imports
import 'package:better_imports/src/cfg.dart';
import 'package:better_imports/src/file_paths.dart';
import 'package:better_imports/src/log.dart';

class FilePathsCollector {
  final Cfg cfg;
  final _allFilePaths = <String>[];
  final _filteredFilePaths = <String>[];

  FilePathsCollector({required this.cfg});

  FilePaths collect() {
    _collectInFolders();

    _filteredFilePaths.addAll(List.from(_allFilePaths));

    _filterFilePaths();

    return FilePaths(all: _allFilePaths, filtered: _filteredFilePaths);
  }

  void _collectInFolders() {
    log.fine("┠ Collecting files in all folders..");

    if (cfg.folders.isEmpty) {
      log.fine("┠ No folders specified, collecting files in root directory..");

      _collectFromDirectory(Directory(cfg.sortPath));
      return;
    }

    for (var folder in cfg.folders) {
      var folderPath = '${cfg.sortPath}${Platform.pathSeparator}$folder';

      if (!Directory(folderPath).existsSync()) {
        continue;
      }

      _collectFromDirectory(Directory(folderPath));
    }
  }

  void _collectFromDirectory(Directory directory) {
    final entities = directory.listSync(
      recursive: cfg.recursive,
      followLinks: false,
    );

    for (final entity in entities) {
      if (entity is Link) {
        continue;
      }

      if (entity is File && entity.path.endsWith('.dart')) {
        _allFilePaths.add(entity.path);
      }
    }
  }

  void _filterFilePaths() {
    log.fine("┠ Removing ignored files..");

    _filterIgnoreFilesLike();
    _filterIgnoreFiles();

    if (cfg.files.isNotEmpty) {
      log.fine("┠ Files option provided.");

      _filterByNamedFiles(cfg.files);
    } else if (cfg.filesLike.isNotEmpty) {
      log.fine("┠ Files-like option provided.");

      _filterByFilesLike();
    }
  }

  void _filterIgnoreFilesLike() {
    for (var pattern in cfg.ignoreFilesLike) {
      log.fine("┠─ Removing ignored file like: $pattern");

      var regex = RegExp(pattern);
      _filteredFilePaths.removeWhere((filePath) => regex.hasMatch(filePath));
    }
  }

  void _filterIgnoreFiles() {
    for (var ignored in cfg.ignoreFiles) {
      log.fine("┠─ Removing ignored file: $ignored");

      _filteredFilePaths.removeWhere(
        (filePath) =>
            filePath.endsWith("${Platform.pathSeparator}$ignored.dart") ||
            filePath.endsWith("${Platform.pathSeparator}$ignored"),
      );
    }
  }

  void _filterByNamedFiles(List<String> files) {
    log.fine("┠─ Retaining only named files..");

    _filteredFilePaths.retainWhere((element) {
      var fileName = p.basename(element);

      return files.any((f) {
        var name = p.basename(p.normalize(f));
        return name == fileName || name == fileName.replaceAll(".dart", "");
      });
    });
  }

  void _filterByFilesLike() {
    log.fine("┠─ Retaining only files like: ${cfg.filesLike}");

    var regex = RegExp(cfg.filesLike.join("|"));
    _filteredFilePaths.retainWhere((element) => regex.hasMatch(element));
  }
}
