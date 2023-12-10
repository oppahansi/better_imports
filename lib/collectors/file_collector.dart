// Dart Imports
import 'dart:io';

// Project Imports
import 'package:better_imports/config/config.dart';
import 'package:better_imports/extensions/extensions.dart';

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

    if (cfg.folders.isNotEmpty) {
      return _collectInFolders(cfg.folders);
    }

    return _collectInProject();
  }

  List<String> _collectFiles(List<String> files) {
    final collectedFiles = _collectInProject();
    final results = <String>[];
    final notFound = <String>[];

    for (var file in files) {
      var fileName = file.contains(".dart") ? file : "$file.dart";

      var match = collectedFiles.firstWhere(
        (element) => element.endsWith(fileName),
        orElse: () => "",
      );

      if (File(match).existsSync()) {
        results.add(match);
      } else {
        notFound.add(file);
      }
    }

    return _filterIgnoredFiles(results);
  }

  List<String> _collectFilesLike() {
    return _filterFilesLike(_collectInProject());
  }

  List<String> _collectInFolders(List<String> folders) {
    final results = <String>[];
    final collectedFileEntities = <FileSystemEntity>[];
    final emptyFolders = <String>[];
    final filteredFolders = _filterIgnoredFolders(folders);

    for (var folder in filteredFolders) {
      final collected = _collectInFolder(folder);

      collectedFileEntities.addAll(collected);

      if (collected.isEmpty) {
        emptyFolders.add(folder);
      }
    }

    for (var file in collectedFileEntities) {
      if (file.existsSync() && file is File && file.name.endsWith(".dart")) {
        var newFilePath = file.path;

        if (!results.contains(newFilePath)) {
          results.add(newFilePath);
        }
      }
    }

    return _filterIgnoredFiles(results);
  }

  List<String> _collectInProject() {
    var projectEntities = Directory.current.listSync(recursive: cfg.recursive);
    var projectFolders = <String>[];

    for (var entity in projectEntities) {
      if (entity is Directory) {
        projectFolders.add(entity.name);
      }
    }

    final results = <String>[];
    final collectedFileEntities = <FileSystemEntity>[];
    final emptyFolders = <String>[];

    for (var folder in projectFolders) {
      final collected = _collectInFolder(folder);

      collectedFileEntities.addAll(collected);

      if (collected.isEmpty) {
        emptyFolders.add(folder);
      }
    }

    for (var file in collectedFileEntities) {
      if (file.existsSync() && file is File && file.name.endsWith(".dart")) {
        var newFilePath = file.path;

        if (!results.contains(newFilePath)) {
          results.add(newFilePath);
        }
      }
    }

    return _filterIgnoredFiles(results);
  }

  List<FileSystemEntity> _collectInFolder(String folder) {
    var path = '${cfg.sortPath}${Platform.pathSeparator}$folder';

    if (Directory(path).existsSync()) {
      return Directory(path).listSync(recursive: cfg.recursive);
    }

    return [];
  }

  List<String> _filterIgnoredFolders(List<String> folders) {
    final filteredFolders = <String>[];

    filteredFolders.addAll(
        folders.where((element) => !cfg.ignoredFolders.contains(element)));

    return filteredFolders;
  }

  List<String> _filterIgnoredFiles(List<String> files) {
    for (var pattern in cfg.ignoreFilesLike) {
      files.removeWhere((element) => RegExp(pattern).hasMatch(element));
    }

    return files;
  }

  List<String> _filterFilesLike(List<String> files) {
    for (var pattern in cfg.filesLike) {
      files.removeWhere((element) => !RegExp(pattern).hasMatch(element));
    }

    return files;
  }
}
