// Dart Imports
import 'dart:io';

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

    return FilePaths(
      allPaths: _allFilePaths,
      filteredPaths: _filteredFilePaths,
    );
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

      _filteredFilePaths.removeWhere(
        (filePath) => RegExp(pattern).hasMatch(filePath),
      );
    }
  }

  void _filterIgnoreFiles() {
    for (var ignored in cfg.ignoreFiles) {
      log.fine("┠─ Removing ignored file: $ignored");

      _filteredFilePaths.removeWhere(
        (filePath) =>
            filePath.endsWith("${Platform.pathSeparator}$ignored.dart"),
      );
    }
  }

  void _filterByNamedFiles(List<String> files) {
    log.fine("┠─ Retaining only named files..");

    _filteredFilePaths.retainWhere((element) {
      var fileName = element.split(Platform.pathSeparator).last;

      return files.contains(fileName) ||
          files.contains(fileName.replaceAll(".dart", ""));
    });
  }

  void _filterByFilesLike() {
    log.fine("┠─ Retaining only files like: ${cfg.filesLike}");

    _filteredFilePaths.retainWhere(
        (element) => RegExp(cfg.filesLike.join("|")).hasMatch(element));
  }
}
