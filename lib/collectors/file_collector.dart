// Dart Imports
import 'dart:io';

// Project Imports
import "package:better_imports/lib.dart";

class Collector {
  final Cfg cfg;

  Collector({required this.cfg});

  List<String> collect() {
    if (cfg.files.isNotEmpty) {
      return _collectFiles(cfg.files);
    }

    if (cfg.filesLike.isNotEmpty) {
      return _collectFilesLike();
    }

    return _collectInFolders(cfg.folders);
  }

  List<String> _collectFiles(List<String> files) {
    final collectedFiles = _collectInFolders(cfg.folders);
    final results = <String>[];

    for (var file in files) {
      var fileName =
          file.contains(".dart") ? file.trim() : "${file.trim()}.dart";

      var match = collectedFiles.firstWhere(
        (element) => element.endsWith(fileName),
        orElse: () => "",
      );

      if (File(match).existsSync()) {
        results.add(match);
      }
    }

    return _filterIgnoredFiles(results);
  }

  List<String> _collectFilesLike() {
    return _filterFilesLike(_collectInFolders(cfg.folders));
  }

  List<String> _collectInFolders(List<String> folders) {
    final results = <String>[];
    final collectedFileEntities = <FileSystemEntity>[];
    final emptyFolders = <String>[];

    for (var folder in folders) {
      final collected = _collectInFolder(folder.trim());

      collectedFileEntities.addAll(collected);

      if (collected.isEmpty) {
        emptyFolders.add(folder.trim());
      }
    }

    for (var file in collectedFileEntities) {
      if (file.existsSync() && file.isFile && file.name.endsWith(".dart")) {
        var newFilePath = file.path;

        if (!results.contains(newFilePath)) {
          results.add(newFilePath);
        }
      }
    }

    return _filterIgnoredFiles(results);
  }

  List<FileSystemEntity> _collectInFolder(String folder) {
    var path = '${cfg.sortPath}${Platform.pathSeparator}${folder.trim()}';

    if (Directory(path).existsSync()) {
      return Directory(path).listSync(recursive: cfg.recursive);
    }

    return [];
  }

  List<String> _filterIgnoredFiles(List<String> files) {
    for (var pattern in cfg.ignoreFilesLike) {
      files.removeWhere((element) => RegExp(pattern.trim()).hasMatch(element));
    }

    return files;
  }

  List<String> _filterFilesLike(List<String> files) {
    for (var pattern in cfg.filesLike) {
      files.removeWhere((element) => !RegExp(pattern.trim()).hasMatch(element));
    }

    return files;
  }
}
