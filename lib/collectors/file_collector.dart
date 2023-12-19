// Dart Imports
import 'dart:io';

// Project Imports
import "package:better_imports/lib.dart";

class Collector {
  final Cfg cfg;
  final _allFilePaths = <String>[];

  Collector({required this.cfg});

  List<String> collect() {
    _collectInFolders();
    _filterIgnoredFiles();
    _processOptions();

    return _allFilePaths;
  }

  void _collectInFolders() {
    log.info("┠ Collecting files in all folders..");

    final allFileEntities = <FileSystemEntity>[];

    for (var folder in cfg.folders) {
      allFileEntities.addAll(_collectInFolder(folder));
    }

    log.info("┠─ Selecting only dart files..");
    for (var fileEntity in allFileEntities) {
      if (fileEntity.existsSync() &&
          fileEntity.isFile &&
          fileEntity.name.endsWith(".dart")) {
        var newFilePath = fileEntity.path;

        if (!_allFilePaths.contains(newFilePath)) {
          _allFilePaths.add(newFilePath);
        }
      }
    }
  }

  void _filterIgnoredFiles() {
    log.info("┠ Removing ignored files..");

    for (var pattern in cfg.ignoreFilesLike) {
      log.info("┠─ Removing ignored file like: $pattern");
      _allFilePaths.removeWhere(
        (filePath) => RegExp(pattern).hasMatch(filePath),
      );
    }

    for (var ignored in cfg.ignoreFiles) {
      log.info("┠─ Removing ignored file: $ignored");
      _allFilePaths.removeWhere(
        (filePath) =>
            filePath.endsWith("${Platform.pathSeparator}$ignored.dart"),
      );
    }
  }

  void _processOptions() {
    if (cfg.files.isNotEmpty) {
      log.info("┠ Files option provided.");

      _retainNamedFiles(cfg.files);
    } else if (cfg.filesLike.isNotEmpty) {
      log.info("┠ Files-like option provided.");

      _retainFilesLike();
    }
  }

  List<FileSystemEntity> _collectInFolder(String folderName) {
    log.info("┠─ Collecting files in folder: $folderName");

    var folderPath = '${cfg.sortPath}${Platform.pathSeparator}$folderName';

    if (Directory(folderPath).existsSync()) {
      return Directory(folderPath).listSync(recursive: cfg.recursive);
    }

    return [];
  }

  void _retainNamedFiles(List<String> files) {
    log.info("┠─ Retaining only named files..");
    _allFilePaths.retainWhere((element) {
      var fileName = element.split(Platform.pathSeparator).last;

      return files.contains(fileName) ||
          files.contains(fileName.replaceAll(".dart", ""));
    });
  }

  void _retainFilesLike() {
    log.info("┠─ Retaining only files like: ${cfg.filesLike}");

    _allFilePaths.retainWhere(
        (element) => RegExp(cfg.filesLike.join("|")).hasMatch(element));
  }
}
