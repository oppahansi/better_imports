import 'dart:io';

import 'package:better_imports/src/config.dart';
import 'package:better_imports/src/print.dart';

class Collector {
  final Config cfg;

  Collector({required this.cfg});

  List<File> collect() {
    if (cfg.files.isNotEmpty) {
      return _collectFiles(cfg.files);
    }

    if (cfg.folders.isNotEmpty) {
      return _collectInFolders(cfg.folders);
    }

    return _collectInFolders(_filterFolders());
  }

  List<File> _collectInFolders(List<String> folders) {
    final results = <File>[];
    final collectedFileEntities = <FileSystemEntity>[];
    final emptyFolders = <String>[];

    for (var folder in folders) {
      final collected = _collectInFolder(folder);

      collectedFileEntities.addAll(collected);

      if (collected.isEmpty) {
        emptyFolders.add(folder);
      }
    }

    for (var file in collectedFileEntities) {
      if (file.existsSync() && file is File) {
        results.add(File(file.path));
      }
    }

    Printer.print(
        "Collected ${results.length} files from ${folders.length - emptyFolders.length} found folder(s).");
    Printer.print("Empty or not found folders: $emptyFolders");

    return results;
  }

  List<FileSystemEntity> _collectInFolder(String folder) {
    if (Directory('${cfg.sortPath}\\$folder').existsSync()) {
      return Directory('${cfg.sortPath}\\$folder').listSync(
        recursive: cfg.recursive,
      );
    }

    return [];
  }

  List<File> _collectFiles(List<String> files) {
    final collectedFiles = _collectInFolders(_filterFolders());
    final results = <File>[];
    final notFound = <String>[];

    for (var file in files) {
      var fileName = file.contains(".dart") ? file : "$file.dart";

      var match = collectedFiles.firstWhere(
        (element) => element.path.endsWith(fileName),
        orElse: () => File(""),
      );

      if (match.existsSync()) {
        results.add(match);
      } else {
        notFound.add(file);
      }
    }

    Printer.print("Collected ${results.length} of ${files.length} file(s).");
    Printer.print("Could not find: ${notFound.length} file(s).\n$notFound");

    return results;
  }

  List<String> _filterFolders() {
    final filteredFolders = <String>[];

    filteredFolders.addAll(
        cfg.folders.where((element) => !cfg.ignoredFolders.contains(element)));

    return filteredFolders;
  }
}
